Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 531996B009B
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:10:22 -0400 (EDT)
Message-Id: <20121025124834.161540645@chello.nl>
Date: Thu, 25 Oct 2012 14:16:39 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 22/31] sched, numa, mm: Implement THP migration
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0022-sched-numa-mm-Implement-THP-migration.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

Add THP migration for the NUMA working set scanning fault case.

It uses the page lock to serialize. No migration pte dance is
necessary because the pte is already unmapped when we decide
to migrate.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
[ Significant fixes and changelog. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c |  133 ++++++++++++++++++++++++++++++++++++++++++-------------
 mm/migrate.c     |    2 
 2 files changed, 104 insertions(+), 31 deletions(-)

Index: tip/mm/huge_memory.c
===================================================================
--- tip.orig/mm/huge_memory.c
+++ tip/mm/huge_memory.c
@@ -742,12 +742,13 @@ void do_huge_pmd_numa_page(struct mm_str
 			   unsigned int flags, pmd_t entry)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct page *new_page = NULL;
 	struct page *page = NULL;
-	int node;
+	int node, lru;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry)))
-		goto out_unlock;
+		goto unlock;
 
 	if (unlikely(pmd_trans_splitting(entry))) {
 		spin_unlock(&mm->page_table_lock);
@@ -755,45 +756,117 @@ void do_huge_pmd_numa_page(struct mm_str
 		return;
 	}
 
-#ifdef CONFIG_NUMA
 	page = pmd_page(entry);
-	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+	if (page) {
+		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
 
-	get_page(page);
+		get_page(page);
+		node = mpol_misplaced(page, vma, haddr);
+		if (node != -1)
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
 	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
 
-	/*
-	 * XXX should we serialize against split_huge_page ?
-	 */
-
-	node = mpol_misplaced(page, vma, haddr);
-	if (node == -1)
-		goto do_fixup;
-
-	/*
-	 * Due to lacking code to migrate thp pages, we'll split
-	 * (which preserves the special PROT_NONE) and re-take the
-	 * fault on the normal pages.
-	 */
-	split_huge_page(page);
-	put_page(page);
 	return;
 
-do_fixup:
+migrate:
+	spin_unlock(&mm->page_table_lock);
+
+	lock_page(page);
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry)))
-		goto out_unlock;
-#endif
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+		unlock_page(page);
+		put_page(page);
+		return;
+	}
+	spin_unlock(&mm->page_table_lock);
 
-	/* change back to regular protection */
-	entry = pmd_modify(entry, vma->vm_page_prot);
-	if (pmdp_set_access_flags(vma, haddr, pmd, entry, 1))
-		update_mmu_cache_pmd(vma, address, entry);
+	new_page = alloc_pages_node(node,
+	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT,
+	    HPAGE_PMD_ORDER);
+
+	if (!new_page)
+		goto alloc_fail;
+
+	lru = PageLRU(page);
+
+	if (lru && isolate_lru_page(page)) /* does an implicit get_page() */
+		goto alloc_fail;
+
+	if (!trylock_page(new_page))
+		BUG();
+
+	/* anon mapping, we can simply copy page->mapping to the new page: */
+	new_page->mapping = page->mapping;
+	new_page->index = page->index;
 
-out_unlock:
+	migrate_page_copy(new_page, page);
+
+	WARN_ON(PageLRU(new_page));
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+		if (lru)
+			putback_lru_page(page);
+
+		unlock_page(new_page);
+		ClearPageActive(new_page);	/* Set by migrate_page_copy() */
+		new_page->mapping = NULL;
+		put_page(new_page);		/* Free it */
+
+		unlock_page(page);
+		put_page(page);			/* Drop the local reference */
+
+		return;
+	}
+
+	entry = mk_pmd(new_page, vma->vm_page_prot);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = pmd_mkhuge(entry);
+
+	page_add_new_anon_rmap(new_page, vma, haddr);
+
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+	page_remove_rmap(page);
 	spin_unlock(&mm->page_table_lock);
-	if (page)
+
+	put_page(page);			/* Drop the rmap reference */
+
+	if (lru)
+		put_page(page);		/* drop the LRU isolation reference */
+
+	unlock_page(new_page);
+	unlock_page(page);
+	put_page(page);			/* Drop the local reference */
+
+	return;
+
+alloc_fail:
+	if (new_page)
+		put_page(new_page);
+
+	unlock_page(page);
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
 		put_page(page);
+		page = NULL;
+		goto unlock;
+	}
+	goto fixup;
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
Index: tip/mm/migrate.c
===================================================================
--- tip.orig/mm/migrate.c
+++ tip/mm/migrate.c
@@ -417,7 +417,7 @@ int migrate_huge_page_move_mapping(struc
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page))
+	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
 		copy_highpage(newpage, page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
