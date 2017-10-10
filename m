Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE84A6B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 03:35:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p2so30448882pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 00:35:19 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o8si7787355pgp.196.2017.10.10.00.35.17
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 00:35:18 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm:swap: skip swapcache only if swapped page has no other reference
Date: Tue, 10 Oct 2017 16:33:45 +0900
Message-Id: <1507620825-5537-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>

When swapped-in pages are shared by several processes, it can cause
unnecessary memory wastage by skipping swap cache. Because, with
swapin fault by read, they could share a page if the page were in swap
cache. Thus, it avoids allocating same content new pages.

This patch makes the swapcache skipping work only if the swap pte is
non-sharable.

Cc: Huang Ying <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  6 ++++++
 mm/memory.c          | 19 ++++++++++---------
 mm/swapfile.c        |  7 +++++++
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index cd2f66fdfc2d..1f5c52313890 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -458,6 +458,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
+extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -584,6 +585,11 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
+static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+{
+	return 0;
+}
+
 static inline int __swp_swapcount(swp_entry_t entry)
 {
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 163ab2062385..aff7e324564f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2890,15 +2890,8 @@ int do_swap_page(struct vm_fault *vmf)
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
 
-		if (!(si->flags & SWP_SYNCHRONOUS_IO)) {
-			if (vma_readahead)
-				page = do_swap_page_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
-			else
-				page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, vmf->address);
-			swapcache = page;
-		} else {
+		if (si->flags & SWP_SYNCHRONOUS_IO &&
+				__swap_count(si, entry) == 1) {
 			/* skip swapcache */
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
 			if (page) {
@@ -2908,6 +2901,14 @@ int do_swap_page(struct vm_fault *vmf)
 				lru_cache_add_anon(page);
 				swap_readpage(page, true);
 			}
+		} else {
+			if (vma_readahead)
+				page = do_swap_page_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
+			else
+				page = swapin_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			swapcache = page;
 		}
 
 		if (!page) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 64a3d85226ba..d67715ffc194 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1328,6 +1328,13 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
+int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+{
+	pgoff_t offset = swp_offset(entry);
+
+	return swap_count(si->swap_map[offset]);
+}
+
 static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
 {
 	int count = 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
