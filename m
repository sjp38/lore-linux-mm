Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D327800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 20:36:54 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id r23so3815150qte.13
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 17:36:54 -0800 (PST)
Received: from scorn.kernelslacker.org (scorn.kernelslacker.org. [45.56.101.199])
        by mx.google.com with ESMTPS id v44si1660190qtc.257.2018.01.23.17.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jan 2018 17:36:52 -0800 (PST)
Date: Tue, 23 Jan 2018 20:36:51 -0500
From: Dave Jones <davej@codemonkey.org.uk>
Subject: [4.15-rc9] fs_reclaim lockdep trace
Message-ID: <20180124013651.GA1718@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Just triggered this on a server I was rsync'ing to.


============================================
WARNING: possible recursive locking detected
4.15.0-rc9-backup-debug+ #1 Not tainted
--------------------------------------------
sshd/24800 is trying to acquire lock:
 (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

but task is already holding lock:
 (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(fs_reclaim);
  lock(fs_reclaim);

 *** DEADLOCK ***

 May be due to missing lock nesting notation

2 locks held by sshd/24800:
 #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000001a069652>] tcp_sendmsg+0x19/0x40
 #1:  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

stack backtrace:
CPU: 3 PID: 24800 Comm: sshd Not tainted 4.15.0-rc9-backup-debug+ #1
Call Trace:
 dump_stack+0xbc/0x13f
 ? _atomic_dec_and_lock+0x101/0x101
 ? fs_reclaim_acquire.part.102+0x5/0x30
 ? print_lock+0x54/0x68
 __lock_acquire+0xa09/0x2040
 ? debug_show_all_locks+0x2f0/0x2f0
 ? mutex_destroy+0x120/0x120
 ? hlock_class+0xa0/0xa0
 ? kernel_text_address+0x5c/0x90
 ? __kernel_text_address+0xe/0x30
 ? unwind_get_return_address+0x2f/0x50
 ? __save_stack_trace+0x92/0x100
 ? graph_lock+0x8d/0x100
 ? check_noncircular+0x20/0x20
 ? __lock_acquire+0x616/0x2040
 ? debug_show_all_locks+0x2f0/0x2f0
 ? __lock_acquire+0x616/0x2040
 ? debug_show_all_locks+0x2f0/0x2f0
 ? print_irqtrace_events+0x110/0x110
 ? active_load_balance_cpu_stop+0x7b0/0x7b0
 ? debug_show_all_locks+0x2f0/0x2f0
 ? mark_lock+0x1b1/0xa00
 ? lock_acquire+0x12e/0x350
 lock_acquire+0x12e/0x350
 ? fs_reclaim_acquire.part.102+0x5/0x30
 ? lockdep_rcu_suspicious+0x100/0x100
 ? set_next_entity+0x20e/0x10d0
 ? mark_lock+0x1b1/0xa00
 ? match_held_lock+0x8d/0x440
 ? mark_lock+0x1b1/0xa00
 ? save_trace+0x1e0/0x1e0
 ? print_irqtrace_events+0x110/0x110
 ? alloc_extent_state+0xa7/0x410
 fs_reclaim_acquire.part.102+0x29/0x30
 ? fs_reclaim_acquire.part.102+0x5/0x30
 kmem_cache_alloc+0x3d/0x2c0
 ? rb_erase+0xe63/0x1240
 alloc_extent_state+0xa7/0x410
 ? lock_extent_buffer_for_io+0x3f0/0x3f0
 ? find_held_lock+0x6d/0xd0
 ? test_range_bit+0x197/0x210
 ? lock_acquire+0x350/0x350
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? iotree_fs_info+0x30/0x30
 __clear_extent_bit+0x3ea/0x570
 ? clear_state_bit+0x270/0x270
 ? count_range_bits+0x2f0/0x2f0
 ? lock_acquire+0x350/0x350
 ? rb_prev+0x21/0x90
 try_release_extent_mapping+0x21a/0x260
 __btrfs_releasepage+0xb0/0x1c0
 ? btrfs_submit_direct+0xca0/0xca0
 ? check_new_page_bad+0x1f0/0x1f0
 ? match_held_lock+0xa5/0x440
 ? debug_show_all_locks+0x2f0/0x2f0
 btrfs_releasepage+0x161/0x170
 ? __btrfs_releasepage+0x1c0/0x1c0
 ? page_rmapping+0xd0/0xd0
 ? rmap_walk+0x100/0x100
 try_to_release_page+0x162/0x1c0
 ? generic_file_write_iter+0x3c0/0x3c0
 ? page_evictable+0xcc/0x110
 ? lookup_address_in_pgd+0x107/0x190
 shrink_page_list+0x1d5a/0x2fb0
 ? putback_lru_page+0x3f0/0x3f0
 ? save_trace+0x1e0/0x1e0
 ? _lookup_address_cpa.isra.13+0x40/0x60
 ? debug_show_all_locks+0x2f0/0x2f0
 ? kmem_cache_free+0x8c/0x280
 ? free_extent_state+0x1c8/0x3b0
 ? mark_lock+0x1b1/0xa00
 ? page_rmapping+0xd0/0xd0
 ? print_irqtrace_events+0x110/0x110
 ? shrink_node_memcg.constprop.88+0x4c9/0x5e0
 ? shrink_node+0x12d/0x260
 ? try_to_free_pages+0x418/0xaf0
 ? __alloc_pages_slowpath+0x976/0x1790
 ? __alloc_pages_nodemask+0x52c/0x5c0
 ? delete_node+0x28d/0x5c0
 ? find_held_lock+0x6d/0xd0
 ? free_pcppages_bulk+0x381/0x570
 ? lock_acquire+0x350/0x350
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? __lock_is_held+0x51/0xc0
 ? _raw_spin_unlock+0x24/0x30
 ? free_pcppages_bulk+0x381/0x570
 ? mark_lock+0x1b1/0xa00
 ? free_compound_page+0x30/0x30
 ? print_irqtrace_events+0x110/0x110
 ? __kernel_map_pages+0x2c9/0x310
 ? mark_lock+0x1b1/0xa00
 ? print_irqtrace_events+0x110/0x110
 ? __delete_from_page_cache+0x2e7/0x4e0
 ? save_trace+0x1e0/0x1e0
 ? __add_to_page_cache_locked+0x680/0x680
 ? find_held_lock+0x6d/0xd0
 ? __list_add_valid+0x29/0xa0
 ? free_unref_page_commit+0x198/0x270
 ? drain_local_pages_wq+0x20/0x20
 ? stop_critical_timings+0x210/0x210
 ? mark_lock+0x1b1/0xa00
 ? mark_lock+0x1b1/0xa00
 ? print_irqtrace_events+0x110/0x110
 ? __lock_acquire+0x616/0x2040
 ? mark_lock+0x1b1/0xa00
 ? mark_lock+0x1b1/0xa00
 ? print_irqtrace_events+0x110/0x110
 ? __phys_addr_symbol+0x23/0x40
 ? __change_page_attr_set_clr+0xe86/0x1640
 ? __btrfs_releasepage+0x1c0/0x1c0
 ? mark_lock+0x1b1/0xa00
 ? mark_lock+0x1b1/0xa00
 ? print_irqtrace_events+0x110/0x110
 ? mark_lock+0x1b1/0xa00
 ? __lock_acquire+0x616/0x2040
 ? __lock_acquire+0x616/0x2040
 ? debug_show_all_locks+0x2f0/0x2f0
 ? swiotlb_free_coherent+0x60/0x60
 ? __phys_addr+0x32/0x80
 ? igb_xmit_frame_ring+0xad7/0x1890
 ? stack_access_ok+0x35/0x80
 ? deref_stack_reg+0xa1/0xe0
 ? __read_once_size_nocheck.constprop.6+0x10/0x10
 ? __orc_find+0x6b/0xc0
 ? unwind_next_frame+0x407/0xa20
 ? __save_stack_trace+0x5e/0x100
 ? stack_access_ok+0x35/0x80
 ? deref_stack_reg+0xa1/0xe0
 ? __read_once_size_nocheck.constprop.6+0x10/0x10
 ? __lock_acquire+0x616/0x2040
 ? debug_lockdep_rcu_enabled.part.37+0x16/0x30
 ? is_ftrace_trampoline+0x112/0x190
 ? ftrace_profile_pages_init+0x130/0x130
 ? unwind_next_frame+0x407/0xa20
 ? rcu_is_watching+0x88/0xd0
 ? unwind_get_return_address_ptr+0x50/0x50
 ? kernel_text_address+0x5c/0x90
 ? __kernel_text_address+0xe/0x30
 ? unwind_get_return_address+0x2f/0x50
 ? __save_stack_trace+0x92/0x100
 ? __list_add_valid+0x29/0xa0
 ? add_lock_to_list.isra.26+0x1d0/0x21f
 ? print_lockdep_cache.isra.29+0xd8/0xd8
 ? save_trace+0x106/0x1e0
 ? __isolate_lru_page+0x2dc/0x3c0
 ? remove_mapping+0x1b0/0x1b0
 ? match_held_lock+0xa5/0x440
 ? __lock_acquire+0x616/0x2040
 ? __mod_zone_page_state+0x1a/0x70
 ? isolate_lru_pages.isra.83+0x888/0xae0
 ? __isolate_lru_page+0x3c0/0x3c0
 ? check_usage+0x174/0x790
 ? mark_lock+0x1b1/0xa00
 ? print_irqtrace_events+0x110/0x110
 ? check_usage_forwards+0x2b0/0x2b0
 ? class_equal+0x11/0x20
 ? __bfs+0xed/0x430
 ? __phys_addr_symbol+0x23/0x40
 ? mutex_destroy+0x120/0x120
 ? match_held_lock+0x8d/0x440
 ? hlock_class+0xa0/0xa0
 ? mark_lock+0x1b1/0xa00
 ? save_trace+0x1e0/0x1e0
 ? print_irqtrace_events+0x110/0x110
 ? lock_acquire+0x350/0x350
 ? __zone_watermark_ok+0xd8/0x280
 ? graph_lock+0x8d/0x100
 ? check_noncircular+0x20/0x20
 ? find_held_lock+0x6d/0xd0
 ? shrink_inactive_list+0x3b4/0x940
 ? lock_acquire+0x350/0x350
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? stop_critical_timings+0x210/0x210
 ? mark_held_locks+0x6e/0x90
 ? _raw_spin_unlock_irq+0x29/0x40
 shrink_inactive_list+0x451/0x940
 ? save_trace+0x180/0x1e0
 ? putback_inactive_pages+0x9f0/0x9f0
 ? dev_queue_xmit_nit+0x548/0x660
 ? __kernel_map_pages+0x2c9/0x310
 ? set_pages_rw+0xe0/0xe0
 ? get_page_from_freelist+0x1ea5/0x2ca0
 ? match_held_lock+0x8d/0x440
 ? blk_start_plug+0x17d/0x1e0
 ? kblockd_schedule_delayed_work_on+0x20/0x20
 ? print_irqtrace_events+0x110/0x110
 ? cpumask_next+0x1d/0x20
 ? zone_reclaimable_pages+0x25b/0x470
 ? mark_held_locks+0x6e/0x90
 ? __remove_mapping+0x4e0/0x4e0
 shrink_node_memcg.constprop.88+0x4c9/0x5e0
 ? __delayacct_freepages_start+0x28/0x40
 ? lock_acquire+0x311/0x350
 ? shrink_active_list+0x9c0/0x9c0
 ? stop_critical_timings+0x210/0x210
 ? allow_direct_reclaim.part.82+0xea/0x220
 ? mark_held_locks+0x6e/0x90
 ? ktime_get+0x1f0/0x3e0
 ? shrink_node+0x12d/0x260
 shrink_node+0x12d/0x260
 ? shrink_node_memcg.constprop.88+0x5e0/0x5e0
 ? __lock_is_held+0x51/0xc0
 try_to_free_pages+0x418/0xaf0
 ? shrink_node+0x260/0x260
 ? lock_acquire+0x12e/0x350
 ? lock_acquire+0x12e/0x350
 ? fs_reclaim_acquire.part.102+0x5/0x30
 ? lockdep_rcu_suspicious+0x100/0x100
 ? rcu_note_context_switch+0x520/0x520
 ? wake_all_kswapds+0x10a/0x150
 __alloc_pages_slowpath+0x976/0x1790
 ? __zone_watermark_ok+0x280/0x280
 ? warn_alloc+0x250/0x250
 ? __lock_acquire+0x616/0x2040
 ? match_held_lock+0x8d/0x440
 ? save_trace+0x1e0/0x1e0
 ? debug_show_all_locks+0x2f0/0x2f0
 ? match_held_lock+0xa5/0x440
 ? stack_access_ok+0x35/0x80
 ? save_trace+0x1e0/0x1e0
 ? __read_once_size_nocheck.constprop.6+0x10/0x10
 ? __lock_acquire+0x616/0x2040
 ? match_held_lock+0xa5/0x440
 ? find_held_lock+0x6d/0xd0
 ? __lock_is_held+0x51/0xc0
 ? rcu_note_context_switch+0x520/0x520
 ? perf_trace_sched_switch+0x560/0x560
 ? __might_sleep+0x58/0xe0
 __alloc_pages_nodemask+0x52c/0x5c0
 ? gfp_pfmemalloc_allowed+0xc0/0xc0
 ? kernel_text_address+0x5c/0x90
 ? __kernel_text_address+0xe/0x30
 ? unwind_get_return_address+0x2f/0x50
 ? memcmp+0x45/0x70
 ? match_held_lock+0x8d/0x440
 ? depot_save_stack+0x12e/0x480
 ? match_held_lock+0xa5/0x440
 ? stop_critical_timings+0x210/0x210
 ? sk_stream_alloc_skb+0xb8/0x340
 ? mark_held_locks+0x6e/0x90
 ? new_slab+0x2f3/0x3f0
 new_slab+0x374/0x3f0
 ___slab_alloc.constprop.81+0x47e/0x5a0
 ? __alloc_skb+0xee/0x390
 ? __alloc_skb+0xee/0x390
 ? __alloc_skb+0xee/0x390
 ? __slab_alloc.constprop.80+0x32/0x60
 __slab_alloc.constprop.80+0x32/0x60
 ? __alloc_skb+0xee/0x390
 __kmalloc_track_caller+0x267/0x310
 __kmalloc_reserve.isra.40+0x29/0x80
 __alloc_skb+0xee/0x390
 ? __skb_splice_bits+0x3e0/0x3e0
 ? ip6_mtu+0x1d9/0x290
 ? ip6_link_failure+0x3c0/0x3c0
 ? tcp_current_mss+0x1d8/0x2f0
 ? tcp_sync_mss+0x520/0x520
 sk_stream_alloc_skb+0xb8/0x340
 ? tcp_ioctl+0x280/0x280
 tcp_sendmsg_locked+0x8e6/0x1d30
 ? match_held_lock+0x8d/0x440
 ? mark_lock+0x1b1/0xa00
 ? tcp_set_state+0x450/0x450
 ? debug_show_all_locks+0x2f0/0x2f0
 ? match_held_lock+0x8d/0x440
 ? save_trace+0x1e0/0x1e0
 ? find_held_lock+0x6d/0xd0
 ? lock_acquire+0x12e/0x350
 ? lock_acquire+0x12e/0x350
 ? tcp_sendmsg+0x19/0x40
 ? lockdep_rcu_suspicious+0x100/0x100
 ? do_raw_spin_trylock+0x100/0x100
 ? stop_critical_timings+0x210/0x210
 ? mark_held_locks+0x6e/0x90
 ? __local_bh_enable_ip+0x94/0x100
 ? lock_sock_nested+0x51/0xb0
 tcp_sendmsg+0x27/0x40
 inet_sendmsg+0xd0/0x310
 ? inet_recvmsg+0x360/0x360
 ? match_held_lock+0x8d/0x440
 ? inet_recvmsg+0x360/0x360
 sock_write_iter+0x17a/0x240
 ? sock_ioctl+0x290/0x290
 ? find_held_lock+0x6d/0xd0
 __vfs_write+0x2ab/0x380
 ? kernel_read+0xa0/0xa0
 ? __context_tracking_exit.part.4+0xe7/0x290
 ? lock_acquire+0x350/0x350
 ? __fdget_pos+0x7f/0x110
 ? __fdget_raw+0x10/0x10
 vfs_write+0xfb/0x260
 SyS_write+0xb6/0x140
 ? SyS_read+0x140/0x140
 ? SyS_clock_settime+0x120/0x120
 ? mark_held_locks+0x1c/0x90
 ? do_syscall_64+0x110/0xc05
 ? SyS_read+0x140/0x140
 do_syscall_64+0x1e5/0xc05
 ? syscall_return_slowpath+0x5b0/0x5b0
 ? lock_acquire+0x350/0x350
 ? lockdep_rcu_suspicious+0x100/0x100
 ? get_vtime_delta+0x15/0xf0
 ? get_vtime_delta+0x8b/0xf0
 ? vtime_user_enter+0x7f/0x90
 ? __context_tracking_enter+0x13c/0x2b0
 ? __context_tracking_enter+0x13c/0x2b0
 ? context_tracking_exit.part.5+0x40/0x40
 ? rcu_is_watching+0x88/0xd0
 ? time_hardirqs_on+0x220/0x220
 ? prepare_exit_to_usermode+0x1d0/0x2a0
 ? enter_from_user_mode+0x30/0x30
 ? entry_SYSCALL_64_after_hwframe+0x18/0x2e
 ? trace_hardirqs_off_caller+0xc2/0x110
 ? trace_hardirqs_off_thunk+0x1a/0x1c
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f26d47d1974
RSP: 002b:00007ffd62e2f548 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000024 RCX: 00007f26d47d1974
RDX: 0000000000000024 RSI: 000055a0bc9a6220 RDI: 0000000000000003
RBP: 000055a0bc984370 R08: 0000000000000000 R09: 00007ffd62fb9080
R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000000
R13: 000055a0bc311ab0 R14: 0000000000000003 R15: 00007ffd62e2f5cf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
