Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA26iPQm015420
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 2 Nov 2008 15:44:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E1B02AC027
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 15:44:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1133F12C044
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 15:44:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7B8A1DB8037
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 15:44:24 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9398A1DB8038
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 15:44:24 +0900 (JST)
Date: Sun, 2 Nov 2008 15:43:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/5] memcg : synchronous LRU
Message-Id: <20081102154352.400411fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

This one is just an experimental. (means may cause panic easily)

==
Experimental!

Now,
  - page and page_cgroup is one-to-one and statically allocated.
    Then, page-to-pc and pc-to-page is always valid.
  - we can trust PCG_USED bit.

Then, it seems that there is a chance to synchronize mem cgroup's lru
and global lru....in other words, remove mz->lru_lock and depends on zone->lru_lock.

This patch also modifies mem_cgroup's LRU to be just a sub-lru of zone....
memcg's LRU is not independent from global LRU after this.

Pros.
  - easy maintainance.
  - we can reduce types of lock.
  - we don't have to duplicate LRU_ flags.
  - memcg can make use of laziness of pagevec.
  - when we make use of zone->lru_lock, the lock is not per memcg and 
    this is much robust than mz->lru_lock which depends on pc->mem_cgroup value.
Cons.
  - may increase cost of LRU rotation.
    (no impact if memcg is not configured.)

Signed-off-by: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

 fs/splice.c                 |    1 
 include/linux/memcontrol.h  |   29 +++-
 include/linux/mm_inline.h   |    3 
 include/linux/page_cgroup.h |   17 --
 mm/memcontrol.c             |  307 +++++++++++++++++---------------------------
 mm/page_cgroup.c            |    1 
 mm/swap.c                   |    1 
 mm/vmscan.c                 |    9 -
 8 files changed, 162 insertions(+), 206 deletions(-)

Index: mmotm-2.6.28-rc2-Oct30/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2-Oct30/mm/memcontrol.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include "internal.h"
 
 #include <asm/uaccess.h>
 
@@ -99,7 +100,6 @@ struct mem_cgroup_per_zone {
 	/*
 	 * spin_lock to protect the per cgroup LRU
 	 */
-	spinlock_t		lru_lock;
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
 };
@@ -167,14 +167,12 @@ enum charge_type {
 /* only for here (for easy reading.) */
 #define PCGF_CACHE	(1UL << PCG_CACHE)
 #define PCGF_USED	(1UL << PCG_USED)
-#define PCGF_ACTIVE	(1UL << PCG_ACTIVE)
 #define PCGF_LOCK	(1UL << PCG_LOCK)
-#define PCGF_FILE	(1UL << PCG_FILE)
 static const unsigned long
 pcg_default_flags[NR_CHARGE_TYPE] = {
-	PCGF_CACHE | PCGF_FILE | PCGF_USED | PCGF_LOCK, /* File Cache */
-	PCGF_ACTIVE | PCGF_USED | PCGF_LOCK, /* Anon */
-	PCGF_ACTIVE | PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* Shmem */
+	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* File Cache */
+	PCGF_USED | PCGF_LOCK, /* Anon */
+	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* Shmem */
 	0, /* FORCE */
 };
 
@@ -188,9 +186,6 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 
 static void mem_cgroup_forget_swapref(struct mem_cgroup *mem);
 
-/*
- * Always modified under lru lock. Then, not necessary to preempt_disable()
- */
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -198,10 +193,9 @@ static void mem_cgroup_charge_statistics
 	int val = (charge)? 1 : -1;
 	struct mem_cgroup_stat *stat = &mem->stat;
 	struct mem_cgroup_stat_cpu *cpustat;
+	int cpu = get_cpu();
 
-	VM_BUG_ON(!irqs_disabled());
-
-	cpustat = &stat->cpustat[smp_processor_id()];
+	cpustat = &stat->cpustat[cpu];
 	if (PageCgroupCache(pc))
 		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
 	else
@@ -213,6 +207,7 @@ static void mem_cgroup_charge_statistics
 	else
 		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
+	put_cpu();
 }
 
 static struct mem_cgroup_per_zone *
@@ -267,80 +262,91 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
-			struct page_cgroup *pc)
-{
-	int lru = LRU_BASE;
+/*
+ * Following LRU functions are allowed to be used without PCG_LOCK.
+ * Operations are called by routine of global LRU independently from memcg.
+ * What we have to take care of here is validness of pc->mem_cgroup.
+ *
+ * Changes to pc->mem_cgroup happens when
+ * 1. charge
+ * 2. moving account
+ * In typical case, "charge" is done before add-to-lru. Exception is SwapCache.
+ * It is added to LRU before charge.
+ * If PCG_USED bit is not set, page_cgroup is not added to this private LRU.
+ * When moving account, the page is not on LRU. It's isolated.
+ */
 
-	if (PageCgroupUnevictable(pc))
-		lru = LRU_UNEVICTABLE;
-	else {
-		if (PageCgroupActive(pc))
-			lru += LRU_ACTIVE;
-		if (PageCgroupFile(pc))
-			lru += LRU_FILE;
-	}
+void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+	struct mem_cgroup_per_zone *mz;
 
+	if (mem_cgroup_subsys.disabled)
+		return;
+	pc = lookup_page_cgroup(page);
+	/* can happen while we handle swapcache */
+	if (list_empty(&pc->lru))
+		return;
+	mz = page_cgroup_zoneinfo(pc);
+	mem = pc->mem_cgroup;
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
-
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, false);
-	list_del(&pc->lru);
+	list_del_init(&pc->lru);
+	return;
 }
 
-static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
-				struct page_cgroup *pc, bool hot)
+void mem_cgroup_del_lru(struct page *page)
 {
-	int lru = LRU_BASE;
+	mem_cgroup_del_lru_list(page, page_lru(page));
+}
 
-	if (PageCgroupUnevictable(pc))
-		lru = LRU_UNEVICTABLE;
-	else {
-		if (PageCgroupActive(pc))
-			lru += LRU_ACTIVE;
-		if (PageCgroupFile(pc))
-			lru += LRU_FILE;
-	}
+void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
 
-	MEM_CGROUP_ZSTAT(mz, lru) += 1;
-	if (hot)
-		list_add(&pc->lru, &mz->lists[lru]);
-	else
-		list_add_tail(&pc->lru, &mz->lists[lru]);
+	if (mem_cgroup_subsys.disabled)
+		return;
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, true);
+	pc = lookup_page_cgroup(page);
+	mz = page_cgroup_zoneinfo(pc);
+	list_move(&pc->lru, &mz->lists[lru]);
 }
 
-static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
+void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 {
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int active    = PageCgroupActive(pc);
-	int file      = PageCgroupFile(pc);
-	int unevictable = PageCgroupUnevictable(pc);
-	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
-				(LRU_FILE * !!file + !!active);
+	struct page_cgroup *pc;
+	struct mem_cgroup_per_zone *mz;
 
-	if (lru == from)
+	if (mem_cgroup_subsys.disabled)
+		return;
+	pc = lookup_page_cgroup(page);
+	/* barrier to sync with "charge" */
+	smp_rmb();
+	if (!PageCgroupUsed(pc))
 		return;
 
-	MEM_CGROUP_ZSTAT(mz, from) -= 1;
-	/*
-	 * However this is done under mz->lru_lock, another flags, which
-	 * are not related to LRU, will be modified from out-of-lock.
-	 * We have to use atomic set/clear flags.
-	 */
-	if (is_unevictable_lru(lru)) {
-		ClearPageCgroupActive(pc);
-		SetPageCgroupUnevictable(pc);
-	} else {
-		if (is_active_lru(lru))
-			SetPageCgroupActive(pc);
-		else
-			ClearPageCgroupActive(pc);
-		ClearPageCgroupUnevictable(pc);
-	}
-
+	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
-	list_move(&pc->lru, &mz->lists[lru]);
+	list_add(&pc->lru, &mz->lists[lru]);
+}
+/*
+ * To add swapcache into LRU. Be careful to all this function.
+ * zone->lru_lock shouldn't be held and irq must not be disabled.
+ */
+static void mem_cgroup_lru_fixup(struct page *page)
+{
+	if (!isolate_lru_page(page))
+		putback_lru_page(page);
+}
+
+void mem_cgroup_move_lists(struct page *page,
+			   enum lru_list from, enum lru_list to)
+{
+	if (mem_cgroup_subsys.disabled)
+		return;
+	mem_cgroup_del_lru_list(page, from);
+	mem_cgroup_add_lru_list(page, to);
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -354,37 +360,6 @@ int task_in_mem_cgroup(struct task_struc
 }
 
 /*
- * This routine assumes that the appropriate zone's lru lock is already held
- */
-void mem_cgroup_move_lists(struct page *page, enum lru_list lru)
-{
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
-	if (mem_cgroup_subsys.disabled)
-		return;
-
-	/*
-	 * We cannot lock_page_cgroup while holding zone's lru_lock,
-	 * because other holders of lock_page_cgroup can be interrupted
-	 * with an attempt to rotate_reclaimable_page.  But we cannot
-	 * safely get to page_cgroup without it, so just try_lock it:
-	 * mem_cgroup_isolate_pages allows for page left on wrong list.
-	 */
-	pc = lookup_page_cgroup(page);
-	if (!trylock_page_cgroup(pc))
-		return;
-	if (pc && PageCgroupUsed(pc)) {
-		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, lru);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-	}
-	unlock_page_cgroup(pc);
-}
-
-/*
  * Calculate mapped_ratio under memory controller. This will be used in
  * vmscan.c for deteremining we have to reclaim mapped pages.
  */
@@ -463,40 +438,24 @@ unsigned long mem_cgroup_isolate_pages(u
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
 	src = &mz->lists[lru];
 
-	spin_lock(&mz->lru_lock);
 	scan = 0;
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
+
+		page = pc->page;
 		if (unlikely(!PageCgroupUsed(pc)))
 			continue;
-		page = pc->page;
-
 		if (unlikely(!PageLRU(page)))
 			continue;
 
-		/*
-		 * TODO: play better with lumpy reclaim, grabbing anything.
-		 */
-		if (PageUnevictable(page) ||
-		    (PageActive(page) && !active) ||
-		    (!PageActive(page) && active)) {
-			__mem_cgroup_move_lists(pc, page_lru(page));
-			continue;
-		}
-
 		scan++;
-		list_move(&pc->lru, &pc_list);
-
 		if (__isolate_lru_page(page, mode, file) == 0) {
 			list_move(&page->lru, dst);
 			nr_taken++;
 		}
 	}
 
-	list_splice(&pc_list, src);
-	spin_unlock(&mz->lru_lock);
-
 	*scanned = scan;
 	return nr_taken;
 }
@@ -610,9 +569,6 @@ static void __mem_cgroup_commit_charge(s
 				     struct page_cgroup *pc,
 				     enum charge_type ctype)
 {
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
 	/* try_charge() can return NULL to *memcg, taking care of it. */
 	if (!mem)
 		return;
@@ -627,17 +583,11 @@ static void __mem_cgroup_commit_charge(s
 		return;
 	}
 	pc->mem_cgroup = mem;
-	/*
-	 * If a page is accounted as a page cache, insert to inactive list.
-	 * If anon, insert to active list.
-	 */
+	smp_wmb();
 	pc->flags = pcg_default_flags[ctype];
 
-	mz = page_cgroup_zoneinfo(pc);
+	mem_cgroup_charge_statistics(mem, pc, true);
 
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc, true);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	unlock_page_cgroup(pc);
 }
 
@@ -648,8 +598,7 @@ static void __mem_cgroup_commit_charge(s
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  *
  * The caller must confirm following.
- * 1. disable irq.
- * 2. lru_lock of old mem_cgroup(@from) should be held.
+ * - page is not on LRU
  *
  * returns 0 at success,
  * returns -EBUSY when lock is busy or "pc" is unstable.
@@ -665,15 +614,14 @@ static int mem_cgroup_move_account(struc
 	int nid, zid;
 	int ret = -EBUSY;
 
-	VM_BUG_ON(!irqs_disabled());
 	VM_BUG_ON(from == to);
+	VM_BUG_ON(PageLRU(pc->page));
 
 	nid = page_cgroup_nid(pc);
 	zid = page_cgroup_zid(pc);
 	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
 	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
 
-
 	if (!trylock_page_cgroup(pc))
 		return ret;
 
@@ -683,18 +631,14 @@ static int mem_cgroup_move_account(struc
 	if (pc->mem_cgroup != from)
 		goto out;
 
-	if (spin_trylock(&to_mz->lru_lock)) {
-		__mem_cgroup_remove_list(from_mz, pc);
-		css_put(&from->css);
-		res_counter_uncharge(&from->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&from->memsw, PAGE_SIZE);
-		pc->mem_cgroup = to;
-		css_get(&to->css);
-		__mem_cgroup_add_list(to_mz, pc, false);
-		ret = 0;
-		spin_unlock(&to_mz->lru_lock);
-	}
+	css_put(&from->css);
+	res_counter_uncharge(&from->res, PAGE_SIZE);
+	mem_cgroup_charge_statistics(from, pc, false);
+	if (do_swap_account)
+		res_counter_uncharge(&from->memsw, PAGE_SIZE);
+	pc->mem_cgroup = to;
+	css_get(&to->css);
+	ret = 0;
 out:
 	unlock_page_cgroup(pc);
 	return ret;
@@ -708,11 +652,10 @@ static int mem_cgroup_move_parent(struct
 				  struct mem_cgroup *child,
 				  gfp_t gfp_mask)
 {
+	struct page *page = pc->page;
 	struct cgroup *cg = child->css.cgroup;
 	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 	int ret;
 
 	/* Is ROOT ? */
@@ -725,22 +668,23 @@ static int mem_cgroup_move_parent(struct
 	if (ret)
 		return ret;
 
-	mz = mem_cgroup_zoneinfo(child,
-			page_cgroup_nid(pc), page_cgroup_zid(pc));
+	ret = isolate_lru_page(page);
+
+	if (ret)
+		goto cancel;
 
-	spin_lock_irqsave(&mz->lru_lock, flags);
 	ret = mem_cgroup_move_account(pc, child, parent);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	/* drop extra refcnt */
+	/* drop extra refcnt by try_charge() (move_account increment one) */
 	css_put(&parent->css);
+	putback_lru_page(page);
+	if (!ret)
+		return 0;
 	/* uncharge if move fails */
-	if (ret) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
-	}
-
+cancel:
+	res_counter_uncharge(&parent->res, PAGE_SIZE);
+	if (do_swap_account)
+		res_counter_uncharge(&parent->memsw, PAGE_SIZE);
 	return ret;
 }
 
@@ -905,6 +849,7 @@ int mem_cgroup_cache_charge_swapin(struc
 			mem_cgroup_forget_swapref(mem);
 		}
 	}
+	mem_cgroup_lru_fixup(page);
 unlock_out:
 	if (!locked)
 		unlock_page(page);
@@ -940,6 +885,7 @@ void mem_cgroup_commit_charge_swapin(str
 		}
 
 	}
+	mem_cgroup_lru_fixup(page);
 }
 
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
@@ -963,7 +909,6 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return NULL;
@@ -1008,9 +953,6 @@ __mem_cgroup_uncharge_common(struct page
 	ClearPageCgroupUsed(pc);
 
 	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	unlock_page_cgroup(pc);
 
 	css_put(&mem->css);
@@ -1259,21 +1201,22 @@ int mem_cgroup_resize_memsw_limit(struct
 	return ret;
 }
 
-
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
-			    struct mem_cgroup_per_zone *mz,
-			    enum lru_list lru)
+				int node, int zid, enum lru_list lru)
 {
+	struct zone *zone;
+	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc, *busy;
-	unsigned long flags;
-	unsigned long loop;
+	unsigned long flags, loop;
 	struct list_head *list;
 	int ret = 0;
 
+	zone = &NODE_DATA(node)->node_zones[zid];
+	mz = mem_cgroup_zoneinfo(mem, node, zid);
 	list = &mz->lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
@@ -1282,19 +1225,19 @@ static int mem_cgroup_force_empty_list(s
 	busy = NULL;
 	while (loop--) {
 		ret = 0;
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		spin_lock_irqsave(&zone->lru_lock, flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			break;
 		}
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		if (busy == pc) {
 			list_move(&pc->lru, list);
 			busy = 0;
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 		ret = mem_cgroup_move_parent(pc, mem, GFP_HIGHUSER_MOVABLE);
 		if (ret == -ENOMEM)
@@ -1307,6 +1250,7 @@ static int mem_cgroup_force_empty_list(s
 		} else
 			busy = NULL;
 	}
+
 	if (!ret && !list_empty(list))
 		return -EBUSY;
 	return ret;
@@ -1336,12 +1280,10 @@ move_account:
 		ret = 0;
 		for_each_node_state(node, N_POSSIBLE) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
-				struct mem_cgroup_per_zone *mz;
 				enum lru_list l;
-				mz = mem_cgroup_zoneinfo(mem, node, zid);
 				for_each_lru(l) {
 					ret = mem_cgroup_force_empty_list(mem,
-								  mz, l);
+							node, zid, l);
 					if (ret)
 						break;
 				}
@@ -1375,6 +1317,7 @@ try_to_free:
 			nr_retries--;
 
 	}
+	lru_add_drain();
 	/* try move_account...there may be some *locked* pages. */
 	if (mem->res.usage)
 		goto move_account;
@@ -1595,7 +1538,6 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		spin_lock_init(&mz->lru_lock);
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
 	}
@@ -1637,10 +1579,17 @@ static struct mem_cgroup *mem_cgroup_all
 
 static void mem_cgroup_free(struct mem_cgroup *mem)
 {
+	int node;
+
 	if (do_swap_account) {
 		if (atomic_read(&mem->swapref) > 0)
 			return;
 	}
+
+
+	for_each_node_state(node, N_POSSIBLE)
+		free_mem_cgroup_per_zone_info(mem, node);
+
 	if (sizeof(*mem) < PAGE_SIZE)
 		kfree(mem);
 	else
@@ -1713,12 +1662,6 @@ static void mem_cgroup_pre_destroy(struc
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	int node;
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-
-	for_each_node_state(node, N_POSSIBLE)
-		free_mem_cgroup_per_zone_info(mem, node);
-
 	mem_cgroup_free(mem_cgroup_from_cont(cont));
 }
 
Index: mmotm-2.6.28-rc2-Oct30/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-rc2-Oct30/include/linux/memcontrol.h
@@ -40,7 +40,12 @@ extern void mem_cgroup_cancel_charge_swa
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
+extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
+extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
+extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
+extern void mem_cgroup_del_lru(struct page *page);
+extern void mem_cgroup_move_lists(struct page *page,
+				  enum lru_list from, enum lru_list to);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
@@ -131,7 +136,27 @@ static inline int mem_cgroup_shrink_usag
 	return 0;
 }
 
-static inline void mem_cgroup_move_lists(struct page *page, bool active)
+static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
+{
+}
+
+static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
+{
+	return ;
+}
+
+static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
+{
+	return ;
+}
+
+static inline void mem_cgroup_del_lru(struct page *page)
+{
+	return ;
+}
+
+static inline void
+mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_list to)
 {
 }
 
Index: mmotm-2.6.28-rc2-Oct30/include/linux/mm_inline.h
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/include/linux/mm_inline.h
+++ mmotm-2.6.28-rc2-Oct30/include/linux/mm_inline.h
@@ -28,6 +28,7 @@ add_page_to_lru_list(struct zone *zone, 
 {
 	list_add(&page->lru, &zone->lru[l].list);
 	__inc_zone_state(zone, NR_LRU_BASE + l);
+	mem_cgroup_add_lru_list(page, l);
 }
 
 static inline void
@@ -35,6 +36,7 @@ del_page_from_lru_list(struct zone *zone
 {
 	list_del(&page->lru);
 	__dec_zone_state(zone, NR_LRU_BASE + l);
+	mem_cgroup_del_lru_list(page, l);
 }
 
 static inline void
@@ -54,6 +56,7 @@ del_page_from_lru(struct zone *zone, str
 		l += page_is_file_cache(page);
 	}
 	__dec_zone_state(zone, NR_LRU_BASE + l);
+	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
Index: mmotm-2.6.28-rc2-Oct30/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-rc2-Oct30/mm/page_cgroup.c
@@ -17,6 +17,7 @@ __init_page_cgroup(struct page_cgroup *p
 	pc->flags = 0;
 	pc->mem_cgroup = NULL;
 	pc->page = pfn_to_page(pfn);
+	INIT_LIST_HEAD(&pc->lru);
 }
 static unsigned long total_usage;
 
Index: mmotm-2.6.28-rc2-Oct30/fs/splice.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/fs/splice.c
+++ mmotm-2.6.28-rc2-Oct30/fs/splice.c
@@ -21,6 +21,7 @@
 #include <linux/file.h>
 #include <linux/pagemap.h>
 #include <linux/splice.h>
+#include <linux/memcontrol.h>
 #include <linux/mm_inline.h>
 #include <linux/swap.h>
 #include <linux/writeback.h>
Index: mmotm-2.6.28-rc2-Oct30/mm/vmscan.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/mm/vmscan.c
+++ mmotm-2.6.28-rc2-Oct30/mm/vmscan.c
@@ -516,7 +516,6 @@ redo:
 		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
 	}
-	mem_cgroup_move_lists(page, lru);
 
 	/*
 	 * page's status can change while we move it among lru. If an evictable
@@ -551,7 +550,6 @@ void putback_lru_page(struct page *page)
 
 	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
 	lru_cache_add_lru(page, lru);
-	mem_cgroup_move_lists(page, lru);
 	put_page(page);
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
@@ -823,6 +821,7 @@ int __isolate_lru_page(struct page *page
 		return ret;
 
 	ret = -EBUSY;
+
 	if (likely(get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
@@ -831,6 +830,7 @@ int __isolate_lru_page(struct page *page
 		 */
 		ClearPageLRU(page);
 		ret = 0;
+		mem_cgroup_del_lru(page);
 	}
 
 	return ret;
@@ -1144,7 +1144,6 @@ static unsigned long shrink_inactive_lis
 			SetPageLRU(page);
 			lru = page_lru(page);
 			add_page_to_lru_list(zone, page, lru);
-			mem_cgroup_move_lists(page, lru);
 			if (PageActive(page) && scan_global_lru(sc)) {
 				int file = !!page_is_file_cache(page);
 				zone->recent_rotated[file]++;
@@ -1277,7 +1276,7 @@ static void shrink_active_list(unsigned 
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_move_lists(page, lru);
+		mem_cgroup_add_lru_list(page, lru);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
@@ -2436,6 +2435,7 @@ retry:
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
 		list_move(&page->lru, &zone->lru[l].list);
+		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
@@ -2444,6 +2444,7 @@ retry:
 		 */
 		SetPageUnevictable(page);
 		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
+		mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
 		if (page_evictable(page, NULL))
 			goto retry;
 	}
Index: mmotm-2.6.28-rc2-Oct30/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.28-rc2-Oct30/include/linux/page_cgroup.h
@@ -26,10 +26,6 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
-	/* flags for LRU placement */
-	PCG_ACTIVE, /* page is active in this cgroup */
-	PCG_FILE, /* page is file system backed */
-	PCG_UNEVICTABLE, /* page is unevictableable */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -50,19 +46,6 @@ TESTPCGFLAG(Cache, CACHE)
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
-/* LRU management flags (from global-lru definition) */
-TESTPCGFLAG(File, FILE)
-SETPCGFLAG(File, FILE)
-CLEARPCGFLAG(File, FILE)
-
-TESTPCGFLAG(Active, ACTIVE)
-SETPCGFLAG(Active, ACTIVE)
-CLEARPCGFLAG(Active, ACTIVE)
-
-TESTPCGFLAG(Unevictable, UNEVICTABLE)
-SETPCGFLAG(Unevictable, UNEVICTABLE)
-CLEARPCGFLAG(Unevictable, UNEVICTABLE)
-
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
Index: mmotm-2.6.28-rc2-Oct30/mm/swap.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/mm/swap.c
+++ mmotm-2.6.28-rc2-Oct30/mm/swap.c
@@ -168,7 +168,6 @@ void activate_page(struct page *page)
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page, lru);
 
 		zone->recent_rotated[!!file]++;
 		zone->recent_scanned[!!file]++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
