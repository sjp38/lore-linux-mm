Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABFB8D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:12:08 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v4 04/11] memcg: add lock to synchronize page accounting and migration
Date: Fri, 29 Oct 2010 00:09:07 -0700
Message-Id: <1288336154-23256-5-git-send-email-gthelen@google.com>
In-Reply-To: <1288336154-23256-1-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Introduce a new bit spin lock, PCG_MOVE_LOCK, to synchronize
the page accounting and migration code.  This reworks the
locking scheme of _update_stat() and _move_account() by
adding new lock bit PCG_MOVE_LOCK, which is always taken
under IRQ disable.

1. If pages are being migrated from a memcg, then updates to
   that memcg page statistics are protected by grabbing
   PCG_MOVE_LOCK using move_lock_page_cgroup().  In an
   upcoming commit, memcg dirty page accounting will be
   updating memcg page accounting (specifically: num
   writeback pages) from IRQ context (softirq).  Avoid a
   deadlocking nested spin lock attempt by disabling irq on
   the local processor when grabbing the PCG_MOVE_LOCK.

2. lock for update_page_stat is used only for avoiding race
   with move_account().  So, IRQ awareness of
   lock_page_cgroup() itself is not a problem.  The problem
   is between mem_cgroup_update_page_stat() and
   mem_cgroup_move_account_page().

Trade-off:
  * Changing lock_page_cgroup() to always disable IRQ (or
    local_bh) has some impacts on performance and I think
    it's bad to disable IRQ when it's not necessary.
  * adding a new lock makes move_account() slower.  Score is
    here.

Performance Impact: moving a 8G anon process.

Before:
	real    0m0.792s
	user    0m0.000s
	sys     0m0.780s

After:
	real    0m0.854s
	user    0m0.000s
	sys     0m0.842s

This score is bad but planned patches for optimization can reduce
this impact.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |   31 ++++++++++++++++++++++++++++---
 mm/memcontrol.c             |    9 +++++++--
 2 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index b59c298..509452e 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -35,15 +35,18 @@ struct page_cgroup *lookup_page_cgroup(struct page *page);
 
 enum {
 	/* flags for mem_cgroup */
-	PCG_LOCK,  /* page cgroup is locked */
+	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
-	PCG_ACCT_LRU, /* page has been accounted for */
+	PCG_MIGRATION, /* under page migration */
+	/* flags for mem_cgroup and file and I/O status */
+	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
 	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
 	PCG_FILE_DIRTY, /* page is dirty */
 	PCG_FILE_WRITEBACK, /* page is under writeback */
 	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
-	PCG_MIGRATION, /* under page migration */
+	/* No lock in page_cgroup */
+	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -119,6 +122,10 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
+	/*
+	 * Don't take this lock in IRQ context.
+	 * This lock is for pc->mem_cgroup, USED, CACHE, MIGRATION
+	 */
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
 
@@ -127,6 +134,24 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline void move_lock_page_cgroup(struct page_cgroup *pc,
+	unsigned long *flags)
+{
+	/*
+	 * We know updates to pc->flags of page cache's stats are from both of
+	 * usual context or IRQ context. Disable IRQ to avoid deadlock.
+	 */
+	local_irq_save(*flags);
+	bit_spin_lock(PCG_MOVE_LOCK, &pc->flags);
+}
+
+static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
+	unsigned long *flags)
+{
+	bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
+	local_irq_restore(*flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4fd00c4..94359d6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1598,6 +1598,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	bool need_unlock = false;
+	unsigned long uninitialized_var(flags);
 
 	if (unlikely(!pc))
 		return;
@@ -1609,7 +1610,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	/* pc->mem_cgroup is unstable ? */
 	if (unlikely(mem_cgroup_stealed(mem))) {
 		/* take a lock against to access pc->mem_cgroup */
-		lock_page_cgroup(pc);
+		move_lock_page_cgroup(pc, &flags);
 		need_unlock = true;
 		mem = pc->mem_cgroup;
 		if (!mem || !PageCgroupUsed(pc))
@@ -1632,7 +1633,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 
 out:
 	if (unlikely(need_unlock))
-		unlock_page_cgroup(pc);
+		move_unlock_page_cgroup(pc, &flags);
 	rcu_read_unlock();
 	return;
 }
@@ -2186,9 +2187,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
+	unsigned long flags;
+
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+		move_lock_page_cgroup(pc, &flags);
 		__mem_cgroup_move_account(pc, from, to, uncharge);
+		move_unlock_page_cgroup(pc, &flags);
 		ret = 0;
 	}
 	unlock_page_cgroup(pc);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
