Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBC76B003C
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:26:07 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so1742693eek.36
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:26:07 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id r9si32015159eew.198.2014.04.30.13.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:26:06 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/9] mm: memcontrol: rewrite charge API
Date: Wed, 30 Apr 2014 16:25:42 -0400
Message-Id: <1398889543-23671-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg charge API charges pages before they are rmapped - i.e. have
an actual "type" - and so every callsite needs its own set of charge
and uncharge functions to know what type is being operated on.

Rewrite the charge API to provide a generic set of try_charge(),
commit_charge() and cancel_charge() transaction operations, much like
what's currently done for swap-in:

  mem_cgroup_try_charge() attempts to reserve a charge, reclaiming
  pages from the memcg if necessary.

  mem_cgroup_commit_charge() commits the page to the charge once it
  has a valid page->mapping and PageAnon() reliably tells the type.

  mem_cgroup_cancel_charge() aborts the transaction.

As pages need to be committed after rmap is established but before
they are added to the LRU, page_add_new_anon_rmap() must stop doing
LRU additions again.  Factor lru_cache_add_active_or_unevictable().

The order of functions in mm/memcontrol.c is entirely random, so this
new charge interface is implemented at the end of the file, where all
new or cleaned up, and documented code should go from now on.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/memcg_test.txt |  32 +-
 include/linux/memcontrol.h           |  53 +--
 include/linux/swap.h                 |   3 +
 kernel/events/uprobes.c              |   1 +
 mm/filemap.c                         |   9 +-
 mm/huge_memory.c                     |  51 ++-
 mm/memcontrol.c                      | 777 ++++++++++++++++-------------------
 mm/memory.c                          |  41 +-
 mm/migrate.c                         |   1 +
 mm/rmap.c                            |   5 -
 mm/shmem.c                           |  24 +-
 mm/swap.c                            |  20 +
 mm/swapfile.c                        |  14 +-
 13 files changed, 479 insertions(+), 552 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index 80ac454704b8..bcf750d3cecd 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -24,24 +24,7 @@ Please note that implementation details can be changed.
 
    a page/swp_entry may be charged (usage += PAGE_SIZE) at
 
-	mem_cgroup_charge_anon()
-	  Called at new page fault and Copy-On-Write.
-
-	mem_cgroup_try_charge_swapin()
-	  Called at do_swap_page() (page fault on swap entry) and swapoff.
-	  Followed by charge-commit-cancel protocol. (With swap accounting)
-	  At commit, a charge recorded in swap_cgroup is removed.
-
-	mem_cgroup_charge_file()
-	  Called at add_to_page_cache()
-
-	mem_cgroup_cache_charge_swapin()
-	  Called at shmem's swapin.
-
-	mem_cgroup_prepare_migration()
-	  Called before migration. "extra" charge is done and followed by
-	  charge-commit-cancel protocol.
-	  At commit, charge against oldpage or newpage will be committed.
+	mem_cgroup_try_charge()
 
 2. Uncharge
   a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
@@ -69,19 +52,14 @@ Please note that implementation details can be changed.
 	to new page is committed. At failure, charge to old page is committed.
 
 3. charge-commit-cancel
-	In some case, we can't know this "charge" is valid or not at charging
-	(because of races).
-	To handle such case, there are charge-commit-cancel functions.
-		mem_cgroup_try_charge_XXX
-		mem_cgroup_commit_charge_XXX
-		mem_cgroup_cancel_charge_XXX
-	these are used in swap-in and migration.
+	Memcg pages are charged in two steps:
+		mem_cgroup_try_charge()
+		mem_cgroup_commit_charge() or mem_cgroup_cancel_charge()
 
 	At try_charge(), there are no flags to say "this page is charged".
 	at this point, usage += PAGE_SIZE.
 
-	At commit(), the function checks the page should be charged or not
-	and set flags or avoid charging.(usage -= PAGE_SIZE)
+	At commit(), the page is associated with the memcg.
 
 	At cancel(), simply usage -= PAGE_SIZE.
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b569b8be5c5a..5578b07376b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -54,28 +54,11 @@ struct mem_cgroup_reclaim_cookie {
 };
 
 #ifdef CONFIG_MEMCG
-/*
- * All "charge" functions with gfp_mask should use GFP_KERNEL or
- * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
- * alloc memory but reclaims memory from all available zones. So, "where I want
- * memory from" bits of gfp_mask has no meaning. So any bits of that field is
- * available but adding a rule is better. charge functions' gfp_mask should
- * be set to GFP_KERNEL or gfp_mask & GFP_RECLAIM_MASK for avoiding ambiguous
- * codes.
- * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
- */
-
-extern int mem_cgroup_charge_anon(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask);
-/* for swap handling */
-extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
-extern void mem_cgroup_commit_charge_swapin(struct page *page,
-					struct mem_cgroup *memcg);
-extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
-
-extern int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
-					gfp_t gfp_mask);
+int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
+			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
+void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
+			      bool lrucare);
+void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
@@ -233,30 +216,22 @@ void mem_cgroup_print_bad_page(struct page *page);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
-static inline int mem_cgroup_charge_anon(struct page *page,
-					struct mm_struct *mm, gfp_t gfp_mask)
-{
-	return 0;
-}
-
-static inline int mem_cgroup_charge_file(struct page *page,
-					struct mm_struct *mm, gfp_t gfp_mask)
-{
-	return 0;
-}
-
-static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t gfp_mask, struct mem_cgroup **memcgp)
+static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
+					gfp_t gfp_mask,
+					struct mem_cgroup **memcgp)
 {
+	*memcgp = NULL;
 	return 0;
 }
 
-static inline void mem_cgroup_commit_charge_swapin(struct page *page,
-					  struct mem_cgroup *memcg)
+static inline void mem_cgroup_commit_charge(struct page *page,
+					    struct mem_cgroup *memcg,
+					    bool lrucare)
 {
 }
 
-static inline void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
+static inline void mem_cgroup_cancel_charge(struct page *page,
+					    struct mem_cgroup *memcg)
 {
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 350711560753..403a8530ee62 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -323,6 +323,9 @@ extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
 
+extern void lru_cache_add_active_or_unevictable(struct page *page,
+						struct vm_area_struct *vma);
+
 /**
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 04709b66369d..44c508044c1d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -180,6 +180,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	get_page(kpage);
 	page_add_new_anon_rmap(kpage, vma, addr);
+	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
 		dec_mm_counter(mm, MM_FILEPAGES);
diff --git a/mm/filemap.c b/mm/filemap.c
index a82fbe4c9e8e..346c2e178193 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -558,19 +558,19 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
+	struct mem_cgroup *memcg;
 	int error;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
 
-	error = mem_cgroup_charge_file(page, current->mm,
-					gfp_mask & GFP_RECLAIM_MASK);
+	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
 	if (error)
 		return error;
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		mem_cgroup_uncharge_cache_page(page);
+		mem_cgroup_cancel_charge(page, memcg);
 		return error;
 	}
 
@@ -585,13 +585,14 @@ static int __add_to_page_cache_locked(struct page *page,
 		goto err_insert;
 	__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
+	mem_cgroup_commit_charge(page, memcg, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
 err_insert:
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_uncharge_cache_page(page);
+	mem_cgroup_cancel_charge(page, memcg);
 	page_cache_release(page);
 	return error;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 64635f5278ff..1a22d8b12cf2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -715,13 +715,20 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					unsigned long haddr, pmd_t *pmd,
 					struct page *page)
 {
+	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	spinlock_t *ptl;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
+
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg))
+		return VM_FAULT_OOM;
+
 	pgtable = pte_alloc_one(mm, haddr);
-	if (unlikely(!pgtable))
+	if (unlikely(!pgtable)) {
+		mem_cgroup_cancel_charge(page, memcg);
 		return VM_FAULT_OOM;
+	}
 
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
 	/*
@@ -734,7 +741,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_none(*pmd))) {
 		spin_unlock(ptl);
-		mem_cgroup_uncharge_page(page);
+		mem_cgroup_cancel_charge(page, memcg);
 		put_page(page);
 		pte_free(mm, pgtable);
 	} else {
@@ -742,6 +749,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr);
+		mem_cgroup_commit_charge(page, memcg, false);
+		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		set_pmd_at(mm, haddr, pmd, entry);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
@@ -827,13 +836,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_KERNEL))) {
-		put_page(page);
-		count_vm_event(THP_FAULT_FALLBACK);
-		return VM_FAULT_FALLBACK;
-	}
 	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
-		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -948,6 +951,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct page *page,
 					unsigned long haddr)
 {
+	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
 	pgtable_t pgtable;
 	pmd_t _pmd;
@@ -968,13 +972,15 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					       __GFP_OTHER_NODE,
 					       vma, address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
-			     mem_cgroup_charge_anon(pages[i], mm,
-						       GFP_KERNEL))) {
+			     mem_cgroup_try_charge(pages[i], mm, GFP_KERNEL,
+						   &memcg))) {
 			if (pages[i])
 				put_page(pages[i]);
 			mem_cgroup_uncharge_start();
 			while (--i >= 0) {
-				mem_cgroup_uncharge_page(pages[i]);
+				memcg = (void *)page_private(pages[i]);
+				set_page_private(pages[i], 0);
+				mem_cgroup_cancel_charge(pages[i], memcg);
 				put_page(pages[i]);
 			}
 			mem_cgroup_uncharge_end();
@@ -982,6 +988,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 			ret |= VM_FAULT_OOM;
 			goto out;
 		}
+		set_page_private(pages[i], (unsigned long)memcg);
 	}
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
@@ -1010,7 +1017,11 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		pte_t *pte, entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		memcg = (void *)page_private(pages[i]);
+		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vma, haddr);
+		mem_cgroup_commit_charge(pages[i], memcg, false);
+		lru_cache_add_active_or_unevictable(pages[i], vma);
 		pte = pte_offset_map(&_pmd, haddr);
 		VM_BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, haddr, pte, entry);
@@ -1036,7 +1047,9 @@ out_free_pages:
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		mem_cgroup_uncharge_page(pages[i]);
+		memcg = (void *)page_private(pages[i]);
+		set_page_private(pages[i], 0);
+		mem_cgroup_cancel_charge(pages[i], memcg);
 		put_page(pages[i]);
 	}
 	mem_cgroup_uncharge_end();
@@ -1050,6 +1063,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 	struct page *page = NULL, *new_page;
+	struct mem_cgroup *memcg;
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -1101,7 +1115,7 @@ alloc:
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))) {
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))) {
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
@@ -1130,7 +1144,7 @@ alloc:
 		put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(ptl);
-		mem_cgroup_uncharge_page(new_page);
+		mem_cgroup_cancel_charge(new_page, memcg);
 		put_page(new_page);
 		goto out_mn;
 	} else {
@@ -1139,6 +1153,8 @@ alloc:
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
+		mem_cgroup_commit_charge(new_page, memcg, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache_pmd(vma, address, pmd);
 		if (!page) {
@@ -2349,6 +2365,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated;
 	unsigned long hstart, hend;
+	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2359,7 +2376,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;
 
-	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)))
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg)))
 		return;
 
 	/*
@@ -2448,6 +2465,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
+	mem_cgroup_commit_charge(new_page, memcg, false);
+	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
@@ -2461,7 +2480,7 @@ out_up_write:
 	return;
 
 out:
-	mem_cgroup_uncharge_page(new_page);
+	mem_cgroup_cancel_charge(new_page, memcg);
 	goto out_up_write;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d3961fce1d54..6f48e292ffe7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2574,163 +2574,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	return NOTIFY_OK;
 }
 
-/**
- * mem_cgroup_try_charge - try charging a memcg
- * @memcg: memcg to charge
- * @nr_pages: number of pages to charge
- * @oom: trigger OOM if reclaim fails
- *
- * Returns 0 if @memcg was charged successfully, -EINTR if the charge
- * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
- */
-static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
-				 gfp_t gfp_mask,
-				 unsigned int nr_pages,
-				 bool oom)
-{
-	unsigned int batch = max(CHARGE_BATCH, nr_pages);
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
-	unsigned long nr_reclaimed;
-	unsigned long flags = 0;
-	unsigned long long size;
-	int ret = 0;
-
-retry:
-	if (consume_stock(memcg, nr_pages))
-		goto done;
-
-	size = batch * PAGE_SIZE;
-	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
-		if (!do_swap_account)
-			goto done_restock;
-		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
-			goto done_restock;
-		res_counter_uncharge(&memcg->res, size);
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
-		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
-	} else
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
-
-	if (batch > nr_pages) {
-		batch = nr_pages;
-		goto retry;
-	}
-
-	/*
-	 * Unlike in global OOM situations, memcg is not in a physical
-	 * memory shortage.  Allow dying and OOM-killed tasks to
-	 * bypass the last charges so that they can exit quickly and
-	 * free their memory.
-	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
-		     fatal_signal_pending(current)))
-		goto bypass;
-
-	if (unlikely(task_in_memcg_oom(current)))
-		goto nomem;
-
-	if (!(gfp_mask & __GFP_WAIT))
-		goto nomem;
-
-	if (gfp_mask & __GFP_NORETRY)
-		goto nomem;
-
-	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
-
-	if (mem_cgroup_margin(mem_over_limit) >= batch)
-		goto retry;
-	/*
-	 * Even though the limit is exceeded at this point, reclaim
-	 * may have been able to free some pages.  Retry the charge
-	 * before killing the task.
-	 *
-	 * Only for regular pages, though: huge pages are rather
-	 * unlikely to succeed so close to the limit, and we fall back
-	 * to regular pages anyway in case of failure.
-	 */
-	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
-		goto retry;
-	/*
-	 * At task move, charge accounts can be doubly counted. So, it's
-	 * better to wait until the end of task_move if something is going on.
-	 */
-	if (mem_cgroup_wait_acct_move(mem_over_limit))
-		goto retry;
-
-	if (nr_retries--)
-		goto retry;
-
-	if (gfp_mask & __GFP_NOFAIL)
-		goto bypass;
-
-	if (fatal_signal_pending(current))
-		goto bypass;
-
-	if (!oom)
-		goto nomem;
-
-	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
-nomem:
-	if (!(gfp_mask & __GFP_NOFAIL))
-		return -ENOMEM;
-bypass:
-	memcg = root_mem_cgroup;
-	ret = -EINTR;
-	goto retry;
-
-done_restock:
-	if (batch > nr_pages)
-		refill_stock(memcg, batch - nr_pages);
-done:
-	return ret;
-}
-
-/**
- * mem_cgroup_try_charge_mm - try charging a mm
- * @mm: mm_struct to charge
- * @nr_pages: number of pages to charge
- * @oom: trigger OOM if reclaim fails
- *
- * Returns the charged mem_cgroup associated with the given mm_struct or
- * NULL the charge failed.
- */
-static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
-				 gfp_t gfp_mask,
-				 unsigned int nr_pages,
-				 bool oom)
-
-{
-	struct mem_cgroup *memcg;
-	int ret;
-
-	memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
-	css_put(&memcg->css);
-	if (ret == -EINTR)
-		memcg = root_mem_cgroup;
-	else if (ret)
-		memcg = NULL;
-
-	return memcg;
-}
-
-/*
- * Somemtimes we have to undo a charge we got by try_charge().
- * This function is for that and do uncharge, put css's refcnt.
- * gotten by try_charge().
- */
-static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
-				       unsigned int nr_pages)
-{
-	unsigned long bytes = nr_pages * PAGE_SIZE;
-
-	res_counter_uncharge(&memcg->res, bytes);
-	if (do_swap_account)
-		res_counter_uncharge(&memcg->memsw, bytes);
-}
-
 /*
  * Cancel chrages in this cgroup....doesn't propagate to parent cgroup.
  * This is useful when moving usage to parent cgroup.
@@ -2788,69 +2631,6 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	return memcg;
 }
 
-static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
-				       struct page *page,
-				       unsigned int nr_pages,
-				       enum charge_type ctype,
-				       bool lrucare)
-{
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct zone *uninitialized_var(zone);
-	struct lruvec *lruvec;
-	bool was_on_lru = false;
-	bool anon;
-
-	lock_page_cgroup(pc);
-	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
-	/*
-	 * we don't need page_cgroup_lock about tail pages, becase they are not
-	 * accessed by any other context at this point.
-	 */
-
-	/*
-	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
-	 * may already be on some other mem_cgroup's LRU.  Take care of it.
-	 */
-	if (lrucare) {
-		zone = page_zone(page);
-		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page)) {
-			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
-			ClearPageLRU(page);
-			del_page_from_lru_list(page, lruvec, page_lru(page));
-			was_on_lru = true;
-		}
-	}
-
-	pc->mem_cgroup = memcg;
-	SetPageCgroupUsed(pc);
-
-	if (lrucare) {
-		if (was_on_lru) {
-			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
-			VM_BUG_ON_PAGE(PageLRU(page), page);
-			SetPageLRU(page);
-			add_page_to_lru_list(page, lruvec, page_lru(page));
-		}
-		spin_unlock_irq(&zone->lru_lock);
-	}
-
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_ANON)
-		anon = true;
-	else
-		anon = false;
-
-	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
-	unlock_page_cgroup(pc);
-
-	/*
-	 * "charge_statistics" updated event counter. Then, check it.
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
-	 */
-	memcg_check_events(memcg, page);
-}
-
 static DEFINE_MUTEX(set_limit_mutex);
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -2895,6 +2675,9 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
+static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
+		      unsigned int nr_pages, bool oom);
+
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
@@ -2904,22 +2687,21 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	if (ret)
 		return ret;
 
-	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
-				    oom_gfp_allowed(gfp));
+	ret = try_charge(memcg, gfp, size >> PAGE_SHIFT, oom_gfp_allowed(gfp));
 	if (ret == -EINTR)  {
 		/*
-		 * mem_cgroup_try_charge() chosed to bypass to root due to
-		 * OOM kill or fatal signal.  Since our only options are to
-		 * either fail the allocation or charge it to this cgroup, do
-		 * it as a temporary condition. But we can't fail. From a
-		 * kmem/slab perspective, the cache has already been selected,
-		 * by mem_cgroup_kmem_get_cache(), so it is too late to change
+		 * try_charge() chose to bypass to root due to OOM kill or
+		 * fatal signal.  Since our only options are to either fail
+		 * the allocation or charge it to this cgroup, do it as a
+		 * temporary condition. But we can't fail. From a kmem/slab
+		 * perspective, the cache has already been selected, by
+		 * mem_cgroup_kmem_get_cache(), so it is too late to change
 		 * our minds.
 		 *
 		 * This condition will only trigger if the task entered
-		 * memcg_charge_kmem in a sane state, but was OOM-killed during
-		 * mem_cgroup_try_charge() above. Tasks that were already
-		 * dying when the allocation triggers should have been already
+		 * memcg_charge_kmem in a sane state, but was OOM-killed
+		 * during try_charge() above. Tasks that were already dying
+		 * when the allocation triggers should have been already
 		 * directed to the root cgroup in memcontrol.h
 		 */
 		res_counter_charge_nofail(&memcg->res, size, &fail_res);
@@ -3728,193 +3510,17 @@ static int mem_cgroup_move_parent(struct page *page,
 	}
 
 	ret = mem_cgroup_move_account(page, nr_pages,
-				pc, child, parent);
-	if (!ret)
-		__mem_cgroup_cancel_local_charge(child, nr_pages);
-
-	if (nr_pages > 1)
-		compound_unlock_irqrestore(page, flags);
-	putback_lru_page(page);
-put:
-	put_page(page);
-out:
-	return ret;
-}
-
-int mem_cgroup_charge_anon(struct page *page,
-			      struct mm_struct *mm, gfp_t gfp_mask)
-{
-	unsigned int nr_pages = 1;
-	struct mem_cgroup *memcg;
-	bool oom = true;
-
-	if (mem_cgroup_disabled())
-		return 0;
-
-	VM_BUG_ON_PAGE(page_mapped(page), page);
-	VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
-	VM_BUG_ON(!mm);
-
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		/*
-		 * Never OOM-kill a process for a huge page.  The
-		 * fault handler will fall back to regular pages.
-		 */
-		oom = false;
-	}
-
-	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
-	if (!memcg)
-		return -ENOMEM;
-	__mem_cgroup_commit_charge(memcg, page, nr_pages,
-				   MEM_CGROUP_CHARGE_TYPE_ANON, false);
-	return 0;
-}
-
-/*
- * While swap-in, try_charge -> commit or cancel, the page is locked.
- * And when try_charge() successfully returns, one refcnt to memcg without
- * struct page_cgroup is acquired. This refcnt will be consumed by
- * "commit()" or removed by "cancel()"
- */
-static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-					  struct page *page,
-					  gfp_t mask,
-					  struct mem_cgroup **memcgp)
-{
-	struct mem_cgroup *memcg = NULL;
-	struct page_cgroup *pc;
-	int ret;
-
-	pc = lookup_page_cgroup(page);
-	/*
-	 * Every swap fault against a single page tries to charge the
-	 * page, bail as early as possible.  shmem_unuse() encounters
-	 * already charged pages, too.  The USED bit is protected by
-	 * the page lock, which serializes swap cache removal, which
-	 * in turn serializes uncharging.
-	 */
-	if (PageCgroupUsed(pc))
-		goto out;
-	if (do_swap_account)
-		memcg = try_get_mem_cgroup_from_page(page);
-	if (!memcg)
-		memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
-	css_put(&memcg->css);
-	if (ret == -EINTR)
-		memcg = root_mem_cgroup;
-	else if (ret)
-		return ret;
-out:
-	*memcgp = memcg;
-	return 0;
-}
-
-int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
-				 gfp_t gfp_mask, struct mem_cgroup **memcgp)
-{
-	if (mem_cgroup_disabled()) {
-		*memcgp = NULL;
-		return 0;
-	}
-	/*
-	 * A racing thread's fault, or swapoff, may have already
-	 * updated the pte, and even removed page from swap cache: in
-	 * those cases unuse_pte()'s pte_same() test will fail; but
-	 * there's also a KSM case which does need to charge the page.
-	 */
-	if (!PageSwapCache(page)) {
-		struct mem_cgroup *memcg;
-
-		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
-		if (!memcg)
-			return -ENOMEM;
-		*memcgp = memcg;
-		return 0;
-	}
-	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp);
-}
-
-void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
-{
-	if (mem_cgroup_disabled())
-		return;
-	if (!memcg)
-		return;
-	__mem_cgroup_cancel_charge(memcg, 1);
-}
-
-static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
-					enum charge_type ctype)
-{
-	if (mem_cgroup_disabled())
-		return;
-	if (!memcg)
-		return;
-
-	__mem_cgroup_commit_charge(memcg, page, 1, ctype, true);
-	/*
-	 * Now swap is on-memory. This means this page may be
-	 * counted both as mem and swap....double count.
-	 * Fix it by uncharging from memsw. Basically, this SwapCache is stable
-	 * under lock_page(). But in do_swap_page()::memory.c, reuse_swap_page()
-	 * may call delete_from_swap_cache() before reach here.
-	 */
-	if (do_swap_account && PageSwapCache(page)) {
-		swp_entry_t ent = {.val = page_private(page)};
-		mem_cgroup_uncharge_swap(ent);
-	}
-}
-
-void mem_cgroup_commit_charge_swapin(struct page *page,
-				     struct mem_cgroup *memcg)
-{
-	__mem_cgroup_commit_charge_swapin(page, memcg,
-					  MEM_CGROUP_CHARGE_TYPE_ANON);
-}
-
-int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask)
-{
-	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
-	struct mem_cgroup *memcg;
-	int ret;
-
-	if (mem_cgroup_disabled())
-		return 0;
-	if (PageCompound(page))
-		return 0;
-
-	if (PageSwapCache(page)) { /* shmem */
-		ret = __mem_cgroup_try_charge_swapin(mm, page,
-						     gfp_mask, &memcg);
-		if (ret)
-			return ret;
-		__mem_cgroup_commit_charge_swapin(page, memcg, type);
-		return 0;
-	}
-
-	/*
-	 * Page cache insertions can happen without an actual mm
-	 * context, e.g. during disk probing on boot.
-	 */
-	if (unlikely(!mm)) {
-		memcg = root_mem_cgroup;
-		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
-		VM_BUG_ON(ret == -EINTR);
-		if (ret)
-			return ret;
-	} else {
-		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
-		if (!memcg)
-			return -ENOMEM;
-	}
-	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
-	return 0;
+				pc, child, parent);
+	if (!ret)
+		__mem_cgroup_cancel_local_charge(child, nr_pages);
+
+	if (nr_pages > 1)
+		compound_unlock_irqrestore(page, flags);
+	putback_lru_page(page);
+put:
+	put_page(page);
+out:
+	return ret;
 }
 
 static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
@@ -4253,6 +3859,9 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
+static void commit_charge(struct page *page, struct mem_cgroup *memcg,
+			  unsigned int nr_pages, bool anon, bool lrucare);
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
@@ -4263,7 +3872,6 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
-	enum charge_type ctype;
 
 	*memcgp = NULL;
 
@@ -4325,16 +3933,12 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	 * page. In the case new page is migrated but not remapped, new page's
 	 * mapcount will be finally 0 and we call uncharge in end_migration().
 	 */
-	if (PageAnon(page))
-		ctype = MEM_CGROUP_CHARGE_TYPE_ANON;
-	else
-		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	/*
 	 * The page is committed to the memcg, but it's not actually
 	 * charged to the res_counter since we plan on replacing the
 	 * old one and only one page is going to be left afterwards.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
+	commit_charge(newpage, memcg, nr_pages, PageAnon(page), false);
 }
 
 /* remove redundant charge if migration failed*/
@@ -4393,7 +3997,6 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 {
 	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
-	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
 
 	if (mem_cgroup_disabled())
 		return;
@@ -4419,7 +4022,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
 	 * LRU while we overwrite pc->mem_cgroup.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, 1, type, true);
+	commit_charge(newpage, memcg, 1, false, true);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -6434,6 +6037,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 #ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 #define PRECHARGE_COUNT_AT_ONCE	256
+static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages);
 static int mem_cgroup_do_precharge(unsigned long count)
 {
 	int ret = 0;
@@ -6470,9 +6074,9 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
+		ret = try_charge(memcg, GFP_KERNEL, 1, false);
 		if (ret == -EINTR)
-			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
+			cancel_charge(root_mem_cgroup, 1);
 		if (ret)
 			return ret;
 		mc.precharge++;
@@ -6736,7 +6340,7 @@ static void __mem_cgroup_clear_mc(void)
 
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
-		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
+		cancel_charge(mc.to, mc.precharge);
 		mc.precharge = 0;
 	}
 	/*
@@ -6744,7 +6348,7 @@ static void __mem_cgroup_clear_mc(void)
 	 * we must uncharge here.
 	 */
 	if (mc.moved_charge) {
-		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
+		cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
 	}
 	/* we must fixup refcnts and charges */
@@ -7070,6 +6674,319 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
+		      unsigned int nr_pages, bool oom)
+{
+	unsigned int batch = max(CHARGE_BATCH, nr_pages);
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct mem_cgroup *mem_over_limit;
+	struct res_counter *fail_res;
+	unsigned long nr_reclaimed;
+	unsigned long flags = 0;
+	unsigned long long size;
+	int ret = 0;
+
+retry:
+	if (consume_stock(memcg, nr_pages))
+		goto done;
+
+	size = batch * PAGE_SIZE;
+	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
+		if (!do_swap_account)
+			goto done_restock;
+		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
+			goto done_restock;
+		res_counter_uncharge(&memcg->res, size);
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
+		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+	} else
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+
+	if (batch > nr_pages) {
+		batch = nr_pages;
+		goto retry;
+	}
+
+	/*
+	 * Unlike in global OOM situations, memcg is not in a physical
+	 * memory shortage.  Allow dying and OOM-killed tasks to
+	 * bypass the last charges so that they can exit quickly and
+	 * free their memory.
+	 */
+	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+		     fatal_signal_pending(current)))
+		goto bypass;
+
+	if (unlikely(task_in_memcg_oom(current)))
+		goto nomem;
+
+	if (!(gfp_mask & __GFP_WAIT))
+		goto nomem;
+
+	if (gfp_mask & __GFP_NORETRY)
+		goto nomem;
+
+	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
+
+	if (mem_cgroup_margin(mem_over_limit) >= batch)
+		goto retry;
+	/*
+	 * Even though the limit is exceeded at this point, reclaim
+	 * may have been able to free some pages.  Retry the charge
+	 * before killing the task.
+	 *
+	 * Only for regular pages, though: huge pages are rather
+	 * unlikely to succeed so close to the limit, and we fall back
+	 * to regular pages anyway in case of failure.
+	 */
+	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
+		goto retry;
+	/*
+	 * At task move, charge accounts can be doubly counted. So, it's
+	 * better to wait until the end of task_move if something is going on.
+	 */
+	if (mem_cgroup_wait_acct_move(mem_over_limit))
+		goto retry;
+
+	if (nr_retries--)
+		goto retry;
+
+	if (gfp_mask & __GFP_NOFAIL)
+		goto bypass;
+
+	if (fatal_signal_pending(current))
+		goto bypass;
+
+	if (!oom)
+		goto nomem;
+
+	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
+nomem:
+	if (!(gfp_mask & __GFP_NOFAIL))
+		return -ENOMEM;
+bypass:
+	memcg = root_mem_cgroup;
+	ret = -EINTR;
+	goto retry;
+
+done_restock:
+	if (batch > nr_pages)
+		refill_stock(memcg, batch - nr_pages);
+done:
+	return ret;
+}
+
+/**
+ * mem_cgroup_try_charge - try charging a page
+ * @page: page to charge
+ * @mm: mm context of the victim
+ * @gfp_mask: reclaim mode
+ * @memcgp: charged memcg return
+ *
+ * Try to charge @page to the memcg that @mm belongs to, reclaiming
+ * pages according to @gfp_mask if necessary.
+ *
+ * Returns 0 on success, with *@memcgp pointing to the charged memcg.
+ * Otherwise, an error code is returned.
+ *
+ * After page->mapping has been set up, the caller must finalize the
+ * charge with mem_cgroup_commit_charge().  Or abort the transaction
+ * with mem_cgroup_cancel_charge() in case page instantiation fails.
+ */
+int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
+			  gfp_t gfp_mask, struct mem_cgroup **memcgp)
+{
+	struct mem_cgroup *memcg = NULL;
+	unsigned int nr_pages = 1;
+	bool oom = true;
+	int ret = 0;
+
+	if (mem_cgroup_disabled())
+		goto out;
+
+	if (PageSwapCache(page)) {
+		struct page_cgroup *pc = lookup_page_cgroup(page);
+		/*
+		 * Every swap fault against a single page tries to charge the
+		 * page, bail as early as possible.  shmem_unuse() encounters
+		 * already charged pages, too.  The USED bit is protected by
+		 * the page lock, which serializes swap cache removal, which
+		 * in turn serializes uncharging.
+		 */
+		if (PageCgroupUsed(pc))
+			goto out;
+	}
+
+	if (PageTransHuge(page)) {
+		nr_pages <<= compound_order(page);
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		/*
+		 * Never OOM-kill a process for a huge page.  The
+		 * fault handler will fall back to regular pages.
+		 */
+		oom = false;
+	}
+
+	if (do_swap_account && PageSwapCache(page))
+		memcg = try_get_mem_cgroup_from_page(page);
+	if (!memcg) {
+		/*
+		 * Page cache insertions can happen without an actual
+		 * mm context, e.g. during disk probing on boot.
+		 */
+		if (unlikely(!mm)) {
+			memcg = root_mem_cgroup;
+			css_get(&memcg->css);
+		} else
+			memcg = get_mem_cgroup_from_mm(mm);
+	}
+
+	ret = try_charge(memcg, gfp_mask, nr_pages, oom);
+
+	css_put(&memcg->css);
+
+	if (ret == -EINTR) {
+		memcg = root_mem_cgroup;
+		ret = 0;
+	}
+out:
+	*memcgp = memcg;
+	return ret;
+}
+
+static void commit_charge(struct page *page, struct mem_cgroup *memcg,
+			  unsigned int nr_pages, bool anon, bool lrucare)
+{
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+	struct zone *uninitialized_var(zone);
+	bool was_on_lru = false;
+	struct lruvec *lruvec;
+
+	lock_page_cgroup(pc);
+
+	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
+	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
+
+	if (lrucare) {
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page)) {
+			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+			ClearPageLRU(page);
+			del_page_from_lru_list(page, lruvec, page_lru(page));
+			was_on_lru = true;
+		}
+	}
+
+	pc->mem_cgroup = memcg;
+	SetPageCgroupUsed(pc);
+
+	if (lrucare) {
+		if (was_on_lru) {
+			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+			VM_BUG_ON_PAGE(PageLRU(page), page);
+			SetPageLRU(page);
+			add_page_to_lru_list(page, lruvec, page_lru(page));
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
+	unlock_page_cgroup(pc);
+
+	memcg_check_events(memcg, page);
+}
+
+/**
+ * mem_cgroup_commit_charge - commit a page charge
+ * @page: page to charge
+ * @memcg: memcg to charge the page to
+ * @lrucare: page might be on LRU already
+ *
+ * Finalize a charge transaction started by mem_cgroup_try_charge(),
+ * after page->mapping has been set up.  This must happen atomically
+ * as part of the page instantiation, i.e. under the page table lock
+ * for anonymous pages, under the page lock for page and swap cache.
+ *
+ * In addition, the page must not be on the LRU during the commit, to
+ * prevent racing with task migration.  If it might be, use @lrucare.
+ *
+ * Use mem_cgroup_cancel_charge() to cancel the transaction instead.
+ */
+void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
+			      bool lrucare)
+{
+	unsigned int nr_pages = 1;
+
+	VM_BUG_ON_PAGE(!page->mapping, page);
+	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
+
+	if (mem_cgroup_disabled())
+		return;
+	/*
+	 * Swap faults will attempt to charge the same page multiple
+	 * times.  But reuse_swap_page() might have removed the page
+	 * from swapcache already, so we can't check PageSwapCache().
+	 */
+	if (!memcg)
+		return;
+
+	if (PageTransHuge(page)) {
+		nr_pages <<= compound_order(page);
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+	}
+
+	commit_charge(page, memcg, nr_pages, PageAnon(page), lrucare);
+
+	if (do_swap_account && PageSwapCache(page)) {
+		swp_entry_t entry = { .val = page_private(page) };
+		/*
+		 * The swap entry might not get freed for a long time,
+		 * let's not wait for it.  The page already received a
+		 * memory+swap charge, drop the swap entry duplicate.
+		 */
+		mem_cgroup_uncharge_swap(entry);
+	}
+}
+
+static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	unsigned long bytes = nr_pages * PAGE_SIZE;
+
+	res_counter_uncharge(&memcg->res, bytes);
+	if (do_swap_account)
+		res_counter_uncharge(&memcg->memsw, bytes);
+}
+
+/**
+ * mem_cgroup_cancel_charge - cancel a page charge
+ * @page: page to charge
+ * @memcg: memcg to charge the page to
+ *
+ * Cancel a charge transaction started by mem_cgroup_try_charge().
+ */
+void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
+{
+	unsigned int nr_pages = 1;
+
+	if (mem_cgroup_disabled())
+		return;
+	/*
+	 * Swap faults will attempt to charge the same page multiple
+	 * times.  But reuse_swap_page() might have removed the page
+	 * from swapcache already, so we can't check PageSwapCache().
+	 */
+	if (!memcg)
+		return;
+
+	if (PageTransHuge(page)) {
+		nr_pages <<= compound_order(page);
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+	}
+
+	cancel_charge(memcg, nr_pages);
+}
+
 /*
  * subsys_initcall() for memory controller.
  *
diff --git a/mm/memory.c b/mm/memory.c
index d0f0bef3be48..36af46a50fad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2673,6 +2673,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *dirty_page = NULL;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
+	struct mem_cgroup *memcg;
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2828,7 +2829,7 @@ gotten:
 	}
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))
+	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))
 		goto oom_free_new;
 
 	mmun_start  = address & PAGE_MASK;
@@ -2858,6 +2859,8 @@ gotten:
 		 */
 		ptep_clear_flush(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
+		mem_cgroup_commit_charge(new_page, memcg, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
 		 * We call the notify macro here because, when using secondary
 		 * mmu page tables (such as kvm shadow page tables), we want the
@@ -2895,7 +2898,7 @@ gotten:
 		new_page = old_page;
 		ret |= VM_FAULT_WRITE;
 	} else
-		mem_cgroup_uncharge_page(new_page);
+		mem_cgroup_cancel_charge(new_page, memcg);
 
 	if (new_page)
 		page_cache_release(new_page);
@@ -3031,10 +3034,10 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	spinlock_t *ptl;
 	struct page *page, *swapcache;
+	struct mem_cgroup *memcg;
 	swp_entry_t entry;
 	pte_t pte;
 	int locked;
-	struct mem_cgroup *ptr;
 	int exclusive = 0;
 	int ret = 0;
 
@@ -3110,7 +3113,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_page;
 	}
 
-	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
@@ -3135,10 +3138,6 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * while the page is counted on swap but not yet in mapcount i.e.
 	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
 	 * must be called after the swap_free(), or it will never succeed.
-	 * Because delete_from_swap_page() may be called by reuse_swap_page(),
-	 * mem_cgroup_commit_charge_swapin() may not be able to find swp_entry
-	 * in page->private. In this case, a record in swap_cgroup  is silently
-	 * discarded at swap_free().
 	 */
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
@@ -3154,12 +3153,14 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(mm, address, page_table, pte);
-	if (page == swapcache)
+	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, address, exclusive);
-	else /* ksm created a completely new copy */
+		mem_cgroup_commit_charge(page, memcg, true);
+	} else { /* ksm created a completely new copy */
 		page_add_new_anon_rmap(page, vma, address);
-	/* It's better to call commit-charge after rmap is established */
-	mem_cgroup_commit_charge_swapin(page, ptr);
+		mem_cgroup_commit_charge(page, memcg, false);
+		lru_cache_add_active_or_unevictable(page, vma);
+	}
 
 	swap_free(entry);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
@@ -3192,7 +3193,7 @@ unlock:
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_cancel_charge_swapin(ptr);
+	mem_cgroup_cancel_charge(page, memcg);
 	pte_unmap_unlock(page_table, ptl);
 out_page:
 	unlock_page(page);
@@ -3248,6 +3249,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags)
 {
+	struct mem_cgroup *memcg;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
@@ -3281,7 +3283,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_charge_anon(page, mm, GFP_KERNEL))
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg))
 		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -3294,6 +3296,8 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
+	mem_cgroup_commit_charge(page, memcg, false);
+	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
 
@@ -3303,7 +3307,7 @@ unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
 release:
-	mem_cgroup_uncharge_page(page);
+	mem_cgroup_cancel_charge(page, memcg);
 	page_cache_release(page);
 	goto unlock;
 oom_free_page:
@@ -3526,6 +3530,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page, *new_page;
+	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int ret;
@@ -3537,7 +3542,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!new_page)
 		return VM_FAULT_OOM;
 
-	if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)) {
+	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg)) {
 		page_cache_release(new_page);
 		return VM_FAULT_OOM;
 	}
@@ -3557,12 +3562,14 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto uncharge_out;
 	}
 	do_set_pte(vma, address, new_page, pte, true, true);
+	mem_cgroup_commit_charge(new_page, memcg, false);
+	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
 	page_cache_release(fault_page);
 	return ret;
 uncharge_out:
-	mem_cgroup_uncharge_page(new_page);
+	mem_cgroup_cancel_charge(new_page, memcg);
 	page_cache_release(new_page);
 	return ret;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index bed48809e5d0..a88fabd71f87 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1853,6 +1853,7 @@ fail_putback:
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_new_anon_rmap(new_page, vma, mmun_start);
+	lru_cache_add_active_or_unevictable(new_page, vma);
 	pmdp_clear_flush(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e77396d1a..6b6fe5f4ece1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1024,11 +1024,6 @@ void page_add_new_anon_rmap(struct page *page,
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
-	if (!mlocked_vma_newpage(vma, page)) {
-		SetPageActive(page);
-		lru_cache_add(page);
-	} else
-		add_page_to_unevictable_list(page);
 }
 
 /**
diff --git a/mm/shmem.c b/mm/shmem.c
index 8f1a95406bae..f8637acc2dad 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -668,6 +668,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 {
 	struct list_head *this, *next;
 	struct shmem_inode_info *info;
+	struct mem_cgroup *memcg;
 	int found = 0;
 	int error = 0;
 
@@ -683,7 +684,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
 	 * Charged back to the user (not to caller) when swap account is used.
 	 */
-	error = mem_cgroup_charge_file(page, current->mm, GFP_KERNEL);
+	error = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL, &memcg);
 	if (error)
 		goto out;
 	/* No radix_tree_preload: swap entry keeps a place for page in tree */
@@ -701,8 +702,11 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (found < 0)
+	if (found < 0) {
 		error = found;
+		mem_cgroup_cancel_charge(page, memcg);
+	} else
+		mem_cgroup_commit_charge(page, memcg, true);
 out:
 	unlock_page(page);
 	page_cache_release(page);
@@ -1005,6 +1009,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info;
 	struct shmem_sb_info *sbinfo;
+	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
 	int error;
@@ -1080,8 +1085,7 @@ repeat:
 				goto failed;
 		}
 
-		error = mem_cgroup_charge_file(page, current->mm,
-						gfp & GFP_RECLAIM_MASK);
+		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
 						gfp, swp_to_radix_entry(swap));
@@ -1097,12 +1101,16 @@ repeat:
 			 * Reset swap.val? No, leave it so "failed" goes back to
 			 * "repeat": reading a hole and writing should succeed.
 			 */
-			if (error)
+			if (error) {
+				mem_cgroup_cancel_charge(page, memcg);
 				delete_from_swap_cache(page);
+			}
 		}
 		if (error)
 			goto failed;
 
+		mem_cgroup_commit_charge(page, memcg, true);
+
 		spin_lock(&info->lock);
 		info->swapped--;
 		shmem_recalc_inode(inode);
@@ -1134,8 +1142,7 @@ repeat:
 
 		SetPageSwapBacked(page);
 		__set_page_locked(page);
-		error = mem_cgroup_charge_file(page, current->mm,
-						gfp & GFP_RECLAIM_MASK);
+		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
 		if (error)
 			goto decused;
 		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
@@ -1145,9 +1152,10 @@ repeat:
 			radix_tree_preload_end();
 		}
 		if (error) {
-			mem_cgroup_uncharge_cache_page(page);
+			mem_cgroup_cancel_charge(page, memcg);
 			goto decused;
 		}
+		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
diff --git a/mm/swap.c b/mm/swap.c
index 9ce43ba4498b..a5bdff331507 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -635,6 +635,26 @@ void add_page_to_unevictable_list(struct page *page)
 	spin_unlock_irq(&zone->lru_lock);
 }
 
+/**
+ * lru_cache_add_active_or_unevictable
+ * @page:  the page to be added to LRU
+ * @vma:   vma in which page is mapped for determining reclaimability
+ *
+ * Place @page on the active or unevictable LRU list, depending on its
+ * evictability.  Note that if the page is not evictable, it goes
+ * directly back onto it's zone's unevictable list, it does NOT use a
+ * per cpu pagevec.
+ */
+void lru_cache_add_active_or_unevictable(struct page *page,
+					 struct vm_area_struct *vma)
+{
+	if (!mlocked_vma_newpage(vma, page)) {
+		SetPageActive(page);
+		lru_cache_add(page);
+	} else
+		add_page_to_unevictable_list(page);
+}
+
 /*
  * If the page can not be invalidated, it is moved to the
  * inactive list to speed up its reclaim.  It is moved to the
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4a7f7e6992b6..7c57c7256c6e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1126,15 +1126,14 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
-					 GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg)) {
 		ret = -ENOMEM;
 		goto out_nolock;
 	}
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (unlikely(!maybe_same_pte(*pte, swp_entry_to_pte(entry)))) {
-		mem_cgroup_cancel_charge_swapin(memcg);
+		mem_cgroup_cancel_charge(page, memcg);
 		ret = 0;
 		goto out;
 	}
@@ -1144,11 +1143,14 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	if (page == swapcache)
+	if (page == swapcache) {
 		page_add_anon_rmap(page, vma, addr);
-	else /* ksm created a completely new copy */
+		mem_cgroup_commit_charge(page, memcg, true);
+	} else { /* ksm created a completely new copy */
 		page_add_new_anon_rmap(page, vma, addr);
-	mem_cgroup_commit_charge_swapin(page, memcg);
+		mem_cgroup_commit_charge(page, memcg, false);
+		lru_cache_add_active_or_unevictable(page, vma);
+	}
 	swap_free(entry);
 	/*
 	 * Move the page to the active list so it is not
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
