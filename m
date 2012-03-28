Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 664106B007E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 06:49:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6B01C3EE0AE
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:49:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46A5F45DE58
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:49:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23C1345DE56
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:49:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 120AD1DB804F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:49:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D2A1DB8040
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:49:17 +0900 (JST)
Message-ID: <4F72EC43.3040105@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 19:47:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 1/6] memcg: add methods to access pc->mem_cgroup
References: <4F72EB84.7080000@jp.fujitsu.com>
In-Reply-To: <4F72EB84.7080000@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>


In order to encode pc->mem_cgroup and pc->flags to be in a word,
access function to pc->mem_cgroup is required.

This patch replaces access to pc->mem_cgroup with
 pc_to_mem_cgroup(pc)          : pc->mem_cgroup
 pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg

Changelog:
 - rebased onto linux-next-Mar 27 2012 handle THP move_page

Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   12 +++++++
 mm/memcontrol.c             |   71 ++++++++++++++++++++++--------------------
 2 files changed, 49 insertions(+), 34 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index a88cdba..92768cb 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -82,6 +82,18 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+
+static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
+{
+	return pc->mem_cgroup;
+}
+
+static inline void
+pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
+{
+	pc->mem_cgroup = memcg;
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2ee6df..8077460 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1034,9 +1034,9 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
- * What we have to take care of here is validness of pc->mem_cgroup.
+ * What we have to take care of here is validness of pc's mem_cgroup.
  *
- * Changes to pc->mem_cgroup happens when
+ * Changes to pc's mem_cgroup happens when
  * 1. charge
  * 2. moving account
  * In typical case, "charge" is done before add-to-lru. Exception is SwapCache.
@@ -1068,7 +1068,7 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 		return &zone->lruvec;
 
 	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 
 	/*
 	 * Surreptitiously switch any uncharged page to root:
@@ -1077,10 +1077,12 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 	 *
 	 * Our caller holds lru_lock, and PageCgroupUsed is updated
 	 * under page_cgroup lock: between them, they make all uses
-	 * of pc->mem_cgroup safe.
+	 * of pc's mem_cgroup safe.
 	 */
-	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
-		pc->mem_cgroup = memcg = root_mem_cgroup;
+	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
+		pc_set_mem_cgroup(pc, root_mem_cgroup);
+		memcg = root_mem_cgroup;
+	}
 
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* compound_order() is stabilized through lru_lock */
@@ -1108,7 +1110,7 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 		return;
 
 	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 	VM_BUG_ON(!memcg);
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
@@ -1255,9 +1257,9 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	if (!PageCgroupUsed(pc))
 		return NULL;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	/* Ensure pc's mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
+	mz = page_cgroup_zoneinfo(pc_to_mem_cgroup(pc), page);
 	return &mz->reclaim_stat;
 }
 
@@ -1334,7 +1336,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
  *
  * mem_cgroup_stolen() -  checking whether a cgroup is mc.from or not. This
  *			  is used for avoiding races in accounting.  If true,
- *			  pc->mem_cgroup may be overwritten.
+ *			  pc's mem_cgroup may be overwritten.
  *
  * mem_cgroup_under_move() - checking a cgroup is mc.from or mc.to or
  *			  under hierarchy of moving cgroups. This is for
@@ -1907,8 +1909,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
  * file-stat operations happen after a page is attached to radix-tree. There
  * are no race with "charge".
  *
- * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
- * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
+ * Considering "uncharge", we know that memcg doesn't clear pc's mem_cgroup
+ * at "uncharge" intentionally. So, we always see valid pc's mem_cgroup even
  * if there are race with "uncharge". Statistics itself is properly handled
  * by flags.
  *
@@ -1925,7 +1927,7 @@ void __mem_cgroup_begin_update_page_stat(struct page *page,
 
 	pc = lookup_page_cgroup(page);
 again:
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 	/*
@@ -1938,7 +1940,7 @@ again:
 		return;
 
 	move_lock_mem_cgroup(memcg, flags);
-	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
+	if (memcg != pc_to_mem_cgroup(pc) || !PageCgroupUsed(pc)) {
 		move_unlock_mem_cgroup(memcg, flags);
 		goto again;
 	}
@@ -1950,11 +1952,11 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
 	/*
-	 * It's guaranteed that pc->mem_cgroup never changes while
-	 * lock is held because a routine modifies pc->mem_cgroup
+	 * It's guaranteed that pc's mem_cgroup never changes while
+	 * lock is held because a routine modifies pc's mem_cgroup
 	 * should take move_lock_page_cgroup().
 	 */
-	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
+	move_unlock_mem_cgroup(pc_to_mem_cgroup(pc), flags);
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
@@ -1967,7 +1969,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	if (mem_cgroup_disabled())
 		return;
 
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
@@ -2264,7 +2266,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
  * has TIF_MEMDIE, this function returns -EINTR while writing root_mem_cgroup
  * to *ptr. There are two reasons for this. 1: fatal threads should quit as soon
  * as possible without any hazards. 2: all pages should have a valid
- * pc->mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
+ * pc's mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
  * pointer, that is treated as a charge to root_mem_cgroup.
  *
  * So __mem_cgroup_try_charge() will return
@@ -2457,7 +2459,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = pc_to_mem_cgroup(pc);
 		if (memcg && !css_tryget(&memcg->css))
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
@@ -2509,11 +2511,11 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 		}
 	}
 
-	pc->mem_cgroup = memcg;
+	pc_set_mem_cgroup(pc, memcg);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
-	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
+	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
+	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
 	 * before USED bit, we need memory barrier here.
 	 * See mem_cgroup_add_lru_list(), etc.
  	 */
@@ -2558,13 +2560,14 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 {
 	struct page_cgroup *head_pc = lookup_page_cgroup(head);
 	struct page_cgroup *pc;
+	struct mem_cgroup *memcg = pc_to_mem_cgroup(head_pc);
 	int i;
 
 	if (mem_cgroup_disabled())
 		return;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-		pc->mem_cgroup = head_pc->mem_cgroup;
+		pc_set_mem_cgroup(pc, memcg);
 		smp_wmb();/* see __commit_charge() */
 		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	}
@@ -2615,7 +2618,7 @@ static int mem_cgroup_move_account(struct page *page,
 	lock_page_cgroup(pc);
 
 	ret = -EINVAL;
-	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
+	if (!PageCgroupUsed(pc) || pc_to_mem_cgroup(pc) != from)
 		goto unlock;
 
 	move_lock_mem_cgroup(from, &flags);
@@ -2633,7 +2636,7 @@ static int mem_cgroup_move_account(struct page *page,
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc_set_mem_cgroup(pc, to);
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2976,7 +2979,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	lock_page_cgroup(pc);
 
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -3012,7 +3015,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	ClearPageCgroupUsed(pc);
 	/*
-	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
+	 * pc's mem_cgroup is not cleared here. It will be accessed when it's
 	 * freed from LRU. This is safe because uncharged page is expected not
 	 * to be reused (freed soon). Exception is SwapCache, it's handled by
 	 * special functions.
@@ -3234,7 +3237,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = pc_to_mem_cgroup(pc);
 		css_get(&memcg->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -3379,7 +3382,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	pc = lookup_page_cgroup(oldpage);
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_mem_cgroup(pc);
 	mem_cgroup_charge_statistics(memcg, false, -1);
 	ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
@@ -3390,7 +3393,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	/*
 	 * Even if newpage->mapping was NULL before starting replacement,
 	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
-	 * LRU while we overwrite pc->mem_cgroup.
+	 * LRU while we overwrite pc's mem_cgroup.
 	 */
 	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type, true);
 }
@@ -3426,7 +3429,7 @@ void mem_cgroup_print_bad_page(struct page *page)
 	pc = lookup_page_cgroup_used(page);
 	if (pc) {
 		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
-		       pc, pc->flags, pc->mem_cgroup);
+		       pc, pc->flags, pc_to_mem_cgroup(pc));
 	}
 }
 #endif
@@ -5238,7 +5241,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) && pc_to_mem_cgroup(pc) == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;
@@ -5274,7 +5277,7 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	if (!move_anon())
 		return ret;
 	pc = lookup_page_cgroup(page);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+	if (PageCgroupUsed(pc) && pc_to_mem_cgroup(pc) == mc.from) {
 		ret = MC_TARGET_PAGE;
 		if (target) {
 			get_page(page);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
