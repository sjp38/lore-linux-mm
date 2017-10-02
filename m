Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 339A36B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 18:45:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e69so10917666pfg.1
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 15:45:26 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id u67si8418701pgc.579.2017.10.02.15.45.23
        for <linux-mm@kvack.org>;
        Mon, 02 Oct 2017 15:45:24 -0700 (PDT)
Date: Tue, 3 Oct 2017 09:45:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential
 file writes
Message-ID: <20171002224520.GJ15067@dastard>
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 02, 2017 at 12:54:53PM -0700, Linus Torvalds wrote:
> On Mon, Oct 2, 2017 at 2:54 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
> >
> > This patch implements write-behind policy which tracks sequential writes
> > and starts background writeback when have enough dirty pages in a row.
> 
> This looks lovely to me.

Yup, it's a good idea. Needs some tweaking, though.

> I do wonder if you also looked at finishing the background
> write-behind at close() time, because it strikes me that once you
> start doing that async writeout, it would probably be good to make
> sure you try to do the whole file.

Inserting arbitrary pipeline bubbles is never good for
performance. Think untar:

create file, write data, create file, write data, create ....

With async write-behind, it pipelines like this:

create, write
	create, write
		create, write
			create, write

If we block on close, it becomes:

create, write, wait
		   create, write, wait
				      create, write, wait

Basically performance of things like cp, untar, etc will suck
badly if we wait for write behind on close() - it's essentially the
same thing as forcing these apps to fdatasync() after every file
is written....

> I'm thinking of filesystems that do delayed allocation etc - I'd
> expect that you'd want the whole file to get allocated on disk
> together, rather than have the "first 256kB aligned chunks" allocated
> thanks to write-behind, and then the final part allocated much later
> (after other files may have triggered their own write-behind). Think
> loads like copying lots of pictures around, for example.

Yeah, this is going to completely screw up delayed allocation
because it doesn't allow time to aggregate large extents in memory
before writeback and allocation occurs. Compared to above, the untar
behaviour for the existing writeback mode is:

create, create, create, create ......  write, write, write, write

i.e. the data writeback is completely decoupled from the creation of
files. With delalloc, this means all the directory and inodes are
created in the syscall context, all closely packed together on disk,
and once that is done the data writeback starts allocating file
extents, which then get allocated as single extents and get packed
tightly together to give cross-file sequential write behaviour and
minimal seeks.

And when the metadata gets written back, the internal XFS algorithms
will sort that all into sequentially issued IO that gets merged into
large sequential IO, too, further minimising seeks.

IOWs, what ends up on disk is:

<metadata><lots of file data in large contiguous extents>

With writebehind, we'll end up with "alloc metadata, alloc data"
for each file being written, which will result in this sort of thing
for an untar:

<m><ddd><m><d><m><ddddddd><m><ddd> .....

It also means we can no longer do cross-file sequentialisation to
minimise seeks on writeback, and metadata writeback will turn into a
massive seek fest instead of being nicely aggregated into large
writes.

If we consider large concurrent sequential writes, we have
heuristics in the delalloc code to get them built into
larger-than-necessary delalloc extents so we typically end up on
disk with very large data extents in each file (hundreds of MB to
8GB each) such that on disk we end up with:

<m><FILE 1 EXT 1><FILE 2 EXT 1><FILE 1 EXT 2> ....

With writebehind, we'll be doing allocation every MB, so end up with
lots of small interleaved extents on disk like this:

<m><f1><f2><f3><f1><f3><f2><f1><f2><f3><f1> ....

(FYI, this is what happened with these worklaods prior to all the
additiona of the speculative delalloc heuristics we have now.)

Now this won't affect overall write speed, but when we go to read
the file back, we have to seek every 1MB IO.  IOWs, we might get the
same write performance because we're still doing sequential writes,
but the performance degradation is seen on the read side when we
have to access that data again.

Further, what happens when we free just file 1? Instead of getting
back a large contiguous free space extent, we get back a heap of
tiny, fragmented free spaces. IOWs, the interleaving causes the
rapid onset of filesystem aging symptoms which will further degrade
allocation behaviour as we'll quickly run out of large contiguous
free spaces to allocate from.

IOWs, rapid write-behind behaviour might not signficantly affect
initial write performance on an empty filesystem. It will, in
general, increase file fragmentation, increase interleaving of
metadata and data, reduce metadata writeback and read performance,
increase free space fragmentation, reduce data read performance and
speed up the onset of aging related performance degradation.

Don't get me wrong - writebehind can be very effective for some
workloads. However, I think that a write-behind default of 1MB is
bordering on insane because it pushes most filesystems straight into
the above problems. At minimum, per-file writebehind needs to have a
much higher default threshold and writeback chunk size to allow
filesystems to avoid the above problems.

Perhaps we need to think about a small per-backing dev threshold
where the behaviour is the current writeback behaviour, but once
it's exceeded we then switch to write-behind so that the amount of
dirty data doesn't exceed that threshold. Make the threshold 2-3x
the bdi's current writeback throughput and we've got something that
should mostly self-tune to 2-3s of outstanding dirty data per
backing dev whilst mostly avoiding the issues with small, strict
write-behind thresholds.

Cheers,

Dave
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
