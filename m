Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1CF82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:07:43 -0400 (EDT)
Received: by ioll68 with SMTP id l68so17799925iol.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:07:43 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id e81si2919090ioi.147.2015.10.18.22.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 22:07:42 -0700 (PDT)
Received: by pasz6 with SMTP id z6so18501023pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:07:42 -0700 (PDT)
Date: Sun, 18 Oct 2015 22:07:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 11/12] mm: page migration avoid touching newpage until no
 going back
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182205390.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

We have had trouble in the past from the way in which page migration's
newpage is initialized in dribs and drabs - see commit 8bdd63809160
("mm: fix direct reclaim writeback regression") which proposed a cleanup.

We have no actual problem now, but I think the procedure would be clearer
(and alternative get_new_page pools safer to implement) if we assert that
newpage is not touched until we are sure that it's going to be used -
except for taking the trylock on it in __unmap_and_move().

So shift the early initializations from move_to_new_page() into
migrate_page_move_mapping(), mapping and NULL-mapping paths.  Similarly
migrate_huge_page_move_mapping(), but its NULL-mapping path can just be
deleted: you cannot reach hugetlbfs_migrate_page() with a NULL mapping.

Adjust stages 3 to 8 in the Documentation file accordingly.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/vm/page_migration |   19 +++++------
 mm/migrate.c                    |   49 ++++++++++++------------------
 2 files changed, 30 insertions(+), 38 deletions(-)

--- migrat.orig/Documentation/vm/page_migration	2015-10-18 17:53:03.715313650 -0700
+++ migrat/Documentation/vm/page_migration	2015-10-18 17:53:31.871345704 -0700
@@ -92,27 +92,26 @@ Steps:
 
 2. Insure that writeback is complete.
 
-3. Prep the new page that we want to move to. It is locked
-   and set to not being uptodate so that all accesses to the new
-   page immediately lock while the move is in progress.
+3. Lock the new page that we want to move to. It is locked so that accesses to
+   this (not yet uptodate) page immediately lock while the move is in progress.
 
-4. The new page is prepped with some settings from the old page so that
-   accesses to the new page will discover a page with the correct settings.
-
-5. All the page table references to the page are converted to migration
+4. All the page table references to the page are converted to migration
    entries. This decreases the mapcount of a page. If the resulting
    mapcount is not zero then we do not migrate the page. All user space
    processes that attempt to access the page will now wait on the page lock.
 
-6. The radix tree lock is taken. This will cause all processes trying
+5. The radix tree lock is taken. This will cause all processes trying
    to access the page via the mapping to block on the radix tree spinlock.
 
-7. The refcount of the page is examined and we back out if references remain
+6. The refcount of the page is examined and we back out if references remain
    otherwise we know that we are the only one referencing this page.
 
-8. The radix tree is checked and if it does not contain the pointer to this
+7. The radix tree is checked and if it does not contain the pointer to this
    page then we back out because someone else modified the radix tree.
 
+8. The new page is prepped with some settings from the old page so that
+   accesses to the new page will discover a page with the correct settings.
+
 9. The radix tree is changed to point to the new page.
 
 10. The reference count of the old page is dropped because the radix tree
--- migrat.orig/mm/migrate.c	2015-10-18 17:53:27.120340297 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:31.871345704 -0700
@@ -320,6 +320,14 @@ int migrate_page_move_mapping(struct add
 		/* Anonymous page without mapping */
 		if (page_count(page) != expected_count)
 			return -EAGAIN;
+
+		/* No turning back from here */
+		set_page_memcg(newpage, page_memcg(page));
+		newpage->index = page->index;
+		newpage->mapping = page->mapping;
+		if (PageSwapBacked(page))
+			SetPageSwapBacked(newpage);
+
 		return MIGRATEPAGE_SUCCESS;
 	}
 
@@ -355,8 +363,15 @@ int migrate_page_move_mapping(struct add
 	}
 
 	/*
-	 * Now we know that no one else is looking at the page.
+	 * Now we know that no one else is looking at the page:
+	 * no turning back from here.
 	 */
+	set_page_memcg(newpage, page_memcg(page));
+	newpage->index = page->index;
+	newpage->mapping = page->mapping;
+	if (PageSwapBacked(page))
+		SetPageSwapBacked(newpage);
+
 	get_page(newpage);	/* add cache reference */
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
@@ -403,12 +418,6 @@ int migrate_huge_page_move_mapping(struc
 	int expected_count;
 	void **pslot;
 
-	if (!mapping) {
-		if (page_count(page) != 1)
-			return -EAGAIN;
-		return MIGRATEPAGE_SUCCESS;
-	}
-
 	spin_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
@@ -426,6 +435,9 @@ int migrate_huge_page_move_mapping(struc
 		return -EAGAIN;
 	}
 
+	set_page_memcg(newpage, page_memcg(page));
+	newpage->index = page->index;
+	newpage->mapping = page->mapping;
 	get_page(newpage);
 
 	radix_tree_replace_slot(pslot, newpage);
@@ -730,21 +742,6 @@ static int move_to_new_page(struct page
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
-	/* Prepare mapping for the new page.*/
-	newpage->index = page->index;
-	newpage->mapping = page->mapping;
-	if (PageSwapBacked(page))
-		SetPageSwapBacked(newpage);
-
-	/*
-	 * Indirectly called below, migrate_page_copy() copies PG_dirty and thus
-	 * needs newpage's memcg set to transfer memcg dirty page accounting.
-	 * So perform memcg migration in two steps:
-	 * 1. set newpage->mem_cgroup (here)
-	 * 2. clear page->mem_cgroup (below)
-	 */
-	set_page_memcg(newpage, page_memcg(page));
-
 	mapping = page_mapping(page);
 	if (!mapping)
 		rc = migrate_page(mapping, newpage, page, mode);
@@ -767,9 +764,6 @@ static int move_to_new_page(struct page
 		set_page_memcg(page, NULL);
 		if (!PageAnon(page))
 			page->mapping = NULL;
-	} else {
-		set_page_memcg(newpage, NULL);
-		newpage->mapping = NULL;
 	}
 	return rc;
 }
@@ -971,10 +965,9 @@ out:
 	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
 	 * during isolation.
 	 */
-	if (put_new_page) {
-		ClearPageSwapBacked(newpage);
+	if (put_new_page)
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+	else if (unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
 		put_page(newpage);
 	} else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
