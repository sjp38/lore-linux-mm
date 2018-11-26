Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 268A36B446B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:29:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so5709741pfi.21
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:29:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14sor2696584pgl.37.2018.11.26.15.29.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:29:19 -0800 (PST)
Date: Mon, 26 Nov 2018 15:29:17 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 08/10] mm/khugepaged: collapse_shmem() without freezing
 new_page
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261527570.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

khugepaged's collapse_shmem() does almost all of its work, to assemble
the huge new_page from 512 scattered old pages, with the new_page's
refcount frozen to 0 (and refcounts of all old pages so far also frozen
to 0).  Including shmem_getpage() to read in any which were out on swap,
memory reclaim if necessary to allocate their intermediate pages, and
copying over all the data from old to new.

Imagine the frozen refcount as a spinlock held, but without any lock
debugging to highlight the abuse: it's not good, and under serious load
heads into lockups - speculative getters of the page are not expecting
to spin while khugepaged is rescheduled.

One can get a little further under load by hacking around elsewhere;
but fortunately, freezing the new_page turns out to have been entirely
unnecessary, with no hacks needed elsewhere.

The huge new_page lock is already held throughout, and guards all its
subpages as they are brought one by one into the page cache tree; and
anything reading the data in that page, without the lock, before it has
been marked PageUptodate, would already be in the wrong.  So simply
eliminate the freezing of the new_page.

Each of the old pages remains frozen with refcount 0 after it has been
replaced by a new_page subpage in the page cache tree, until they are all
unfrozen on success or failure: just as before.  They could be unfrozen
sooner, but cause no problem once no longer visible to find_get_entry(),
filemap_map_pages() and other speculative lookups.

Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 9d4e9ff1af95..55930cbed3fd 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1287,7 +1287,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
  *
  * Basic scheme is simple, details are more complex:
- *  - allocate and freeze a new huge page;
+ *  - allocate and lock a new huge page;
  *  - scan page cache replacing old pages with the new one
  *    + swap in pages if necessary;
  *    + fill in gaps;
@@ -1295,11 +1295,11 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  *  - if replacing succeeds:
  *    + copy data over;
  *    + free old pages;
- *    + unfreeze huge page;
+ *    + unlock huge page;
  *  - if replacing failed;
  *    + put all pages back and unfreeze them;
  *    + restore gaps in the page cache;
- *    + free huge page;
+ *    + unlock and free huge page;
  */
 static void collapse_shmem(struct mm_struct *mm,
 		struct address_space *mapping, pgoff_t start,
@@ -1333,13 +1333,11 @@ static void collapse_shmem(struct mm_struct *mm,
 	__SetPageSwapBacked(new_page);
 	new_page->index = start;
 	new_page->mapping = mapping;
-	BUG_ON(!page_ref_freeze(new_page, 1));
 
 	/*
-	 * At this point the new_page is 'frozen' (page_count() is zero),
-	 * locked and not up-to-date. It's safe to insert it into the page
-	 * cache, because nobody would be able to map it or use it in other
-	 * way until we unfreeze it.
+	 * At this point the new_page is locked and not up-to-date.
+	 * It's safe to insert it into the page cache, because nobody would
+	 * be able to map it or use it in another way until we unlock it.
 	 */
 
 	/* This will be less messy when we use multi-index entries */
@@ -1491,9 +1489,8 @@ static void collapse_shmem(struct mm_struct *mm,
 			index++;
 		}
 
-		/* Everything is ready, let's unfreeze the new_page */
 		SetPageUptodate(new_page);
-		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
+		page_ref_add(new_page, HPAGE_PMD_NR - 1);
 		set_page_dirty(new_page);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_anon(new_page);
@@ -1541,8 +1538,6 @@ static void collapse_shmem(struct mm_struct *mm,
 		VM_BUG_ON(nr_none);
 		xas_unlock_irq(&xas);
 
-		/* Unfreeze new_page, caller would take care about freeing it */
-		page_ref_unfreeze(new_page, 1);
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		new_page->mapping = NULL;
 	}
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
