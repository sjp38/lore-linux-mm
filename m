Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 296076B0088
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:44:41 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082454eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:44:40 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 20/52] mm, numa: Implement migrate-on-fault lazy NUMA strategy for regular and THP pages
Date: Sun,  2 Dec 2012 19:43:12 +0100
Message-Id: <1354473824-19229-21-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add regular page and TH-page lazy migration for the NUMA working set
scanning fault case.

This code imports and integrates code heavily from various NUMA
migration and fault based lazy migration patches sent to lkml:

    mm, mempolicy: Lazy migration
    Author: Lee Schermerhorn <lee.schermerhorn@hp.com>

    autonuma: memory follows CPU algorithm and task/mm_autonuma stats collection
    Author: Andrea Arcangeli <aarcange@redhat.com>

    mm/migrate: Introduce migrate_misplaced_page()
    Author: Peter Zijlstra <a.p.zijlstra@chello.nl>

    mm: Numa: Migrate pages handled during a pmd_numa hinting fault
    Author: Mel Gorman <mgorman@suse.de>

And it also includes fixes sent by Hugh Dickins and Johannes Weiner.

On regular pages we use the migrate_pages() facility.

On THP we use the page lock to serialize. No migration pte dance
is necessary because the pte is already unmapped when we decide
to migrate.

Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
Author: Andrea Arcangeli <aarcange@redhat.com>
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Author: Mel Gorman <mgorman@suse.de>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/migrate.h |  29 ++++++--
 mm/huge_memory.c        | 169 ++++++++++++++++++++++++++++++++++++---------
 mm/internal.h           |   7 +-
 mm/memcontrol.c         |   7 +-
 mm/memory.c             |  94 ++++++++++++++++---------
 mm/mempolicy.c          |  61 +++++++++++++----
 mm/migrate.c            | 178 +++++++++++++++++++++++++++++++++++++++---------
 mm/mprotect.c           |  26 +++++--
 8 files changed, 445 insertions(+), 126 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f7404b6..c92d455 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -40,16 +40,31 @@ extern int migrate_vmas(struct mm_struct *mm,
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
-#ifdef CONFIG_NUMA_BALANCING
-extern int migrate_misplaced_page(struct page *page, int node);
-#else
+# ifdef CONFIG_NUMA_BALANCING
+extern int migrate_misplaced_page_put(struct page *page, int node);
+extern int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node);
+# else /* !CONFIG_NUMA_BALANCING: */
 static inline
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page_put(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
-#endif
-#else
+
+static inline
+int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node)
+{
+	return -EAGAIN;
+}
+# endif
+#else /* !CONFIG_MIGRATION: */
 
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
@@ -83,7 +98,7 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #define fail_migrate_page NULL
 
 static inline
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page_put(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3566820..848960c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -600,7 +600,7 @@ out:
 }
 __setup("transparent_hugepage=", setup_transparent_hugepage);
 
-static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
+pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 {
 	if (likely(vma->vm_flags & VM_WRITE))
 		pmd = pmd_mkwrite(pmd);
@@ -711,8 +711,7 @@ out:
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
+	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
 	if (unlikely(pmd_trans_huge(*pmd)))
@@ -1019,51 +1018,157 @@ out:
 	return page;
 }
 
-/* NUMA hinting page fault entry point for trans huge pmds */
+/*
+ * Handle a NUMA fault: check whether we should migrate and
+ * mark it accessible again.
+ */
 int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
+			  unsigned long address, pmd_t entry, pmd_t *pmd)
 {
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
+	struct page *new_page;
 	struct page *page = NULL;
-	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	int target_nid;
+	int last_cpu;
+	int node = -1;
 
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
-		goto out_unlock;
+	if (unlikely(!pmd_same(*pmd, entry)))
+		goto unlock;
 
-	page = pmd_page(pmd);
-	get_page(page);
+	if (unlikely(pmd_trans_splitting(entry))) {
+		spin_unlock(&mm->page_table_lock);
+		wait_split_huge_page(vma->anon_vma, pmd);
+		return 0;
+	}
+
+	page = pmd_page(entry);
+	if (page) {
+		int page_nid = page_to_nid(page);
+
+		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+		last_cpu = page_last_cpu(page);
+
+		get_page(page);
+		/*
+		 * Note that migrating pages shared by others is safe, since
+		 * get_user_pages() or GUP fast would have to fault this page
+		 * present before they could proceed, and we are holding the
+		 * pagetable lock here and are mindful of pmd races below.
+		 */
+		node = mpol_misplaced(page, vma, haddr);
+		if (node != -1 && node != page_nid)
+			goto migrate;
+	}
+
+fixup:
+	/* change back to regular protection */
+	entry = pmd_modify(entry, vma->vm_page_prot);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+
+unlock:
+	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
+
+	return 0;
+
+migrate:
 	spin_unlock(&mm->page_table_lock);
-	count_vm_numa_event(NUMA_HINT_FAULTS);
 
-	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1)
-		goto clear_pmdnuma;
+	lock_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+		unlock_page(page);
+		put_page(page);
+		return 0;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	new_page = alloc_pages_node(node,
+	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+	if (!new_page)
+		goto alloc_fail;
+
+	if (isolate_lru_page(page)) {	/* Does an implicit get_page() */
+		put_page(new_page);
+		goto alloc_fail;
+	}
+
+	__set_page_locked(new_page);
+	SetPageSwapBacked(new_page);
+
+	/* anon mapping, we can simply copy page->mapping to the new page: */
+	new_page->mapping = page->mapping;
+	new_page->index = page->index;
+
+	migrate_page_copy(new_page, page);
+
+	WARN_ON(PageLRU(new_page));
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+
+		/* Reverse changes made by migrate_page_copy() */
+		if (TestClearPageActive(new_page))
+			SetPageActive(page);
+		if (TestClearPageUnevictable(new_page))
+			SetPageUnevictable(page);
+		mlock_migrate_page(page, new_page);
+
+		unlock_page(new_page);
+		put_page(new_page);		/* Free it */
 
+		unlock_page(page);
+		putback_lru_page(page);
+		put_page(page);			/* Drop the local reference */
+		return 0;
+	}
 	/*
-	 * Due to lacking code to migrate thp pages, we'll split
-	 * (which preserves the special PROT_NONE) and re-take the
-	 * fault on the normal pages.
+	 * Traditional migration needs to prepare the memcg charge
+	 * transaction early to prevent the old page from being
+	 * uncharged when installing migration entries.  Here we can
+	 * save the potential rollback and start the charge transfer
+	 * only when migration is already known to end successfully.
 	 */
-	split_huge_page(page);
-	put_page(page);
-	return 0;
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
 
-clear_pmdnuma:
-	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
-		goto out_unlock;
+	entry = mk_pmd(new_page, vma->vm_page_prot);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = pmd_mkhuge(entry);
 
-	pmd = pmd_mknonnuma(pmd);
-	set_pmd_at(mm, haddr, pmdp, pmd);
-	VM_BUG_ON(pmd_numa(*pmdp));
-	update_mmu_cache_pmd(vma, addr, pmdp);
+	page_add_new_anon_rmap(new_page, vma, haddr);
 
-out_unlock:
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+	page_remove_rmap(page);
+	/*
+	 * Finish the charge transaction under the page table lock to
+	 * prevent split_huge_page() from dividing up the charge
+	 * before it's fully transferred to the new page.
+	 */
+	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(&mm->page_table_lock);
-	if (page)
-		put_page(page);
+
+	unlock_page(new_page);
+	unlock_page(page);
+	put_page(page);			/* Drop the rmap reference */
+	put_page(page);			/* Drop the LRU isolation reference */
+	put_page(page);			/* Drop the local reference */
 	return 0;
+
+alloc_fail:
+	unlock_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		put_page(page);
+		page = NULL;
+		goto unlock;
+	}
+	goto fixup;
 }
 
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
diff --git a/mm/internal.h b/mm/internal.h
index a4fa284..7e60ac8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -212,15 +212,18 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 {
 	if (TestClearPageMlocked(page)) {
 		unsigned long flags;
+		int nr_pages = hpage_nr_pages(page);
 
 		local_irq_save(flags);
-		__dec_zone_page_state(page, NR_MLOCK);
+		__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		SetPageMlocked(newpage);
-		__inc_zone_page_state(newpage, NR_MLOCK);
+		__mod_zone_page_state(page_zone(newpage), NR_MLOCK, nr_pages);
 		local_irq_restore(flags);
 	}
 }
 
+extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dd39ba0..d97af96 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3288,15 +3288,18 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 				  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg = NULL;
+	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
 
 	*memcgp = NULL;
 
-	VM_BUG_ON(PageTransHuge(page));
 	if (mem_cgroup_disabled())
 		return;
 
+	if (PageTransHuge(page))
+		nr_pages <<= compound_order(page);
+
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
@@ -3358,7 +3361,7 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	 * charged to the res_counter since we plan on replacing the
 	 * old one and only one page is going to be left afterwards.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
+	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
 }
 
 /* remove redundant charge if migration failed*/
diff --git a/mm/memory.c b/mm/memory.c
index 0197ca0..0cfd26a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3453,12 +3453,25 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+static int numa_migration_target(struct page *page, struct vm_area_struct *vma,
+			       unsigned long addr, int page_nid)
+{
+	count_vm_numa_event(NUMA_HINT_FAULTS);
+	if (page_nid == numa_node_id())
+		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
+
+	return mpol_misplaced(page, vma, addr);
+}
+
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
 	struct page *page = NULL;
+	bool migrated = false;
 	spinlock_t *ptl;
-	int current_nid, target_nid;
+	int target_nid;
+	int last_cpu;
+	int page_nid;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3473,40 +3486,40 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*ptep, pte))) {
 		pte_unmap_unlock(ptep, ptl);
-		goto out;
+		return 0;
 	}
 
 	pte = pte_mknonnuma(pte);
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
-	count_vm_numa_event(NUMA_HINT_FAULTS);
 	page = vm_normal_page(vma, addr, pte);
 	if (!page) {
 		pte_unmap_unlock(ptep, ptl);
 		return 0;
 	}
 
-	get_page(page);
-	current_nid = page_to_nid(page);
-	if (current_nid == numa_node_id())
-		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
-	target_nid = mpol_misplaced(page, vma, addr);
-	pte_unmap_unlock(ptep, ptl);
+	page_nid = page_to_nid(page);
+	WARN_ON_ONCE(page_nid == -1);
+
+	/* Get it before mpol_misplaced() flips it: */
+	last_cpu = page_last_cpu(page);
+	WARN_ON_ONCE(last_cpu == -1);
+
+	target_nid = numa_migration_target(page, vma, addr, page_nid);
 	if (target_nid == -1) {
-		/*
-		 * Account for the fault against the current node if it not
-		 * being replaced regardless of where the page is located.
-		 */
-		current_nid = numa_node_id();
-		put_page(page);
+		pte_unmap_unlock(ptep, ptl);
 		goto out;
 	}
 
-	/* Migrate to the requested node */
-	if (migrate_misplaced_page(page, target_nid))
-		current_nid = target_nid;
+	/* Get a reference for migration: */
+	get_page(page);
+	pte_unmap_unlock(ptep, ptl);
 
+	/* Migrate to the requested node */
+	migrated = migrate_misplaced_page_put(page, target_nid); /* Drops the reference */
+	if (migrated)
+		page_nid = target_nid;
 out:
 	return 0;
 }
@@ -3521,10 +3534,6 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int local_nid = numa_node_id();
-	int curr_nid;
-	unsigned long nr_faults = 0;
-	unsigned long nr_faults_local = 0;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3545,8 +3554,15 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	orig_pte = pte = pte_offset_map_lock(mm, pmdp, _addr, &ptl);
 	pte += offset >> PAGE_SHIFT;
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
-		pte_t pteval = *pte;
 		struct page *page;
+		int page_nid;
+		int target_nid;
+		int last_cpu;
+		bool migrated;
+		pte_t pteval;
+
+		pteval = ACCESS_ONCE(*pte);
+
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3564,16 +3580,33 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page = vm_normal_page(vma, addr, pteval);
 		if (unlikely(!page))
 			continue;
-		curr_nid = page_to_nid(page);
+		/* only check non-shared pages */
+		if (unlikely(page_mapcount(page) != 1))
+			continue;
+
+		page_nid = page_to_nid(page);
+		WARN_ON_ONCE(page_nid == -1);
+
+		last_cpu = page_last_cpu(page);
+		WARN_ON_ONCE(last_cpu == -1);
+
+		target_nid = numa_migration_target(page, vma, addr, page_nid);
+		if (target_nid == -1)
+			continue;
+
+		/* Get a reference for the migration: */
+		get_page(page);
+		pte_unmap_unlock(pte, ptl);
+
+		/* Migrate to the requested node */
+		migrated = migrate_misplaced_page_put(page, target_nid); /* Drops the reference */
+		if (migrated)
+			page_nid = target_nid;
 
-		nr_faults++;
-		if (curr_nid == local_nid)
-			nr_faults_local++;
+		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
 	pte_unmap_unlock(orig_pte, ptl);
 
-	count_vm_numa_events(NUMA_HINT_FAULTS, nr_faults);
-	count_vm_numa_events(NUMA_HINT_FAULTS_LOCAL, nr_faults_local);
 	return 0;
 }
 
@@ -3715,8 +3748,7 @@ retry:
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
+	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
 	if (unlikely(pmd_trans_huge(*pmd)))
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4c1c8d8..ad683b9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2268,10 +2268,9 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 {
 	struct mempolicy *pol;
 	struct zone *zone;
-	int curnid = page_to_nid(page);
+	int page_nid = page_to_nid(page);
 	unsigned long pgoff;
-	int polnid = -1;
-	int ret = -1;
+	int target_node = page_nid;
 
 	BUG_ON(!vma);
 
@@ -2286,14 +2285,15 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 		pgoff = vma->vm_pgoff;
 		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
-		polnid = offset_il_node(pol, vma, pgoff);
+		target_node = offset_il_node(pol, vma, pgoff);
 		break;
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
-			polnid = numa_node_id();
+
+			target_node = numa_node_id();
 		else
-			polnid = pol->v.preferred_node;
+			target_node = pol->v.preferred_node;
 		break;
 
 	case MPOL_BIND:
@@ -2303,13 +2303,13 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * else select nearest allowed node, if any.
 		 * If no allowed nodes, use current [!misplaced].
 		 */
-		if (node_isset(curnid, pol->v.nodes))
+		if (node_isset(page_nid, pol->v.nodes))
 			goto out;
 		(void)first_zones_zonelist(
 				node_zonelist(numa_node_id(), GFP_HIGHUSER),
 				gfp_zone(GFP_HIGHUSER),
 				&pol->v.nodes, &zone);
-		polnid = zone->node;
+		target_node = zone->node;
 		break;
 
 	default:
@@ -2317,15 +2317,50 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	}
 
 	/* Migrate the page towards the node whose CPU is referencing it */
-	if (pol->flags & MPOL_F_MORON)
-		polnid = numa_node_id();
+	if (pol->flags & MPOL_F_MORON) {
+		int cpu_last_access;
+		int this_cpu;
+		int this_node;
+
+		this_cpu = raw_smp_processor_id();
+		this_node = numa_node_id();
+
+		/*
+		 * Multi-stage node selection is used in conjunction
+		 * with a periodic migration fault to build a temporal
+		 * task<->page relation. By using a two-stage filter we
+		 * remove short/unlikely relations.
+		 *
+		 * Using P(p) ~ n_p / n_t as per frequentist
+		 * probability, we can equate a task's usage of a
+		 * particular page (n_p) per total usage of this
+		 * page (n_t) (in a given time-span) to a probability.
+		 *
+		 * Our periodic faults will sample this probability and
+		 * getting the same result twice in a row, given these
+		 * samples are fully independent, is then given by
+		 * P(n)^2, provided our sample period is sufficiently
+		 * short compared to the usage pattern.
+		 *
+		 * This quadric squishes small probabilities, making
+		 * it less likely we act on an unlikely task<->page
+		 * relation.
+		 */
+		cpu_last_access = page_xchg_last_cpu(page, this_cpu);
 
-	if (curnid != polnid)
-		ret = polnid;
+		/* Migrate towards us: */
+		if (cpu_last_access == this_cpu)
+			target_node = this_node;
+	}
 out:
 	mpol_cond_put(pol);
 
-	return ret;
+	/* Page already at its ideal target node: */
+	if (target_node == page_nid)
+		return -1;
+
+	/* Migrate: */
+	return target_node;
 }
 
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
diff --git a/mm/migrate.c b/mm/migrate.c
index cdd07c7..5e50c094 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -410,7 +410,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page))
+	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
 		copy_highpage(newpage, page);
@@ -1460,14 +1460,41 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	return newpage;
 }
 
+int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+{
+	/* Avoid migrating to a node that is nearly full */
+	if (migrate_balanced_pgdat(pgdat, 1)) {
+		int page_lru;
+
+		if (isolate_lru_page(page)) {
+			put_page(page);
+			return 0;
+		}
+
+		/*
+		 * Page is isolated which takes a reference count so now the
+		 * callers reference can be safely dropped without the page
+		 * disappearing underneath us during migration
+		 */
+		put_page(page);
+
+		page_lru = page_is_file_cache(page);
+		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+	}
+
+	return 1;
+}
+
 /*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page_put(struct page *page, int node)
 {
+	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
+	int nr_remaining;
 	LIST_HEAD(migratepages);
 
 	/*
@@ -1479,45 +1506,130 @@ int migrate_misplaced_page(struct page *page, int node)
 		goto out;
 	}
 
-	/* Avoid migrating to a node that is nearly full */
-	if (migrate_balanced_pgdat(NODE_DATA(node), 1)) {
-		int page_lru;
+	isolated = numamigrate_isolate_page(pgdat, page);
+	if (!isolated)
+		goto out;
 
-		if (isolate_lru_page(page)) {
-			put_page(page);
-			goto out;
-		}
-		isolated = 1;
+	list_add(&page->lru, &migratepages);
+	nr_remaining = migrate_pages(&migratepages,
+			alloc_misplaced_dst_page,
+			node, false, MIGRATE_ASYNC,
+			MR_NUMA_MISPLACED);
+	if (nr_remaining) {
+		putback_lru_pages(&migratepages);
+		isolated = 0;
+	} else
+		count_vm_numa_event(NUMA_PAGE_MIGRATE);
+	BUG_ON(!list_empty(&migratepages));
 
-		/*
-		 * Page is isolated which takes a reference count so now the
-		 * callers reference can be safely dropped without the page
-		 * disappearing underneath us during migration
-		 */
-		put_page(page);
+out:
+	return isolated;
+}
 
-		page_lru = page_is_file_cache(page);
-		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
-		list_add(&page->lru, &migratepages);
-	}
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
+				struct vm_area_struct *vma,
+				pmd_t *pmd, pmd_t entry,
+				unsigned long address,
+				struct page *page, int node)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	pg_data_t *pgdat = NODE_DATA(node);
+	int isolated = 0;
+	LIST_HEAD(migratepages);
+	struct page *new_page = NULL;
+	struct mem_cgroup *memcg = NULL;
+	int page_lru = page_is_file_cache(page);
 
-	if (isolated) {
-		int nr_remaining;
-
-		nr_remaining = migrate_pages(&migratepages,
-				alloc_misplaced_dst_page,
-				node, false, MIGRATE_ASYNC,
-				MR_NUMA_MISPLACED);
-		if (nr_remaining) {
-			putback_lru_pages(&migratepages);
-			isolated = 0;
-		} else
-			count_vm_numa_event(NUMA_PAGE_MIGRATE);
+	/*
+	 * Don't migrate pages that are mapped in multiple processes.
+	 * TODO: Handle false sharing detection instead of this hammer
+	 */
+	if (page_mapcount(page) != 1)
+		goto out_dropref;
+
+	new_page = alloc_pages_node(node,
+		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+	if (!new_page)
+		goto out_dropref;
+
+	isolated = numamigrate_isolate_page(pgdat, page);
+	if (!isolated)
+		goto out_keep_locked;
+	list_add(&page->lru, &migratepages);
+
+	/* Prepare a page as a migration target */
+	__set_page_locked(new_page);
+	SetPageSwapBacked(new_page);
+
+	/* anon mapping, we can simply copy page->mapping to the new page: */
+	new_page->mapping = page->mapping;
+	new_page->index = page->index;
+	migrate_page_copy(new_page, page);
+	WARN_ON(PageLRU(new_page));
+
+	/* Recheck the target PMD */
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+
+		/* Reverse changes made by migrate_page_copy() */
+		if (TestClearPageActive(new_page))
+			SetPageActive(page);
+		if (TestClearPageUnevictable(new_page))
+			SetPageUnevictable(page);
+		mlock_migrate_page(page, new_page);
+
+		unlock_page(new_page);
+		put_page(new_page);		/* Free it */
+
+		unlock_page(page);
+		putback_lru_page(page);
+		goto out;
 	}
-	BUG_ON(!list_empty(&migratepages));
+
+	/*
+	 * Traditional migration needs to prepare the memcg charge
+	 * transaction early to prevent the old page from being
+	 * uncharged when installing migration entries.  Here we can
+	 * save the potential rollback and start the charge transfer
+	 * only when migration is already known to end successfully.
+	 */
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
+
+	entry = mk_pmd(new_page, vma->vm_page_prot);
+	entry = pmd_mknonnuma(entry);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = pmd_mkhuge(entry);
+
+	page_add_new_anon_rmap(new_page, vma, haddr);
+
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+	page_remove_rmap(page);
+	/*
+	 * Finish the charge transaction under the page table lock to
+	 * prevent split_huge_page() from dividing up the charge
+	 * before it's fully transferred to the new page.
+	 */
+	mem_cgroup_end_migration(memcg, page, new_page, true);
+	spin_unlock(&mm->page_table_lock);
+
+	unlock_page(new_page);
+	unlock_page(page);
+	put_page(page);			/* Drop the rmap reference */
+	put_page(page);			/* Drop the LRU isolation reference */
+
 out:
+	dec_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
 	return isolated;
+
+out_dropref:
+	put_page(page);
+out_keep_locked:
+	return 0;
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_NUMA */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1b383b7..47335a9 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,12 +37,14 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		int dirty_accountable, int prot_numa, bool *ret_all_same_node)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
+	bool all_same_node = true;
+	int last_nid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -61,6 +63,12 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
+					int this_nid = page_to_nid(page);
+					if (last_nid == -1)
+						last_nid = this_nid;
+					if (last_nid != this_nid)
+						all_same_node = false;
+
 					/* only check non-shared pages */
 					if (!pte_numa(oldpte) &&
 					    page_mapcount(page) == 1) {
@@ -81,7 +89,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			if (updated)
 				pages++;
-
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
@@ -101,6 +108,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
+	*ret_all_same_node = all_same_node;
 	return pages;
 }
 
@@ -111,6 +119,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
+	bool all_same_node;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -127,16 +136,21 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		pages += change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
-
-		if (prot_numa) {
+				 dirty_accountable, prot_numa, &all_same_node);
+
+		/*
+		 * If we are changing protections for NUMA hinting faults then
+		 * set pmd_numa if the examined pages were all on the same
+		 * node. This allows a regular PMD to be handled as one fault
+		 * and effectively batches the taking of the PTL
+		 */
+		if (prot_numa && all_same_node) {
 			struct mm_struct *mm = vma->vm_mm;
 
 			spin_lock(&mm->page_table_lock);
 			set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
 			spin_unlock(&mm->page_table_lock);
 		}
-
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
