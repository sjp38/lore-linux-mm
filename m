Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB556B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 22:56:18 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so12018315pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:56:17 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id b1si637053pat.116.2015.02.20.19.56.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 19:56:17 -0800 (PST)
Received: by padfb1 with SMTP id fb1so12806961pad.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:56:17 -0800 (PST)
Date: Fri, 20 Feb 2015 19:56:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 03/24] mm: use __SetPageSwapBacked and don't
 ClearPageSwapBacked
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502201954100.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 07a427884348 ("mm: shmem: avoid atomic operation during
shmem_getpage_gfp") rightly replaced one instance of SetPageSwapBacked
by __SetPageSwapBacked, pointing out that the newly allocated page is
not yet visible to other users (except speculative get_page_unless_zero-
ers, who may not update page flags before their further checks).

That was part of a series in which Mel was focused on tmpfs profiles:
but almost all SetPageSwapBacked uses can be so optimized, with the
same justification.  And remove the ClearPageSwapBacked from
read_swap_cache_async()'s and zswap_get_swap_cache_page()'s error
paths: it's not an error to free a page with PG_swapbacked set.

(There's probably scope for further __SetPageFlags in other places,
but SwapBacked is the one I'm interested in at the moment.)

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c    |    6 +++---
 mm/rmap.c       |    2 +-
 mm/shmem.c      |    4 ++--
 mm/swap_state.c |    3 +--
 mm/zswap.c      |    3 +--
 5 files changed, 8 insertions(+), 10 deletions(-)

--- thpfs.orig/mm/migrate.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/migrate.c	2015-02-20 19:33:35.676074594 -0800
@@ -763,7 +763,7 @@ static int move_to_new_page(struct page
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
 	if (PageSwapBacked(page))
-		SetPageSwapBacked(newpage);
+		__SetPageSwapBacked(newpage);
 
 	mapping = page_mapping(page);
 	if (!mapping)
@@ -978,7 +978,7 @@ out:
 	 * during isolation.
 	 */
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
-		ClearPageSwapBacked(newpage);
+		__ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
 	} else if (unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
@@ -1792,7 +1792,7 @@ int migrate_misplaced_transhuge_page(str
 
 	/* Prepare a page as a migration target */
 	__set_page_locked(new_page);
-	SetPageSwapBacked(new_page);
+	__SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
--- thpfs.orig/mm/rmap.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/rmap.c	2015-02-20 19:33:35.676074594 -0800
@@ -1068,7 +1068,7 @@ void page_add_new_anon_rmap(struct page
 	struct vm_area_struct *vma, unsigned long address)
 {
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
-	SetPageSwapBacked(page);
+	__SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
--- thpfs.orig/mm/shmem.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:33:35.676074594 -0800
@@ -987,8 +987,8 @@ static int shmem_replace_page(struct pag
 	flush_dcache_page(newpage);
 
 	__set_page_locked(newpage);
+	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
-	SetPageSwapBacked(newpage);
 	set_page_private(newpage, swap_index);
 	SetPageSwapCache(newpage);
 
@@ -1177,8 +1177,8 @@ repeat:
 			goto decused;
 		}
 
-		__SetPageSwapBacked(page);
 		__set_page_locked(page);
+		__SetPageSwapBacked(page);
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
--- thpfs.orig/mm/swap_state.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/swap_state.c	2015-02-20 19:33:35.676074594 -0800
@@ -364,7 +364,7 @@ struct page *read_swap_cache_async(swp_e
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__set_page_locked(new_page);
-		SetPageSwapBacked(new_page);
+		__SetPageSwapBacked(new_page);
 		err = __add_to_swap_cache(new_page, entry);
 		if (likely(!err)) {
 			radix_tree_preload_end();
@@ -376,7 +376,6 @@ struct page *read_swap_cache_async(swp_e
 			return new_page;
 		}
 		radix_tree_preload_end();
-		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
--- thpfs.orig/mm/zswap.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/zswap.c	2015-02-20 19:33:35.676074594 -0800
@@ -491,7 +491,7 @@ static int zswap_get_swap_cache_page(swp
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__set_page_locked(new_page);
-		SetPageSwapBacked(new_page);
+		__SetPageSwapBacked(new_page);
 		err = __add_to_swap_cache(new_page, entry);
 		if (likely(!err)) {
 			radix_tree_preload_end();
@@ -500,7 +500,6 @@ static int zswap_get_swap_cache_page(swp
 			return ZSWAP_SWAPCACHE_NEW;
 		}
 		radix_tree_preload_end();
-		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
