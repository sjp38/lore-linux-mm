Date: Tue, 19 Feb 2008 21:54:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

I'd like to start from RFC.

In following code
==
  lock_page_cgroup(page);
  pc = page_get_page_cgroup(page);
  unlock_page_cgroup(page);

  access 'pc' later..
== (See, page_cgroup_move_lists())

There is a race because 'pc' is not a stable value without lock_page_cgroup().
(mem_cgroup_uncharge can free this 'pc').

For example, page_cgroup_move_lists() access pc without lock.
There is a small race window, between page_cgroup_move_lists()
and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
freed but move_list can access it after taking lru_lock.
(*) mem_cgroup_uncharge_page() can be called without zone->lru lock.

This is not good manner.
.....
There is no quick fix (maybe). Moreover, I hear some people around me said
current memcontrol.c codes are very complicated.
I agree ;( ..it's caued by my work.

I'd like to fix problems in clean way.
(Note: current -rc2 codes works well under heavy pressure. but there
 is possibility of race, I think.)



This patch is first trial to fix the issue by clean up the whole lock
related codes of mem_cgroup. And add necessary explanations as comment.

For making thing clearer, adds following.
 - page_cgroup->usage  for reference of charge.
 - page_cgroup->refcnt for reference from kernel objects.

reference to page_cgroup->usage is incremented at charge and
decremented at uncharge.

Usually there are 2 reference to page_cgroup->ref_cnt.
 (a) A reference from struct page's page->page_cgroup
 (b) A reference from cgroup"s LRU.

 (a) is dropped when page_cgroup->usage goes down to zero.
 (b) is dropped when page_cgroup is removed from LRU list.
 Extra reference can be coutned while accessing page_cgroup without
 taking lock_page_cgroup().

Typical usage is
==
	lock_page_cgroup(page);
	pc = page_get_page_cgroup(page);
	if (pc)
		get_page_cgroup(pc); /* increment pc->refcnt here */
	unlock_page_cgroup(page);
==

It is safe when
 * handling 'pc' under lock_page_cgroup(page) && page_get_page_cgroup(page)==pc.
 * handling 'pc' under lru_lock && !list_empty(&pc->lru);
 * handling 'pc' with holding page_cgroup->refcnt.

What this patch does is..
 * remove special funcitons. (I added...sigh..)
 * added pc->usage.
 * refactoring to make lock rule clearer.
 * added Lock Rule as comment.
 * add node_id/zone_id information to page_cgroup.
   Current codes has to access pc->page while page->page_cgroup is cleared.
   This is for accessing LRU withoug accesing pc->page.
 * Make fore_empty to take page_lock(). This will help us to avoid
   all racy condition.

However # of of lines is increased (mainly because of added cooments),
I think this version is easier to read.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h |    2 
 mm/memcontrol.c            |  283 ++++++++++++++++++++++++++-------------------
 mm/vmscan.c                |    4 
 3 files changed, 172 insertions(+), 117 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -17,6 +17,44 @@
  * GNU General Public License for more details.
  */
 
+/*
+ * Lock and Refcnt Rule for page_cgroup.
+ * (pc means struct page_cgroup)
+ *
+ * - pc->usage is reference count of 'charge'.
+ *     + must be modified under page_lock_cgroup()
+ *     + incremented at charge.
+ *     + decremented at uncharge.
+ *     + if pc->usage tunrs to be zero, page_cgroup drops referenece from
+ *       struct page.
+ *
+ * - pc->refcnt is reference from kernel codes/objects. using atomic_ops.
+ *     + One reference from page struct.
+ *     + One reference from LRU.
+ *     + Under lock_page_cgroup(), page_cgroup is alive if page->page_cgroup
+ *	 points this.
+ *     + Under lru_lock, page_cgroup is alive if it's linked to list.
+ *     + Any other codes which handles page_cgroup withoug lock_page_cgroup()
+ *	 must increment this.
+ *
+ *  - under lock_page_cgroup().
+ *     + you can access pc by checking pc == page_get_page_cgroup(page).
+ *     + you must not take page_lock() under lock_page_cgroup().
+ *	 lock_page_cgroup() under page_lock() is ok.
+ *     + you must not take mz->lru_lock under lock_page_cgroup().
+ *
+ *  - under lru_lock.
+ *     + you can access pc safely by checking !list_empty(&pc->lru);
+ *
+ *  - lru_lock must not be held under lock_page_cgroup(). You must increment
+ *    pc->refcnt and call unlock_page_cgroup() and lock lru_lock.
+ *    You can check page_cgroup is still on LRU by list_empty(&pc->lru);
+ *
+ *  - pc->page will not be NULL once it is filled but page->cgroup can be
+ *    NULL if you don't take lock_page_cgroup().
+ */
+
+
 #include <linux/res_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
@@ -30,6 +68,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/pagemap.h>
 
 #include <asm/uaccess.h>
 
@@ -154,23 +193,15 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
-					/* mapped and cached states     */
+	int    usage;			/* # of charged users  */
+	atomic_t refcnt;		/* reference from kernel */
 	int	 flags;
+	short	 nid;
+	short	 zid;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
-static inline int page_cgroup_nid(struct page_cgroup *pc)
-{
-	return page_to_nid(pc->page);
-}
-
-static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
-{
-	return page_zonenum(pc->page);
-}
-
 enum {
 	MEM_CGROUP_TYPE_UNSPEC = 0,
 	MEM_CGROUP_TYPE_MAPPED,
@@ -184,6 +215,21 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 };
 
+static int get_page_cgroup(struct page_cgroup *pc)
+{
+	if (atomic_inc_not_zero(&pc->refcnt))
+		return 0;
+	return 1;
+}
+
+/*
+ * decrement and free when refcnt goes down to zero.
+ */
+static void put_page_cgroup(struct page_cgroup *pc)
+{
+	if (atomic_dec_and_test(&pc->refcnt))
+		kfree(pc);
+}
 
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
@@ -213,10 +259,7 @@ static inline struct mem_cgroup_per_zone
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem = pc->mem_cgroup;
-	int nid = page_cgroup_nid(pc);
-	int zid = page_cgroup_zid(pc);
-
-	return mem_cgroup_zoneinfo(mem, nid, zid);
+	return mem_cgroup_zoneinfo(mem, pc->nid, pc->zid);
 }
 
 static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
@@ -303,47 +346,6 @@ static void __always_inline unlock_page_
 	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
-/*
- * Tie new page_cgroup to struct page under lock_page_cgroup()
- * This can fail if the page has been tied to a page_cgroup.
- * If success, returns 0.
- */
-static int page_cgroup_assign_new_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	int ret = 0;
-
-	lock_page_cgroup(page);
-	if (!page_get_page_cgroup(page))
-		page_assign_page_cgroup(page, pc);
-	else /* A page is tied to other pc. */
-		ret = 1;
-	unlock_page_cgroup(page);
-	return ret;
-}
-
-/*
- * Clear page->page_cgroup member under lock_page_cgroup().
- * If given "pc" value is different from one page->page_cgroup,
- * page->cgroup is not cleared.
- * Returns a value of page->page_cgroup at lock taken.
- * A can can detect failure of clearing by following
- *  clear_page_cgroup(page, pc) == pc
- */
-
-static struct page_cgroup *clear_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	struct page_cgroup *ret;
-	/* lock and clear */
-	lock_page_cgroup(page);
-	ret = page_get_page_cgroup(page);
-	if (likely(ret == pc))
-		page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-	return ret;
-}
-
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
@@ -407,18 +409,28 @@ int task_in_mem_cgroup(struct task_struc
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
-void mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
+void mem_cgroup_move_lists(struct page *page, bool active)
 {
+	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
-	if (!pc)
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (!pc) {
+		unlock_page_cgroup(page);
 		return;
+	}
+	/* Because we release lock after this, get refcnt */
+	get_page_cgroup(pc);
+	unlock_page_cgroup(page);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_move_lists(pc, active);
+	if (!list_empty(&pc->lru))
+		__mem_cgroup_move_lists(pc, active);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	put_page_cgroup(pc);
 }
 
 /*
@@ -530,14 +542,19 @@ unsigned long mem_cgroup_isolate_pages(u
 
 	spin_lock(&mz->lru_lock);
 	scan = 0;
+	/* Handling 'pc' is always safe because we have lru_lock and
+	   'pc' is all linked to LRU list.*/
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
 		page = pc->page;
-		VM_BUG_ON(!pc);
+		VM_BUG_ON(!page);
 
 		if (unlikely(!PageLRU(page)))
 			continue;
+		/* being uncharged ? */
+		if (!pc->usage)
+			continue;
 
 		if (PageActive(page) && !active) {
 			__mem_cgroup_move_lists(pc, true);
@@ -595,18 +612,20 @@ retry:
 		 * the page has already been accounted.
 		 */
 		if (pc) {
-			if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
+			if (!pc->usage) {
 				/* this page is under being uncharged ? */
 				unlock_page_cgroup(page);
 				cpu_relax();
 				goto retry;
 			} else {
+				++pc->usage;
 				unlock_page_cgroup(page);
 				goto done;
 			}
 		}
 		unlock_page_cgroup(page);
-	}
+	} else
+		return 0;
 
 	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
 	if (pc == NULL)
@@ -658,33 +677,32 @@ retry:
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	atomic_set(&pc->ref_cnt, 1);
-	pc->mem_cgroup = mem;
-	pc->page = page;
-	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
-		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	lock_page_cgroup(page);
 
-	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
+	if (page_get_page_cgroup(page) != NULL) {
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
-		kfree(pc);
-		if (!page)
-			goto done;
+		unlock_page_cgroup(page);
 		goto retry;
 	}
+	pc->usage = 1;
+	atomic_set(&pc->refcnt, 1); /* A reference from page struct */
+	pc->mem_cgroup = mem;
+	pc->page = page;	/* This will be never be NULL while alive */
+	pc->nid = page_to_nid(page);
+	pc->zid = page_zonenum(page);
+
+	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
+		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	page_assign_page_cgroup(page, pc);
+	unlock_page_cgroup(page);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	/* Update statistics vector */
+	get_page_cgroup(pc);	/* reference from LRU */
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
 done:
 	return 0;
 out:
@@ -716,10 +734,6 @@ int mem_cgroup_cache_charge(struct page 
 	return ret;
 }
 
-/*
- * Uncharging is always a welcome operation, we never complain, simply
- * uncharge. This routine should be called with lock_page_cgroup held
- */
 void mem_cgroup_uncharge(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem;
@@ -732,24 +746,30 @@ void mem_cgroup_uncharge(struct page_cgr
 	 */
 	if (!pc)
 		return;
+	--pc->usage;
+	if (!pc->usage) {
+		/* At first, drop charge */
+		mem = pc->mem_cgroup;
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
 
-	if (atomic_dec_and_test(&pc->ref_cnt)) {
 		page = pc->page;
-		mz = page_cgroup_zoneinfo(pc);
+
 		/*
-		 * get page->cgroup and clear it under lock.
-		 * force_empty can drop page->cgroup without checking refcnt.
+		 * There is no user. drop referenece from 'page'.
+		 * We got this 'pc' under this page_cgroup_lock. Below is safe.
 		 */
+		page_assign_page_cgroup(page, NULL);
+		put_page_cgroup(pc); /* drop reference from 'page' */
 		unlock_page_cgroup(page);
-		if (clear_page_cgroup(page, pc) == pc) {
-			mem = pc->mem_cgroup;
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			spin_lock_irqsave(&mz->lru_lock, flags);
-			__mem_cgroup_remove_list(pc);
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
-			kfree(pc);
-		}
+
+		/* Remove from our LRU */
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_remove_list(pc);
+		put_page_cgroup(pc); /* drop refrerence from LRU */
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
 		lock_page_cgroup(page);
 	}
 }
@@ -772,8 +792,12 @@ int mem_cgroup_prepare_migration(struct 
 	int ret = 0;
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
+	if (pc && pc->usage) {
+		++pc->usage;
 		ret = 1;
+	}
+	if (ret)
+		get_page_cgroup(pc);
 	unlock_page_cgroup(page);
 	return ret;
 }
@@ -784,7 +808,10 @@ void mem_cgroup_end_migration(struct pag
 
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	mem_cgroup_uncharge(pc);
+	if (pc) {
+		mem_cgroup_uncharge(pc);
+		put_page_cgroup(pc);
+	}
 	unlock_page_cgroup(page);
 }
 /*
@@ -799,21 +826,27 @@ void mem_cgroup_page_migration(struct pa
 	struct mem_cgroup *mem;
 	unsigned long flags;
 	struct mem_cgroup_per_zone *mz;
-retry:
+
+	/*
+	 * Against uncharge, we have on extra usage count.
+	 * Aginst force_empty, this is done under PageLock.
+	 */
+	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (!pc)
-		return;
+	page_assign_page_cgroup(page, NULL);
+	unlock_page_cgroup(page);
+
 	mem = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(pc);
-	if (clear_page_cgroup(page, pc) != pc)
-		goto retry;
 	spin_lock_irqsave(&mz->lru_lock, flags);
-
 	__mem_cgroup_remove_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	pc->page = newpage;
 	lock_page_cgroup(newpage);
+	VM_BUG_ON(page_get_page_cgroup(newpage) != NULL);
+	pc->page = newpage;
+	pc->nid = page_to_nid(newpage);
+	pc->zid = page_zonenum(newpage);
 	page_assign_page_cgroup(newpage, pc);
 	unlock_page_cgroup(newpage);
 
@@ -826,7 +859,7 @@ retry:
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
- * This routine ignores page_cgroup->ref_cnt.
+ * This routine ignores page_cgroup->usage.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
@@ -854,17 +887,42 @@ retry:
 
 	while (--count && !list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
+
+		/* pc->page is never cleared while 'pc' is alive */
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
-			css_put(&mem->css);
+		VM_BUG_ON(!page);
+
+		/*
+		 * This guarantees that page migration will not touch
+		 * this page.
+		 */
+		if (TestSetPageLocked(page))
+			goto unlock_exit_loop;
+
+		lock_page_cgroup(page);
+		if (page_get_page_cgroup(page) == pc &&
+		    pc->usage) {
+			/* See also mem_cgroup_uncharge(). */
+			/* drop charge at first */
+			pc->usage = 0;
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			css_put(&mem->css);
+			page_assign_page_cgroup(page, NULL);
+			put_page_cgroup(pc);
+			unlock_page_cgroup(page);
+			/* Here, no reference from struct 'page' */
+			/* Just remove from LRU */
 			__mem_cgroup_remove_list(pc);
-			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
-			break;
+			put_page_cgroup(pc);
+			unlock_page(page);
+		} else {
+			/* This page is being uncharged */
+			unlock_page_cgroup(page);
+			unlock_page(page);
+			goto unlock_exit_loop;
+		}
 	}
+unlock_exit_loop:
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	if (!list_empty(list)) {
 		cond_resched();
Index: linux-2.6.25-rc2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/memcontrol.h
+++ linux-2.6.25-rc2/include/linux/memcontrol.h
@@ -39,7 +39,7 @@ extern int mem_cgroup_charge(struct page
 				gfp_t gfp_mask);
 extern void mem_cgroup_uncharge(struct page_cgroup *pc);
 extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page_cgroup *pc, bool active);
+extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
Index: linux-2.6.25-rc2/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/vmscan.c
+++ linux-2.6.25-rc2/mm/vmscan.c
@@ -1128,7 +1128,7 @@ static void shrink_active_list(unsigned 
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->inactive_list);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
+		mem_cgroup_move_lists(page, false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
@@ -1157,7 +1157,7 @@ static void shrink_active_list(unsigned 
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		list_move(&page->lru, &zone->active_list);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
Index: linux-2.6.25-rc2/mm/swap.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/swap.c
+++ linux-2.6.25-rc2/mm/swap.c
@@ -176,7 +176,7 @@ void activate_page(struct page *page)
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
