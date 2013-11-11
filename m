Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 834F56B00B4
	for <linux-mm@kvack.org>; Sun, 10 Nov 2013 22:22:39 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so4578111pbc.40
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 19:22:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id gj2si14698398pac.312.2013.11.10.19.22.36
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 19:22:38 -0800 (PST)
Date: Mon, 11 Nov 2013 14:22:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131111032211.GT6188@dastard>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
 <89AE8FE8-5B15-41DB-B9CE-DFF73531D821@dilger.ca>
 <20131105041245.GY6188@dastard>
 <20131107134806.GB30832@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131107134806.GB30832@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@dilger.ca>, "Artem S. Tashkinov" <t.artem@lycos.com>, Wu Fengguang <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>

On Thu, Nov 07, 2013 at 02:48:06PM +0100, Jan Kara wrote:
> On Tue 05-11-13 15:12:45, Dave Chinner wrote:
> > On Mon, Nov 04, 2013 at 05:50:13PM -0700, Andreas Dilger wrote:
> > > Something simple like a??start writing at 16MB dirty on a single filea??
> > > would probably avoid a lot of complexity at little real-world cost.
> > > That shouldna??t throttle dirtying memory above 16MB, but just start
> > > writeout much earlier than it does today.
> > 
> > That doesn't solve the "slow device, large file" problem. We can
> > write data into the page cache at rates of over a GB/s, so it's
> > irrelevant to a device that can write at 5MB/s whether we start
> > writeback immediately or a second later when there is 500MB of dirty
> > pages in memory.  AFAIK, the only way to avoid that problem is to
> > use write-through caching for such devices - where they throttle to
> > the IO rate at very low levels of cached data.
>   Agreed.
> 
> > Realistically, there is no "one right answer" for all combinations
> > of applications, filesystems and hardware, but writeback caching is
> > the best *general solution* we've got right now.
> > 
> > However, IMO users should not need to care about tuning BDI dirty
> > ratios or even have to understand what a BDI dirty ratio is to
> > select the rigth caching method for their devices and/or workload.
> > The difference between writeback and write through caching is easy
> > to explain and AFAICT those two modes suffice to solve the problems
> > being discussed here.  Further, if two modes suffice to solve the
> > problems, then we should be able to easily define a trigger to
> > automatically switch modes.
> > 
> > /me notes that if we look at random vs sequential IO and the impact
> > that has on writeback duration, then it's very similar to suddenly
> > having a very slow device. IOWs, fadvise(RANDOM) could be used to
> > switch an *inode* to write through mode rather than writeback mode
> > to solve the problem aggregating massive amounts of random write IO
> > in the page cache...
>   I disagree here. Writeback cache is also useful for aggregating random
> writes and making semi-sequential writes out of them. There are quite some
> applications which rely on the fact that they can write a file in a rather
> random manner (Berkeley DB, linker, ...) but the files are written out in
> one large linear sweep. That is actually the reason why SLES (and I believe
> RHEL as well) tune dirty_limit even higher than what's the default value.

Right - but the correct behaviour really depends on the pattern of
randomness. The common case we get into trouble with is when no
clustering occurs and we end up with small, random IO for gigabytes
of cached data. That's the case where write-through caching for
random data is better.

It's also questionable whether writeback caching for aggregation is
faster for random IO on high-IOPS devices or not. Again, I think it
woul depend very much on how random the patterns are...

> So I think it's rather the other way around: If you can detect the file is
> being written in a streaming manner, there's not much point in caching too
> much data for it.

But we're not talking about how much data we cache here - we are
considering how much data we allow to get dirty before writing it
back.  It doesn't matter if we use writeback or write through
caching, the page cache footprint for a given workload is likely to
be similar, but without any data we can't draw any conclusions here.

> And I agree with you that we also have to be careful not
> to cache too few because otherwise two streaming writes would be
> interleaved too much. Currently, we have writeback_chunk_size() which
> determines how much we ask to write from a single inode. So streaming
> writers are going to be interleaved at this chunk size anyway (currently
> that number is "measured bandwidth / 2"). So it would make sense to also
> limit amount of dirty cache for each file with streaming pattern at this
> number.

My experience says that for streaming IO we typically need at least
5s of cached *dirty* data to even out delays and latencies in the
writeback IO pipeline. Hence limiting a file to what we can write in
a second given we might only write a file once a second is likely
going to result in pipeline stalls...

Remember, writeback caching is about maximising throughput, not
minimising latency. The "sync latency" problem with caching too much
dirty data on slow block devices is really a corner case behaviour
and should not compromise the common case for bulk writeback
throughput.

> > Indeed, the above implies that we need the caching behaviour to be a
> > property of the address space, not just a property of the backing
> > device.
>   Yes, and that would be interesting to implement and not make a mess out
> of the whole writeback logic because the way we currently do writeback is
> inherently BDI based. When we introduce some special per-inode limits,
> flusher threads would have to pick more carefully what to write and what
> not. We might be forced to go that way eventually anyway because of memcg
> aware writeback but it's not a simple step.

Agreed, it's not simple, and that's why we need to start working
from the architectural level....

> > IOWs, the implementation needs to trickle down from a coherent high
> > level design - that will define the knobs that we need to expose to
> > userspace. We should not be adding new writeback behaviours by
> > adding knobs to sysfs without first having some clue about whether
> > we are solving the right problem and solving it in a sane manner...
>   Agreed. But the ability to limit amount of dirty pages outstanding
> against a particular BDI seems as a sane one to me. It's not as flexible
> and automatic as the approach you suggested but it's much simpler and
> solves most of problems we currently have.

That's true, but....

> The biggest objection against the sysfs-tunable approach is that most
> people won't have a clue meaning that the tunable is useless for them.

.... that's the big problem I see - nobody is going to know how to
use it, when to use it, or be able to tell if it's the root cause of
some weird performance problem they are seeing.

> But I
> wonder if something like:
> 1) turn on strictlimit by default
> 2) don't allow dirty cache of BDI to grow over 5s of measured writeback
>    speed
> 
> won't go a long way into solving our current problems without too much
> complication...

Turning on strict limit by default is going to change behaviour
quite markedly. Again, it's not something I'd want to see done
without a bunch of data showing that it doesn't cause regressions
for common workloads...

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
