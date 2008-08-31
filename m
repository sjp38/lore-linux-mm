Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7VHnonR019224
	for <linux-mm@kvack.org>; Sun, 31 Aug 2008 23:19:50 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7VHnmtH1339464
	for <linux-mm@kvack.org>; Sun, 31 Aug 2008 23:19:50 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7VHnl2X022996
	for <linux-mm@kvack.org>; Sun, 31 Aug 2008 23:19:48 +0530
Date: Sun, 31 Aug 2008 23:17:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [RFC][PATCH] Remove cgroup member from struct page
Message-ID: <20080831174756.GA25790@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a rewrite of a patch I had written long back to remove struct page
(I shared the patches with Kamezawa, but never posted them anywhere else).
I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).

I've tested the patches on an x86_64 box, I've run a simple test running
under the memory control group and the same test running concurrently under
two different groups (and creating pressure within their groups). I've also
compiled the patch with CGROUP_MEM_RES_CTLR turned off.

Advantages of the patch

1. It removes the extra pointer in struct page

Disadvantages

1. It adds an additional lock structure to struct page_cgroup
2. Radix tree lookup is not an O(1) operation, once the page is known
   getting to the page_cgroup (pc) is a little more expensive now.

This is an initial RFC for comments

TODOs

1. Test the page migration changes
2. Test the performance impact of the patch/approach

Comments/Reviews?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |   23 +++++-
 include/linux/mm_types.h   |    4 -
 mm/memcontrol.c            |  165 +++++++++++++++++++++++++++++++++------------
 3 files changed, 144 insertions(+), 48 deletions(-)

diff -puN mm/memcontrol.c~memcg_move_to_radix_tree mm/memcontrol.c
--- linux-2.6.27-rc5/mm/memcontrol.c~memcg_move_to_radix_tree	2008-08-30 22:49:28.000000000 +0530
+++ linux-2.6.27-rc5-balbir/mm/memcontrol.c	2008-08-31 23:03:06.000000000 +0530
@@ -24,7 +24,7 @@
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
-#include <linux/bit_spinlock.h>
+#include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
@@ -40,6 +40,9 @@ struct cgroup_subsys mem_cgroup_subsys _
 static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+static struct radix_tree_root mem_cgroup_tree;
+static spinlock_t mem_cgroup_tree_lock;
+
 /*
  * Statistics for memory cgroup.
  */
@@ -159,6 +162,7 @@ struct page_cgroup {
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
 	int flags;
+	spinlock_t lock;
 };
 #define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
@@ -248,35 +252,94 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
+static int page_assign_page_cgroup(struct page *page, struct page_cgroup *pc,
+					gfp_t gfp_mask)
 {
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	int err = 0;
+	struct page_cgroup *old_pc;
+
+	if (pc) {
+		err = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+		if (err) {
+			printk(KERN_WARNING "could not preload radix tree "
+				"in %s\n", __func__);
+			goto done;
+		}
+	}
+
+	spin_lock_irqsave(&mem_cgroup_tree_lock, flags);
+	old_pc = radix_tree_lookup(&mem_cgroup_tree, pfn);
+	if (pc && old_pc) {
+		err = -EEXIST;
+		goto pc_race;
+	}
+	if (pc) {
+		err = radix_tree_insert(&mem_cgroup_tree, pfn, pc);
+		if (err)
+			printk(KERN_WARNING "Inserting into radix tree failed "
+				"in %s\n", __func__);
+	} else
+		radix_tree_delete(&mem_cgroup_tree, pfn);
+pc_race:
+	spin_unlock_irqrestore(&mem_cgroup_tree_lock, flags);
+done:
+	if (pc)
+		radix_tree_preload_end();
+	return err;
 }
 
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
+struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
+						bool trylock)
 {
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
+	unsigned long pfn = page_to_pfn(page);
+	struct page_cgroup *pc;
+	int ret;
+
+	BUG_ON(lock && trylock);
+
+	rcu_read_lock();
+	pc = radix_tree_lookup(&mem_cgroup_tree, pfn);
+
+	if (pc && lock)
+		spin_lock(&pc->lock);
+
+	if (pc && trylock) {
+		ret = spin_trylock(&pc->lock);
+		if (!ret)
+			pc = NULL;
+	}
+
+	rcu_read_unlock();
+
+	return pc;
 }
 
-struct page_cgroup *page_get_page_cgroup(struct page *page)
+static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
+	BUG_ON(!pc);
+	spin_lock(&pc->lock);
 }
 
-static void lock_page_cgroup(struct page *page)
+static __always_inline void lock_page_cgroup_irqsave(struct page_cgroup *pc,
+							unsigned long *flags)
 {
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	BUG_ON(!pc);
+	spin_lock_irqsave(&pc->lock, *flags);
 }
 
-static int try_lock_page_cgroup(struct page *page)
+static inline void unlock_page_cgroup_irqrestore(struct page_cgroup *pc,
+							unsigned long flags)
 {
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	BUG_ON(!pc);
+	spin_unlock_irqrestore(&pc->lock, flags);
 }
 
-static void unlock_page_cgroup(struct page *page)
+static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	BUG_ON(!pc);
+	spin_unlock(&pc->lock);
 }
 
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
@@ -377,17 +440,15 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	pc = page_get_page_cgroup_trylock(page);
+	if (!pc)
 		return;
 
-	pc = page_get_page_cgroup(page);
-	if (pc) {
-		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, lru);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-	}
-	unlock_page_cgroup(page);
+	mz = page_cgroup_zoneinfo(pc);
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	__mem_cgroup_move_lists(pc, lru);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	unlock_page_cgroup(pc);
 }
 
 /*
@@ -516,7 +577,7 @@ static int mem_cgroup_charge_common(stru
 				struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
+	struct page_cgroup *pc, *old_pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
@@ -569,6 +630,8 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	spin_lock_init(&pc->lock);
+
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
@@ -582,22 +645,34 @@ static int mem_cgroup_charge_common(stru
 	} else
 		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 
-	lock_page_cgroup(page);
-	if (unlikely(page_get_page_cgroup(page))) {
-		unlock_page_cgroup(page);
+	old_pc = page_get_page_cgroup_locked(page);
+	if (old_pc) {
+		unlock_page_cgroup(old_pc);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		kmem_cache_free(page_cgroup_cache, old_pc);
+		goto done;
+	}
+
+	lock_page_cgroup(pc);
+	/*
+	 * page_get_page_cgroup() does not necessarily guarantee that
+	 * there will be no race in checking for pc, page_assign_page_pc()
+	 * will definitely catch it.
+	 */
+	if (page_assign_page_cgroup(page, pc, gfp_mask)) {
+		unlock_page_cgroup(pc);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		kmem_cache_free(page_cgroup_cache, pc);
 		goto done;
 	}
-	page_assign_page_cgroup(page, pc);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 done:
 	return 0;
 out:
@@ -645,15 +720,14 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
+		pc = page_get_page_cgroup_locked(page);
 		if (pc) {
 			VM_BUG_ON(pc->page != page);
 			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
+			unlock_page_cgroup(pc);
 			return 0;
 		}
-		unlock_page_cgroup(page);
+		unlock_page_cgroup(pc);
 	}
 
 	if (unlikely(!mm))
@@ -673,6 +747,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
+	int ret;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
@@ -680,8 +755,7 @@ __mem_cgroup_uncharge_common(struct page
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
+	pc = page_get_page_cgroup_locked(page);
 	if (unlikely(!pc))
 		goto unlock;
 
@@ -697,8 +771,9 @@ __mem_cgroup_uncharge_common(struct page
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
+	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
+	VM_BUG_ON(ret);
+	unlock_page_cgroup(pc);
 
 	mem = pc->mem_cgroup;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
@@ -707,7 +782,14 @@ __mem_cgroup_uncharge_common(struct page
 	kmem_cache_free(page_cgroup_cache, pc);
 	return;
 unlock:
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
+}
+
+void page_reset_bad_cgroup(struct page *page)
+{
+	int ret;
+	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
+	VM_BUG_ON(ret);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -734,15 +816,14 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
+	pc = page_get_page_cgroup_locked(page);
 	if (pc) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	}
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
diff -puN include/linux/memcontrol.h~memcg_move_to_radix_tree include/linux/memcontrol.h
--- linux-2.6.27-rc5/include/linux/memcontrol.h~memcg_move_to_radix_tree	2008-08-30 22:49:28.000000000 +0530
+++ linux-2.6.27-rc5-balbir/include/linux/memcontrol.h	2008-08-31 22:57:08.000000000 +0530
@@ -27,9 +27,28 @@ struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
-#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
+extern void page_reset_bad_cgroup(struct page *page);
+extern struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
+							bool trylock);
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup(struct page *page)
+{
+	return __page_get_page_cgroup(page, false, false);
+}
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup_trylock(struct page *page)
+{
+	return __page_get_page_cgroup(page, false, true);
+}
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup_locked(struct page *page)
+{
+	return __page_get_page_cgroup(page, true, false);
+}
 
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
diff -puN include/linux/mm_types.h~memcg_move_to_radix_tree include/linux/mm_types.h
--- linux-2.6.27-rc5/include/linux/mm_types.h~memcg_move_to_radix_tree	2008-08-31 13:30:57.000000000 +0530
+++ linux-2.6.27-rc5-balbir/include/linux/mm_types.h	2008-08-31 13:32:03.000000000 +0530
@@ -92,10 +92,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
-#endif
-
 #ifdef CONFIG_KMEMCHECK
 	void *shadow;
 #endif
diff -puN mm/page_alloc.c~memcg_move_to_radix_tree mm/page_alloc.c
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
