Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B90E78E0011
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:45:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id w19-v6so114870pfa.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:45:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e8-v6si22134418pgl.498.2018.09.11.17.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 17:45:22 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V5 RESEND 17/21] swap: Support PMD swap mapping for MADV_WILLNEED
Date: Wed, 12 Sep 2018 08:44:10 +0800
Message-Id: <20180912004414.22583-18-ying.huang@intel.com>
In-Reply-To: <20180912004414.22583-1-ying.huang@intel.com>
References: <20180912004414.22583-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

During MADV_WILLNEED, for a PMD swap mapping, if THP swapin is enabled
for the VMA, the whole swap cluster will be swapin.  Otherwise, the
huge swap cluster and the PMD swap mapping will be split and fallback
to PTE swap mapping.

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
 mm/madvise.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 07ef599d4255..608c5ae201c6 100644
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
+	if (IS_ENABLED(CONFIG_THP_SWAP) && is_swap_pmd(pmdval) &&
+	    !is_pmd_migration_entry(pmdval)) {
+		entry = pmd_to_swp_entry(pmdval);
+		if (!transparent_hugepage_swapin_enabled(vma)) {
+			if (!split_swap_cluster(entry, 0))
+				split_huge_swap_pmd(vma, pmd, start, pmdval);
+		} else {
+			page = read_swap_cache_async(entry,
+						     GFP_HIGHUSER_MOVABLE,
+						     vma, start, false);
+			if (page) {
+				/* The swap cluster has been split under us */
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
2.16.4
