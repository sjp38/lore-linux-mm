Date: Fri, 22 Aug 2008 20:35:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/14]  memcg: lockless page cgroup
Message-Id: <20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch removes lock_page_cgroup(). Now, page_cgroup is guarded by RCU.

To remove lock_page_cgroup(), we have to confirm there is no race.

Anon pages:
* pages are chareged/uncharged only when first-mapped/last-unmapped.
  page_mapcount() handles that.
   (And... pte_lock() is always held in any racy case.)

Swap pages:
  There will be race because charge is done before lock_page().
  This patch moves mem_cgroup_charge() under lock_page().

File pages: (not Shmem)
* pages are charged/uncharged only when it's added/removed to radix-tree.
  In this case, PageLock() is always held.

Install Page:
  Is it worth to charge this special map page ? which is (maybe) not on LRU.
  I think no.
  I removed charge/uncharge from install_page().

Page Migration:
  We precharge it and map it back under lock_page(). This should be treated
  as special case.

freeing page_cgroup is done under RCU.

After this patch, page_cgroup can be accesced via struct page->page_cgroup
under following conditions.

1. The page is file cache and on radix-tree.
   (means lock_page() or mapping->tree_lock is held.)
2. The page is anounymous page and mapped.
   (means pte_lock is held.)
3. under RCU and the page_cgroup is not Obsolete.

Typical style of "3" is following.
**
	rcu_read_lock();
	pc = page_get_page_cgroup(page);
	if (pc && !PcgObsolete(pc)) {
		......
	}
	rcu_read_unlock();
**

This is now under test. Don't apply if you're not brave.

Changelog: (v1) -> (v2)
 - Added Documentation.

Changelog: (preview) -> (v1)
 - Added comments.
 - Fixed page migration.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 Documentation/controllers/memory.txt |   16 ++++
 include/linux/mm_types.h             |    2 
 mm/memcontrol.c                      |  125 +++++++++++++----------------------
 mm/memory.c                          |   16 +---
 4 files changed, 70 insertions(+), 89 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -142,20 +142,6 @@ struct mem_cgroup {
 static struct mem_cgroup init_mem_cgroup;
 
 /*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
  * A page_cgroup page is associated with every page descriptor. The
  * page_cgroup helps us identify information about the cgroup
  */
@@ -317,35 +303,14 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
 static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
 {
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
+	rcu_assign_pointer(page->page_cgroup, pc);
 }
 
 struct page_cgroup *page_get_page_cgroup(struct page *page)
 {
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
-}
-
-static void lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	return rcu_dereference(page->page_cgroup);
 }
 
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
@@ -440,29 +405,22 @@ void mem_cgroup_move_lists(struct page *
 	if (mem_cgroup_subsys.disabled)
 		return;
 
-	/*
-	 * We cannot lock_page_cgroup while holding zone's lru_lock,
-	 * because other holders of lock_page_cgroup can be interrupted
-	 * with an attempt to rotate_reclaimable_page.  But we cannot
-	 * safely get to page_cgroup without it, so just try_lock it:
-	 * mem_cgroup_isolate_pages allows for page left on wrong list.
-	 */
-	if (!try_lock_page_cgroup(page))
-		return;
-
+	rcu_read_lock();
 	pc = page_get_page_cgroup(page);
 	if (pc) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
 		/*
-		 * check against the race with force_empty.
+		 * check against the race with force_empty. pc->mem_cgroup is
+		 * if pc is valid because the page is under page_lock. move
+		 * function will not change pc->mem_cgroup.
 		 */
-		if (!PcgObsolete(pc) && likely(mem == pc->mem_cgroup))
+		if (!PcgObsolete(pc))
 			__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
-	unlock_page_cgroup(page);
+	rcu_read_unlock();
 }
 
 /*
@@ -766,14 +724,9 @@ static int mem_cgroup_charge_common(stru
 	} else
 		__SetPcgActive(pc);
 
-	lock_page_cgroup(page);
-	if (unlikely(page_get_page_cgroup(page))) {
-		unlock_page_cgroup(page);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kmem_cache_free(page_cgroup_cache, pc);
-		goto done;
-	}
+	/* Double counting race condition ? */
+	VM_BUG_ON(page_get_page_cgroup(page));
+
 	page_assign_page_cgroup(page, pc);
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -781,8 +734,6 @@ static int mem_cgroup_charge_common(stru
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	unlock_page_cgroup(page);
-done:
 	return 0;
 out:
 	css_put(&mem->css);
@@ -807,6 +758,28 @@ int mem_cgroup_charge(struct page *page,
 		return 0;
 	if (unlikely(!mm))
 		mm = &init_mm;
+	/*
+	 * Check for pre-charged case of an anonymous page.
+	 * i.e. page migraion.
+	 *
+	 * Under page migration, the new page (target of migration) is charged
+	 * befere being mapped. And page->mapping points to anon_vma.
+	 * Check it here wheter we've already charged this or not.
+	 *
+	 * But, in this case, we don't charge against a page which is newly
+	 * allocated. It should be locked for avoiding race.
+	 */
+	if (PageAnon(page)) {
+		struct page_cgroup *pc;
+		VM_BUG_ON(!PageLocked(page));
+		rcu_read_lock();
+		pc = page_get_page_cgroup(page);
+		if (pc && !PcgObsolete(pc)) {
+			rcu_read_unlock();
+			return 0;
+		}
+		rcu_read_unlock();
+	}
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
@@ -824,20 +797,21 @@ int mem_cgroup_cache_charge(struct page 
 	 *
 	 * For GFP_NOWAIT case, the page may be pre-charged before calling
 	 * add_to_page_cache(). (See shmem.c) check it here and avoid to call
-	 * charge twice. (It works but has to pay a bit larger cost.)
+	 * charge twice.
+	 *
+	 * Note: page migration doesn't call add_to_page_cache(). We can ignore
+	 * the case.
 	 */
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
-
-		lock_page_cgroup(page);
+		rcu_read_lock();
 		pc = page_get_page_cgroup(page);
-		if (pc) {
+		if (pc && !PcgObsolete(pc)) {
 			VM_BUG_ON(pc->page != page);
 			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
 			return 0;
 		}
-		unlock_page_cgroup(page);
+		rcu_read_unlock();
 	}
 
 	if (unlikely(!mm))
@@ -862,27 +836,26 @@ __mem_cgroup_uncharge_common(struct page
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
+	rcu_read_lock();
 	pc = page_get_page_cgroup(page);
-	if (unlikely(!pc))
-		goto unlock;
+	if (unlikely(!pc) || PcgObsolete(pc))
+		goto out;
 
 	VM_BUG_ON(pc->page != page);
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
 	    && ((PcgCache(pc) || page_mapped(page))))
-		goto unlock;
+		goto out;
 	mem = pc->mem_cgroup;
 	SetPcgObsolete(pc);
 	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
 
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	free_obsolete_page_cgroup(pc);
 
+out:
+	rcu_read_unlock();
 	return;
-unlock:
-	unlock_page_cgroup(page);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -909,15 +882,15 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
+	rcu_read_lock();
 	pc = page_get_page_cgroup(page);
-	if (pc) {
+	if (pc && !PcgObsolete(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (PcgCache(pc))
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	}
-	unlock_page_cgroup(page);
+	rcu_read_unlock();
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
Index: mmtom-2.6.27-rc3+/mm/memory.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memory.c
+++ mmtom-2.6.27-rc3+/mm/memory.c
@@ -1323,18 +1323,14 @@ static int insert_page(struct vm_area_st
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	retval = mem_cgroup_charge(page, mm, GFP_KERNEL);
-	if (retval)
-		goto out;
-
 	retval = -EINVAL;
 	if (PageAnon(page))
-		goto out_uncharge;
+		goto out;
 	retval = -ENOMEM;
 	flush_dcache_page(page);
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
-		goto out_uncharge;
+		goto out;
 	retval = -EBUSY;
 	if (!pte_none(*pte))
 		goto out_unlock;
@@ -1350,8 +1346,6 @@ static int insert_page(struct vm_area_st
 	return retval;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
-out_uncharge:
-	mem_cgroup_uncharge_page(page);
 out:
 	return retval;
 }
@@ -2325,16 +2319,16 @@ static int do_swap_page(struct mm_struct
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
+	lock_page(page);
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
-		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		ret = VM_FAULT_OOM;
+		unlock_page(page);
 		goto out;
 	}
 
 	mark_page_accessed(page);
-	lock_page(page);
-	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	/*
 	 * Back out if somebody else already faulted in this pte.
Index: mmtom-2.6.27-rc3+/include/linux/mm_types.h
===================================================================
--- mmtom-2.6.27-rc3+.orig/include/linux/mm_types.h
+++ mmtom-2.6.27-rc3+/include/linux/mm_types.h
@@ -93,7 +93,7 @@ struct page {
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
+	struct page_cgroup *page_cgroup;
 #endif
 
 #ifdef CONFIG_KMEMCHECK
Index: mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
===================================================================
--- mmtom-2.6.27-rc3+.orig/Documentation/controllers/memory.txt
+++ mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
@@ -151,7 +151,21 @@ The memory controller uses the following
 
 1. zone->lru_lock is used for selecting pages to be isolated
 2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
-3. lock_page_cgroup() is used to protect page->page_cgroup
+
+Access to page_cgroup via struct page->page_cgroup is safe while
+
+1. The page is file cache and on radix-tree.
+   (means mapping->tree_lock or lock_page should be held.)
+2. The page is anonymous page and it's guaranteed to be mapped.
+   (means pte_lock should be held.)
+3. under rcu_read_lock() and !PcgObsolete(pc)
+
+In any case, the user should use page_get_page_cgroup().
+Accessing member of page_cgroup->flags is not dangerous.
+Accessing member of page_cgroup->mem_cgroup, page_cgroup->lru is a
+little more dangerous. You should avoid it from outside of mm/memcontrol.c
+
+
 
 3. User Interface
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
