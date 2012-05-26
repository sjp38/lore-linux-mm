Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BCD136B0081
	for <linux-mm@kvack.org>; Sat, 26 May 2012 15:33:57 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so2073207bkc.14
        for <linux-mm@kvack.org>; Sat, 26 May 2012 12:33:55 -0700 (PDT)
Message-ID: <1338060890.4284.12.camel@lappy>
Subject: mm: hung task after fuzzing
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sat, 26 May 2012 21:34:50 +0200
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, hughd@google.com
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

I stumbled on the following when fuzzing with trinity inside a KVM guest, using latest linux-next kernel:

[ 3367.906805] INFO: task numad/2:24 blocked for more than 120 seconds.
[ 3367.910318] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 3367.914853] numad/2         D 0000000000000001  5928    24      2 0x00000000
[ 3367.918638]  ffff8800294fdc58 0000000000000046 ffff8800294fdc08 ffffffff81152212
[ 3367.923198]  ffff8800294fc000 ffff8800294fc010 ffff8800294fdfd8 ffff8800294fc000
[ 3367.933897]  ffff8800294fc010 ffff8800294fdfd8 ffff88000c878000 ffff880029500000
[ 3367.942510] Call Trace:
[ 3367.944815]  [<ffffffff81152212>] ? __lock_release+0x1c2/0x1e0
[ 3367.948480]  [<ffffffff832476c5>] schedule+0x55/0x60
[ 3367.951647]  [<ffffffff832484c5>] rwsem_down_failed_common+0xf5/0x130
[ 3367.955499]  [<ffffffff8114b7be>] ? put_lock_stats+0xe/0x40
[ 3367.959585]  [<ffffffff8114e565>] ? __lock_contended+0x1f5/0x230
[ 3367.964727]  [<ffffffff83248535>] rwsem_down_read_failed+0x15/0x17
[ 3367.968708]  [<ffffffff81968194>] call_rwsem_down_read_failed+0x14/0x30
[ 3367.972904]  [<ffffffff83246569>] ? down_read+0x79/0xa0
[ 3367.976229]  [<ffffffff81218442>] ? lazy_migrate_process+0x22/0x60
[ 3367.980044]  [<ffffffff81218442>] lazy_migrate_process+0x22/0x60
[ 3367.983716]  [<ffffffff81132360>] process_mem_migrate+0x10/0x20
[ 3367.987362]  [<ffffffff81131ca0>] move_processes+0x190/0x230
[ 3367.990828]  [<ffffffff81132c7a>] numad_thread+0x7a/0x120
[ 3367.994156]  [<ffffffff81132c00>] ? find_busiest_node+0x310/0x310
[ 3367.998057]  [<ffffffff811071b2>] kthread+0xb2/0xc0
[ 3367.998062]  [<ffffffff8324b734>] kernel_thread_helper+0x4/0x10
[ 3367.998067]  [<ffffffff832499b4>] ? retint_restore_args+0x13/0x13
[ 3367.998069]  [<ffffffff81107100>] ? __init_kthread_worker+0x70/0x70
[ 3367.998072]  [<ffffffff8324b730>] ? gs_change+0x13/0x13
[ 3367.998076] 1 lock held by numad/2/24:
[ 3367.998083]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81218442>] lazy_migrate_process+0x22/0x60
[ 3367.998117] INFO: task khugepaged:2640 blocked for more than 120 seconds.
[ 3367.998118] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 3367.998124] khugepaged      D 0000000000000001  5264  2640      2 0x00000000
[ 3367.998129]  ffff88000c919c18 0000000000000046 ffff88000c919bc8 ffffffff81152212
[ 3367.998134]  ffff88000c918000 ffff88000c918010 ffff88000c919fd8 ffff88000c918000
[ 3367.998138]  ffff88000c918010 ffff88000c919fd8 ffff88000c87b000 ffff88000c89b000
[ 3367.998139] Call Trace:
[ 3367.998143]  [<ffffffff81152212>] ? __lock_release+0x1c2/0x1e0
[ 3367.998145]  [<ffffffff832476c5>] schedule+0x55/0x60
[ 3367.998147]  [<ffffffff832484c5>] rwsem_down_failed_common+0xf5/0x130
[ 3367.998150]  [<ffffffff8114b7be>] ? put_lock_stats+0xe/0x40
[ 3367.998152]  [<ffffffff8114e565>] ? __lock_contended+0x1f5/0x230
[ 3367.998156]  [<ffffffff83248535>] rwsem_down_read_failed+0x15/0x17
[ 3367.998160]  [<ffffffff81968194>] call_rwsem_down_read_failed+0x14/0x30
[ 3367.998161]  [<ffffffff83246569>] ? down_read+0x79/0xa0
[ 3367.998164]  [<ffffffff8122ed0f>] ? khugepaged_scan_mm_slot+0xaf/0x320
[ 3367.998166]  [<ffffffff832490c0>] ? _raw_spin_unlock+0x30/0x60
[ 3367.998168]  [<ffffffff8122ed0f>] khugepaged_scan_mm_slot+0xaf/0x320
[ 3367.998170]  [<ffffffff8122f040>] khugepaged_do_scan+0xc0/0x100
[ 3367.998172]  [<ffffffff81230529>] khugepaged_loop+0x69/0x400
[ 3367.998174]  [<ffffffff832459f5>] ? __mutex_unlock_slowpath+0x1a5/0x200
[ 3367.998176]  [<ffffffff811079e0>] ? wake_up_bit+0x40/0x40
[ 3367.998178]  [<ffffffff812308c0>] ? khugepaged_loop+0x400/0x400
[ 3367.998180]  [<ffffffff8123091d>] khugepaged+0x5d/0xf0
[ 3367.998181]  [<ffffffff811071b2>] kthread+0xb2/0xc0
[ 3367.998183]  [<ffffffff8324b734>] kernel_thread_helper+0x4/0x10
[ 3367.998185]  [<ffffffff832499b4>] ? retint_restore_args+0x13/0x13
[ 3367.998187]  [<ffffffff81107100>] ? __init_kthread_worker+0x70/0x70
[ 3367.998188]  [<ffffffff8324b730>] ? gs_change+0x13/0x13
[ 3367.998190] 1 lock held by khugepaged/2640:
[ 3367.998193]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8122ed0f>] khugepaged_scan_mm_slot+0xaf/0x320

Digging into it, I noticed that both of those threads were waiting for a down_read() on mmap_sem, but trying to figure out which thread was trying to write, yielded nothing:

[ 3433.005415] Showing all locks held in the system:
[ 3433.005415] 1 lock held by numad/2/24:
[ 3433.005415]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81218442>] lazy_migrate_process+0x22/0x60
[ 3433.005415] 1 lock held by khugepaged/2640:
[ 3433.005415]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8122ed0f>] khugepaged_scan_mm_slot+0xaf/0x320
[ 3433.005415] 6 locks held by kjournald/5818:
[ 3433.005415]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff811e4a97>] shrink_slab+0x37/0x520
[ 3433.005415]  #1:  (sb_lock){+.+.-.}, at: [<ffffffff8123bb46>] grab_super_passive+0x16/0x80
[ 3433.005415]  #2:  (&(&i->lock)->rlock){-.-.-.}, at: [<ffffffff81b4732c>] serial8250_interrupt+0x2c/0xd0
[ 3433.005415]  #3:  (&port_lock_key){-.-.-.}, at: [<ffffffff81b48e83>] serial8250_handle_irq+0x23/0x80
[ 3433.005415]  #4:  (sysrq_key_table_lock){-.....}, at: [<ffffffff81b2b9ad>] __handle_sysrq+0x2d/0x180
[ 3433.005415]  #5:  (tasklist_lock){.?.+..}, at: [<ffffffff8114dbbc>] debug_show_all_locks+0x5c/0x260
[ 3433.005415] 1 lock held by sh/5834:
[ 3433.005415]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff81b2447e>] n_tty_read+0x2fe/0x8d0

On the other hand, I've noticed that all other fuzzing processes were stuck inside the kernel, trying to reclaim memory (I'm pasting just a few, they all look the same in the reclaiming part of the stack):

[ 3433.005415] trinity-child2  R  running task     3088  5243   5832 0x00000004
[ 3433.005415]  ffff880023d1f638 0000000000000046 0000000000000001 0000000000000001
[ 3433.005415]  ffff880023d1e000 ffff880023d1e010 ffff880023d1ffd8 ffff880023d1e000
[ 3433.005415]  ffff880023d1e010 ffff880023d1ffd8 ffff88000c808000 ffff880023d2b000
[ 3433.005415] Call Trace:
[ 3433.005415]  [<ffffffff811523ad>] ? lock_release+0x17d/0x1a0
[ 3433.005415]  [<ffffffff83247651>] preempt_schedule+0x51/0x70
[ 3433.005415]  [<ffffffff832490d9>] _raw_spin_unlock+0x49/0x60
[ 3433.005415]  [<ffffffff8123b9cc>] put_super+0x2c/0x40
[ 3433.005415]  [<ffffffff8123bb1d>] drop_super+0x1d/0x30
[ 3433.005415]  [<ffffffff8123bd1b>] prune_super+0x16b/0x1b0
[ 3433.005415]  [<ffffffff811e4b30>] shrink_slab+0xd0/0x520
[ 3433.005415]  [<ffffffff811e5e19>] do_try_to_free_pages+0x1c9/0x3e0
[ 3433.005415]  [<ffffffff811e6253>] try_to_free_pages+0x143/0x200
[ 3433.005415]  [<ffffffff811d40bb>] __perform_reclaim+0x8b/0xe0
[ 3433.005415]  [<ffffffff811d8967>] __alloc_pages_slowpath+0x407/0x6a0
[ 3433.005415]  [<ffffffff811d8305>] ? get_page_from_freelist+0x625/0x660
[ 3433.005415]  [<ffffffff811d8e46>] __alloc_pages_nodemask+0x246/0x330
[ 3433.005415]  [<ffffffff81217ecd>] alloc_pages_current+0xed/0x140
[ 3433.005415]  [<ffffffff810a67f6>] pte_alloc_one+0x16/0x40
[ 3433.005415]  [<ffffffff811f66ad>] __pte_alloc+0x2d/0x1e0
[ 3433.005415]  [<ffffffff81230cb1>] do_huge_pmd_anonymous_page+0x151/0x230
[ 3433.005415]  [<ffffffff811fc223>] handle_mm_fault+0x1e3/0x350
[ 3433.005415]  [<ffffffff811f7c87>] ? follow_page+0xe7/0x5a0
[ 3433.005415]  [<ffffffff811fc888>] __get_user_pages+0x438/0x5d0
[ 3433.005415]  [<ffffffff811fd976>] __mlock_vma_pages_range+0xc6/0xd0
[ 3433.005415]  [<ffffffff811fdb75>] mlock_vma_pages_range+0x75/0xb0
[ 3433.005415]  [<ffffffff81201656>] mmap_region+0x4c6/0x600
[ 3433.005415]  [<ffffffff81201a90>] do_mmap_pgoff+0x300/0x390
[ 3433.005415]  [<ffffffff81201d0d>] ? sys_mmap_pgoff+0x1ed/0x230
[ 3433.005415]  [<ffffffff81201d2b>] sys_mmap_pgoff+0x20b/0x230
[ 3433.005415]  [<ffffffff8196825e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 3433.005415]  [<ffffffff8106c52d>] sys_mmap+0x1d/0x20
[ 3433.005415]  [<ffffffff8324a279>] system_call_fastpath+0x16/0x1b
[ 3433.005415] trinity-child2  R  running task     3824  5357   5826 0x00000004
[ 3433.005415]  ffff88004c0935d8 0000000000000046 ffff88004c0935a8 ffffffff81150146
[ 3433.005415]  ffff88004c092000 ffff88004c092010 ffff88004c093fd8 ffff88004c092000
[ 3433.005415]  ffff88004c092010 ffff88004c093fd8 ffff88000c808000 ffff880023d28000
[ 3433.005415] Call Trace:
[ 3433.005415]  [<ffffffff81150146>] ? mark_held_locks+0xf6/0x120
[ 3433.005415]  [<ffffffff8123bb15>] ? drop_super+0x15/0x30
[ 3433.005415]  [<ffffffff83247af4>] preempt_schedule_irq+0x94/0xd0
[ 3433.005415]  [<ffffffff83249ae6>] retint_kernel+0x26/0x30
[ 3433.005415]  [<ffffffff811523ad>] ? lock_release+0x17d/0x1a0
[ 3433.005415]  [<ffffffff8110d83e>] up_read+0x1e/0x40
[ 3433.005415]  [<ffffffff8123bb15>] drop_super+0x15/0x30
[ 3433.005415]  [<ffffffff8123bd1b>] prune_super+0x16b/0x1b0
[ 3433.005415]  [<ffffffff811e4b30>] shrink_slab+0xd0/0x520
[ 3433.005415]  [<ffffffff811e5e19>] do_try_to_free_pages+0x1c9/0x3e0
[ 3433.005415]  [<ffffffff811e6253>] try_to_free_pages+0x143/0x200
[ 3433.005415]  [<ffffffff811d40bb>] __perform_reclaim+0x8b/0xe0
[ 3433.005415]  [<ffffffff811d8967>] __alloc_pages_slowpath+0x407/0x6a0
[ 3433.005415]  [<ffffffff811d8305>] ? get_page_from_freelist+0x625/0x660
[ 3433.005415]  [<ffffffff811d8e46>] __alloc_pages_nodemask+0x246/0x330
[ 3433.005415]  [<ffffffff81217ecd>] alloc_pages_current+0xed/0x140
[ 3433.005415]  [<ffffffff811cd067>] __page_cache_alloc+0xc7/0xe0
[ 3433.005415]  [<ffffffff811ceb57>] filemap_fault+0x367/0x4d0
[ 3433.005415]  [<ffffffff811fb309>] __do_fault+0xa9/0x5a0
[ 3433.005415]  [<ffffffff81121968>] ? sched_clock_cpu+0x108/0x120
[ 3433.005415]  [<ffffffff811fbed1>] handle_pte_fault+0x81/0x1f0
[ 3433.005415]  [<ffffffff811fc369>] handle_mm_fault+0x329/0x350
[ 3433.005415]  [<ffffffff811f80f0>] ? follow_page+0x550/0x5a0
[ 3433.005415]  [<ffffffff811fc888>] __get_user_pages+0x438/0x5d0
[ 3433.005415]  [<ffffffff811fd976>] __mlock_vma_pages_range+0xc6/0xd0
[ 3433.005415]  [<ffffffff811fda81>] do_mlock_pages+0x101/0x180
[ 3433.005415]  [<ffffffff811fe1c8>] sys_mlockall+0x128/0x1a0
[ 3433.005415]  [<ffffffff8324a279>] system_call_fastpath+0x16/0x1b
[ 3433.005415] trinity-child2  R  running task     4032  5365   5830 0x00000004
[ 3433.005415]  ffff880027a0b718 0000000000000046 ffff880027a0b6b8 000000000000bf6f
[ 3433.005415]  ffff880027a0a000 ffff880027a0a010 ffff880027a0bfd8 ffff880027a0a000
[ 3433.005415]  ffff880027a0a010 ffff880027a0bfd8 ffff88000c80b000 ffff880023d90000
[ 3433.005415] Call Trace:
[ 3433.005415]  [<ffffffff83247651>] preempt_schedule+0x51/0x70
[ 3433.005415]  [<ffffffff832490d9>] _raw_spin_unlock+0x49/0x60
[ 3433.005415]  [<ffffffff8123bb76>] grab_super_passive+0x46/0x80
[ 3433.005415]  [<ffffffff8123bbf7>] prune_super+0x47/0x1b0
[ 3433.005415]  [<ffffffff811e4b30>] shrink_slab+0xd0/0x520
[ 3433.005415]  [<ffffffff811e5e19>] do_try_to_free_pages+0x1c9/0x3e0
[ 3433.005415]  [<ffffffff81150146>] ? mark_held_locks+0xf6/0x120
[ 3433.005415]  [<ffffffff811e6253>] try_to_free_pages+0x143/0x200
[ 3433.005415]  [<ffffffff811d40bb>] __perform_reclaim+0x8b/0xe0
[ 3433.005415]  [<ffffffff811d8967>] __alloc_pages_slowpath+0x407/0x6a0
[ 3433.005415]  [<ffffffff811d8305>] ? get_page_from_freelist+0x625/0x660
[ 3433.005415]  [<ffffffff811d8e46>] __alloc_pages_nodemask+0x246/0x330
[ 3433.005415]  [<ffffffff8121804f>] alloc_pages_vma+0x12f/0x140
[ 3433.005415]  [<ffffffff811fb2c1>] __do_fault+0x61/0x5a0
[ 3433.005415]  [<ffffffff81121968>] ? sched_clock_cpu+0x108/0x120
[ 3433.005415]  [<ffffffff8114b77a>] ? get_lock_stats+0x2a/0x60
[ 3433.005415]  [<ffffffff8114b7be>] ? put_lock_stats+0xe/0x40
[ 3433.005415]  [<ffffffff811fbed1>] handle_pte_fault+0x81/0x1f0
[ 3433.005415]  [<ffffffff811fc369>] handle_mm_fault+0x329/0x350
[ 3433.005415]  [<ffffffff811f80f0>] ? follow_page+0x550/0x5a0
[ 3433.005415]  [<ffffffff811fc888>] __get_user_pages+0x438/0x5d0
[ 3433.005415]  [<ffffffff811fd976>] __mlock_vma_pages_range+0xc6/0xd0
[ 3433.005415]  [<ffffffff811fda81>] do_mlock_pages+0x101/0x180
[ 3433.005415]  [<ffffffff811fe1c8>] sys_mlockall+0x128/0x1a0
[ 3433.005415]  [<ffffffff8324a279>] system_call_fastpath+0x16/0x1b
[ 3433.005415] trinity-child1  R  running task     3824  5367   5832 0x00000004
[ 3433.005415]  ffff880017189758 0000000000000046 ffff8800171896f8 0000000000000218
[ 3433.005415]  ffff880017188000 ffff880017188010 ffff880017189fd8 ffff880017188000
[ 3433.005415]  ffff880017188010 ffff880017189fd8 ffff88000c840000 ffff88001580b000
[ 3433.005415] Call Trace:
[ 3433.005415]  [<ffffffff83247651>] preempt_schedule+0x51/0x70
[ 3433.005415]  [<ffffffff832490d9>] _raw_spin_unlock+0x49/0x60
[ 3433.005415]  [<ffffffff8123bb76>] grab_super_passive+0x46/0x80
[ 3433.005415]  [<ffffffff8123bbf7>] prune_super+0x47/0x1b0
[ 3433.005415]  [<ffffffff811e4b30>] shrink_slab+0xd0/0x520
[ 3433.005415]  [<ffffffff811e4a30>] ? shrink_zones+0x1f0/0x220
[ 3433.005415]  [<ffffffff811e5e19>] do_try_to_free_pages+0x1c9/0x3e0
[ 3433.005415]  [<ffffffff832499b4>] ? retint_restore_args+0x13/0x13
[ 3433.005415]  [<ffffffff811e6253>] try_to_free_pages+0x143/0x200
[ 3433.005415]  [<ffffffff811d40bb>] __perform_reclaim+0x8b/0xe0
[ 3433.005415]  [<ffffffff811d8967>] __alloc_pages_slowpath+0x407/0x6a0
[ 3433.005415]  [<ffffffff811d8305>] ? get_page_from_freelist+0x625/0x660
[ 3433.005415]  [<ffffffff811d8e46>] __alloc_pages_nodemask+0x246/0x330
[ 3433.005415]  [<ffffffff8121804f>] alloc_pages_vma+0x12f/0x140
[ 3433.005415]  [<ffffffff811f701b>] do_anonymous_page+0x17b/0x310
[ 3433.005415]  [<ffffffff81151adc>] ? __lock_acquire+0x43c/0x4c0
[ 3433.005415]  [<ffffffff811fbef4>] handle_pte_fault+0xa4/0x1f0
[ 3433.005415]  [<ffffffff811fc369>] handle_mm_fault+0x329/0x350
[ 3433.005415]  [<ffffffff810a2051>] do_page_fault+0x421/0x450
[ 3433.005415]  [<ffffffff8114b77a>] ? get_lock_stats+0x2a/0x60
[ 3433.005415]  [<ffffffff8114b7be>] ? put_lock_stats+0xe/0x40
[ 3433.005415]  [<ffffffff81201177>] ? sys_brk+0x147/0x160
[ 3433.005415]  [<ffffffff81152212>] ? __lock_release+0x1c2/0x1e0
[ 3433.005415]  [<ffffffff81201177>] ? sys_brk+0x147/0x160
[ 3433.005415]  [<ffffffff8109a1d1>] do_async_page_fault+0x31/0xb0
[ 3433.005415]  [<ffffffff83249c95>] async_page_fault+0x25/0x30
[ 3433.005415] trinity-child3  R  running task     3824  5368   5826 0x00000004
[ 3433.005415]  ffff880027a09668 0000000000000046 ffff880027a09608 00000000000114d2
[ 3433.005415]  ffff880027a08000 ffff880027a08010 ffff880027a09fd8 ffff880027a08000
[ 3433.005415]  ffff880027a08010 ffff880027a09fd8 ffff88000c81b000 ffff880023d58000
[ 3433.005415] Call Trace:
[ 3433.005415]  [<ffffffff83247651>] preempt_schedule+0x51/0x70
[ 3433.005415]  [<ffffffff832490d9>] _raw_spin_unlock+0x49/0x60
[ 3433.005415]  [<ffffffff8123b9cc>] put_super+0x2c/0x40
[ 3433.005415]  [<ffffffff8123bb1d>] drop_super+0x1d/0x30
[ 3433.005415]  [<ffffffff8123bd1b>] prune_super+0x16b/0x1b0
[ 3433.005415]  [<ffffffff811e4b30>] shrink_slab+0xd0/0x520
[ 3433.005415]  [<ffffffff811e5e19>] do_try_to_free_pages+0x1c9/0x3e0
[ 3433.005415]  [<ffffffff811e6253>] try_to_free_pages+0x143/0x200
[ 3433.005415]  [<ffffffff811d40bb>] __perform_reclaim+0x8b/0xe0
[ 3433.005415]  [<ffffffff811d8967>] __alloc_pages_slowpath+0x407/0x6a0
[ 3433.005415]  [<ffffffff811d8305>] ? get_page_from_freelist+0x625/0x660
[ 3433.005415]  [<ffffffff811d8e46>] __alloc_pages_nodemask+0x246/0x330
[ 3433.005415]  [<ffffffff81217ecd>] alloc_pages_current+0xed/0x140
[ 3433.005415]  [<ffffffff811cd067>] __page_cache_alloc+0xc7/0xe0
[ 3433.005415]  [<ffffffff811ceb57>] filemap_fault+0x367/0x4d0
[ 3433.005415]  [<ffffffff811fb309>] __do_fault+0xa9/0x5a0
[ 3433.005415]  [<ffffffff811fbed1>] handle_pte_fault+0x81/0x1f0
[ 3433.005415]  [<ffffffff811fc369>] handle_mm_fault+0x329/0x350
[ 3433.005415]  [<ffffffff810a2051>] do_page_fault+0x421/0x450
[ 3433.005415]  [<ffffffff811f5b4e>] ? might_fault+0x4e/0xa0
[ 3433.005415]  [<ffffffff811f5b4e>] ? might_fault+0x4e/0xa0
[ 3433.005415]  [<ffffffff81152212>] ? __lock_release+0x1c2/0x1e0
[ 3433.005415]  [<ffffffff811f5b4e>] ? might_fault+0x4e/0xa0
[ 3433.005415]  [<ffffffff8109a1d1>] do_async_page_fault+0x31/0xb0
[ 3433.005415]  [<ffffffff83249c95>] async_page_fault+0x25/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
