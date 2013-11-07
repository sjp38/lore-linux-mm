Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A93856B015A
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 08:48:14 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so626076pad.39
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 05:48:14 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id dj3si2692052pbc.250.2013.11.07.05.48.11
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 05:48:12 -0800 (PST)
Date: Thu, 7 Nov 2013 14:48:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131107134806.GB30832@quack.suse.cz>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
 <89AE8FE8-5B15-41DB-B9CE-DFF73531D821@dilger.ca>
 <20131105041245.GY6188@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131105041245.GY6188@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andreas Dilger <adilger@dilger.ca>, "Artem S. Tashkinov" <t.artem@lycos.com>, Wu Fengguang <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>

On Tue 05-11-13 15:12:45, Dave Chinner wrote:
> On Mon, Nov 04, 2013 at 05:50:13PM -0700, Andreas Dilger wrote:
> > Something simple like a??start writing at 16MB dirty on a single filea??
> > would probably avoid a lot of complexity at little real-world cost.
> > That shouldna??t throttle dirtying memory above 16MB, but just start
> > writeout much earlier than it does today.
> 
> That doesn't solve the "slow device, large file" problem. We can
> write data into the page cache at rates of over a GB/s, so it's
> irrelevant to a device that can write at 5MB/s whether we start
> writeback immediately or a second later when there is 500MB of dirty
> pages in memory.  AFAIK, the only way to avoid that problem is to
> use write-through caching for such devices - where they throttle to
> the IO rate at very low levels of cached data.
  Agreed.

> Realistically, there is no "one right answer" for all combinations
> of applications, filesystems and hardware, but writeback caching is
> the best *general solution* we've got right now.
> 
> However, IMO users should not need to care about tuning BDI dirty
> ratios or even have to understand what a BDI dirty ratio is to
> select the rigth caching method for their devices and/or workload.
> The difference between writeback and write through caching is easy
> to explain and AFAICT those two modes suffice to solve the problems
> being discussed here.  Further, if two modes suffice to solve the
> problems, then we should be able to easily define a trigger to
> automatically switch modes.
> 
> /me notes that if we look at random vs sequential IO and the impact
> that has on writeback duration, then it's very similar to suddenly
> having a very slow device. IOWs, fadvise(RANDOM) could be used to
> switch an *inode* to write through mode rather than writeback mode
> to solve the problem aggregating massive amounts of random write IO
> in the page cache...
  I disagree here. Writeback cache is also useful for aggregating random
writes and making semi-sequential writes out of them. There are quite some
applications which rely on the fact that they can write a file in a rather
random manner (Berkeley DB, linker, ...) but the files are written out in
one large linear sweep. That is actually the reason why SLES (and I believe
RHEL as well) tune dirty_limit even higher than what's the default value.

So I think it's rather the other way around: If you can detect the file is
being written in a streaming manner, there's not much point in caching too
much data for it. And I agree with you that we also have to be careful not
to cache too few because otherwise two streaming writes would be
interleaved too much. Currently, we have writeback_chunk_size() which
determines how much we ask to write from a single inode. So streaming
writers are going to be interleaved at this chunk size anyway (currently
that number is "measured bandwidth / 2"). So it would make sense to also
limit amount of dirty cache for each file with streaming pattern at this
number.

> So rather than treating this as a "one size fits all" type of
> problem, let's step back and:
> 
> 	a) define 2-3 different caching behaviours we consider
> 	   optimal for the majority of workloads/hardware we care
> 	   about.
> 	b) determine optimal workloads for each caching
> 	   behaviour.
> 	c) develop reliable triggers to detect when we
> 	   should switch between caching behaviours.
> 
> e.g:
> 
> 	a) write back caching
> 		- what we have now
> 	   write through caching
> 		- extremely low dirty threshold before writeback
> 		  starts, enough to optimise for, say, stripe width
> 		  of the underlying storage.
> 
> 	b) write back caching:
> 		- general purpose workload
> 	   write through caching:
> 		- slow device, write large file, sync
> 		- extremely high bandwidth devices, multi-stream
> 		  sequential IO
> 		- random IO.
> 
> 	c) write back caching:
> 		- default
> 		- fadvise(NORMAL, SEQUENTIAL, WILLNEED)
> 	   write through caching:
> 		- fadvise(NOREUSE, DONTNEED, RANDOM)
> 		- random IO
> 		- sequential IO, BDI write bandwidth <<< dirty threshold
> 		- sequential IO, BDI write bandwidth >>> dirty threshold
> 
> I think that covers most of the issues and use cases that have been
> discussed in this thread. IMO, this is the level at which we need to
> solve the problem (i.e. architectural), not at the level of "let's
> add sysfs variables so we can tweak bdi ratios".
> 
> Indeed, the above implies that we need the caching behaviour to be a
> property of the address space, not just a property of the backing
> device.
  Yes, and that would be interesting to implement and not make a mess out
of the whole writeback logic because the way we currently do writeback is
inherently BDI based. When we introduce some special per-inode limits,
flusher threads would have to pick more carefully what to write and what
not. We might be forced to go that way eventually anyway because of memcg
aware writeback but it's not a simple step.

> IOWs, the implementation needs to trickle down from a coherent high
> level design - that will define the knobs that we need to expose to
> userspace. We should not be adding new writeback behaviours by
> adding knobs to sysfs without first having some clue about whether
> we are solving the right problem and solving it in a sane manner...
  Agreed. But the ability to limit amount of dirty pages outstanding
against a particular BDI seems as a sane one to me. It's not as flexible
and automatic as the approach you suggested but it's much simpler and
solves most of problems we currently have.

The biggest objection against the sysfs-tunable approach is that most
people won't have a clue meaning that the tunable is useless for them. But I
wonder if something like:
1) turn on strictlimit by default
2) don't allow dirty cache of BDI to grow over 5s of measured writeback
   speed

won't go a long way into solving our current problems without too much
complication...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
