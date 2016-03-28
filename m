Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB8AD6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:18:00 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id p65so106861085wmp.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 10:18:00 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id hp10si29502638wjb.161.2016.03.28.10.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 10:17:59 -0700 (PDT)
Date: Mon, 28 Mar 2016 13:17:57 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: 4.5 shmem lockdep/out-of-bound/list corruption disaster
Message-ID: <20160328171757.GA21665@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

I hit this a few days ago.  I'm not 100% what kernel it was running,
but I'm pretty sure it was a post 4.5 kernel from this merge window.

WARNING: CPU: 2 PID: 28919 at kernel/locking/lockdep.c:3198 __lock_acquire+0x74d/0x1c60
DEBUG_LOCKS_WARN_ON(class_idx > MAX_LOCKDEP_KEYS)
CPU: 2 PID: 28919 Comm: trinity-c30 Not tainted 4.5.0-think+ #6 
 ffffffffba141ccd 000000001ded0b05 ffff8803e4b67480 ffffffffba575c0b
 ffff8803e4b674f8 0000000000000000 ffff8803e4b674c8 ffffffffba0b3eb1
 ffff88045fbe37c0 00000c7ee4b674e0 ffffed007c96ce9b 0000000000000000
Call Trace:
 [<ffffffffba141ccd>] ? __lock_acquire+0x74d/0x1c60
 [<ffffffffba575c0b>] dump_stack+0x68/0x9d
 [<ffffffffba0b3eb1>] __warn+0x111/0x130
 [<ffffffffba0b3f84>] warn_slowpath_fmt+0xb4/0xf0
 [<ffffffffba0b3ed0>] ? __warn+0x130/0x130
 [<ffffffffba1409cb>] ? mark_lock+0x45b/0x800
 [<ffffffffba141ccd>] __lock_acquire+0x74d/0x1c60
 [<ffffffffba1611aa>] ? debug_lockdep_rcu_enabled.part.18+0x1a/0x30
 [<ffffffffba1611f5>] ? debug_lockdep_rcu_enabled+0x35/0x40
 [<ffffffffba141580>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffba141580>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffbad456b2>] ? _raw_spin_unlock_irq+0x32/0x50
 [<ffffffffba0f77aa>] ? preempt_count_sub+0x1a/0x130
 [<ffffffffba143dcf>] lock_acquire+0xcf/0x2a0
 [<ffffffffba12eba8>] ? finish_wait+0x68/0xc0
 [<ffffffffbad4541c>] _raw_spin_lock_irqsave+0x4c/0x90
 [<ffffffffba12eba8>] ? finish_wait+0x68/0xc0
 [<ffffffffba12eba8>] finish_wait+0x68/0xc0
 [<ffffffffba2a6453>] shmem_fault+0x323/0x390
 [<ffffffffba2a6130>] ? shmem_file_splice_read+0x720/0x720
 [<ffffffffba12f180>] ? prepare_to_wait_event+0x200/0x200
 [<ffffffffba1611f5>] ? debug_lockdep_rcu_enabled+0x35/0x40
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba2c3eb8>] __do_fault+0x138/0x2e0
 [<ffffffffba2c3d80>] ? wp_page_copy.isra.79+0x850/0x850
 [<ffffffffba2c9a5b>] handle_mm_fault+0x42b/0x2400
 [<ffffffffba141e38>] ? __lock_acquire+0x8b8/0x1c60
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba1611aa>] ? debug_lockdep_rcu_enabled.part.18+0x1a/0x30
 [<ffffffffba035e36>] ? native_sched_clock+0x66/0x160
 [<ffffffffba2c9630>] ? copy_page_range+0xec0/0xec0
 [<ffffffffba0f7a9e>] ? ___might_sleep.part.86+0x1de/0x2c0
 [<ffffffffba2bd8ad>] ? vmacache_find+0xed/0x140
 [<ffffffffba0722d2>] __do_page_fault+0x1d2/0x5a0
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba0726c0>] do_page_fault+0x20/0x70
 [<ffffffffbad469d7>] ? native_iret+0x7/0x7
 [<ffffffffbad47cdf>] page_fault+0x1f/0x30
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba58c112>] ? copy_user_enhanced_fast_string+0x2/0x10
 [<ffffffffba4dcb7f>] ? shmctl_nolock.constprop.24+0x5ff/0x690
 [<ffffffffba4dc847>] ? shmctl_nolock.constprop.24+0x2c7/0x690
 [<ffffffffba141580>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffba4dc580>] ? newseg+0x5e0/0x5e0
 [<ffffffffba5a7247>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffba0f7849>] ? preempt_count_sub+0xb9/0x130
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba4dd412>] SyS_shmctl+0x342/0x490
 [<ffffffffba003aa4>] do_syscall_64+0xf4/0x240
 [<ffffffffbad4605a>] entry_SYSCALL64_slow_path+0x25/0x25
---[ end trace 638c142c3cb9ddb1 ]---
==================================================================
BUG: KASAN: stack-out-of-bounds in do_raw_spin_trylock+0x14/0x70 at addr ffff8803ee067ba0
Read of size 4 by task trinity-c30/28919
page:ffffea000fb819c0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x8000000000000000()
page dumped because: kasan: bad access detected
CPU: 2 PID: 28919 Comm: trinity-c30 Tainted: G        W       4.5.0-think+ #6
 ffff8803e4b678b0 000000001ded0b05 ffff8803e4b676a0 ffffffffba575c0b
 ffff8803e4b67738 ffff8803ee067ba0 ffff8803e4b67728 ffffffffba308cb3
 0000000000000003 dffffc0000000000 0000000000000082 0000000000000001
Call Trace:
 [<ffffffffba575c0b>] dump_stack+0x68/0x9d
 [<ffffffffba308cb3>] kasan_report_error+0x503/0x530
 [<ffffffffbad456b2>] ? _raw_spin_unlock_irq+0x32/0x50
 [<ffffffffba0f77aa>] ? preempt_count_sub+0x1a/0x130
 [<ffffffffba309278>] kasan_report+0x58/0x60
 [<ffffffffba149ca4>] ? do_raw_spin_trylock+0x14/0x70
 [<ffffffffba307a8a>] __asan_load4+0x6a/0x70
 [<ffffffffba149ca4>] do_raw_spin_trylock+0x14/0x70
 [<ffffffffbad45424>] _raw_spin_lock_irqsave+0x54/0x90
 [<ffffffffba12eba8>] ? finish_wait+0x68/0xc0
 [<ffffffffba12eba8>] finish_wait+0x68/0xc0
 [<ffffffffba2a6453>] shmem_fault+0x323/0x390
 [<ffffffffba2a6130>] ? shmem_file_splice_read+0x720/0x720
 [<ffffffffba12f180>] ? prepare_to_wait_event+0x200/0x200
 [<ffffffffba1611f5>] ? debug_lockdep_rcu_enabled+0x35/0x40
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba2c3eb8>] __do_fault+0x138/0x2e0
 [<ffffffffba2c3d80>] ? wp_page_copy.isra.79+0x850/0x850
 [<ffffffffba2c9a5b>] handle_mm_fault+0x42b/0x2400
 [<ffffffffba141e38>] ? __lock_acquire+0x8b8/0x1c60
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba1611aa>] ? debug_lockdep_rcu_enabled.part.18+0x1a/0x30
 [<ffffffffba035e36>] ? native_sched_clock+0x66/0x160
 [<ffffffffba2c9630>] ? copy_page_range+0xec0/0xec0
 [<ffffffffba0f7a9e>] ? ___might_sleep.part.86+0x1de/0x2c0
 [<ffffffffba2bd8ad>] ? vmacache_find+0xed/0x140
 [<ffffffffba0722d2>] __do_page_fault+0x1d2/0x5a0
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba0726c0>] do_page_fault+0x20/0x70
 [<ffffffffbad469d7>] ? native_iret+0x7/0x7
 [<ffffffffbad47cdf>] page_fault+0x1f/0x30
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba58c112>] ? copy_user_enhanced_fast_string+0x2/0x10
 [<ffffffffba4dcb7f>] ? shmctl_nolock.constprop.24+0x5ff/0x690
 [<ffffffffba4dc847>] ? shmctl_nolock.constprop.24+0x2c7/0x690
 [<ffffffffba141580>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffba4dc580>] ? newseg+0x5e0/0x5e0
 [<ffffffffba5a7247>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffba0f7849>] ? preempt_count_sub+0xb9/0x130
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba4dd412>] SyS_shmctl+0x342/0x490
 [<ffffffffba003aa4>] do_syscall_64+0xf4/0x240
 [<ffffffffbad4605a>] entry_SYSCALL64_slow_path+0x25/0x25
Memory state around the buggy address:
 ffff8803ee067a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8803ee067b00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff8803ee067b80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                               ^
 ffff8803ee067c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8803ee067c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================
------------[ cut here ]------------
WARNING: CPU: 2 PID: 28919 at lib/list_debug.c:59 __list_del_entry+0xdc/0x100
list_del corruption. prev->next should be ffff8803e4b678a8, but was 0000000041b58ab3
CPU: 2 PID: 28919 Comm: trinity-c30 Tainted: G    B   W       4.5.0-think+ #6
 ffffffffba5a743c 000000001ded0b05 ffff8803e4b67690 ffffffffba575c0b
 ffff8803e4b67708 0000000000000000 ffff8803e4b676d8 ffffffffba0b3eb1
 ffff88045fbe37c0 0000003bba308c0c ffffed007c96cedd ffff8803ee067be8
Call Trace:
 [<ffffffffba5a743c>] ? __list_del_entry+0xdc/0x100
 [<ffffffffba575c0b>] dump_stack+0x68/0x9d
 [<ffffffffba0b3eb1>] __warn+0x111/0x130
 [<ffffffffba0b3f84>] warn_slowpath_fmt+0xb4/0xf0
 [<ffffffffba0b3ed0>] ? __warn+0x130/0x130
 [<ffffffffba58c6a4>] ? delay_tsc+0x94/0xc0
 [<ffffffffba12eba8>] ? finish_wait+0x68/0xc0
 [<ffffffffba5a743c>] __list_del_entry+0xdc/0x100
 [<ffffffffba12ebb3>] finish_wait+0x73/0xc0
 [<ffffffffba2a6453>] shmem_fault+0x323/0x390
 [<ffffffffba2a6130>] ? shmem_file_splice_read+0x720/0x720
 [<ffffffffba12f180>] ? prepare_to_wait_event+0x200/0x200
 [<ffffffffba1611f5>] ? debug_lockdep_rcu_enabled+0x35/0x40
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba2c3eb8>] __do_fault+0x138/0x2e0
 [<ffffffffba2c3d80>] ? wp_page_copy.isra.79+0x850/0x850
 [<ffffffffba2c9a5b>] handle_mm_fault+0x42b/0x2400
 [<ffffffffba141e38>] ? __lock_acquire+0x8b8/0x1c60
 [<ffffffffba14063f>] ? mark_lock+0xcf/0x800
 [<ffffffffba1611aa>] ? debug_lockdep_rcu_enabled.part.18+0x1a/0x30
 [<ffffffffba035e36>] ? native_sched_clock+0x66/0x160
 [<ffffffffba2c9630>] ? copy_page_range+0xec0/0xec0
 [<ffffffffba0f7a9e>] ? ___might_sleep.part.86+0x1de/0x2c0
 [<ffffffffba2bd8ad>] ? vmacache_find+0xed/0x140
 [<ffffffffba0722d2>] __do_page_fault+0x1d2/0x5a0
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba0726c0>] do_page_fault+0x20/0x70
 [<ffffffffbad469d7>] ? native_iret+0x7/0x7
 [<ffffffffbad47cdf>] page_fault+0x1f/0x30
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba58c112>] ? copy_user_enhanced_fast_string+0x2/0x10
 [<ffffffffba4dcb7f>] ? shmctl_nolock.constprop.24+0x5ff/0x690
 [<ffffffffba4dc847>] ? shmctl_nolock.constprop.24+0x2c7/0x690
 [<ffffffffba141580>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffba4dc580>] ? newseg+0x5e0/0x5e0
 [<ffffffffba5a7247>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffba0f7849>] ? preempt_count_sub+0xb9/0x130
 [<ffffffffba4dd0d0>] ? SyS_shmget+0x100/0x100
 [<ffffffffba4dd412>] SyS_shmctl+0x342/0x490
 [<ffffffffba003aa4>] do_syscall_64+0xf4/0x240
 [<ffffffffbad4605a>] entry_SYSCALL64_slow_path+0x25/0x25
---[ end trace 638c142c3cb9ddb2 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
