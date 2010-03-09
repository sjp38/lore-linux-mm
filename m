Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 976686B00D2
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 18:01:04 -0500 (EST)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Wed, 10 Mar 2010 00:00:32 +0100
Message-Id: <1268175636-4673-2-git-send-email-arighi@develer.com>
In-Reply-To: <1268175636-4673-1-git-send-email-arighi@develer.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

In current implementation, we don't have to disable irq at lock_page_cgroup()
because the lock is never acquired in interrupt context.
But we are going to call it in later patch in an interrupt context or with
irq disabled, so this patch disables irq at lock_page_cgroup() and enables it
at unlock_page_cgroup().

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |   16 ++++++++++++++--
 mm/memcontrol.c             |   43 +++++++++++++++++++++++++------------------
 2 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 30b0813..0d2f92c 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -83,16 +83,28 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 	return page_zonenum(pc->page);
 }
 
-static inline void lock_page_cgroup(struct page_cgroup *pc)
+static inline void __lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
 
-static inline void unlock_page_cgroup(struct page_cgroup *pc)
+static inline void __unlock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+#define lock_page_cgroup(pc, flags)		\
+	do {					\
+		local_irq_save(flags);		\
+		__lock_page_cgroup(pc);		\
+	} while (0)
+
+#define unlock_page_cgroup(pc, flags)		\
+	do {					\
+		__unlock_page_cgroup(pc);	\
+		local_irq_restore(flags);	\
+	} while (0)
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7fab84e..a9fd736 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1352,12 +1352,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	unsigned long flags;
 
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	mem = pc->mem_cgroup;
 	if (!mem)
 		goto done;
@@ -1371,7 +1372,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
 
 done:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 }
 
 /*
@@ -1705,11 +1706,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	struct page_cgroup *pc;
 	unsigned short id;
 	swp_entry_t ent;
+	unsigned long flags;
 
 	VM_BUG_ON(!PageLocked(page));
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
@@ -1723,7 +1725,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 			mem = NULL;
 		rcu_read_unlock();
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	return mem;
 }
 
@@ -1736,13 +1738,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 				     struct page_cgroup *pc,
 				     enum charge_type ctype)
 {
+	unsigned long flags;
+
 	/* try_charge() can return NULL to *memcg, taking care of it. */
 	if (!mem)
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup(pc, flags);
 		mem_cgroup_cancel_charge(mem);
 		return;
 	}
@@ -1772,7 +1776,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 
 	mem_cgroup_charge_statistics(mem, pc, true);
 
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
@@ -1842,12 +1846,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
-	lock_page_cgroup(pc);
+	unsigned long flags;
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	/*
 	 * check events
 	 */
@@ -1974,17 +1979,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	 */
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
-
+		unsigned long flags;
 
 		pc = lookup_page_cgroup(page);
 		if (!pc)
 			return 0;
-		lock_page_cgroup(pc);
+		lock_page_cgroup(pc, flags);
 		if (PageCgroupUsed(pc)) {
-			unlock_page_cgroup(pc);
+			unlock_page_cgroup(pc, flags);
 			return 0;
 		}
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup(pc, flags);
 	}
 
 	if (unlikely(!mm && !mem))
@@ -2166,6 +2171,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2180,7 +2186,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
 		return NULL;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 
 	mem = pc->mem_cgroup;
 
@@ -2219,7 +2225,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 */
 
 	mz = page_cgroup_zoneinfo(pc);
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 
 	memcg_check_events(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
@@ -2229,7 +2235,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	return mem;
 
 unlock_out:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	return NULL;
 }
 
@@ -2417,17 +2423,18 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	int ret = 0;
+	unsigned long flags;
 
 	if (mem_cgroup_disabled())
 		return 0;
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 
 	if (mem) {
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
