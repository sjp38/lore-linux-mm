Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 235F16B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 21:29:42 -0500 (EST)
Received: by mail-gg0-f169.google.com with SMTP id i1so1701689ggm.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 18:29:41 -0800 (PST)
Date: Tue, 13 Nov 2012 18:29:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] sched, numa, mm: Fixes and cleanups in
 do_huge_pmd_numa_page()
In-Reply-To: <alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1211131828020.29612@eggly.anvils>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org> <1352826834-11774-22-git-send-email-mingo@kernel.org> <20121113184835.GH10092@cmpxchg.org> <alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Zhouping Liu <zliu@redhat.com>

Refuse to migrate a THPage if its page count is raised: that covers both
the case when it is mapped into another address space, and the case
when it has been pinned by get_user_pages(), fast or slow.

Repeat this check each time we recheck pmd_same() under page_table_lock:
it is unclear how necessary this is, perhaps once after lock_page() or
once after isolate_lru_page() would be enough; but normal page migration
certainly checks page count, and we often think "ah, this is safe against
page migration because its page count is raised" - though sadly without
thinking through what serialization supports that.

Do not proceed with migration when PageLRU is unset: such a page may
well be in a private list or on a pagevec, about to be added to LRU at
any instant: checking PageLRU under zone lock, as isolate_lru_page() does,
is essential before proceeding safely.

Replace trylock_page and BUG by __set_page_locked: here the page has
been allocated a few lines earlier.  And SetPageSwapBacked: it is set
later, but there may be an error path which needs it set earlier.

On error path reverse the Active, Unevictable, Mlocked changes made
by migrate_page_copy().  Update mlock_migrate_page() to account for
THPages correctly now that it can get called on them.

Cleanup: rearrange unwinding slightly, removing a few blank lines.

Previous-Version-Tested-by: Zhouping Liu <zliu@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
I did not understand at all how pmd_page(entry) might be NULL, but
assumed that check is there for good reason and did not remove it.

 mm/huge_memory.c |   60 +++++++++++++++++++++++----------------------
 mm/internal.h    |    5 ++-
 2 files changed, 34 insertions(+), 31 deletions(-)

--- mmotm/mm/huge_memory.c	2012-11-13 14:51:04.000321370 -0800
+++ linux/mm/huge_memory.c	2012-11-13 15:01:01.892335579 -0800
@@ -751,9 +751,9 @@ void do_huge_pmd_numa_page(struct mm_str
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	struct mem_cgroup *memcg = NULL;
-	struct page *new_page = NULL;
+	struct page *new_page;
 	struct page *page = NULL;
-	int node, lru;
+	int node = -1;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry)))
@@ -770,7 +770,17 @@ void do_huge_pmd_numa_page(struct mm_str
 		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
 
 		get_page(page);
-		node = mpol_misplaced(page, vma, haddr);
+		/*
+		 * Do not migrate this page if it is mapped anywhere else.
+		 * Do not migrate this page if its count has been raised.
+		 * Our caller's down_read of mmap_sem excludes fork raising
+		 * mapcount; but recheck page count below whenever we take
+		 * page_table_lock - although it's unclear what pin we are
+		 * protecting against, since get_user_pages() or GUP fast
+		 * would have to fault it present before they could proceed.
+		 */
+		if (page_count(page) == 2)
+			node = mpol_misplaced(page, vma, haddr);
 		if (node != -1)
 			goto migrate;
 	}
@@ -794,7 +804,7 @@ migrate:
 
 	lock_page(page);
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry))) {
+	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 		spin_unlock(&mm->page_table_lock);
 		unlock_page(page);
 		put_page(page);
@@ -803,19 +813,17 @@ migrate:
 	spin_unlock(&mm->page_table_lock);
 
 	new_page = alloc_pages_node(node,
-	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT,
-	    HPAGE_PMD_ORDER);
-
+	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto alloc_fail;
 
-	lru = PageLRU(page);
-
-	if (lru && isolate_lru_page(page)) /* does an implicit get_page() */
+	if (isolate_lru_page(page)) {	/* Does an implicit get_page() */
+		put_page(new_page);
 		goto alloc_fail;
+	}
 
-	if (!trylock_page(new_page))
-		BUG();
+	__set_page_locked(new_page);
+	SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
@@ -826,19 +834,22 @@ migrate:
 	WARN_ON(PageLRU(new_page));
 
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry))) {
+	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 3)) {
 		spin_unlock(&mm->page_table_lock);
-		if (lru)
-			putback_lru_page(page);
+
+		/* Reverse changes made by migrate_page_copy() */
+		if (TestClearPageActive(new_page))
+			SetPageActive(page);
+		if (TestClearPageUnevictable(new_page))
+			SetPageUnevictable(page);
+		mlock_migrate_page(page, new_page);
 
 		unlock_page(new_page);
-		ClearPageActive(new_page);	/* Set by migrate_page_copy() */
-		new_page->mapping = NULL;
 		put_page(new_page);		/* Free it */
 
 		unlock_page(page);
+		putback_lru_page(page);
 		put_page(page);			/* Drop the local reference */
-
 		return;
 	}
 	/*
@@ -867,26 +878,17 @@ migrate:
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(&mm->page_table_lock);
 
-	put_page(page);			/* Drop the rmap reference */
-
 	task_numa_fault(node, HPAGE_PMD_NR);
 
-	if (lru)
-		put_page(page);		/* drop the LRU isolation reference */
-
 	unlock_page(new_page);
-
 	unlock_page(page);
+	put_page(page);			/* Drop the rmap reference */
+	put_page(page);			/* Drop the LRU isolation reference */
 	put_page(page);			/* Drop the local reference */
-
 	return;
 
 alloc_fail:
-	if (new_page)
-		put_page(new_page);
-
 	unlock_page(page);
-
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry))) {
 		put_page(page);
--- mmotm/mm/internal.h	2012-11-09 09:43:46.896046342 -0800
+++ linux/mm/internal.h	2012-11-13 15:01:01.892335579 -0800
@@ -218,11 +218,12 @@ static inline void mlock_migrate_page(st
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
