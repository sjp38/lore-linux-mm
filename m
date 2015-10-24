Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 74E8B6B0038
	for <linux-mm@kvack.org>; Sat, 24 Oct 2015 17:39:43 -0400 (EDT)
Received: by pasz6 with SMTP id z6so148973835pas.2
        for <linux-mm@kvack.org>; Sat, 24 Oct 2015 14:39:43 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id ya6si40291860pab.83.2015.10.24.14.39.40
        for <linux-mm@kvack.org>;
        Sat, 24 Oct 2015 14:39:42 -0700 (PDT)
Date: Sun, 25 Oct 2015 08:39:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151024213912.GE8773@dastard>
References: <20151022131555.GC4378@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022131555.GC4378@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 03:15:55PM +0200, Andres Freund wrote:
> Hi,
> 
> postgres regularly has to checkpoint data to disk to be able to free
> data from its journal. We currently use buffered IO and that's not
> going to change short term.
> 
> In a busy database this checkpointing process can write out a lot of
> data. Currently that frequently leads to massive latency spikes
> (c.f. 20140326191113.GF9066@alap3.anarazel.de) for other processed doing
> IO. These happen either when the kernel starts writeback or when, at the
> end of the checkpoint, we issue an fsync() on the datafiles.
> 
> One odd issue there is that the kernel tends to do writeback in a very
> irregular manner. Even if we write data at a constant rate writeback
> very often happens in bulk - not a good idea for preserving
> interactivity.
> 
> What we're preparing to do now is to regularly issue
> sync_file_range(SYNC_FILE_RANGE_WRITE) on a few blocks shortly after
> we've written them to to the OS. That way there's not too much dirty
> data in the page cache, so writeback won't cause latency spikes, and the
> fsync at the end doesn't have to write much if anything.
> 
> That improves things a lot.
> 
> But I still see latency spikes that shouldn't be there given the amount
> of IO. I'm wondering if that is related to the fact that
> SYNC_FILE_RANGE_WRITE ends up doing __filemap_fdatawrite_range with
> WB_SYNC_ALL specified. Given the the documentation for
> SYNC_FILE_RANGE_WRITE I did not expect that:
>  * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
>  * are not presently under writeout.  This is an asynchronous flush-to-disk
>  * operation.  Not suitable for data integrity operations.

WB_SYNC_ALL is simply a method of saying "writeback all dirty pages
and don't skip any". That's part of a data integrity operation, but
it's not what results in data integrity being provided. It may cause
some latencies caused by blocking on locks or in the request queues,
so that's what I'd be looking for.

i.e. if the request queues are full, SYNC_FILE_RANGE_WRITE will
block until all the IO it has been requested to write has been
submitted to the request queues. Put simply: the IO is asynchronous
in that we don't wait for completion, but the IO submission is still
synchronous.

Data integrity operations require related file metadata (e.g. block
allocation trnascations) to be forced to the journal/disk, and a
device cache flush issued to ensure the data is on stable storage.
SYNC_FILE_RANGE_WRITE does neither of these things, and hence while
the IO might be the same pattern as a data integrity operation, it
does not provide such guarantees.

> If I followed the code correctly - not a sure thing at all - that means
> bios are submitted with WRITE_SYNC specified. Not really what's needed
> in this case.

That just allows the IO scheduler to classify them differently to
bulk background writeback. 

> Now I think the docs are somewhat clear that SYNC_FILE_RANGE_WRITE isn't
> there for data integrity, but it might be that people rely on in
> nonetheless. so I'm loathe to suggest changing that. But I do wonder if
> there's a way non-integrity writeback triggering could be exposed to
> userspace. A new fadvise flags seems like a good way to do that -
> POSIX_FADV_DONTNEED actually does non-integrity writeback, but also does
> other things, so it's not suitable for us.

You don't want to do writeback from the syscall, right? i.e. you'd
like to expire the inode behind the fd, and schedule background
writeback to run on it immediately?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
