Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4C1B76B00A4
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:27 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so66300eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:26 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 21/31] sched, numa, mm: Implement THP migration
Date: Tue, 13 Nov 2012 18:13:44 +0100
Message-Id: <1352826834-11774-22-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

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
Link: http://lkml.kernel.org/n/tip-yv9vbiz2s455zxq1ffzx3fye@git.kernel.org
[ Significant fixes and changelog. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c | 131 +++++++++++++++++++++++++++++++++++++++++++------------
 mm/migrate.c     |   2 +-
 2 files changed, 103 insertions(+), 30 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c4c0a57..931caf4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -742,12 +742,13 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -755,45 +756,117 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return;
 	}
 
-#ifdef CONFIG_NUMA
 	page = pmd_page(entry);
-	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+	if (page) {
+		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
 
-	get_page(page);
-	spin_unlock(&mm->page_table_lock);
+		get_page(page);
+		node = mpol_misplaced(page, vma, haddr);
+		if (node != -1)
+			goto migrate;
+	}
 
-	/*
-	 * XXX should we serialize against split_huge_page ?
-	 */
+fixup:
+	/* change back to regular protection */
+	entry = pmd_modify(entry, vma->vm_page_prot);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
 
-	node = mpol_misplaced(page, vma, haddr);
-	if (node == -1)
-		goto do_fixup;
+unlock:
+	spin_unlock(&mm->page_table_lock);
+	if (page)
+		put_page(page);
 
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
 
-out_unlock:
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
+
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
diff --git a/mm/migrate.c b/mm/migrate.c
index 3299949..72d1056 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -417,7 +417,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page))
+	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
 		copy_highpage(newpage, page);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
