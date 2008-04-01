Date: Tue, 1 Apr 2008 17:34:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 5/6] remove refcnt use mapcount
Message-Id: <20080401173402.dc20fd06.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

This patch removes page_cgroup->refcnt.
Instead of page_cgroup->refcnt, page->mapcount is used.

After this patch, rule is below.

 - page is charged only if mapcount == 0.
 - page is uncharged only if mapcount == 0.
 - If page is accounted, page_cgroup->mem_cgroup of the page is not NULL.

For managing page-cache, which has no mapcount, PAGE_CGROUP_FLAG_CACHE
is used. (this works as refcnt from mapping->radix-tree.)

By introducing page->mapcount into accounting rule
 - page_cgroup->refcnt can be omitted.
 - fork() can be faster.

Under my easy test, works well. But needs harder test.

Signed-off-by: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/memcontrol.h  |    1 
 include/linux/page_cgroup.h |    3 --
 mm/filemap.c                |    6 ++--
 mm/memcontrol.c             |   60 ++++++++++++++++++++++++++++++++++++--------
 mm/page_cgroup.c            |    2 -
 5 files changed, 56 insertions(+), 16 deletions(-)

Index: mm-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/include/linux/page_cgroup.h
+++ mm-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
@@ -13,10 +13,9 @@ struct mem_cgroup;
 
 struct page_cgroup {
 	spinlock_t		lock;        /* lock for all members */
-	int  			refcnt;      /* reference count */
+	int    			flags;	     /* See below */
 	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
 	struct list_head 	lru;         /* for per cgroup LRU */
-	int    			flags;	     /* See below */
 	struct page 		*page;       /* the page this accounts for*/
 };
 
Index: mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/page_cgroup.c
+++ mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
@@ -81,7 +81,7 @@ init_page_cgroup_head(struct page_cgroup
 	cpus_clear(head->mask);
 	for (i = 0, page = pfn_to_page(pfn), pc = &head->pc[0];
 	     i < PCGRP_SIZE; i++, page++, pc++) {
-		pc->refcnt = 0;
+		pc->mem_cgroup = NULL;
 		pc->page = page;
 		spin_lock_init(&pc->lock);
 	}
Index: mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/memcontrol.c
+++ mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
@@ -312,7 +312,7 @@ void mem_cgroup_move_lists(struct page *
 	 */
 	if (!spin_trylock_irqsave(&pc->lock, flags))
 		return;
-	if (pc->refcnt) {
+	if (pc->mem_cgroup) {
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock(&mz->lru_lock);
 		__mem_cgroup_move_lists(pc, active);
@@ -486,7 +486,7 @@ static int mem_cgroup_charge_common(stru
 	/* Before kmalloc initialization, get_page_cgroup can return EBUSY */
 	if (unlikely(IS_ERR(pc))) {
 		if (PTR_ERR(pc) == -EBUSY)
-			return NULL;
+			return 0;
 		return PTR_ERR(pc);
 	}
 
@@ -494,15 +494,12 @@ static int mem_cgroup_charge_common(stru
 	/*
 	 * Has the page already been accounted ?
 	 */
-	if (pc->refcnt > 0) {
-		pc->refcnt++;
+	if (pc->mem_cgroup) {
 		spin_unlock_irqrestore(&pc->lock, flags);
 		goto success;
 	}
 	spin_unlock_irqrestore(&pc->lock, flags);
 
-	/* Note: *new* pc's refcnt is still 0 here. */
-
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -552,9 +549,8 @@ static int mem_cgroup_charge_common(stru
 	 */
 	spin_lock_irqsave(&pc->lock, flags);
 	/* Is anyone charged ? */
-	if (unlikely(pc->refcnt)) {
+	if (unlikely(pc->mem_cgroup)) {
 		/* Someone charged this page while we released the lock */
-		pc->refcnt++;
 		spin_unlock_irqrestore(&pc->lock, flags);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
@@ -567,7 +563,6 @@ static int mem_cgroup_charge_common(stru
 		pc->flags = PAGE_CGROUP_FLAG_ACTIVE | PAGE_CGROUP_FLAG_CACHE;
 	else
 		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
-	pc->refcnt = 1;
 	pc->mem_cgroup = mem;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -586,6 +581,8 @@ nomem:
 
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
+	if (page_mapped(page))
+		return 0;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
@@ -609,6 +606,8 @@ void mem_cgroup_uncharge_page(struct pag
 
 	if (mem_cgroup_subsys.disabled)
 		return;
+	if (page_mapped(page))
+		return;
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -619,7 +618,9 @@ void mem_cgroup_uncharge_page(struct pag
 		struct mem_cgroup_per_zone *mz;
 
 		spin_lock_irqsave(&pc->lock, flags);
-		if (!pc->refcnt || --pc->refcnt > 0) {
+		if (page_mapped(page) ||
+		    pc->flags & PAGE_CGROUP_FLAG_CACHE ||
+		    !pc->mem_cgroup) {
 			spin_unlock_irqrestore(&pc->lock, flags);
 			return;
 		}
@@ -637,6 +638,49 @@ void mem_cgroup_uncharge_page(struct pag
 	}
 }
 
+void mem_cgroup_uncharge_cache_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+
+	if (mem_cgroup_subsys.disabled)
+		return;
+
+	pc = get_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	spin_lock_irqsave(&pc->lock, flags);
+	if (!pc->mem_cgroup)
+		goto unlock_return;
+	mem = pc->mem_cgroup;
+	/*
+	 * This page is still alive as mapped page.
+	 * Change this account as MAPPED page.
+	 */
+	if (page_mapped(page)) {
+		mem_cgroup_charge_statistics(mem, pc->flags, false);
+		pc->flags &= ~PAGE_CGROUP_FLAG_CACHE;
+		mem_cgroup_charge_statistics(mem, pc->flags, true);
+		goto unlock_return;
+	}
+	mz = page_cgroup_zoneinfo(pc);
+	spin_lock(&mz->lru_lock);
+	__mem_cgroup_remove_list(mz, pc);
+	spin_unlock(&mz->lru_lock);
+	pc->flags = 0;
+	pc->mem_cgroup = 0;
+	spin_unlock_irqrestore(&pc->lock, flags);
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	css_put(&mem->css);
+	return;
+unlock_return:
+	spin_unlock_irqrestore(&pc->lock, flags);
+	return;
+}
+
 /*
  * Pre-charge against newpage while moving a page.
  * This function is called before taking page locks.
@@ -656,7 +700,7 @@ int mem_cgroup_prepare_migration(struct 
 
 	if (pc) {
 		spin_lock_irqsave(&pc->lock, flags);
-		if (pc->refcnt) {
+		if (pc->mem_cgroup) {
 			mem = pc->mem_cgroup;
 			css_get(&mem->css);
 			if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
Index: mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/include/linux/memcontrol.h
+++ mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
@@ -36,6 +36,7 @@ extern int mem_cgroup_charge(struct page
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
+extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
Index: mm-2.6.25-rc5-mm1-k/mm/filemap.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/filemap.c
+++ mm-2.6.25-rc5-mm1-k/mm/filemap.c
@@ -118,7 +118,7 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
-	mem_cgroup_uncharge_page(page);
+	mem_cgroup_uncharge_cache_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -477,12 +477,12 @@ int add_to_page_cache(struct page *page,
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		} else
-			mem_cgroup_uncharge_page(page);
+			mem_cgroup_uncharge_cache_page(page);
 
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
 	} else
-		mem_cgroup_uncharge_page(page);
+		mem_cgroup_uncharge_cache_page(page);
 out:
 	return error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
