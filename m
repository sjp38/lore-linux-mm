Date: Wed, 20 Aug 2008 19:04:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH -mm 4/7] memcg: lockless page_cgroup
Message-Id: <20080820190445.86919438.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

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

After this patch, page_cgroup can be accessed via

**
	rcu_read_lock();
	pc = page_get_page_cgroup(page);
	if (pc && !PcgObsolete(pc)) {
		......
	}
	rcu_read_unlock();
**

This is now under test. Don't apply if you're not brave.

Changelog: (preview) -> (v1)
 - Added comments.
 - Fixed page migration.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/mm_types.h |    2 
 mm/memcontrol.c          |  119 +++++++++++++++++------------------------------
 mm/memory.c              |   16 +-----
 3 files changed, 51 insertions(+), 86 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -137,20 +137,6 @@ struct mem_cgroup {
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
@@ -312,35 +298,14 @@ struct mem_cgroup *mem_cgroup_from_task(
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
@@ -434,16 +399,7 @@ void mem_cgroup_move_lists(struct page *
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
 	if (pc && !PcgObsolete(pc)) {
 		mz = page_cgroup_zoneinfo(pc);
@@ -451,7 +407,7 @@ void mem_cgroup_move_lists(struct page *
 		__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
-	unlock_page_cgroup(page);
+	rcu_read_unlock();
 }
 
 /*
@@ -755,14 +711,9 @@ static int mem_cgroup_charge_common(stru
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
@@ -770,8 +721,6 @@ static int mem_cgroup_charge_common(stru
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	unlock_page_cgroup(page);
-done:
 	return 0;
 out:
 	css_put(&mem->css);
@@ -796,6 +745,28 @@ int mem_cgroup_charge(struct page *page,
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
@@ -813,20 +784,21 @@ int mem_cgroup_cache_charge(struct page 
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
@@ -851,27 +823,26 @@ __mem_cgroup_uncharge_common(struct page
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
@@ -898,15 +869,15 @@ int mem_cgroup_prepare_migration(struct 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
