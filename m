Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8662D6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:25:18 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id hq12so4415008vcb.6
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:25:18 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g3si3108197vdw.53.2015.02.12.11.25.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 11:25:17 -0800 (PST)
Message-ID: <54DCFDF8.4000207@oracle.com>
Date: Thu, 12 Feb 2015 14:24:40 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 14/24] thp: implement new split_huge_page()
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-15-git-send-email-kirill.shutemov@linux.intel.com> <54DCDDEE.5030501@oracle.com>
In-Reply-To: <54DCDDEE.5030501@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/12/2015 12:07 PM, Sasha Levin wrote:
> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
>> > +void __get_page_tail(struct page *page);
>> >  static inline void get_page(struct page *page)
>> >  {
>> > -	struct page *page_head = compound_head(page);
>> > -	VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page);
>> > -	atomic_inc(&page_head->_count);
>> > +	if (unlikely(PageTail(page)))
>> > +		return __get_page_tail(page);
>> > +
>> > +	/*
>> > +	 * Getting a normal page or the head of a compound page
>> > +	 * requires to already have an elevated page->_count.
>> > +	 */
>> > +	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
> This BUG_ON seems to get hit:

Plus a few more different traces:

[  908.874364] BUG: Bad page map in process trinity-c55  pte:1ad673100 pmd:1721f3067
[  908.877609] page:ffffea0006b59cc0 count:0 mapcount:-1 mapping:          (null) index:0x2
[  908.880244] flags: 0x12fffff80000000()
[  908.881503] page dumped because: bad pte
[  908.883124] addr:00007f0b86e73000 vm_flags:08100073 anon_vma:ffff88016f2b6438 mapping:          (null) index:7f0b86e73
[  908.887086] CPU: 55 PID: 15463 Comm: trinity-c55 Not tainted 3.19.0-next-20150212-sasha-00072-gdc1aa32 #1913
[  908.889486]  ffff88016f2c4ca0 000000003dbb1858 ffff88001688f738 ffffffffa7b863a0
[  908.891869]  1ffff1002de58994 0000000000000000 ffff88001688f7a8 ffffffff9d6edf6c
[  908.894464]  0000000000000000 ffffea0006b59cc0 00000001ad673100 0000000000000000
[  908.896629] Call Trace:
[  908.897351] dump_stack (lib/dump_stack.c:52)
[  908.898848] print_bad_pte (mm/memory.c:694)
[  908.900229] unmap_single_vma (mm/memory.c:1124 mm/memory.c:1215 mm/memory.c:1236 mm/memory.c:1260 mm/memory.c:1305)
[  908.901701] ? vm_normal_page (mm/memory.c:1270)
[  908.904309] ? pagevec_lru_move_fn (include/linux/pagevec.h:44 mm/swap.c:272)
[  908.907091] ? lru_cache_add_file (mm/swap.c:861)
[  908.910132] unmap_vmas (mm/memory.c:1334 (discriminator 3))
[  908.912016] exit_mmap (mm/mmap.c:2841)
[  908.913800] ? __debug_object_init (lib/debugobjects.c:667)
[  908.915679] ? SyS_remap_file_pages (mm/mmap.c:2811)
[  908.917569] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2464 mm/huge_memory.c:2245)
[  908.919733] mmput (kernel/fork.c:681 kernel/fork.c:664)
[  908.921609] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[  908.924012] ? debug_check_no_locks_freed (kernel/locking/lockdep.c:3051)
[  908.926954] ? mm_update_next_owner (kernel/exit.c:654)
[  908.929141] ? up_read (./arch/x86/include/asm/rwsem.h:156 kernel/locking/rwsem.c:101)
[  908.931523] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:861)
[  908.933657] get_signal (kernel/signal.c:2358)
[  908.935700] ? trace_hardirqs_off (kernel/locking/lockdep.c:2647)
[  908.938485] do_signal (arch/x86/kernel/signal.c:703)
[  908.940637] ? setup_sigcontext (arch/x86/kernel/signal.c:700)
[  908.943275] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:144 (discriminator 2))
[  908.946258] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2554 kernel/locking/lockdep.c:2601)
[  908.951986] do_notify_resume (arch/x86/kernel/signal.c:748)
[  908.955202] int_signal (arch/x86/kernel/entry_64.S:480)
[  908.957110] Disabling lock debugging due to kernel taint
[  909.052751] page:ffffea0006b59cc0 count:0 mapcount:-1 mapping:          (null) index:0x2
[  909.055737] flags: 0x12fffff80000000()
[  909.057355] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0)
[  909.060767] ------------[ cut here ]------------
[  909.061682] kernel BUG at include/linux/mm.h:340!
[  909.061682] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  909.061682] Dumping ftrace buffer:
[  909.061682]    (ftrace buffer empty)
[  909.061682] Modules linked in:
[  909.061682] CPU: 55 PID: 15463 Comm: trinity-c55 Tainted: G    B           3.19.0-next-20150212-sasha-00072-gdc1aa32 #1913
[  909.061682] task: ffff88001accb000 ti: ffff880016888000 task.ti: ffff880016888000
[  909.061682] RIP: release_pages (include/linux/mm.h:340 mm/swap.c:766)
[  909.061682] RSP: 0000:ffff88001688f638  EFLAGS: 00010296
[  909.061682] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
[  909.061682] RDX: 1ffffd4000d6b39f RSI: 0000000000000000 RDI: ffffea0006b59cf8
[  909.061682] RBP: ffff88001688f708 R08: 0000000000000001 R09: 0000000000000000
[  909.061682] R10: ffffffffae875ce8 R11: 3d2029746e756f63 R12: ffff88001ade0be8
[  909.061682] R13: 00000000000001fe R14: dffffc0000000000 R15: ffffea0006b59cc0
[  909.061682] FS:  0000000000000000(0000) GS:ffff881165600000(0000) knlGS:0000000000000000
[  909.061682] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  909.061682] CR2: 00007f0b89ff08c1 CR3: 000000002a82c000 CR4: 00000000000007a0
[  909.061682] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  909.061682] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  909.061682] Stack:
[  909.061682]  ffff88016f2c4ca0 1ffff10002d11ecf 0000000100000000 ffff880047ac0340
[  909.061682]  0000000000000286[  909.108909] pps pps0: PPS event at 1.227081767
[  909.108918] pps pps0: capture assert seq #848

[  909.061682]  ffff881434f85000 ffff88001ade1000 ffff88140000001f
[  909.061682]  0000000041b58ab3 ffffffffaa4a9f39 ffffffff9d68d0f0 0000000000000037
[  909.061682] Call Trace:
[  909.061682] ? put_pages_list (mm/swap.c:736)
[  909.061682] ? get_parent_ip (kernel/sched/core.c:2581)
[  909.061682] free_pages_and_swap_cache (mm/swap_state.c:267)
[  909.061682] tlb_flush_mmu_free (mm/memory.c:255 (discriminator 4))
[  909.061682] unmap_single_vma (mm/memory.c:1172 mm/memory.c:1215 mm/memory.c:1236 mm/memory.c:1260 mm/memory.c:1305)
[  909.061682] ? vm_normal_page (mm/memory.c:1270)
[  909.061682] ? pagevec_lru_move_fn (include/linux/pagevec.h:44 mm/swap.c:272)
[  909.061682] ? lru_cache_add_file (mm/swap.c:861)
[  909.061682] unmap_vmas (mm/memory.c:1334 (discriminator 3))
[  909.061682] exit_mmap (mm/mmap.c:2841)
[  909.061682] ? __debug_object_init (lib/debugobjects.c:667)
[  909.061682] ? SyS_remap_file_pages (mm/mmap.c:2811)
[  909.061682] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2464 mm/huge_memory.c:2245)
[  909.061682] mmput (kernel/fork.c:681 kernel/fork.c:664)
[  909.061682] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[  909.061682] ? debug_check_no_locks_freed (kernel/locking/lockdep.c:3051)
[  909.061682] ? mm_update_next_owner (kernel/exit.c:654)
[  909.061682] ? up_read (./arch/x86/include/asm/rwsem.h:156 kernel/locking/rwsem.c:101)
[  909.061682] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:861)
[  909.061682] get_signal (kernel/signal.c:2358)
[  909.061682] ? trace_hardirqs_off (kernel/locking/lockdep.c:2647)
[  909.061682] do_signal (arch/x86/kernel/signal.c:703)
[  909.061682] ? setup_sigcontext (arch/x86/kernel/signal.c:700)
[  909.061682] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:144 (discriminator 2))
[  909.061682] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2554 kernel/locking/lockdep.c:2601)
[  909.061682] do_notify_resume (arch/x86/kernel/signal.c:748)
[  909.061682] int_signal (arch/x86/kernel/entry_64.S:480)
[ 909.061682] Code: 18 e3 56 0a 4c 89 ff 31 db e8 1e [ 909.179340] BUG: Bad page map in process trinity-c65 pte:1ad673960 pmd:1ab55d067

Code starting with the faulting instruction
===========================================
[  909.179350] page:ffffea0006b59cc0 count:0 mapcount:-2 mapping:          (null) index:0x2
[  909.179357] flags: 0x12fffff80000014(referenced|dirty)
[  909.179370] page dumped because: bad pte
[  909.179376] addr:0000000001105000 vm_flags:08100073 anon_vma:ffff8801ab54b378 mapping:          (null) index:1105
[  909.179387] CPU: 7 PID: 15373 Comm: trinity-c65 Tainted: G    B           3.19.0-next-20150212-sasha-00072-gdc1aa32 #1913
[  909.179399]  ffff8801ab54daa0 00000000faf56450 ffff8801ab557738 ffffffffa7b863a0
[  909.179411]  1ffff100356a9b54 0000000000000000 ffff8801ab5577a8 ffffffff9d6edf6c
[  909.179425]  0000000000000000 ffffea0006b59cc0 00000001ad673960 0000000000000000
[  909.179446] Call Trace:
[  909.179451] dump_stack (lib/dump_stack.c:52)
[  909.179475] print_bad_pte (mm/memory.c:694)
[  909.179492] unmap_single_vma (mm/memory.c:1124 mm/memory.c:1215 mm/memory.c:1236 mm/memory.c:1260 mm/memory.c:1305)
[  909.179516] ? vm_normal_page (mm/memory.c:1270)
[  909.179532] ? cmpxchg_double_slab.isra.27 (mm/slub.c:429)
[  909.179686] unmap_vmas (mm/memory.c:1334 (discriminator 3))
[  909.179695] exit_mmap (mm/mmap.c:2841)
[  909.179705] ? __debug_object_init (lib/debugobjects.c:667)
[  909.179720] ? SyS_remap_file_pages (mm/mmap.c:2811)
[  909.179838] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2464 mm/huge_memory.c:2245)
[  909.179853] mmput (kernel/fork.c:681 kernel/fork.c:664)
[  909.179863] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[  909.179982] ? debug_check_no_locks_freed (kernel/locking/lockdep.c:3051)
[  909.179997] ? mm_update_next_owner (kernel/exit.c:654)
[  909.186881] ? up_read (./arch/x86/include/asm/rwsem.h:156 kernel/locking/rwsem.c:101)
[  909.186891] ? task_numa_work (kernel/sched/fair.c:2217)
[  909.186905] ? get_signal (kernel/signal.c:2207)
[  909.186919] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:861)
[  909.186928] get_signal (kernel/signal.c:2358)
[  909.186936] ? trace_hardirqs_off (kernel/locking/lockdep.c:2647)
[  909.186945] do_signal (arch/x86/kernel/signal.c:703)
[  909.186964] ? setup_sigcontext (arch/x86/kernel/signal.c:700)
[  909.186982] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:154 kernel/locking/spinlock.c:183)
[  909.187006] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:114 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:140)
[  909.187570] ? rcu_eqs_exit (kernel/rcu/tree.c:743)
[  909.187584] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2566)
[  909.187593] do_notify_resume (arch/x86/kernel/signal.c:748)
[  909.187601] retint_signal (arch/x86/kernel/entry_64.S:895)
[  909.236015] page:ffffea0006b59cc0 count:0 mapcount:-2 mapping:          (null) index:0x2
[  909.236028] flags: 0x12fffff80000014(referenced|dirty)
[  909.236048] page dumped because: VM_BUG_ON_PAGE(page->flags & ((1 << 24) - 1))

[  909.061682] f7 ff ff e9 d5 fc ff ff 66 0f 1f 84 00 00 00 00 00 48 c7 c6 a0 1b f3 a7 4c 89 ff e8 61 bb 05 00 <0f> 0b 0f 1f 80 00 00 00 00 48 c7 c6 e0 1a f3 a7 4c 89 ff e8 49
[  909.061682] RIP release_pages (include/linux/mm.h:340 mm/swap.c:766)
[  909.061682]  RSP <ffff88001688f638>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
