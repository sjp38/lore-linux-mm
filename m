Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAB0B6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:23:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w51so15543370qtc.12
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:23:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i68si457575qke.182.2017.08.11.03.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 03:23:01 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:22:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170811102256.GU25347@redhat.com>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
 <20170811070938.GA30811@dhcp22.suse.cz>
 <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 11, 2017 at 04:54:36PM +0900, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > +/*
> > > > + * Checks whether a page fault on the given mm is still reliable.
> > > > + * This is no longer true if the oom reaper started to reap the
> > > > + * address space which is reflected by MMF_UNSTABLE flag set in
> > > > + * the mm. At that moment any !shared mapping would lose the content
> > > > + * and could cause a memory corruption (zero pages instead of the
> > > > + * original content).
> > > > + *
> > > > + * User should call this before establishing a page table entry for
> > > > + * a !shared mapping and under the proper page table lock.
> > > > + *
> > > > + * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
> > > > + */
> > > > +static inline int check_stable_address_space(struct mm_struct *mm)
> > > > +{
> > > > +	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
> > > > +		return VM_FAULT_SIGBUS;
> > > > +	return 0;
> > > > +}
> > > > +
> > > 
> > > Will you explain the mechanism why random values are written instead of zeros
> > > so that this patch can actually fix the race problem?
> > 
> > I am not sure what you mean here. Were you able to see a write with an
> > unexpected content?
> 
> Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .

The oom reaper depends on userland not possibly running anymore in any
thread associated with the reaped "mm" by the time wake_oom_reaper is
called and I'm not sure do_send_sig_info is anything close to provide
such guarantee. Problem is the reschedule seems async see
native_smp_send_reschedule invoked by kick_process. So perhaps the
thread is running with a corrupted stack for a little while until the
IPI arrives to destination. I guess it wouldn't be reproducible
without a large NUMA system.

Said that I looked the assembly of your program and I don't see
anything in the file_writer that could load data from the stack by the
time it starts to write() and clearly the sigkill and
smp_send_reschedule() will happen after it's already in the write()
tight loop. The only thing it loads from the user stack after it
reaches the tight loop is the canary which should then crash it if it
breaks out of the write loop which still wouldn't cause a write.

So I don't see much explanation on the VM side, but perhaps it's
possible this is a filesystem bug that enlarges the i_size before
issuing the write that SIGBUS in copy_from_user, because of
MMF_UNSTABLE is set at first access? And then leaves i_size enlarged
and what you're seeing in od -b is leaked content from an unintialized
disk block? This would happen on ext4 as well if mounted with -o
journal=data instead of -o journal=ordered in fact, perhaps you simply
have a filesystem that isn't mounted with journal=oredered semantics
and this isn't the OOM killer.

Also why you're using octal output? -x would be more intuitive for the
0xff (377) which is to be expected (should be all zeros or 0xff, and
some zero showup too).

Assuming those values not-zeros and not-0xff are simply lack of
ordered journaling mode and it's deleted file data (you clearly must
not have a ssd with -o discard or it'd be zero there), even if you
would only see zeroes it wouldn't concern me any bit less.

The non zeroes and non-0xff if they happen beyond the end of the
previous i_size they concern me less becuase they're at least less
obviously going to create sticky data corruption in a OOM killed
database. The database could handle it by recording the valid i_size
it successfully expanded the file to, with userland journaling in its
own user metadata.

Those expected zeroes that showup in your dump, are the real major
issue here and they showup as well. A database that hits OOM would
then generate persistent sticky memory corruption in user data that
could break the entire userland journaling and you could notice only
much later too.

OOM deadlock is certainly preferable here. Rebooting on a OOM hang is
totally ok and very minor issue as the user journaling is guaranteed
to be preserved. Writing random zeroes on shared storage may break the
whole thing instead and you may notice at next reboot to upgrade the
kernel that the db journaling fails and nothing starts and you could
have lost data too.

Back to your previous xfs OOM reaper timeout failure, one way around
it, is to implement a down_read_trylock_unfair, that will obtain a
read lock ignoring any write waiter breaking fairness but if done only
in the OOM reaper that would be not a
concern. down_read_trylock_unfair should solve this xfs lockup
involving khugepaged without the need to remove the mmap_sem from the
OOM reaper while mm_users > 0. Problem would then remain if the OOM
selected task is allocating memory and stuck on a xfs lock taken by
shrink_slabs while holding the mmap_sem for writing. This is why my
preference would be to dig in xfs and solve the source of the OOM
lockup at its core, as the OOM reaper is kicking the can down the
road, and ultimately if the process runs on pure
MAP_ANONYMOUS|MAP_SHARED kicking the can won't move it one bit, unless
OOM reaper starts to reap shmem too by expanding even more with more
checks and stuff when the fix for xfs ultimately will become simpler
and more self contained and targeted.

I would like if it would be possible to tell which kernel thread has
to be allowed to make progress lowering the wmark to unstuck the
TIF_MEMDIE task. For kernel threads this could involve adding a
pf_memalloc_pid dependency that is accessible at OOM time. Workqueues
submitted in PF_MEMALLOC context could set this pf_memalloc_pid
dependency in the worker threads themselves, fs kernel threads would
need the filesystem to set this pid dependency. So if TIF_MEMDIE pid
matches the current kernel thread pf_memalloc_pid, the kernel thread
allocation would inherit PF_MEMALLOC wmark privileges, by artificially
lowering the wmark for the TIF_MEMDIE task.

Or simply we could stop calling shrink_slab for fs dependent slab
caches with a per shrinker flag, in direct reclaim and offload those
to kswapd only. That would be a real simple change, much simpler than
the current unsafe but simpler OOM reaper.

There are several dozen of mbytes of RAM available when the system
hangs and fails to get rid of the TIF_MEMDIE task, problem they must
be given to the kernel thread that the TIF_MEMDIE task is waiting for
and we can't rely on lockdep to sort it out or it's too slow.

Refusal to fix the fs hangs and relying solely on the OOM reaper
ultimately causes the OOM reaper to keep escalating, to the point not
even down_read_trylock_unfair would suffice anymore and it would need
to zap pagetables without holding the mmap_sem at all (for example in
order to solve your same xfs OOM hang that would still remain if
shrink_slabs runs in direct reclaim under a mmap_sem-for-writing
section like while allocating a vma in mmap).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
