Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id A28D76B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 14:42:01 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id t7so389046284vkf.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:42:01 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id m2si3077681ybc.209.2016.06.20.11.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 11:42:00 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id l125so4435185ywb.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:42:00 -0700 (PDT)
Date: Mon, 20 Jun 2016 14:41:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] memcg: mem_cgroup_migrate() may be called with irq disabled
Message-ID: <20160620184158.GO3262@mtj.duckdns.org>
References: <5767CFE5.7080904@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5767CFE5.7080904@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org >> Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, kernel-team@fb.com

Hello,

Christian, I *think* this should fix it.  Can you please verify?

Thanks!
------ 8< ------
mem_cgroup_migrate() uses local_irq_disable/enable() but can be called
with irq disabled from migrate_page_copy().  This ends up enabling irq
while holding a irq context lock triggering the following lockdep
warning.  Fix it by using irq_save/restore instead.

  =================================
  [ INFO: inconsistent lock state ]
  4.7.0-rc1+ #52 Tainted: G        W      
  ---------------------------------
  inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
  kcompactd0/151 [HC0[0]:SC0[0]:HE1:SE1] takes:
   (&(&ctx->completion_lock)->rlock){+.?.-.}, at: [<000000000038fd96>] aio_migratepage+0x156/0x1e8
  {IN-SOFTIRQ-W} state was registered at:
    [<00000000001a8366>] __lock_acquire+0x5b6/0x1930
    [<00000000001a9b9e>] lock_acquire+0xee/0x270
    [<0000000000951fee>] _raw_spin_lock_irqsave+0x66/0xb0
    [<0000000000390108>] aio_complete+0x98/0x328
    [<000000000037c7d4>] dio_complete+0xe4/0x1e0
    [<0000000000650e64>] blk_update_request+0xd4/0x450
    [<000000000072a1a8>] scsi_end_request+0x48/0x1c8
    [<000000000072d7e2>] scsi_io_completion+0x272/0x698
    [<000000000065adb2>] blk_done_softirq+0xca/0xe8
    [<0000000000953f80>] __do_softirq+0xc8/0x518
    [<00000000001495de>] irq_exit+0xee/0x110
    [<000000000010ceba>] do_IRQ+0x6a/0x88
    [<000000000095342e>] io_int_handler+0x11a/0x25c
    [<000000000094fb5c>] __mutex_unlock_slowpath+0x144/0x1d8
    [<000000000094fb58>] __mutex_unlock_slowpath+0x140/0x1d8
    [<00000000003c6114>] kernfs_iop_permission+0x64/0x80
    [<000000000033ba86>] __inode_permission+0x9e/0xf0
    [<000000000033ea96>] link_path_walk+0x6e/0x510
    [<000000000033f09c>] path_lookupat+0xc4/0x1a8
    [<000000000034195c>] filename_lookup+0x9c/0x160
    [<0000000000341b44>] user_path_at_empty+0x5c/0x70
    [<0000000000335250>] SyS_readlinkat+0x68/0x140
    [<0000000000952f8e>] system_call+0xd6/0x270
  irq event stamp: 971410
  hardirqs last  enabled at (971409): [<000000000030f982>] migrate_page_move_mapping+0x3ea/0x588
  hardirqs last disabled at (971410): [<0000000000951fc4>] _raw_spin_lock_irqsave+0x3c/0xb0
  softirqs last  enabled at (970526): [<0000000000954318>] __do_softirq+0x460/0x518
  softirqs last disabled at (970519): [<00000000001495de>] irq_exit+0xee/0x110

  other info that might help us debug this:
   Possible unsafe locking scenario:

	 CPU0
	 ----
    lock(&(&ctx->completion_lock)->rlock);
    <Interrupt>
      lock(&(&ctx->completion_lock)->rlock);

    *** DEADLOCK ***

  3 locks held by kcompactd0/151:
   #0:  (&(&mapping->private_lock)->rlock){+.+.-.}, at: [<000000000038fc82>] aio_migratepage+0x42/0x1e8
   #1:  (&ctx->ring_lock){+.+.+.}, at: [<000000000038fc9a>] aio_migratepage+0x5a/0x1e8
   #2:  (&(&ctx->completion_lock)->rlock){+.?.-.}, at: [<000000000038fd96>] aio_migratepage+0x156/0x1e8

  stack backtrace:
  CPU: 20 PID: 151 Comm: kcompactd0 Tainted: G        W       4.7.0-rc1+ #52
	 00000001c6cbb730 00000001c6cbb7c0 0000000000000002 0000000000000000 
	 00000001c6cbb860 00000001c6cbb7d8 00000001c6cbb7d8 0000000000114496 
	 0000000000000000 0000000000b517ec 0000000000b680b6 000000000000000b 
	 00000001c6cbb820 00000001c6cbb7c0 0000000000000000 0000000000000000 
	 040000000184ad18 0000000000114496 00000001c6cbb7c0 00000001c6cbb820 
  Call Trace:
  ([<00000000001143d2>] show_trace+0xea/0xf0)
  ([<000000000011444a>] show_stack+0x72/0xf0)
  ([<0000000000684522>] dump_stack+0x9a/0xd8)
  ([<000000000028679c>] print_usage_bug.part.27+0x2d4/0x2e8)
  ([<00000000001a71ce>] mark_lock+0x17e/0x758)
  ([<00000000001a784a>] mark_held_locks+0xa2/0xd0)
  ([<00000000001a79b8>] trace_hardirqs_on_caller+0x140/0x1c0)
  ([<0000000000326026>] mem_cgroup_migrate+0x266/0x370)
  ([<000000000038fdaa>] aio_migratepage+0x16a/0x1e8)
  ([<0000000000310568>] move_to_new_page+0xb0/0x260)
  ([<00000000003111b4>] migrate_pages+0x8f4/0x9f0)
  ([<00000000002c507c>] compact_zone+0x4dc/0xdc8)
  ([<00000000002c5e22>] kcompactd_do_work+0x1aa/0x358)
  ([<00000000002c608a>] kcompactd+0xba/0x2c8)
  ([<000000000016b09a>] kthread+0x10a/0x110)
  ([<000000000095315a>] kernel_thread_starter+0x6/0xc)
  ([<0000000000953154>] kernel_thread_starter+0x0/0xc)
  INFO: lockdep is turned off.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Link: http://lkml.kernel.org/g/5767CFE5.7080904@de.ibm.com
---
 mm/memcontrol.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75e7440..d4a33e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5544,6 +5544,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 	struct mem_cgroup *memcg;
 	unsigned int nr_pages;
 	bool compound;
+	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
@@ -5574,10 +5575,10 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 
 	commit_charge(newpage, memcg, false);
 
-	local_irq_disable();
+	local_irq_save(flags);
 	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
 	memcg_check_events(memcg, newpage);
-	local_irq_enable();
+	local_irq_restore(flags);
 }
 
 DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
