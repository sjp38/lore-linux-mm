Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 51FF66B0070
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:39:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 30 May 2012 20:09:46 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4UEdhZL61931540
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:09:43 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4UK8wLJ026792
	for <linux-mm@kvack.org>; Thu, 31 May 2012 06:08:59 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 07/14] mm/page_cgroup: Make page_cgroup point to the cgroup rather than the mem_cgroup
Date: Wed, 30 May 2012 20:08:52 +0530
Message-Id: <1338388739-22919-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use it later to make page_cgroup track the hugetlb cgroup information.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/mmzone.h      |    2 +-
 include/linux/page_cgroup.h |    8 ++++----
 init/Kconfig                |    4 ++++
 mm/Makefile                 |    3 ++-
 mm/memcontrol.c             |   42 +++++++++++++++++++++++++-----------------
 5 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2427706..2483cc5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1052,7 +1052,7 @@ struct mem_section {
 
 	/* See declaration of similar field in struct zone */
 	unsigned long *pageblock_flags;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_PAGE_CGROUP
 	/*
 	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
 	 * section. (see memcontrol.h/page_cgroup.h about this.)
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index a88cdba..7bbfe37 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -12,7 +12,7 @@ enum {
 #ifndef __GENERATING_BOUNDS_H
 #include <generated/bounds.h>
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_PAGE_CGROUP
 #include <linux/bit_spinlock.h>
 
 /*
@@ -24,7 +24,7 @@ enum {
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
+	struct cgroup *cgroup;
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -82,7 +82,7 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+#else /* CONFIG_PAGE_CGROUP */
 struct page_cgroup;
 
 static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
@@ -102,7 +102,7 @@ static inline void __init page_cgroup_init_flatmem(void)
 {
 }
 
-#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+#endif /* CONFIG_PAGE_CGROUP */
 
 #include <linux/swap.h>
 
diff --git a/init/Kconfig b/init/Kconfig
index 81816b8..1363203 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -687,10 +687,14 @@ config RESOURCE_COUNTERS
 	  This option enables controller independent resource accounting
 	  infrastructure that works with cgroups.
 
+config PAGE_CGROUP
+       bool
+
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS
 	select MM_OWNER
+	select PAGE_CGROUP
 	help
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
diff --git a/mm/Makefile b/mm/Makefile
index a156285..a70f9a9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -47,7 +47,8 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_PAGE_CGROUP) += page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac35bcc..6df019b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -864,6 +864,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 
 struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
+	if (!cont)
+		return NULL;
 	return container_of(cgroup_subsys_state(cont,
 				mem_cgroup_subsys_id), struct mem_cgroup,
 				css);
@@ -1097,7 +1099,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 		return &zone->lruvec;
 
 	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
+	memcg = mem_cgroup_from_cont(pc->cgroup);
 
 	/*
 	 * Surreptitiously switch any uncharged offlist page to root:
@@ -1108,8 +1110,10 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 	 * under page_cgroup lock: between them, they make all uses
 	 * of pc->mem_cgroup safe.
 	 */
-	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup)
-		pc->mem_cgroup = memcg = root_mem_cgroup;
+	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
+		memcg = root_mem_cgroup;
+		pc->cgroup = memcg->css.cgroup;
+	}
 
 	mz = page_cgroup_zoneinfo(memcg, page);
 	return &mz->lruvec;
@@ -1889,12 +1893,14 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 void __mem_cgroup_begin_update_page_stat(struct page *page,
 				bool *locked, unsigned long *flags)
 {
+	struct cgroup *cgroup;
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
 
 	pc = lookup_page_cgroup(page);
 again:
-	memcg = pc->mem_cgroup;
+	cgroup = pc->cgroup;
+	memcg = mem_cgroup_from_cont(cgroup);
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 	/*
@@ -1907,7 +1913,7 @@ again:
 		return;
 
 	move_lock_mem_cgroup(memcg, flags);
-	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
+	if (cgroup != pc->cgroup || !PageCgroupUsed(pc)) {
 		move_unlock_mem_cgroup(memcg, flags);
 		goto again;
 	}
@@ -1923,7 +1929,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 	 * lock is held because a routine modifies pc->mem_cgroup
 	 * should take move_lock_page_cgroup().
 	 */
-	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
+	move_unlock_mem_cgroup(mem_cgroup_from_cont(pc->cgroup), flags);
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
@@ -1936,7 +1942,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	if (mem_cgroup_disabled())
 		return;
 
-	memcg = pc->mem_cgroup;
+	memcg = mem_cgroup_from_cont(pc->cgroup);
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
@@ -2444,7 +2450,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = mem_cgroup_from_cont(pc->cgroup);
 		if (memcg && !css_tryget(&memcg->css))
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
@@ -2491,14 +2497,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 		zone = page_zone(page);
 		spin_lock_irq(&zone->lru_lock);
 		if (PageLRU(page)) {
-			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+			lruvec = mem_cgroup_zone_lruvec(zone,
+					mem_cgroup_from_cont(pc->cgroup));
 			ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_lru(page));
 			was_on_lru = true;
 		}
 	}
 
-	pc->mem_cgroup = memcg;
+	pc->cgroup = memcg->css.cgroup;
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -2511,7 +2518,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 	if (lrucare) {
 		if (was_on_lru) {
-			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+			lruvec = mem_cgroup_zone_lruvec(zone,
+					mem_cgroup_from_cont(pc->cgroup));
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			add_page_to_lru_list(page, lruvec, page_lru(page));
@@ -2601,7 +2609,7 @@ static int mem_cgroup_move_account(struct page *page,
 	lock_page_cgroup(pc);
 
 	ret = -EINVAL;
-	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
+	if (!PageCgroupUsed(pc) || pc->cgroup != from->css.cgroup)
 		goto unlock;
 
 	move_lock_mem_cgroup(from, &flags);
@@ -2616,7 +2624,7 @@ static int mem_cgroup_move_account(struct page *page,
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc->cgroup = to->css.cgroup;
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2937,7 +2945,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	lock_page_cgroup(pc);
 
-	memcg = pc->mem_cgroup;
+	memcg = mem_cgroup_from_cont(pc->cgroup);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -3183,7 +3191,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = mem_cgroup_from_cont(pc->cgroup);
 		css_get(&memcg->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -3328,7 +3336,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = mem_cgroup_from_cont(pc->cgroup);
 		mem_cgroup_charge_statistics(memcg, false, -1);
 		ClearPageCgroupUsed(pc);
 	}
@@ -5135,7 +5143,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) && pc->cgroup == mc.from->css.cgroup) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
