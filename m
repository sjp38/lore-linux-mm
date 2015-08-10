Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E91616B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:37:58 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so57969975qkd.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 06:37:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 194si12960213qhw.118.2015.08.10.06.37.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 06:37:57 -0700 (PDT)
Message-ID: <55C8A902.4080207@oracle.com>
Date: Mon, 10 Aug 2015 09:37:06 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: use after free and panic in free_pages_and_swap_cache
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running -next I've stumbled on the following:

[486475.535183] ==================================================================
[486475.536099] BUG: KASan: use after free in tlb_flush_mmu_free+0xfe/0x120 at addr ffff8803c3a62008
[486475.537936] Read of size 4 by task trinity-c218/7429
[486475.538464] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.539252] flags: 0x22fffff80000000()
[486475.539735] page dumped because: kasan: bad access detected
[486475.540313] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.541464]  ffff880406b27910 ffff880406b277c0 ffffffffa1e89e54 ffff880406b27848
[486475.542260]  ffff880406b27838 ffffffff9877299e ffffffff983b359d ffff880406b277f0
[486475.543146]  0000000000000282 ffff880406b27800 ffffffff983b359d 0000000000000001
[486475.543994] Call Trace:
[486475.544260] dump_stack (lib/dump_stack.c:52)
[486475.544841] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.545445] ? get_parent_ip (kernel/sched/core.c:2796)
[486475.545983] ? get_parent_ip (kernel/sched/core.c:2796)
[486475.546520] __asan_report_load4_noabort (mm/kasan/report.c:250)
[486475.547163] ? tlb_flush_mmu_free (mm/memory.c:254)
[486475.547760] tlb_flush_mmu_free (mm/memory.c:254)
[486475.548335] tlb_finish_mmu (mm/memory.c:280)
[486475.548873] exit_mmap (mm/mmap.c:2865)
[486475.549386] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.550007] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.550613] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.551215] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.551688] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.552194] ? mm_update_next_owner (kernel/exit.c:654)
[486475.552811] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.553348] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.553973] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.555012] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.555884] get_signal (kernel/signal.c:2353)
[486475.556693] do_signal (arch/x86/kernel/signal.c:711)
[486475.557521] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.558443] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.559266] ? vfs_write (fs/read_write.c:777)
[486475.559996] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.560929] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.561961] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.562647] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.563385] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.564207] ? do_setitimer (kernel/time/itimer.c:239)
[486475.564977] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.565909] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.566886] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.567791] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.568763] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.569557] Memory state around the buggy address:
[486475.570069]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.571142]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.572127] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.573188]                       ^
[486475.573641]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.574584]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.575524] ==================================================================
[486475.577906] FAULT_INJECTION: forcing a failure.
[486475.577906] name failslab, interval 50, probability 30, space 0, times -1
[486475.593541] ==================================================================
[486475.595556] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62010
[486475.596984] Read of size 8 by task trinity-c218/7429
[486475.597908] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.599883] flags: 0x22fffff80000000()
[486475.600674] page dumped because: kasan: bad access detected
[486475.601859] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.603504]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486475.604831]  ffff880406b277f0 ffffffff9877299e ffffffff9869c496 ffffed005803b45c
[486475.606150]  0000000000000282 ffffffff98696fe0 ffffffffa1f110e2 ffff8803df648000
[486475.607404] Call Trace:
[486475.607824] dump_stack (lib/dump_stack.c:52)
[486475.608689] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.609709] ? pagevec_lru_move_fn (include/linux/pagevec.h:44 mm/swap.c:445)
[486475.610696] ? trace_event_raw_event_mm_lru_activate (mm/swap.c:1079)
[486475.611952] ? _raw_spin_unlock_irqrestore (kernel/locking/spinlock.c:192)
[486475.613072] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486475.614177] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.615431] free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.616748] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486475.617722] tlb_finish_mmu (mm/memory.c:280)
[486475.618691] exit_mmap (mm/mmap.c:2865)
[486475.619527] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.620734] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.621666] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.622698] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.623453] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.624312] ? mm_update_next_owner (kernel/exit.c:654)
[486475.625379] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.626305] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.627285] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.627835] FAULT_INJECTION: forcing a failure.
[486475.627835] name failslab, interval 50, probability 30, space 0, times -1
[486475.631698] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.633017] get_signal (kernel/signal.c:2353)
[486475.633997] do_signal (arch/x86/kernel/signal.c:711)
[486475.635136] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.636766] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.637879] ? vfs_write (fs/read_write.c:777)
[486475.638895] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.640246] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.641623] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.642807] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.644075] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.645137] ? do_setitimer (kernel/time/itimer.c:239)
[486475.646019] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.647120] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.648157] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.649274] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.650319] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.651264] Memory state around the buggy address:
[486475.652239]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.653704]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.655116] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.656311]                          ^
[486475.656924]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.658088]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.659196] ==================================================================
[486475.668686] ==================================================================
[486475.669882] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62018
[486475.671308] Read of size 8 by task trinity-c218/7429
[486475.672128] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.673375] flags: 0x22fffff80000000()
[486475.673990] page dumped because: kasan: bad access detected
[486475.674886] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.677047]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486475.679387]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486475.681127]  0000000000000282 ffffed007874c402 66666620a1f110e2 6133633330383866
[486475.682449] Call Trace:
[486475.682861] dump_stack (lib/dump_stack.c:52)
[486475.683705] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.684777] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486475.685891] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.687061] free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.688187] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486475.689365] tlb_finish_mmu (mm/memory.c:280)
[486475.690840] exit_mmap (mm/mmap.c:2865)
[486475.692441] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.694383] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.695780] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.697056] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.698196] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.699207] ? mm_update_next_owner (kernel/exit.c:654)
[486475.700338] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.701425] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.702443] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.703981] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.704927] get_signal (kernel/signal.c:2353)
[486475.705772] do_signal (arch/x86/kernel/signal.c:711)
[486475.706595] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.707526] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.708573] ? vfs_write (fs/read_write.c:777)
[486475.709447] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.710396] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.711624] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.712758] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.713820] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.714861] ? do_setitimer (kernel/time/itimer.c:239)
[486475.715756] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.716865] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.717950] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.719043] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.720035] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.721041] Memory state around the buggy address:
[486475.721834]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.722992]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.724134] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.725355]                             ^
[486475.726013]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.727099]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.728210] ==================================================================
[486475.733496] ==================================================================
[486475.734654] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62020
[486475.736177] Read of size 8 by task trinity-c218/7429
[486475.737202] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.738476] flags: 0x22fffff80000000()
[486475.739099] page dumped because: kasan: bad access detected
[486475.739962] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.741643]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486475.742972]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486475.744189]  0000000000000282 ffffed007874c403 66666620a1f110e2 6133633330383866
[486475.745517] Call Trace:
[486475.746007] dump_stack (lib/dump_stack.c:52)
[486475.746983] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.747993] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486475.749025] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.750069] free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.751095] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486475.752073] tlb_finish_mmu (mm/memory.c:280)
[486475.752912] exit_mmap (mm/mmap.c:2865)
[486475.753715] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.754651] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.755597] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.756549] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.757341] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.758386] ? mm_update_next_owner (kernel/exit.c:654)
[486475.760300] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.761970] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.763699] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.766164] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.767847] get_signal (kernel/signal.c:2353)
[486475.769393] do_signal (arch/x86/kernel/signal.c:711)
[486475.770306] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.771871] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.773646] ? vfs_write (fs/read_write.c:777)
[486475.775339] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.777103] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.779505] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.780654] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.781692] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.783407] ? do_setitimer (kernel/time/itimer.c:239)
[486475.784644] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.785975] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.786978] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.787924] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.791314] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.792442] Memory state around the buggy address:
[486475.793276]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.794359]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.795569] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.797329]                                ^
[486475.798181]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.799900]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.801651] ==================================================================
[486475.803572] ==================================================================
[486475.804801] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62028
[486475.806866] Read of size 8 by task trinity-c218/7429
[486475.808305] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.810323] flags: 0x22fffff80000000()
[486475.811276] page dumped because: kasan: bad access detected
[486475.812678] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.814973]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486475.816527]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486475.818088]  0000000000000282 ffffed007874c404 66666620a1f110e2 6133633330383866
[486475.819606] Call Trace:
[486475.820044] dump_stack (lib/dump_stack.c:52)
[486475.820866] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.821880] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486475.822434] audit: type=1326 audit(7.030:417): auid=4294967295 uid=3067829327 gid=2901925822 ses=4294967295 pid=11247 comm="trinity-c84" exe="/trinity/trinity" sig=9 arch=c000003e syscall=231 compat=0 ip=0x7fbd70916818 code=0x0
[486475.826094] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.826948] free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.827780] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486475.828526] tlb_finish_mmu (mm/memory.c:280)
[486475.829215] exit_mmap (mm/mmap.c:2865)
[486475.829875] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.830672] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.831439] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.832209] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.832822] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.833525] ? mm_update_next_owner (kernel/exit.c:654)
[486475.834364] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.835497] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.836363] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.837666] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.838518] get_signal (kernel/signal.c:2353)
[486475.839527] do_signal (arch/x86/kernel/signal.c:711)
[486475.839970] FAULT_INJECTION: forcing a failure.
[486475.839970] name failslab, interval 50, probability 30, space 0, times -1
[486475.842025] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.842882] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.844128] ? vfs_write (fs/read_write.c:777)
[486475.845446] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.846838] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.848693] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.850230] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.851665] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.853097] ? do_setitimer (kernel/time/itimer.c:239)
[486475.854420] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.855637] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.856720] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.857863] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.858953] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.859945] Memory state around the buggy address:
[486475.860863]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.862096]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.863217] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.864440]                                   ^
[486475.865861]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.867322]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.868396] ==================================================================
[486475.888839] ==================================================================
[486475.889830] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62030
[486475.891008] Read of size 8 by task trinity-c218/7429
[486475.891674] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486475.892688] flags: 0x22fffff80000000()
[486475.893198] page dumped because: kasan: bad access detected
[486475.893921] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486475.895402]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486475.896764]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486475.898202]  0000000000000282 ffffed007874c405 66666620a1f110e2 6133633330383866
[486475.899592] Call Trace:
[486475.899995] dump_stack (lib/dump_stack.c:52)
[486475.900872] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486475.901785] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486475.902957] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.904447] free_pages_and_swap_cache (mm/swap_state.c:265)
[486475.905525] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486475.906393] tlb_finish_mmu (mm/memory.c:280)
[486475.907230] exit_mmap (mm/mmap.c:2865)
[486475.908024] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486475.909159] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.910303] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486475.911281] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486475.912089] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486475.912895] ? mm_update_next_owner (kernel/exit.c:654)
[486475.913848] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486475.914782] ? lock_release (kernel/locking/lockdep.c:3644)
[486475.915784] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.917287] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486475.918263] get_signal (kernel/signal.c:2353)
[486475.919085] do_signal (arch/x86/kernel/signal.c:711)
[486475.920007] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486475.920952] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486475.921840] ? vfs_write (fs/read_write.c:777)
[486475.922567] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486475.923469] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486475.924591] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.925726] ? preempt_count_sub (kernel/sched/core.c:2852)
[486475.926693] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486475.927802] ? do_setitimer (kernel/time/itimer.c:239)
[486475.928899] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486475.929963] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486475.930968] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486475.931985] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486475.932932] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486475.933931] Memory state around the buggy address:
[486475.934767]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.935851]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.936993] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.938216]                                      ^
[486475.938956]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.940053]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486475.941165] ==================================================================
[486475.997632] ==================================================================
[486475.998924] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62038
[486476.000443] Read of size 8 by task trinity-c218/7429
[486476.001768] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.003032] flags: 0x22fffff80000000()
[486476.003865] page dumped because: kasan: bad access detected
[486476.004848] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.006915]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.008185]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.009382]  0000000000000282 ffffed007874c406 66666620a1f110e2 6133633330383866
[486476.010634] Call Trace:
[486476.011041] dump_stack (lib/dump_stack.c:52)
[486476.011845] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.012950] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.014037] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.015505] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.016547] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.017599] tlb_finish_mmu (mm/memory.c:280)
[486476.018684] exit_mmap (mm/mmap.c:2865)
[486476.019559] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.020689] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.021683] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.022504] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.023122] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.023832] ? mm_update_next_owner (kernel/exit.c:654)
[486476.024692] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.025394] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.026121] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.027113] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.027810] get_signal (kernel/signal.c:2353)
[486476.028499] do_signal (arch/x86/kernel/signal.c:711)
[486476.029163] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.029909] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.030698] ? vfs_write (fs/read_write.c:777)
[486476.031384] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.032140] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.033140] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.034168] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.034968] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.035948] ? do_setitimer (kernel/time/itimer.c:239)
[486476.036732] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.037625] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.038501] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.039347] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.040226] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.041030] Memory state around the buggy address:
[486476.041682]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.042612]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.043503] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.044476]                                         ^
[486476.045313]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.046515]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.047576] ==================================================================
[486476.104666] ==================================================================
[486476.105798] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62040
[486476.107316] Read of size 8 by task trinity-c218/7429
[486476.108230] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.109479] flags: 0x22fffff80000000()
[486476.110165] page dumped because: kasan: bad access detected
[486476.110961] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.112354]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.113519]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.114576]  0000000000000282 ffffed007874c407 66666620a1f110e2 6133633330383866
[486476.115959] Call Trace:
[486476.116423] dump_stack (lib/dump_stack.c:52)
[486476.117306] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.118525] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.119547] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.120635] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.121807] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.122759] tlb_finish_mmu (mm/memory.c:280)
[486476.123803] exit_mmap (mm/mmap.c:2865)
[486476.124622] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.125444] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.126216] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.126988] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.127614] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.128334] ? mm_update_next_owner (kernel/exit.c:654)
[486476.129177] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.129972] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.130748] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.131793] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.132511] get_signal (kernel/signal.c:2353)
[486476.133202] do_signal (arch/x86/kernel/signal.c:711)
[486476.133899] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.134906] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.136216] ? vfs_write (fs/read_write.c:777)
[486476.137225] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.138227] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.139509] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.140549] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.141684] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.142674] ? do_setitimer (kernel/time/itimer.c:239)
[486476.143767] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.144835] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.146086] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.147129] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.148132] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.149031] Memory state around the buggy address:
[486476.149755]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.150806]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.151864] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.152954]                                            ^
[486476.153826]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.155014]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.156254] ==================================================================
[486476.215515] ==================================================================
[486476.217578] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62048
[486476.220360] Read of size 8 by task trinity-c218/7429
[486476.221560] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.223076] flags: 0x22fffff80000000()
[486476.224067] page dumped because: kasan: bad access detected
[486476.225064] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.226393]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.227400]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.228430]  0000000000000282 ffffed007874c408 66666620a1f110e2 6133633330383866
[486476.229433] Call Trace:
[486476.229839] dump_stack (lib/dump_stack.c:52)
[486476.230525] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.231312] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.232154] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.233019] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.234040] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.234814] tlb_finish_mmu (mm/memory.c:280)
[486476.235294] exit_mmap (mm/mmap.c:2865)
[486476.235745] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.236280] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.236804] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.237634] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.238173] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.238836] ? mm_update_next_owner (kernel/exit.c:654)
[486476.239666] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.240427] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.241243] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.242133] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.242730] get_signal (kernel/signal.c:2353)
[486476.243393] do_signal (arch/x86/kernel/signal.c:711)
[486476.243959] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.244627] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.245315] ? vfs_write (fs/read_write.c:777)
[486476.245902] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.246548] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.247395] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.248000] FAULT_INJECTION: forcing a failure.
[486476.248000] name failslab, interval 50, probability 30, space 0, times -1
[486476.249267] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.249924] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.250583] ? do_setitimer (kernel/time/itimer.c:239)
[486476.251190] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.251901] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.252596] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.253284] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.253966] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.254637] Memory state around the buggy address:
[486476.255156]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.255934]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.256693] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.257450]                                               ^
[486476.258044]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.258803]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.259562] ==================================================================
[486476.261376] ==================================================================
[486476.262308] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62050
[486476.263540] Read of size 8 by task trinity-c218/7429
[486476.264189] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.265569] flags: 0x22fffff80000000()
[486476.266095] page dumped because: kasan: bad access detected
[486476.266834] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.267813]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54[486476.268552] FAULT_INJECTION: forcing a failure.
[486476.268552] name failslab, interval 50, probability 30, space 0, times -1

[486476.269940]  ffff880406b27800
[486476.270439]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.271528]  0000000000000282 ffffed007874c409 66666620a1f110e2 6133633330383866
[486476.272569] Call Trace:
[486476.272912] dump_stack (lib/dump_stack.c:52)
[486476.273559] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.274356] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.275180] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.275936] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.276684] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.277346] tlb_finish_mmu (mm/memory.c:280)
[486476.277961] exit_mmap (mm/mmap.c:2865)
[486476.278549] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.279259] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.279940] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.280619] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.281160] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.281742] ? mm_update_next_owner (kernel/exit.c:654)
[486476.282451] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.283064] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.283707] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.284615] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.285228] get_signal (kernel/signal.c:2353)
[486476.285842] do_signal (arch/x86/kernel/signal.c:711)
[486476.286433] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.287099] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.287789] ? vfs_write (fs/read_write.c:777)
[486476.288390] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.289056] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.289935] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.290657] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.291332] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.292016] ? do_setitimer (kernel/time/itimer.c:239)
[486476.292643] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.293382] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.294101] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.294831] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.295544] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.296220] Memory state around the buggy address:
[486476.296759]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.297554]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.298349] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.299145]                                                  ^
[486476.299796]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.300591]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.301384] ==================================================================
[486476.302475] ==================================================================
[486476.303278] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62058
[486476.304301] Read of size 8 by task trinity-c218/7429
[486476.304889] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.305387] FAULT_INJECTION: forcing a failure.
[486476.305387] name failslab, interval 50, probability 30, space 0, times -1
[486476.306956] flags: 0x22fffff80000000()
[486476.307394] page dumped because: kasan: bad access detected
[486476.308005] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.309122]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.310005]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.310890]  0000000000000282 ffffed007874c40a 66666620a1f110e2 6133633330383866
[486476.311774] Call Trace:
[486476.312068] dump_stack (lib/dump_stack.c:52)
[486476.312634] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.313286] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.313826] FAULT_INJECTION: forcing a failure.
[486476.313826] name failslab, interval 50, probability 30, space 0, times -1
[486476.315293] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.316040] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.316764] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.317414] tlb_finish_mmu (mm/memory.c:280)
[486476.318019] exit_mmap (mm/mmap.c:2865)
[486476.318599] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.319299] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.319973] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.320646] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.321182] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.321755] ? mm_update_next_owner (kernel/exit.c:654)
[486476.322454] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.323063] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.323700] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.324581] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.325209] get_signal (kernel/signal.c:2353)
[486476.325785] do_signal (arch/x86/kernel/signal.c:711)
[486476.326232] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.326823] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.327355] ? vfs_write (fs/read_write.c:777)
[486476.327817] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.328325] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.328995] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.329546] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.330145] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.330670] ? do_setitimer (kernel/time/itimer.c:239)
[486476.331150] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.331712] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.332340] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.332916] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.333506] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.334233] Memory state around the buggy address:
[486476.334836]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.335530]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.336148] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.336802]                                                     ^
[486476.337336]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.337969]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.338574] ==================================================================
[486476.339259] ==================================================================
[486476.339866] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62060
[486476.340638] Read of size 8 by task trinity-c218/7429
[486476.341055] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.341795] flags: 0x22fffff80000000()
[486476.342132] page dumped because: kasan: bad access detected
[486476.342598] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.343473]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.344144]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.344858]  0000000000000282 ffffed007874c40b 66666620a1f110e2 6133633330383866
[486476.345533] Call Trace:
[486476.345757] dump_stack (lib/dump_stack.c:52)
[486476.346256] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.346869] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.347419] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.348051] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.348885] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.349597] tlb_finish_mmu (mm/memory.c:280)
[486476.350318] exit_mmap (mm/mmap.c:2865)
[486476.351035] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.351889] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.352708] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.353520] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.354174] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.354686] FAULT_INJECTION: forcing a failure.
[486476.354686] name failslab, interval 50, probability 30, space 0, times -1
[486476.356376] ? mm_update_next_owner (kernel/exit.c:654)
[486476.357234] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.357976] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.358755] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.359820] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.360570] get_signal (kernel/signal.c:2353)
[486476.361303] do_signal (arch/x86/kernel/signal.c:711)
[486476.362014] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.362811] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.363649] ? vfs_write (fs/read_write.c:777)
[486476.364373] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.365193] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.366242] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.367115] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.367877] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.368787] ? do_setitimer (kernel/time/itimer.c:239)
[486476.369541] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.370432] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.371234] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.372071] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.372932] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.373747] Memory state around the buggy address:
[486476.374393]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.375371]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.376265] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.377032]                                                        ^
[486476.377820]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.378760]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.379642] ==================================================================
[486476.380553] ==================================================================
[486476.381406] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62068
[486476.382186] Read of size 8 by task trinity-c218/7429
[486476.382613] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.383350] flags: 0x22fffff80000000()
[486476.383691] page dumped because: kasan: bad access detected
[486476.384159] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.385175]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.386157]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.387069]  0000000000000282 ffffed007874c40c 66666620a1f110e2 6133633330383866
[486476.388073] Call Trace:
[486476.388329] FAULT_INJECTION: forcing a failure.
[486476.388329] name failslab, interval 50, probability 30, space 0, times -1
[486476.389770] dump_stack (lib/dump_stack.c:52)
[486476.390478] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.391242] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.392123] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.393029] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.393908] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.394831] tlb_finish_mmu (mm/memory.c:280)
[486476.395566] exit_mmap (mm/mmap.c:2865)
[486476.396225] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.397071] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.397857] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.398670] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.399321] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.400017] ? mm_update_next_owner (kernel/exit.c:654)
[486476.400886] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.401629] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.402398] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.403681] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.404364] get_signal (kernel/signal.c:2353)
[486476.405238] do_signal (arch/x86/kernel/signal.c:711)
[486476.406040] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.406300] FAULT_INJECTION: forcing a failure.
[486476.406300] name failslab, interval 50, probability 30, space 0, times -1
[486476.408278] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.409060] ? vfs_write (fs/read_write.c:777)
[486476.409985] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.410741] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.411978] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.412800] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.413553] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.413727] FAULT_INJECTION: forcing a failure.
[486476.413727] name failslab, interval 50, probability 30, space 0, times -1
[486476.416007] ? do_setitimer (kernel/time/itimer.c:239)
[486476.416658] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.417521] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.418372] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.419207] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.420020] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.420783] Memory state around the buggy address:
[486476.421386]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.422271]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.423162] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.423442] FAULT_INJECTION: forcing a failure.
[486476.423442] name failslab, interval 50, probability 30, space 0, times -1
[486476.425568]                                                           ^
[486476.426400]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.427309]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.428173] ==================================================================
[486476.428311] FAULT_INJECTION: forcing a failure.
[486476.428311] name failslab, interval 50, probability 30, space 0, times -1
[486476.430647] ==================================================================
[486476.431581] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62070
[486476.432796] Read of size 8 by task trinity-c218/7429
[486476.433450] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.434519] flags: 0x22fffff80000000()
[486476.435056] page dumped because: kasan: bad access detected
[486476.435809] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.437152]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.438222]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.439295]  0000000000000282 ffffed007874c40d 66666620a1f110e2 6133633330383866
[486476.440374] Call Trace:
[486476.440733] dump_stack (lib/dump_stack.c:52)
[486476.441438] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.442233] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.443067] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.444024] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.445027] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.445822] tlb_finish_mmu (mm/memory.c:280)
[486476.446624] exit_mmap (mm/mmap.c:2865)
[486476.447267] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.448090] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.448906] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.449712] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.450331] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.451018] ? mm_update_next_owner (kernel/exit.c:654)
[486476.451858] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.452589] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.453355] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.454405] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.455173] get_signal (kernel/signal.c:2353)
[486476.455894] do_signal (arch/x86/kernel/signal.c:711)
[486476.456588] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.457379] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.458182] ? vfs_write (fs/read_write.c:777)
[486476.458948] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.459836] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.461001] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.462059] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.463068] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.463932] ? do_setitimer (kernel/time/itimer.c:239)
[486476.464753] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.465632] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.466503] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.467370] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.468222] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.469029] Memory state around the buggy address:
[486476.469675]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.470615]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.471557] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.472496]                                                              ^
[486476.473398]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.474336]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.475301] ==================================================================
[486476.477819] ==================================================================
[486476.478757] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62078
[486476.480002] Read of size 8 by task trinity-c218/7429
[486476.480662] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.481719] flags: 0x22fffff80000000()
[486476.482263] page dumped because: kasan: bad access detected
[486476.483013] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.484373]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.485508]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.486598]  0000000000000282 ffffed007874c40e 66666620a1f110e2 6133633330383866
[486476.487700] Call Trace:
[486476.488056] dump_stack (lib/dump_stack.c:52)
[486476.488768] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.489577] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.490441] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.491357] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.492232] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.493032] tlb_finish_mmu (mm/memory.c:280)
[486476.493775] exit_mmap (mm/mmap.c:2865)
[486476.494496] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.495344] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.496168] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.497003] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.497654] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.498353] ? mm_update_next_owner (kernel/exit.c:654)
[486476.499223] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.499973] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.500432] FAULT_INJECTION: forcing a failure.
[486476.500432] name failslab, interval 50, probability 30, space 0, times -1
[486476.502250] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.503310] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.504142] get_signal (kernel/signal.c:2353)
[486476.504966] do_signal (arch/x86/kernel/signal.c:711)
[486476.505733] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.506615] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.507564] ? vfs_write (fs/read_write.c:777)
[486476.508300] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.509062] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.510136] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.510987] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.511789] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.512628] ? do_setitimer (kernel/time/itimer.c:239)
[486476.513377] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.514243] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.515202] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.516024] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.516883] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.517695] Memory state around the buggy address:
[486476.518346]  ffff8803c3a61f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.519279]  ffff8803c3a61f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.520213] >ffff8803c3a62000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.521162]                                                                 ^
[486476.522104]  ffff8803c3a62080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.523063]  ffff8803c3a62100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[486476.524007] ==================================================================
[486476.525088] ==================================================================
[486476.526040] BUG: KASan: use after free in free_pages_and_swap_cache+0x17d/0x1a0 at addr ffff8803c3a62080
[486476.527275] Read of size 8 by task trinity-c218/7429
[486476.527971] page:ffffea000f0e9880 count:1 mapcount:0 mapping:          (null) index:0x0
[486476.529029] flags: 0x22fffff80000000()
[486476.529571] page dumped because: kasan: bad access detected
[486476.530325] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.531715]  dffffc0000000000 ffff880406b27778 ffffffffa1e89e54 ffff880406b27800
[486476.532804]  ffff880406b277f0 ffffffff9877299e 0000000000000010 ffffed0000000000
[486476.533888]  0000000000000282 ffffed007874c40f 66666620a1f110e2 6133633330383866
[486476.534984] Call Trace:
[486476.535344] dump_stack (lib/dump_stack.c:52)
[486476.536024] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[486476.536836] __asan_report_load8_noabort (mm/kasan/report.c:251)
[486476.537728] ? free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.538649] free_pages_and_swap_cache (mm/swap_state.c:265)
[486476.539544] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.540335] tlb_finish_mmu (mm/memory.c:280)
[486476.541068] exit_mmap (mm/mmap.c:2865)
[486476.541764] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.542620] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.543381] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.544204] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.544819] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.545450] ? mm_update_next_owner (kernel/exit.c:654)
[486476.546200] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.546854] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.547538] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.548475] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.549138] get_signal (kernel/signal.c:2353)
[486476.549791] do_signal (arch/x86/kernel/signal.c:711)
[486476.550596] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.551550] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.552298] ? vfs_write (fs/read_write.c:777)
[486476.552954] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.553790] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.554876] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.555749] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.556567] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.557390] ? do_setitimer (kernel/time/itimer.c:239)
[486476.558147] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.559037] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.559914] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.560400] FAULT_INJECTION: forcing a failure.
[486476.560400] name failslab, interval 50, probability 30, space 0, times -1
[486476.562266] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.563123] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.563936] Memory state around the buggy address:
[486476.564605]  ffff8803c3a61f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[486476.565556]  ffff8803c3a62000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[486476.566494] >ffff8803c3a62080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[486476.567459]                    ^
[486476.567901]  ffff8803c3a62100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[486476.568839]  ffff8803c3a62180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[486476.569771] ==================================================================
[486476.570789] kasan: CONFIG_KASAN_INLINE enabled
[486476.571371] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[486476.573697] Dumping ftrace buffer:
[486476.574537]    (ftrace buffer empty)
[486476.575185] Modules linked in:
[486476.575715] CPU: 5 PID: 7429 Comm: trinity-c218 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2418
[486476.577310] task: ffff8803df648000 ti: ffff880406b20000 task.ti: ffff880406b20000
[486476.578449] RIP: free_pages_and_swap_cache (./arch/x86/include/asm/bitops.h:311 (discriminator 3) include/linux/page-flags.h:337 (discriminator 3) mm/swap_state.c:238 (discriminator 3) mm/swap_state.c:265 (discriminator 3))
[486476.579870] RSP: 0018:ffff880406b27838  EFLAGS: 00010246
[486476.580693] RAX: 0000000000000000 RBX: ffff8803c3a624e8 RCX: 0000000000000000
[486476.581792] RDX: ffff8803c3a63000 RSI: ffffffff987728fb RDI: ffffffffa1f110cb
[486476.582897] RBP: ffff880406b27870 R08: 0000000000000001 R09: 0000000000000000
[486476.583967] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[486476.585112] R13: dffffc0000000000 R14: ffff8803c3a62010 R15: 00000000000001fe
[486476.585651] FAULT_INJECTION: forcing a failure.
[486476.585651] name failslab, interval 50, probability 30, space 0, times -1
[486476.587904] FS:  00007fbd70df9700(0000) GS:ffff8802c0000000(0000) knlGS:0000000000000000
[486476.589034] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[486476.589954] CR2: 00007fbd6fdf4220 CR3: 0000000692c7b000 CR4: 00000000000006a0
[486476.591058] Stack:
[486476.591434]  ffff880406b27870 ffff8803c3a63000 ffff8803c3a62000 dffffc0000000000
[486476.592757]  ffff880406b27910 ffff880406b27938 ffff8803c3a62008 ffff880406b278a8
[486476.594117]  ffffffff986e673a ffff880406b27910 1ffff10080d64f1e dffffc0000000000
[486476.595427] Call Trace:
[486476.595866] tlb_flush_mmu_free (mm/memory.c:256 (discriminator 4))
[486476.596811] tlb_finish_mmu (mm/memory.c:280)
[486476.597603] exit_mmap (mm/mmap.c:2865)
[486476.598227] ? SyS_remap_file_pages (mm/mmap.c:2827)
[486476.598955] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.599752] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2563 mm/huge_memory.c:2204)
[486476.600723] mmput (include/linux/compiler.h:207 kernel/fork.c:737 kernel/fork.c:704)
[486476.601545] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[486476.602405] ? mm_update_next_owner (kernel/exit.c:654)
[486476.603424] ? lockdep_init (kernel/locking/lockdep.c:3298)
[486476.604311] ? lock_release (kernel/locking/lockdep.c:3644)
[486476.605201] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.606412] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[486476.607306] get_signal (kernel/signal.c:2353)
[486476.608111] do_signal (arch/x86/kernel/signal.c:711)
[486476.608752] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[486476.609665] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[486476.610691] ? vfs_write (fs/read_write.c:777)
[486476.611596] ? setup_sigcontext (arch/x86/kernel/signal.c:708)
[486476.612622] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[486476.613949] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.615163] ? preempt_count_sub (kernel/sched/core.c:2852)
[486476.616169] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[486476.617220] ? do_setitimer (kernel/time/itimer.c:239)
[486476.618140] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[486476.619229] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[486476.620290] prepare_exit_to_usermode (arch/x86/entry/common.c:282)
[486476.621439] syscall_return_slowpath (arch/x86/entry/common.c:349)
[486476.622363] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[486476.623369] Code: eb 0d 48 83 c3 08 48 39 d3 0f 84 9d 00 00 00 48 89 d8 48 c1 e8 03 42 80 3c 28 00 0f 85 10 01 00 00 4c 8b 23 4c 89 e0 48 c1 e8 03 <42> 80 3c 28 00 0f 85 e6 00 00 00 49 8b 04 24 a9 00 00 01 00 74
All code
========
   0:	eb 0d                	jmp    0xf
   2:	48 83 c3 08          	add    $0x8,%rbx
   6:	48 39 d3             	cmp    %rdx,%rbx
   9:	0f 84 9d 00 00 00    	je     0xac
   f:	48 89 d8             	mov    %rbx,%rax
  12:	48 c1 e8 03          	shr    $0x3,%rax
  16:	42 80 3c 28 00       	cmpb   $0x0,(%rax,%r13,1)
  1b:	0f 85 10 01 00 00    	jne    0x131
  21:	4c 8b 23             	mov    (%rbx),%r12
  24:	4c 89 e0             	mov    %r12,%rax
  27:	48 c1 e8 03          	shr    $0x3,%rax
  2b:*	42 80 3c 28 00       	cmpb   $0x0,(%rax,%r13,1)		<-- trapping instruction
  30:	0f 85 e6 00 00 00    	jne    0x11c
  36:	49 8b 04 24          	mov    (%r12),%rax
  3a:	a9 00 00 01 00       	test   $0x10000,%eax
  3f:	74 00                	je     0x41

Code starting with the faulting instruction
===========================================
   0:	42 80 3c 28 00       	cmpb   $0x0,(%rax,%r13,1)
   5:	0f 85 e6 00 00 00    	jne    0xf1
   b:	49 8b 04 24          	mov    (%r12),%rax
   f:	a9 00 00 01 00       	test   $0x10000,%eax
  14:	74 00                	je     0x16
[486476.628902] RIP free_pages_and_swap_cache (./arch/x86/include/asm/bitops.h:311 (discriminator 3) include/linux/page-flags.h:337 (discriminator 3) mm/swap_state.c:238 (discriminator 3) mm/swap_state.c:265 (discriminator 3))
[486476.630017]  RSP <ffff880406b27838>
[486476.633716] ---[ end trace 3e2ea69469462bc0 ]---
[486476.634480] Kernel panic - not syncing: Fatal exception


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
