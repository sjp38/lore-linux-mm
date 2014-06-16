Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 377E26B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 17:12:52 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so4851214pdi.27
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 14:12:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rq2si12172142pbc.163.2014.06.16.14.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 14:12:51 -0700 (PDT)
Message-ID: <539F5BC5.3010501@oracle.com>
Date: Mon, 16 Jun 2014 17:04:05 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in remove_migration_pte
References: <534E9ACA.2090008@oracle.com> <5367B365.1070709@oracle.com> <537FE9F3.40508@oracle.com> <alpine.LSU.2.11.1405261255530.3649@eggly.anvils> <538498A1.7010305@oracle.com> <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Bob Liu <bob.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 06/10/2014 12:20 AM, Hugh Dickins wrote:
> On Tue, 27 May 2014, Sasha Levin wrote:
>> > On 05/26/2014 04:05 PM, Hugh Dickins wrote:
>>> > > On Fri, 23 May 2014, Sasha Levin wrote:
>>> > > 
>>>> > >> Ping?
>>>> > >>
>>>> > >> On 05/05/2014 11:51 AM, Sasha Levin wrote:
>>>>> > >>> Did anyone have a chance to look at it? I still see it in -next.
>>>>> > >>>
>>>>> > >>>
>>>>> > >>> Thanks,
>>>>> > >>> Sasha
>>>>> > >>>
>>>>> > >>> On 04/16/2014 10:59 AM, Sasha Levin wrote:
>>>>>> > >>>> Hi all,
>>>>>> > >>>>
>>>>>> > >>>> While fuzzing with trinity inside a KVM tools guest running latest -next
>>>>>> > >>>> kernel I've stumbled on the following:
>>>>>> > >>>>
>>>>>> > >>>> [ 2552.313602] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
>>>>>> > >>>> [ 2552.315878] IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
>>>>>> > >>>> [ 2552.315878] PGD 465836067 PUD 465837067 PMD 0
>>>>>> > >>>> [ 2552.315878] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>>>>> > >>>> [ 2552.315878] Dumping ftrace buffer:
>>>>>> > >>>> [ 2552.315878]    (ftrace buffer empty)
>>>>>> > >>>> [ 2552.315878] Modules linked in:
>>>>>> > >>>> [ 2552.315878] CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W     3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
>>>>>> > >>>> [ 2552.315878] task: ffff88046548b000 ti: ffff88044e532000 task.ti: ffff88044e532000
>>>>>> > >>>> [ 2552.320286] RIP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
>>>>>> > >>>> [ 2552.320286] RSP: 0018:ffff88044e5339c8  EFLAGS: 00010002
>>>>>> > >>>> [ 2552.320286] RAX: 0000000000000082 RBX: ffff88046548b000 RCX: 0000000000000000
>>>>>> > >>>> [ 2552.320286] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000018
>>>>>> > >>>> [ 2552.320286] RBP: ffff88044e533ab8 R08: 0000000000000001 R09: 0000000000000000
>>>>>> > >>>> [ 2552.320286] R10: ffff88046548b000 R11: 0000000000000001 R12: 0000000000000000
>>>>>> > >>>> [ 2552.320286] R13: 0000000000000018 R14: 0000000000000000 R15: 0000000000000000
>>>>>> > >>>> [ 2552.320286] FS:  00007fd286a9a700(0000) GS:ffff88018b000000(0000) knlGS:0000000000000000
>>>>>> > >>>> [ 2552.320286] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>>> > >>>> [ 2552.320286] CR2: 0000000000000018 CR3: 0000000442c17000 CR4: 00000000000006a0
>>>>>> > >>>> [ 2552.320286] DR0: 0000000000695000 DR1: 0000000000000000 DR2: 0000000000000000
>>>>>> > >>>> [ 2552.320286] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>>>>>> > >>>> [ 2552.320286] Stack:
>>>>>> > >>>> [ 2552.320286]  ffff88044e5339e8 ffffffff9f56e761 0000000000000000 ffff880315c13000
>>>>>> > >>>> [ 2552.320286]  ffff88044e533a38 ffffffff9c193f0d ffffffff9c193e34 ffff8804654e8000
>>>>>> > >>>> [ 2552.320286]  ffff8804654e8000 0000000000000001 ffff88046548b000 0000000000000007
>>>>>> > >>>> [ 2552.320286] Call Trace:
>>>>>> > >>>> [ 2552.320286] ? _raw_spin_unlock_irq (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:169 kernel/locking/spinlock.c:199)
>>>>>> > >>>> [ 2552.320286] ? finish_task_switch (include/linux/tick.h:206 kernel/sched/core.c:2163)
>>>>>> > >>>> [ 2552.320286] ? finish_task_switch (arch/x86/include/asm/current.h:14 kernel/sched/sched.h:993 kernel/sched/core.c:2145)
>>>>>> > >>>> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
>>>>>> > >>>> [ 2552.320286] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
>>>>>> > >>>> [ 2552.320286] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
>>>>>> > >>>> [ 2552.320286] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
>>>>>> > >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
>>>>>> > >>>> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
>>>>>> > >>>> [ 2552.320286] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
>>>>>> > >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
>>>>>> > >>>> [ 2552.320286] remove_migration_pte (mm/migrate.c:137)
>>>>>> > >>>> [ 2552.320286] rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
>>>>>> > >>>> [ 2552.320286] remove_migration_ptes (mm/migrate.c:224)
>>>>>> > >>>> [ 2552.320286] ? new_page_node (mm/migrate.c:107)
>>>>>> > >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:195)
>>>>>> > >>>> [ 2552.320286] migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
>>>>>> > >>>> [ 2552.320286] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1574)
>>>>>> > >>>> [ 2552.320286] migrate_misplaced_page (mm/migrate.c:1733)
>>>>>> > >>>> [ 2552.320286] __handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
>>>>>> > >>>> [ 2552.320286] ? __const_udelay (arch/x86/lib/delay.c:126)
>>>>>> > >>>> [ 2552.320286] ? __rcu_read_unlock (kernel/rcu/update.c:97)
>>>>>> > >>>> [ 2552.320286] handle_mm_fault (mm/memory.c:3948)
>>>>>> > >>>> [ 2552.320286] __get_user_pages (mm/memory.c:1851)
>>>>>> > >>>> [ 2552.320286] ? preempt_count_sub (kernel/sched/core.c:2527)
>>>>>> > >>>> [ 2552.320286] __mlock_vma_pages_range (mm/mlock.c:255)
>>>>>> > >>>> [ 2552.320286] __mm_populate (mm/mlock.c:711)
>>>>>> > >>>> [ 2552.320286] SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)
>>>>>> > >>>> [ 2552.320286] tracesys (arch/x86/kernel/entry_64.S:749)
>>>>>> > >>>> [ 2552.320286] Code: 85 2d 1e 00 00 48 c7 c1 d7 68 6c a0 48 c7 c2 47 11 6c a0 31 c0 be fa 0b 00 00 48 c7 c7 91 68 6c a0 e8 1c 6d f9 ff e9 07 1e 00 00 <49> 81 7d 00 80 31 76 a2 b8 00 00 00 00 44 0f 44 c0 eb 07 0f 1f
>>>>>> > >>>> [ 2552.320286] RIP __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
>>>>>> > >>>> [ 2552.320286]  RSP <ffff88044e5339c8>
>>>>>> > >>>> [ 2552.320286] CR2: 0000000000000018
>>> > > 
>>> > > Sasha, please clarify your Ping: I've seen you say in other mail
>>> > > "I had to disable transhuge/hugetlb in my testing .config".
>>> > > 
>>> > > Do you see this remove_migration_pte oops even with THP disabled?
>>> > > 
>>> > > Do you see the filemap.c:202 BUG_ON(page_mapped(page))
>>> > > even with THP disabled?
>> > 
>> > The mail that you mentioned prompted me to go back and re-enable THP and
>> > see what still breaks, which would explain why I pinged this thread again (I
>> > only do that once I see that problem still occurs).
>> > 
>> > However, I can't confirm if these problems happen without THP as I didn't
>> > think they were related. I'll disable THP again and give it a go.
> Although there's nothing in the backtrace to implicate it,
> I think this crash is caused by THP: please try this patch - thanks.
> 
> [PATCH] mm: let mm_find_pmd fix buggy race with THP fault
> 
> Trinity has reported:
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W
>                         3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
> lock_acquire (arch/x86/include/asm/current.h:14
>               kernel/locking/lockdep.c:3602)
> _raw_spin_lock (include/linux/spinlock_api_smp.h:143
>                 kernel/locking/spinlock.c:151)
> remove_migration_pte (mm/migrate.c:137)
> rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
> remove_migration_ptes (mm/migrate.c:224)
> migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
> migrate_misplaced_page (mm/migrate.c:1733)
> __handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
> handle_mm_fault (mm/memory.c:3948)
> __get_user_pages (mm/memory.c:1851)
> __mlock_vma_pages_range (mm/mlock.c:255)
> __mm_populate (mm/mlock.c:711)
> SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)
> 
> I believe this comes about because, whereas collapsing and splitting
> THP functions take anon_vma lock in write mode (which excludes
> concurrent rmap walks), faulting THP functions (write protection and
> misplaced NUMA) do not - and mostly they do not need to.
> 
> But they do use a pmdp_clear_flush(), set_pmd_at() sequence which,
> for an instant (indeed, for a long instant, given the inter-CPU
> TLB flush in there), leaves *pmd neither present not trans_huge.
> 
> Which can confuse a concurrent rmap walk, as when removing migration
> ptes, seen in the dumped trace.  Although that rmap walk has a 4k
> page to insert, anon_vmas containing THPs are in no way segregated
> from 4k-page anon_vmas, so the 4k-intent mm_find_pmd() does need to
> cope with that instant when a trans_huge pmd is temporarily absent.
> 
> I don't think we need strengthen the locking at the THP end: it's
> easily handled with an ACCESS_ONCE() before testing both conditions.
> 
> And since mm_find_pmd() had only one caller who wanted a THP rather
> than a pmd, let's slightly repurpose it to fail when it hits a THP
> or non-present pmd, and open code split_huge_page_address() again.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Hi Hugh,

It took some time to hit something here, but I think that the following
is related:

[  489.152166] INFO: trying to register non-static key.
[  489.152166] the code is fine but needs lockdep annotation.
[  489.152166] turning off the locking correctness validator.
[  489.152166] CPU: 23 PID: 12148 Comm: trinity-c79 Not tainted 3.15.0-next-20140616-sasha-00025-g0fd1f7d-dirty #657
[  489.152166]  ffff8804dd013000 ffff8804e15a38e8 ffffffff965140d1 0000000000000002
[  489.152166]  ffffffff9a5ce7c0 ffff8804e15a39e8 ffffffff931ca363 ffff8804e15a3928
[  489.152166]  0000000000000000 0000000000000000 ffff8804e4730978 0000000000000001
[  489.152166] Call Trace:
[  489.152166] dump_stack (lib/dump_stack.c:52)
[  489.152166] __lock_acquire (kernel/locking/lockdep.c:743 kernel/locking/lockdep.c:3078)
[  489.152166] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  489.152166] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  489.152166] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  489.152166] ? __page_check_address (include/linux/spinlock.h:303 mm/rmap.c:630)
[  489.152166] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[  489.152166] ? __page_check_address (include/linux/spinlock.h:303 mm/rmap.c:630)
[  489.152166] ? get_parent_ip (kernel/sched/core.c:2546)
[  489.152166] __page_check_address (include/linux/spinlock.h:303 mm/rmap.c:630)
[  489.152166] try_to_unmap_one (mm/rmap.c:1153)
[  489.152166] ? __const_udelay (arch/x86/lib/delay.c:126)
[  489.152166] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[  489.152166] ? page_lock_anon_vma_read (mm/rmap.c:448)
[  489.152166] rmap_walk (mm/rmap.c:1654 mm/rmap.c:1725)
[  489.152166] ? preempt_count_sub (kernel/sched/core.c:2602)
[  489.152166] try_to_unmap (mm/rmap.c:1547)
[  489.152166] ? page_remove_rmap (mm/rmap.c:1144)
[  489.152166] ? invalid_migration_vma (mm/rmap.c:1503)
[  489.152166] ? try_to_unmap_one (mm/rmap.c:1411)
[  489.152166] ? anon_vma_prepare (mm/rmap.c:448)
[  489.152166] ? invalid_mkclean_vma (mm/rmap.c:1498)
[  489.152166] ? page_get_anon_vma (mm/rmap.c:405)
[  489.152166] migrate_pages (mm/migrate.c:913 mm/migrate.c:959 mm/migrate.c:1146)
[  489.152166] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:169 kernel/locking/spinlock.c:199)
[  489.152166] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1594)
[  489.152166] migrate_misplaced_page (mm/migrate.c:1754)
[  489.152166] __handle_mm_fault (mm/memory.c:3157 mm/memory.c:3207 mm/memory.c:3317)
[  489.152166] handle_mm_fault (include/linux/memcontrol.h:151 mm/memory.c:3343)
[  489.152166] ? __do_page_fault (arch/x86/mm/fault.c:1163)
[  489.152166] __do_page_fault (arch/x86/mm/fault.c:1230)
[  489.152166] ? vtime_account_user (kernel/sched/cputime.c:687)
[  489.152166] ? get_parent_ip (kernel/sched/core.c:2546)
[  489.152166] ? preempt_count_sub (kernel/sched/core.c:2602)
[  489.152166] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[  489.152166] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  489.152166] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
[  489.152166] trace_do_page_fault (arch/x86/mm/fault.c:1313 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1314)
[  489.152166] do_async_page_fault (arch/x86/kernel/kvm.c:264)
[  489.152166] async_page_fault (arch/x86/kernel/entry_64.S:1322)
[  494.710068] =============================================================================
[  494.710068] BUG page->ptl (Not tainted): Redzone overwritten
[  494.710068] -----------------------------------------------------------------------------
[  494.710068]
[  494.710068] INFO: 0xffff8804e4730e58-0xffff8804e4730e5f. First byte 0x0 instead of 0xbb
[  494.710068] INFO: Slab 0xffffea001391cc00 objects=40 used=40 fp=0x          (null) flags=0x56fffff80004080
[  494.710068] INFO: Object 0xffff8804e4730e10 @offset=3600 fp=0x          (null)
[  494.710068]
[  494.710068] Bytes b4 ffff8804e4730e00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  494.710068] Object ffff8804e4730e10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  494.710068] Object ffff8804e4730e20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  494.710068] Object ffff8804e4730e30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  494.710068] Object ffff8804e4730e40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  494.710068] Object ffff8804e4730e50: 00 00 00 00 00 00 00 00                          ........
[  494.710068] Redzone ffff8804e4730e58: 00 00 00 00 00 00 00 00                          ........
[  494.710068] Padding ffff8804e4730f98: 00 00 00 00 00 00 00 00                          ........
[  494.710068] CPU: 21 PID: 12452 Comm: trinity-c128 Tainted: G    B         3.15.0-next-20140616-sasha-00025-g0fd1f7d-dirty #657
[  494.710068]  ffff8804e4730e10 ffff88040b7d3980 ffffffff965140d1 0000000000000001
[  494.710068]  ffff88003680bb80 ffff88040b7d39b0 ffffffff932eac11 ffff8804e4730e60
[  494.710068]  ffff88003680bb80 00000000000000bb ffff8804e4730e10 ffff88040b7d3a00
[  494.710068] Call Trace:
[  494.710068] dump_stack (lib/dump_stack.c:52)
[  494.710068] print_trailer (mm/slub.c:641)
[  494.710068] check_bytes_and_report (mm/slub.c:680 mm/slub.c:704)
[  494.710068] check_object (mm/slub.c:804)
[  494.710068] ? ptlock_alloc (mm/memory.c:3826)
[  494.742119] alloc_debug_processing (mm/slub.c:1082)
[  494.742119] __slab_alloc (mm/slub.c:2382 (discriminator 1))
[  494.742119] ? ptlock_alloc (mm/memory.c:3826)
[  494.742119] ? get_parent_ip (kernel/sched/core.c:2546)
[  494.742119] kmem_cache_alloc (mm/slub.c:2442 mm/slub.c:2484 mm/slub.c:2489)
[  494.742119] ? ptlock_alloc (mm/memory.c:3826)
[  494.742119] ? pte_alloc_one (arch/x86/mm/pgtable.c:28)
[  494.742119] ? copy_huge_pmd (./arch/x86/include/asm/paravirt.h:571 ./arch/x86/include/asm/pgtable.h:168 mm/huge_memory.c:867)
[  494.742119] ptlock_alloc (mm/memory.c:3826)
[  494.742119] pte_alloc_one (include/linux/mm.h:1464 include/linux/mm.h:1499 arch/x86/mm/pgtable.c:30)
[  494.742119] copy_huge_pmd (mm/huge_memory.c:858)
[  494.742119] copy_page_range (mm/memory.c:968 mm/memory.c:998 mm/memory.c:1062)
[  494.742119] copy_process (kernel/fork.c:460 kernel/fork.c:835 kernel/fork.c:898 kernel/fork.c:1346)
[  494.742119] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2619)
[  494.742119] do_fork (kernel/fork.c:1607)
[  494.742119] ? get_parent_ip (kernel/sched/core.c:2546)
[  494.742119] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  494.742119] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2564)
[  494.742119] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  494.742119] SyS_clone (kernel/fork.c:1693)
[  494.742119] stub_clone (arch/x86/kernel/entry_64.S:637)
[  494.742119] ? tracesys (arch/x86/kernel/entry_64.S:542)
[  494.742119] FIX page->ptl: Restoring 0xffff8804e4730e58-0xffff8804e4730e5f=0xbb
[  494.742119]
[  494.742119] FIX page->ptl: Marking all objects used


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
