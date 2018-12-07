Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA036B7E96
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:41:41 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id m3so2388333pfj.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:41:41 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:41:39 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 04/21] swap: Support PMD swap mapping in put_swap_page()
Date: Fri,  7 Dec 2018 13:41:04 +0800
Message-Id: <20181207054122.27822-5-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Previously, during swapout, all PMD page mapping will be split and
replaced with PTE swap mapping.  And when clearing the SWAP_HAS_CACHE
flag for the huge swap cluster in put_swap_page(), the huge swap
cluster will be split.  Now, during swapout, the PMD page mappings to
the THP will be changed to PMD swap mappings to the corresponding swap
cluster.  So when clearing the SWAP_HAS_CACHE flag, the huge swap
cluster will only be split if the PMD swap mapping count is 0.
Otherwise, we will keep it as the huge swap cluster.  So that we can
swapin a THP in one piece later.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swapfile.c | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 37e20ce4983c..f30eed59c355 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1314,6 +1314,15 @@ void swap_free(swp_entry_t entry)
 
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
+ *
+ * When a THP is added into swap cache, the SWAP_HAS_CACHE flag will
+ * be set in the swap_map[] of all swap entries in the huge swap
+ * cluster backing the THP.  This huge swap cluster will not be split
+ * unless the THP is split even if its PMD swap mapping count dropped
+ * to 0.  Later, when the THP is removed from swap cache, the
+ * SWAP_HAS_CACHE flag will be cleared in the swap_map[] of all swap
+ * entries in the huge swap cluster.  And this huge swap cluster will
+ * be split if its PMD swap mapping count is 0.
  */
 void put_swap_page(struct page *page, swp_entry_t entry)
 {
@@ -1332,15 +1341,23 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (size == SWAPFILE_CLUSTER) {
-		VM_BUG_ON(!cluster_is_huge(ci));
+		VM_BUG_ON(!IS_ALIGNED(offset, size));
 		map = si->swap_map + offset;
-		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-			val = map[i];
-			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
-			if (val == SWAP_HAS_CACHE)
-				free_entries++;
+		/*
+		 * No PMD swap mapping, the swap cluster will be freed
+		 * if all swap entries becoming free, otherwise the
+		 * huge swap cluster will be split.
+		 */
+		if (!cluster_swapcount(ci)) {
+			for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+				val = map[i];
+				VM_BUG_ON(!(val & SWAP_HAS_CACHE));
+				if (val == SWAP_HAS_CACHE)
+					free_entries++;
+			}
+			if (free_entries != SWAPFILE_CLUSTER)
+				cluster_clear_huge(ci);
 		}
-		cluster_clear_huge(ci);
 		if (free_entries == SWAPFILE_CLUSTER) {
 			unlock_cluster_or_swap_info(si, ci);
 			spin_lock(&si->lock);
-- 
2.18.1
