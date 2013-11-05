Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BC1B66B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 23:12:54 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id q10so7740250pdj.0
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 20:12:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.173])
        by mx.google.com with SMTP id qj1si6755567pbc.174.2013.11.04.20.12.51
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 20:12:52 -0800 (PST)
Date: Tue, 5 Nov 2013 15:12:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131105041245.GY6188@dastard>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
 <89AE8FE8-5B15-41DB-B9CE-DFF73531D821@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <89AE8FE8-5B15-41DB-B9CE-DFF73531D821@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, Wu Fengguang <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>

On Mon, Nov 04, 2013 at 05:50:13PM -0700, Andreas Dilger wrote:
> 
> On Oct 25, 2013, at 2:18 AM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > On Fri, Oct 25, 2013 at 8:25 AM, Artem S. Tashkinov <t.artem@lycos.com> wrote:
> >> 
> >> On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11
> >> kernel built for the i686 (with PAE) and x86-64 architectures. Whata??s
> >> really troubling me is that the x86-64 kernel has the following problem:
> >> 
> >> When I copy large files to any storage device, be it my HDD with ext4
> >> partitions or flash drive with FAT32 partitions, the kernel first
> >> caches them in memory entirely then flushes them some time later
> >> (quite unpredictably though) or immediately upon invoking "sync".
> > 
> > Yeah, I think we default to a 10% "dirty background memory" (and
> > allows up to 20% dirty), so on your 16GB machine, we allow up to 1.6GB
> > of dirty memory for writeout before we even start writing, and twice
> > that before we start *waiting* for it.
> > 
> > On 32-bit x86, we only count the memory in the low 1GB (really
> > actually up to about 890MB), so "10% dirty" really means just about
> > 90MB of buffering (and a "hard limit" of ~180MB of dirty).
> > 
> > And that "up to 3.2GB of dirty memory" is just crazy. Our defaults
> > come from the old days of less memory (and perhaps servers that don't
> > much care), and the fact that x86-32 ends up having much lower limits
> > even if you end up having more memory.
> 
> I think the a??delay writes for a long timea?? is a holdover from the
> days when e.g. /tmp was on a disk and compilers had lousy IO
> patterns, then they deleted the file.  Today, /tmp is always in
> RAM, and IMHO the a??write and deletea?? workload tested by dbench
> is not worthwhile optimizing for.
> 
> With Lustre, wea??ve long taken the approach that if there is enough
> dirty data on a file to make a decent write (which is around 8MB
> today even for very fast storage) then there isna??t much point to
> hold back for more data before starting the IO.

Agreed - write-through caching is much better for high throughput
streaming data environments than write back caching that can leave
the devices unnecessarily idle.

However, most systems are not running in high-throughput streaming
data environments... :/

> Any decent allocator will be able to grow allocated extents to
> handle following data, or allocate a new extent.  At 4-8MB extents,
> even very seek-impaired media could do 400-800MB/s (likely much
> faster than the underlying storage anyway).

True, but this makes the assumption that the filesystem you are
using is optimising purely for write throughput and your storage is
not seek limited on reads. That's simply not an assumption we can
allow the generic writeback code to make.

In more detail, if we simply implement "we have 8 MB of dirty pages
on a single file, write it" we can maximise write throughput by
allocating sequentially on disk for each subsquent write. The
problem with this comes when you are writing multiple files at a
time, and that leads to this pattern on disk:

 ABC...ABC....ABC....ABC....

And the result is a) fragmented files b) a large number of seeks
during sequential read operations and c) filesystems that age and
degrade rapidly under workloads that concurrently write files with
different life times (i.e. due to free space fragmention).

In some situations this is acceptable, but the performance
degradation as the filesystem ages that this sort of allocation
causes in most environments is not. I'd say that >90% of filesystems
out there would suffer accelerated aging as a result of doing
writeback in this manner by default.

> This also avoids wasting (tens of?) seconds of idle disk bandwidth.
> If the disk is already busy, then the IO will be delayed anyway.
> If it is not busy, then why aggregate GB of dirty data in memory
> before flushing it?

There are plenty of workloads out there where delaying IO for a few
seconds can result in writeback that is an order of magnitude
faster. Similarly, I've seen other workloads where the writeback
delay results in files that can be *read* orders of magnitude
faster....

> Something simple like a??start writing at 16MB dirty on a single filea??
> would probably avoid a lot of complexity at little real-world cost.
> That shouldna??t throttle dirtying memory above 16MB, but just start
> writeout much earlier than it does today.

That doesn't solve the "slow device, large file" problem. We can
write data into the page cache at rates of over a GB/s, so it's
irrelevant to a device that can write at 5MB/s whether we start
writeback immediately or a second later when there is 500MB of dirty
pages in memory.  AFAIK, the only way to avoid that problem is to
use write-through caching for such devices - where they throttle to
the IO rate at very low levels of cached data.

Realistically, there is no "one right answer" for all combinations
of applications, filesystems and hardware, but writeback caching is
the best *general solution* we've got right now.

However, IMO users should not need to care about tuning BDI dirty
ratios or even have to understand what a BDI dirty ratio is to
select the rigth caching method for their devices and/or workload.
The difference between writeback and write through caching is easy
to explain and AFAICT those two modes suffice to solve the problems
being discussed here.  Further, if two modes suffice to solve the
problems, then we should be able to easily define a trigger to
automatically switch modes.

/me notes that if we look at random vs sequential IO and the impact
that has on writeback duration, then it's very similar to suddenly
having a very slow device. IOWs, fadvise(RANDOM) could be used to
switch an *inode* to write through mode rather than writeback mode
to solve the problem aggregating massive amounts of random write IO
in the page cache...

So rather than treating this as a "one size fits all" type of
problem, let's step back and:

	a) define 2-3 different caching behaviours we consider
	   optimal for the majority of workloads/hardware we care
	   about.
	b) determine optimal workloads for each caching
	   behaviour.
	c) develop reliable triggers to detect when we
	   should switch between caching behaviours.

e.g:

	a) write back caching
		- what we have now
	   write through caching
		- extremely low dirty threshold before writeback
		  starts, enough to optimise for, say, stripe width
		  of the underlying storage.

	b) write back caching:
		- general purpose workload
	   write through caching:
		- slow device, write large file, sync
		- extremely high bandwidth devices, multi-stream
		  sequential IO
		- random IO.

	c) write back caching:
		- default
		- fadvise(NORMAL, SEQUENTIAL, WILLNEED)
	   write through caching:
		- fadvise(NOREUSE, DONTNEED, RANDOM)
		- random IO
		- sequential IO, BDI write bandwidth <<< dirty threshold
		- sequential IO, BDI write bandwidth >>> dirty threshold

I think that covers most of the issues and use cases that have been
discussed in this thread. IMO, this is the level at which we need to
solve the problem (i.e. architectural), not at the level of "let's
add sysfs variables so we can tweak bdi ratios".

Indeed, the above implies that we need the caching behaviour to be a
property of the address space, not just a property of the backing
device.

IOWs, the implementation needs to trickle down from a coherent high
level design - that will define the knobs that we need to expose to
userspace. We should not be adding new writeback behaviours by
adding knobs to sysfs without first having some clue about whether
we are solving the right problem and solving it in a sane manner...

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
