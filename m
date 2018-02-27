Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2176B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 18:26:21 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s25so287822pfh.9
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 15:26:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b123sor74008pgc.311.2018.02.27.15.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 15:26:20 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm:swap: do not check readahead flag with THP anon
Date: Wed, 28 Feb 2018 08:26:11 +0900
Message-Id: <20180227232611.169883-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Huang, Ying" <ying.huang@intel.com>

Huang reported PG_readahead flag marked PF_NO_COMPOUND so that
we cannot use the flag for THP page. So, we need to check first
whether page is THP or not before using TestClearPageReadahead
in lookup_swap_cache.

This patch fixes it.

Furthermore, swap_[cluster|vma]_readahead cannot mark PG_readahead
for newly allocated page because the allocated page is always a
normal page, not THP at this moment. So let's clean it up, too.

Cc: Hugh Dickins <hughd@google.com>
Cc: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swap_state.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8dde719e973c..1c4ac3220f41 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -348,12 +348,17 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 	INC_CACHE_INFO(find_total);
 	if (page) {
 		bool vma_ra = swap_use_vma_readahead();
-		bool readahead = TestClearPageReadahead(page);
+		bool readahead;
 
 		INC_CACHE_INFO(find_success);
+		/*
+		 * At the moment, we don't support PG_readahead for anon THP
+		 * so let's bail out rather than confusing the readahead stat.
+		 */
 		if (unlikely(PageTransCompound(page)))
 			return page;
 
+		readahead = TestClearPageReadahead(page);
 		if (vma && vma_ra) {
 			unsigned long ra_val;
 			int win, hits;
@@ -608,8 +613,7 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (offset != entry_offset &&
-			    likely(!PageTransCompound(page))) {
+			if (offset != entry_offset) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}
@@ -772,8 +776,7 @@ struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (i != ra_info.offset &&
-			    likely(!PageTransCompound(page))) {
+			if (i != ra_info.offset) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
