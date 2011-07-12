Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D74056B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 10:06:19 -0400 (EDT)
Subject: [3.0.0-rc7] possible recursive locking at cache_alloc_refill
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201107112137.FAD00545.SHtLOFOJOMFQFV@I-love.SAKURA.ne.jp>
In-Reply-To: <201107112137.FAD00545.SHtLOFOJOMFQFV@I-love.SAKURA.ne.jp>
Message-Id: <201107122306.GGI56206.FSVFJOQOtOFHLM@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jul 2011 23:06:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

What can I do to debug this?

[    5.567313] sd 0:0:0:0: [sda] Assuming drive cache: write through
[    5.574085] sd 0:0:0:0: [sda] Assuming drive cache: write through
[    5.597950] sd 0:0:0:0: [sda] Assuming drive cache: write through
[   11.347153] 
[   11.347153] =============================================
[   11.347300] [ INFO: possible recursive locking detected ]
[   11.347300] 3.0.0-rc7 #1
[   11.347300] ---------------------------------------------
[   11.347300] udevd/2038 is trying to acquire lock:
[   11.347300]  (&(&parent->list_lock)->rlock){-.-...}, at: [<c10c6706>] cache_alloc_refill+0x66/0x2e0
[   11.347300] 
[   11.347300] but task is already holding lock:
[   11.347300]  (&(&parent->list_lock)->rlock){-.-...}, at: [<c10c5b13>] cache_flusharray+0x43/0x110
[   11.347300] 
[   11.347300] other info that might help us debug this:
[   11.347300]  Possible unsafe locking scenario:
[   11.347300] 
[   11.347300]        CPU0
[   11.347300]        ----
[   11.347300]   lock(&(&parent->list_lock)->rlock);
[   11.347300]   lock(&(&parent->list_lock)->rlock);
[   11.347300] 
[   11.347300]  *** DEADLOCK ***
[   11.347300] 
[   11.347300]  May be due to missing lock nesting notation
[   11.347300] 
[   11.347300] 1 lock held by udevd/2038:
[   11.347300]  #0:  (&(&parent->list_lock)->rlock){-.-...}, at: [<c10c5b13>] cache_flusharray+0x43/0x110
[   11.347300] 
[   11.347300] stack backtrace:
[   11.347300] Pid: 2038, comm: udevd Not tainted 3.0.0-rc7 #1
[   11.347300] Call Trace:
[   11.347300]  [<c106b58e>] print_deadlock_bug+0xce/0xe0
[   11.347300]  [<c106d63a>] validate_chain+0x5aa/0x720
[   11.347300]  [<c106da47>] __lock_acquire+0x297/0x480
[   11.347300]  [<c106e19b>] lock_acquire+0x7b/0xa0
[   11.347300]  [<c10c6706>] ? cache_alloc_refill+0x66/0x2e0
[   11.347300]  [<c13f4a76>] _raw_spin_lock+0x36/0x70
[   11.347300]  [<c10c6706>] ? cache_alloc_refill+0x66/0x2e0
[   11.347300]  [<c1221016>] ? __debug_object_init+0x346/0x360
[   11.347300]  [<c10c6706>] cache_alloc_refill+0x66/0x2e0
[   11.347300]  [<c106da65>] ? __lock_acquire+0x2b5/0x480
[   11.347300]  [<c1221016>] ? __debug_object_init+0x346/0x360
[   11.347300]  [<c10c639f>] kmem_cache_alloc+0x11f/0x140
[   11.347300]  [<c1221016>] __debug_object_init+0x346/0x360
[   11.347300]  [<c106dfa2>] ? __lock_release+0x72/0x180
[   11.347300]  [<c12208b5>] ? debug_object_activate+0x85/0x130
[   11.347300]  [<c1221067>] debug_object_init+0x17/0x20
[   11.347300]  [<c105441a>] rcuhead_fixup_activate+0x1a/0x60
[   11.347300]  [<c12208c5>] debug_object_activate+0x95/0x130
[   11.347300]  [<c10c60e0>] ? kmem_cache_shrink+0x50/0x50
[   11.347300]  [<c108e64a>] __call_rcu+0x2a/0x180
[   11.347300]  [<c10c48f0>] ? slab_destroy_debugcheck+0x70/0x110
[   11.347300]  [<c108e7bd>] call_rcu_sched+0xd/0x10
[   11.347300]  [<c10c5913>] slab_destroy+0x73/0x80
[   11.347300]  [<c10c595f>] free_block+0x3f/0x1b0
[   11.347300]  [<c10c5b13>] ? cache_flusharray+0x43/0x110
[   11.347300]  [<c10c5b43>] cache_flusharray+0x73/0x110
[   11.347300]  [<c10c5887>] kmem_cache_free+0xb7/0xd0
[   11.347300]  [<c10bbff9>] __put_anon_vma+0x49/0xa0
[   11.347300]  [<c10bc61c>] unlink_anon_vmas+0xfc/0x160
[   11.347300]  [<c10b455c>] free_pgtables+0x3c/0x90
[   11.347300]  [<c10b9acf>] exit_mmap+0xbf/0xf0
[   11.347300]  [<c1039d3c>] mmput+0x4c/0xc0
[   11.347300]  [<c103d9fc>] exit_mm+0xec/0x130
[   11.347300]  [<c13f5352>] ? _raw_spin_unlock_irq+0x22/0x30
[   11.347300]  [<c103fa43>] do_exit+0x123/0x390
[   11.347300]  [<c10cba05>] ? fput+0x15/0x20
[   11.347300]  [<c10c7c6d>] ? filp_close+0x4d/0x80
[   11.347300]  [<c103fce9>] do_group_exit+0x39/0xa0
[   11.347300]  [<c103fd63>] sys_exit_group+0x13/0x20
[   11.347300]  [<c13f5c8c>] sysenter_do_call+0x12/0x32
[   11.452291] dracut: Switching root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
