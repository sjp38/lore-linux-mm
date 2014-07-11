Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDA16B0031
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:00:54 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so885486pde.38
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:00:54 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id n2si731625pdi.294.2014.07.11.00.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 00:00:53 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so900601pde.3
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:00:53 -0700 (PDT)
Date: Thu, 10 Jul 2014 23:59:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
In-Reply-To: <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407102253380.1252@eggly.anvils>
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com>
 <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com> <53BECBA4.3010508@oracle.com> <alpine.LSU.2.11.1407101033280.18934@eggly.anvils> <53BED7F6.4090502@oracle.com> <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 10 Jul 2014, Hugh Dickins wrote:
> On Thu, 10 Jul 2014, Sasha Levin wrote:
> > On 07/10/2014 01:55 PM, Hugh Dickins wrote:
> > >> And finally, (not) holding the i_mmap_mutex:
> > > I don't understand what prompts you to show this particular task.
> > > I imagine the dump shows lots of other tasks which are waiting to get an
> > > i_mmap_mutex, and quite a lot of other tasks which are neither waiting
> > > for nor holding an i_mmap_mutex.
> > > 
> > > Why are you showing this one in particular?  Because it looks like the
> > > one you fingered yesterday?  But I didn't see a good reason to finger
> > > that one either.
> > 
> > There are a few more tasks like this one, my criteria was tasks that lockdep
> > claims were holding i_mmap_mutex, but are actually not.
> 
> You and Vlastimil enlightened me yesterday that lockdep shows tasks as
> holding i_mmap_mutex when they are actually waiting to get i_mmap_mutex.
> Hundreds of those in yesterday's log, hundreds of them in today's.
> 
> The full log you've sent (thanks) is for a different run from the one
> you showed in today's mail.  No problem with that, except when I assert
> that trinity-c190 in today's mail is just like trinity-c402 in yesterday's,
> a task caught at one stage of exit_mmap in the stack dumps, then a later
> stage of exit_mmap in the locks held dumps, I'm guessing rather than
> confirming from the log.
> 
> There's nothing(?) interesting about those tasks, they're just tasks we
> have been lucky to catch a moment before they reach the i_mmap_mutex
> hang affecting the majority.
> 
> > 
> > One new thing that I did notice is that since trinity spins a lot of new children
> > to test out things like execve() which would kill said children, there tends to
> > be a rather large amount of new tasks created and killed constantly.
> > 
> > So if you look at the bottom of the new log (attached), you'll see that there
> > are quite a few "trinity-subchild" processes trying to die, unsuccessfully.
> 
> Lots of those in yesterday's log too: waiting to get i_mmap_mutex.
> 
> I'll pore over the new log.  It does help to know that its base kernel
> is more stable: thanks so much.  But whether I can work out any more...

In fact Thursday's log was good enough, and no need for the improved
lockdep messaging we talked about, not for this bug at least.

Not that I properly understand it yet, but at least I identified the
task holding the i_mmap_mutex in Wednesday's and in Thursday's log.
So very obvious that I'm embarrassed even to pass on the info: I
pretty much said which the task was, without realizing it myself.

In each log there was only one task down below unmap_mapping_range().

Wednesday on linux-next-based 3.16.0-rc4-next-20140709-sasha-00024-gd22103d-dirty #775

trinity-c235    R  running task    12216  9169   8558 0x10000002
 ffff8800bbf978a8 0000000000000002 ffff88010cfe3290 0000000000000282
 ffff8800bbf97fd8 00000000001e2740 00000000001e2740 00000000001e2740
 ffff8800bdb03000 ffff8800bbf2b000 ffff8800bbf978a8 ffff8800bbf97fd8
Call Trace:
preempt_schedule (./arch/x86/include/asm/preempt.h:80 kernel/sched/core.c:2889)  (that's the __preempt_count_sub line after __schedule, I believe)
___preempt_schedule (arch/x86/kernel/preempt.S:11)
? zap_pte_range (mm/memory.c:1218)
? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
? _raw_spin_unlock (include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
zap_pte_range (mm/memory.c:1218)
unmap_single_vma (mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301 mm/memory.c:1346)
zap_page_range_single (include/linux/mmu_notifier.h:234 mm/memory.c:1427)
? unmap_mapping_range (mm/memory.c:2392)
? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
unmap_mapping_range (mm/memory.c:2317 mm/memory.c:2393)
truncate_inode_page (mm/truncate.c:136 mm/truncate.c:180)
shmem_undo_range (mm/shmem.c:441)
shmem_truncate_range (mm/shmem.c:537)
shmem_fallocate (mm/shmem.c:1771)
? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
SyS_madvise (mm/madvise.c:332 mm/madvise.c:381 mm/madvise.c:531 mm/madvise.c:462)
tracesys (arch/x86/kernel/entry_64.S:542)

Thursday on Linus-based 3.16.0-rc4-sasha-00069-g615ded7-dirty #793

trinity-c100    R  running task    13048  8967   8490 0x00000006
 ffff88001b903978 0000000000000002 0000000000000006 ffff880404666fd8
 ffff88001b903fd8 00000000001d7740 00000000001d7740 00000000001d7740
 ffff880007a40000 ffff88001b8f8000 ffff88001b903968 ffff88001b903fd8
Call Trace:
preempt_schedule_irq (./arch/x86/include/asm/paravirt.h:814 kernel/sched/core.c:2912) (that's the local_irq_disable line after __schedule, I believe)
retint_kernel (arch/x86/kernel/entry_64.S:937)
? unmap_single_vma (mm/memory.c:1230 mm/memory.c:1277 mm/memory.c:1302 mm/memory.c:1348)
? unmap_single_vma (mm/memory.c:1297 mm/memory.c:1348)
zap_page_range_single (include/linux/mmu_notifier.h:234 mm/memory.c:1429)
? get_parent_ip (kernel/sched/core.c:2546)
? unmap_mapping_range (mm/memory.c:2391)
unmap_mapping_range (mm/memory.c:2316 mm/memory.c:2392)
truncate_inode_page (mm/truncate.c:136 mm/truncate.c:180)
shmem_undo_range (mm/shmem.c:429)
shmem_truncate_range (mm/shmem.c:528)
shmem_fallocate (mm/shmem.c:1749)
? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
SyS_madvise (mm/madvise.c:335 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
tracesys (arch/x86/kernel/entry_64.S:543)

At first I thought the preempt_schedule[_irq] lines were exciting,
but seeing them in other traces, I now suppose they're nothing but
an artifact of how your watchdog gets the traces of running tasks.
(I wonder why so many tasks are shown as "running" when they're not,
but I don't think that has any bearing on the issue at hand.)

So, in each case we have a task which _appears_ to be stuck in the
i_mmap tree, holding i_mmap_mutex inside i_mutex.

I wondered if there were some interval tree corruption or bug, that
gets it stuck in a cycle.  But it seems unlikely that such a bug
would manifest always here and never under other conditions.

I've looked back at your original December and February reports in
the "mm: shm: hang in shmem_fallocate" thread.  I think "chastening"
is the word for how similar those traces are to what I show above.
I feel I have come full circle and made exactly 0 progress since then.

And I notice your remark from back then: "To me it seems like a series
of calls to shmem_truncate_range() takes so long that one of the tasks
triggers a hung task.  We don't actually hang in any specific
shmem_truncate_range() for too long though."

I think I'm coming around to that view: that trinity's forks drive
the i_mmap tree big enough, that the work to remove a single page
from that tree (while holding both i_mmap_mutex and i_mutex) takes
so long that as soon as i_mmap_mutex is dropped, a large number of
forks and exits waiting for that i_mmap_mutex come in, and if another
page gets mapped and has to be removed, our hole-punch will have to
wait a long time behind them to get the i_mmap_mutex again, all the
while holding i_mutex to make matters even worse for the other
waiting hole-punchers.

Or that's the picture I'm currently playing with, anyway.  And what
to do about it?  Dunno yet: maybe something much closer to the patch
that's already in Linus's tree (but buggy because of grabbing i_mutex
itself).  I'll mull over it.  But maybe this picture is rubbish:
I've made enough mistakes already, no surprise if this is wrong too.

And as soon as I write that, I remember something else to check,
and it does seem interesting, leading off in another direction.

Your Wednesday log took 5 advancing snapshots of the same hang,
across 4 seconds.  Above I've shown trinity-c235 from the first
of them.  But the following 4 are identical apart from timestamps.
Identical, when I'd expect it to be caught at different places in
its loop, not every time in zap_pte_range at mm/memory.c:1218
(which is the closing brace of zap_pte_range in my tree: your
line numbering is sometimes helpful, but sometimes puzzling:
I might prefer zap_pte_range+0xXXX/0xYYY in this case).

Or, thinking again on those preempt_schedule()s, maybe it's just an
artifact: that the major work in the loop is done under ptl spinlock,
so if you have to preempt to gather the trace, the most likely place
to be preempted is immediately after dropping the spinlock.

Yes, that's probably why those five are identical.
I'll go back to mulling over the starvation theory.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
