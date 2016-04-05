Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 646516B0277
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:44:21 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id td3so17598772pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:44:21 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id le10si9847061pab.161.2016.04.05.13.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:44:20 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id zm5so17667677pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:44:20 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:44:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 03/10] mm: use __SetPageSwapBacked and dont
 ClearPageSwapBacked
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051342080.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

v3.16 commit 07a427884348 ("mm: shmem: avoid atomic operation during
shmem_getpage_gfp") rightly replaced one instance of SetPageSwapBacked
by __SetPageSwapBacked, pointing out that the newly allocated page is
not yet visible to other users (except speculative get_page_unless_zero-
ers, who may not update page flags before their further checks).

That was part of a series in which Mel was focused on tmpfs profiles:
but almost all SetPageSwapBacked uses can be so optimized, with the same
justification.  Remove ClearPageSwapBacked from __read_swap_cache_async()
error path: it's not an error to free a page with PG_swapbacked set.

Follow a convention of __SetPageLocked, __SetPageSwapBacked instead of
doing it differently in different places; but that's for tidiness - if
the ordering actually mattered, we should not be using the __variants.

There's probably scope for further __SetPageFlags in other places,
but SwapBacked is the one I'm interested in at the moment.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Sorry, Mel did give
Reviewed-by: Mel Gorman <mgorman@suse.de>
a year ago, but the kernel has moved on since then,
so it feels slightly ruder to carry that forward without asking,
than to ask again after all this time not submitting what he approved.

 mm/migrate.c    |    6 +++---
 mm/rmap.c       |    2 +-
 mm/shmem.c      |    4 ++--
 mm/swap_state.c |    3 +--
 4 files changed, 7 insertions(+), 8 deletions(-)

--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -332,7 +332,7 @@ int migrate_page_move_mapping(struct add
 		newpage->index = page->index;
 		newpage->mapping = page->mapping;
 		if (PageSwapBacked(page))
-			SetPageSwapBacked(newpage);
+			__SetPageSwapBacked(newpage);
 
 		return MIGRATEPAGE_SUCCESS;
 	}
@@ -378,7 +378,7 @@ int migrate_page_move_mapping(struct add
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
 	if (PageSwapBacked(page))
-		SetPageSwapBacked(newpage);
+		__SetPageSwapBacked(newpage);
 
 	get_page(newpage);	/* add cache reference */
 	if (PageSwapCache(page)) {
@@ -1785,7 +1785,7 @@ int migrate_misplaced_transhuge_page(str
 
 	/* Prepare a page as a migration target */
 	__SetPageLocked(new_page);
-	SetPageSwapBacked(new_page);
+	__SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1249,7 +1249,7 @@ void page_add_new_anon_rmap(struct page
 	int nr = compound ? hpage_nr_pages(page) : 1;
 
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
-	SetPageSwapBacked(page);
+	__SetPageSwapBacked(page);
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1085,8 +1085,8 @@ static int shmem_replace_page(struct pag
 	flush_dcache_page(newpage);
 
 	__SetPageLocked(newpage);
+	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
-	SetPageSwapBacked(newpage);
 	set_page_private(newpage, swap_index);
 	SetPageSwapCache(newpage);
 
@@ -1276,8 +1276,8 @@ repeat:
 			goto decused;
 		}
 
-		__SetPageSwapBacked(page);
 		__SetPageLocked(page);
+		__SetPageSwapBacked(page);
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -358,7 +358,7 @@ struct page *__read_swap_cache_async(swp
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__SetPageLocked(new_page);
-		SetPageSwapBacked(new_page);
+		__SetPageSwapBacked(new_page);
 		err = __add_to_swap_cache(new_page, entry);
 		if (likely(!err)) {
 			radix_tree_preload_end();
@@ -370,7 +370,6 @@ struct page *__read_swap_cache_async(swp
 			return new_page;
 		}
 		radix_tree_preload_end();
-		ClearPageSwapBacked(new_page);
 		__ClearPageLocked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
