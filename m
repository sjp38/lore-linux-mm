Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DCC446B00D1
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:13 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 44/49] mm: numa: Add THP migration for the NUMA working set scanning fault case.
Date: Fri,  7 Dec 2012 10:23:47 +0000
Message-Id: <1354875832-9700-45-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Note: This is very heavily based on a patch from Peter Zijlstra with
	fixes from Ingo Molnar, Hugh Dickins and Johannes Weiner.  That patch
	put a lot of migration logic into mm/huge_memory.c where it does
	not belong. This version puts tries to share some of the migration
	logic with migrate_misplaced_page.  However, it should be noted
	that now migrate.c is doing more with the pagetable manipulation
	than is preferred. The end result is barely recognisable so as
	before, the signed-offs had to be removed but will be re-added if
	the original authors are ok with it.

Add THP migration for the NUMA working set scanning fault case.

It uses the page lock to serialize. No migration pte dance is
necessary because the pte is already unmapped when we decide
to migrate.

[dhillf@gmail.com: Fix memory leak on isolation failure]
[dhillf@gmail.com: Fix transfer of last_nid information]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h |   15 +++
 mm/huge_memory.c        |   59 ++++++++----
 mm/internal.h           |    7 +-
 mm/memcontrol.c         |    7 +-
 mm/migrate.c            |  231 ++++++++++++++++++++++++++++++++++++++---------
 5 files changed, 255 insertions(+), 64 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 6229177..ed5a6c5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -79,6 +79,12 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 extern int migrate_misplaced_page(struct page *page, int node);
 extern int migrate_misplaced_page(struct page *page, int node);
 extern bool migrate_ratelimited(int node);
+extern int migrate_misplaced_transhuge_page(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node);
+
 #else
 static inline int migrate_misplaced_page(struct page *page, int node)
 {
@@ -88,6 +94,15 @@ static inline bool migrate_ratelimited(int node)
 {
 	return false;
 }
+
+static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node)
+{
+	return -EAGAIN;
+}
 #endif /* CONFIG_BALANCE_NUMA */
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1327a03..61b66f8 100644
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
@@ -1022,10 +1022,12 @@ out:
 int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
-	struct page *page = NULL;
+	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int target_nid;
 	int current_nid = -1;
+	bool migrated;
+	bool page_locked = false;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1033,42 +1035,61 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(pmd);
 	get_page(page);
-	spin_unlock(&mm->page_table_lock);
 	current_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (current_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1)
+	if (target_nid == -1) {
+		put_page(page);
 		goto clear_pmdnuma;
+	}
 
-	/*
-	 * Due to lacking code to migrate thp pages, we'll split
-	 * (which preserves the special PROT_NONE) and re-take the
-	 * fault on the normal pages.
-	 */
-	split_huge_page(page);
-	put_page(page);
-
-	return 0;
+	/* Acquire the page lock to serialise THP migrations */
+	spin_unlock(&mm->page_table_lock);
+	lock_page(page);
+	page_locked = true;
 
-clear_pmdnuma:
+	/* Confirm the PTE did not while locked */
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
+	if (unlikely(!pmd_same(pmd, *pmdp))) {
+		unlock_page(page);
+		put_page(page);
 		goto out_unlock;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	/* Migrate the THP to the requested node */
+	migrated = migrate_misplaced_transhuge_page(mm, vma,
+				pmdp, pmd, addr,
+				page, target_nid);
+	if (migrated)
+		current_nid = target_nid;
+	else {
+		spin_lock(&mm->page_table_lock);
+		if (unlikely(!pmd_same(pmd, *pmdp))) {
+			unlock_page(page);
+			goto out_unlock;
+		}
+		goto clear_pmdnuma;
+	}
+
+	task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
+	return 0;
 
+clear_pmdnuma:
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
+	if (page_locked)
+		unlock_page(page);
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (page) {
-		put_page(page);
-		task_numa_fault(numa_node_id(), HPAGE_PMD_NR, false);
-	}
+	if (current_nid != -1)
+		task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
 	return 0;
 }
 
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
diff --git a/mm/migrate.c b/mm/migrate.c
index 6bc9745..4b1b239 100644
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
@@ -1491,25 +1491,10 @@ bool migrate_ratelimited(int node)
 	return true;
 }
 
-/*
- * Attempt to migrate a misplaced page to the specified destination
- * node. Caller is expected to have an elevated reference count on
- * the page that will be dropped by this function before returning.
- */
-int migrate_misplaced_page(struct page *page, int node)
+/* Returns true if the node is migrate rate-limited after the update */
+bool numamigrate_update_ratelimit(pg_data_t *pgdat)
 {
-	pg_data_t *pgdat = NODE_DATA(node);
-	int isolated = 0;
-	LIST_HEAD(migratepages);
-
-	/*
-	 * Don't migrate pages that are mapped in multiple processes.
-	 * TODO: Handle false sharing detection instead of this hammer
-	 */
-	if (page_mapcount(page) != 1) {
-		put_page(page);
-		goto out;
-	}
+	bool rate_limited = false;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -1522,13 +1507,18 @@ int migrate_misplaced_page(struct page *page, int node)
 		pgdat->balancenuma_migrate_next_window = jiffies +
 			msecs_to_jiffies(migrate_interval_millisecs);
 	}
-	if (pgdat->balancenuma_migrate_nr_pages > ratelimit_pages) {
-		spin_unlock(&pgdat->balancenuma_migrate_lock);
-		put_page(page);
-		goto out;
-	}
-	pgdat->balancenuma_migrate_nr_pages++;
+	if (pgdat->balancenuma_migrate_nr_pages > ratelimit_pages)
+		rate_limited = true;
+	else
+		pgdat->balancenuma_migrate_nr_pages++;
 	spin_unlock(&pgdat->balancenuma_migrate_lock);
+	
+	return rate_limited;
+}
+
+int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+{
+	int ret = 0;
 
 	/* Avoid migrating to a node that is nearly full */
 	if (migrate_balanced_pgdat(pgdat, 1)) {
@@ -1536,13 +1526,18 @@ int migrate_misplaced_page(struct page *page, int node)
 
 		if (isolate_lru_page(page)) {
 			put_page(page);
-			goto out;
+			return 0;
 		}
-		isolated = 1;
 
+		/* Page is isolated */
+		ret = 1;
 		page_lru = page_is_file_cache(page);
-		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
-		list_add(&page->lru, &migratepages);
+		if (!PageTransHuge(page))
+			inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+		else
+			mod_zone_page_state(page_zone(page),
+					NR_ISOLATED_ANON + page_lru,
+					HPAGE_PMD_NR);
 	}
 
 	/*
@@ -1555,23 +1550,177 @@ int migrate_misplaced_page(struct page *page, int node)
 	 */
 	put_page(page);
 
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
+	return ret;
+}
+
+/*
+ * Attempt to migrate a misplaced page to the specified destination
+ * node. Caller is expected to have an elevated reference count on
+ * the page that will be dropped by this function before returning.
+ */
+int migrate_misplaced_page(struct page *page, int node)
+{
+	pg_data_t *pgdat = NODE_DATA(node);
+	int isolated = 0;
+	int nr_remaining;
+	LIST_HEAD(migratepages);
+
+	/*
+	 * Don't migrate pages that are mapped in multiple processes.
+	 * TODO: Handle false sharing detection instead of this hammer
+	 */
+	if (page_mapcount(page) != 1) {
+		put_page(page);
+		goto out;
 	}
+
+	/*
+	 * Rate-limit the amount of data that is being migrated to a node.
+	 * Optimal placement is no good if the memory bus is saturated and
+	 * all the time is being spent migrating!
+	 */
+	if (numamigrate_update_ratelimit(pgdat)) {
+		put_page(page);
+		goto out;
+	}
+
+	isolated = numamigrate_isolate_page(pgdat, page);
+	if (!isolated)
+		goto out;
+
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
 	BUG_ON(!list_empty(&migratepages));
 out:
 	return isolated;
 }
+
+int migrate_misplaced_transhuge_page(struct mm_struct *mm,
+				struct vm_area_struct *vma,
+				pmd_t *pmd, pmd_t entry,
+				unsigned long address,
+				struct page *page, int node)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	pg_data_t *pgdat = NODE_DATA(node);
+	int isolated = 0;
+	struct page *new_page = NULL;
+	struct mem_cgroup *memcg = NULL;
+	int page_lru = page_is_file_cache(page);
+
+	/*
+	 * Don't migrate pages that are mapped in multiple processes.
+	 * TODO: Handle false sharing detection instead of this hammer
+	 */
+	if (page_mapcount(page) != 1)
+		goto out_dropref;
+
+	/*
+	 * Rate-limit the amount of data that is being migrated to a node.
+	 * Optimal placement is no good if the memory bus is saturated and
+	 * all the time is being spent migrating!
+	 */
+	if (numamigrate_update_ratelimit(pgdat))
+		goto out_dropref;
+
+	new_page = alloc_pages_node(node,
+		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+	if (!new_page)
+		goto out_dropref;
+	page_xchg_last_nid(new_page, page_last_nid(page));
+
+	isolated = numamigrate_isolate_page(pgdat, page);
+	if (!isolated) {
+		put_page(new_page);
+		goto out_keep_locked;
+	}
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
+
+		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
+		goto out;
+	}
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
+	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
+	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
+
+out:
+	mod_zone_page_state(page_zone(page),
+			NR_ISOLATED_ANON + page_lru,
+			-HPAGE_PMD_NR);
+	return isolated;
+
+out_dropref:
+	put_page(page);
+out_keep_locked:
+	return 0;
+}
 #endif /* CONFIG_BALANCE_NUMA */
 
 #endif /* CONFIG_NUMA */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
