Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA41E83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so28601923lfb.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:34 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m12si13014235wjq.88.2016.08.25.03.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:32 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so6652499wmg.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 4/9] kernel, oom: fix potential pgd_lock deadlock from __mmdrop
Date: Thu, 25 Aug 2016 12:03:09 +0200
Message-Id: <1472119394-11342-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Lockdep complains that __mmdrop is not safe from the softirq context:

[   63.860469] =================================
[   63.861326] [ INFO: inconsistent lock state ]
[   63.862677] 4.6.0-oomfortification2-00011-geeb3eadeab96-dirty #949 Tainted: G        W
[   63.864072] ---------------------------------
[   63.864072] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   63.864072] swapper/1/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   63.864072]  (pgd_lock){+.?...}, at: [<ffffffff81048762>] pgd_free+0x19/0x6b
[   63.864072] {SOFTIRQ-ON-W} state was registered at:
[   63.864072]   [<ffffffff81097da2>] __lock_acquire+0xa06/0x196e
[   63.864072]   [<ffffffff810994d8>] lock_acquire+0x139/0x1e1
[   63.864072]   [<ffffffff81625cd2>] _raw_spin_lock+0x32/0x41
[   63.864072]   [<ffffffff8104594d>] __change_page_attr_set_clr+0x2a5/0xacd
[   63.864072]   [<ffffffff810462e4>] change_page_attr_set_clr+0x16f/0x32c
[   63.864072]   [<ffffffff81046544>] set_memory_nx+0x37/0x3a
[   63.864072]   [<ffffffff81041b2c>] free_init_pages+0x9e/0xc7
[   63.864072]   [<ffffffff81d49105>] alternative_instructions+0xa2/0xb3
[   63.864072]   [<ffffffff81d4a763>] check_bugs+0xe/0x2d
[   63.864072]   [<ffffffff81d3eed0>] start_kernel+0x3ce/0x3ea
[   63.864072]   [<ffffffff81d3e2f1>] x86_64_start_reservations+0x2a/0x2c
[   63.864072]   [<ffffffff81d3e46d>] x86_64_start_kernel+0x17a/0x18d
[   63.864072] irq event stamp: 105916
[   63.864072] hardirqs last  enabled at (105916): [<ffffffff8112f5ba>] free_hot_cold_page+0x37e/0x390
[   63.864072] hardirqs last disabled at (105915): [<ffffffff8112f4fd>] free_hot_cold_page+0x2c1/0x390
[   63.864072] softirqs last  enabled at (105878): [<ffffffff81055724>] _local_bh_enable+0x42/0x44
[   63.864072] softirqs last disabled at (105879): [<ffffffff81055a6d>] irq_exit+0x6f/0xd1
[   63.864072]
[   63.864072] other info that might help us debug this:
[   63.864072]  Possible unsafe locking scenario:
[   63.864072]
[   63.864072]        CPU0
[   63.864072]        ----
[   63.864072]   lock(pgd_lock);
[   63.864072]   <Interrupt>
[   63.864072]     lock(pgd_lock);
[   63.864072]
[   63.864072]  *** DEADLOCK ***
[   63.864072]
[   63.864072] 1 lock held by swapper/1/0:
[   63.864072]  #0:  (rcu_callback){......}, at: [<ffffffff810b44f2>] rcu_process_callbacks+0x390/0x800
[   63.864072]
[   63.864072] stack backtrace:
[   63.864072] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W       4.6.0-oomfortification2-00011-geeb3eadeab96-dirty #949
[   63.864072] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   63.864072]  0000000000000000 ffff88000fb03c38 ffffffff81312df8 ffffffff8257a0d0
[   63.864072]  ffff8800069f8000 ffff88000fb03c70 ffffffff81125bc5 0000000000000004
[   63.864072]  ffff8800069f8888 ffff8800069f8000 ffffffff8109603a 0000000000000004
[   63.864072] Call Trace:
[   63.864072]  <IRQ>  [<ffffffff81312df8>] dump_stack+0x67/0x90
[   63.864072]  [<ffffffff81125bc5>] print_usage_bug.part.25+0x259/0x268
[   63.864072]  [<ffffffff8109603a>] ? print_shortest_lock_dependencies+0x180/0x180
[   63.864072]  [<ffffffff81096d33>] mark_lock+0x381/0x567
[   63.864072]  [<ffffffff81097d2f>] __lock_acquire+0x993/0x196e
[   63.864072]  [<ffffffff81048762>] ? pgd_free+0x19/0x6b
[   63.864072]  [<ffffffff8117b8ae>] ? discard_slab+0x42/0x44
[   63.864072]  [<ffffffff8117e00d>] ? __slab_free+0x3e6/0x429
[   63.864072]  [<ffffffff810994d8>] lock_acquire+0x139/0x1e1
[   63.864072]  [<ffffffff810994d8>] ? lock_acquire+0x139/0x1e1
[   63.864072]  [<ffffffff81048762>] ? pgd_free+0x19/0x6b
[   63.864072]  [<ffffffff81625cd2>] _raw_spin_lock+0x32/0x41
[   63.864072]  [<ffffffff81048762>] ? pgd_free+0x19/0x6b
[   63.864072]  [<ffffffff81048762>] pgd_free+0x19/0x6b
[   63.864072]  [<ffffffff8104d018>] __mmdrop+0x25/0xb9
[   63.864072]  [<ffffffff8104d29d>] __put_task_struct+0x103/0x11e
[   63.864072]  [<ffffffff810526a0>] delayed_put_task_struct+0x157/0x15e
[   63.864072]  [<ffffffff810b47c2>] rcu_process_callbacks+0x660/0x800
[   63.864072]  [<ffffffff81052549>] ? will_become_orphaned_pgrp+0xae/0xae
[   63.864072]  [<ffffffff8162921c>] __do_softirq+0x1ec/0x4d5
[   63.864072]  [<ffffffff81055a6d>] irq_exit+0x6f/0xd1
[   63.864072]  [<ffffffff81628d7b>] smp_apic_timer_interrupt+0x42/0x4d
[   63.864072]  [<ffffffff8162732e>] apic_timer_interrupt+0x8e/0xa0
[   63.864072]  <EOI>  [<ffffffff81021657>] ? default_idle+0x6b/0x16e
[   63.864072]  [<ffffffff81021ed2>] arch_cpu_idle+0xf/0x11
[   63.864072]  [<ffffffff8108e59b>] default_idle_call+0x32/0x34
[   63.864072]  [<ffffffff8108e7a9>] cpu_startup_entry+0x20c/0x399
[   63.864072]  [<ffffffff81034600>] start_secondary+0xfe/0x101

More over a79e53d85683 ("x86/mm: Fix pgd_lock deadlock") was explicit
about pgd_lock not to be called from the irq context. This means that
__mmdrop called from free_signal_struct has to be postponed to a user
context. We already have a similar mechanism for mmput_async so we
can use it here as well. This is safe because mm_count is pinned by
mm_users.

This fixes bug introduced by "oom: keep mm of the killed task available"

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm_types.h |  2 --
 include/linux/sched.h    | 14 ++++++++++++++
 kernel/fork.c            |  6 +++++-
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 903200f4ec41..4a8acedf4b7d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -515,9 +515,7 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
-#ifdef CONFIG_MMU
 	struct work_struct async_put_work;
-#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index da278b6ce44d..cccb575dc242 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2829,6 +2829,20 @@ static inline void mmdrop(struct mm_struct *mm)
 		__mmdrop(mm);
 }
 
+static inline void mmdrop_async_fn(struct work_struct *work)
+{
+	struct mm_struct *mm = container_of(work, struct mm_struct, async_put_work);
+	__mmdrop(mm);
+}
+
+static inline void mmdrop_async(struct mm_struct *mm)
+{
+	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
+		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
+		schedule_work(&mm->async_put_work);
+	}
+}
+
 static inline bool mmget_not_zero(struct mm_struct *mm)
 {
 	return atomic_inc_not_zero(&mm->mm_users);
diff --git a/kernel/fork.c b/kernel/fork.c
index f3b78c713211..136a2c6784cb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -243,8 +243,12 @@ static inline void free_signal_struct(struct signal_struct *sig)
 {
 	taskstats_tgid_free(sig);
 	sched_autogroup_exit(sig);
+	/*
+	 * __mmdrop is not safe to call from softirq context on x86 due to
+	 * pgd_dtor so postpone it to the async context
+	 */
 	if (sig->oom_mm)
-		mmdrop(sig->oom_mm);
+		mmdrop_async(sig->oom_mm);
 	kmem_cache_free(signal_cachep, sig);
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
