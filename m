Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A70BC6B002A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so202035pfh.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q74si633723pfi.282.2018.04.16.19.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:28 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 17/21] mm, THP, swap: Support PMD swap mapping for MADV_WILLNEED
Date: Tue, 17 Apr 2018 10:02:26 +0800
Message-Id: <20180417020230.26412-18-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

During MADV_WILLNEED, for a PMD swap mapping, if THP swapin is enabled
for the VMA, the whole swap cluster will be swapin.  Otherwise, the
huge swap cluster and the PMD swap mapping will be split and fallback
to PTE swap mapping.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/madvise.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index e03e85a20fb4..44a0a62f4848 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -196,14 +196,36 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 	pte_t *orig_pte;
 	struct vm_area_struct *vma = walk->private;
 	unsigned long index;
+	swp_entry_t entry;
+	struct page *page;
+	pmd_t pmdval;
+
+	pmdval = *pmd;
+	if (thp_swap_supported() && is_swap_pmd(pmdval) &&
+	    !is_pmd_migration_entry(pmdval)) {
+		entry = pmd_to_swp_entry(pmdval);
+		if (!transparent_hugepage_swapin_enabled(vma)) {
+			if (!split_swap_cluster(entry, false))
+				split_huge_swap_pmd(vma, pmd, start, pmdval);
+		} else {
+			page = read_swap_cache_async(entry,
+						     GFP_HIGHUSER_MOVABLE,
+						     vma, start, false);
+			/* The swap cluster has been split under us */
+			if (page) {
+				if (!PageTransHuge(page))
+					split_huge_swap_pmd(vma, pmd, start,
+							    pmdval);
+				put_page(page);
+			}
+		}
+	}
 
 	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 		return 0;
 
 	for (index = start; index != end; index += PAGE_SIZE) {
 		pte_t pte;
-		swp_entry_t entry;
-		struct page *page;
 		spinlock_t *ptl;
 
 		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
-- 
2.17.0
