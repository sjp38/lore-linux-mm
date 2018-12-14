Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 693D68E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:27:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so2935004pls.11
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:27:44 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m28si2919232pgn.273.2018.12.13.22.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 22:27:42 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V9 01/21] swap: Deal with PTE mapped THP when unuse PTE
Date: Fri, 14 Dec 2018 14:27:34 +0800
Message-Id: <20181214062754.13723-2-ying.huang@intel.com>
In-Reply-To: <20181214062754.13723-1-ying.huang@intel.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>

A PTE swap entry may map to a normal swap slot inside a huge swap
cluster.  To free the huge swap cluster and the corresponding
THP (transparent huge page), all PTE swap entry mappings need to be
unmapped.  The original implementation only checks current PTE swap
entry mapping, this is fixed via calling try_to_free_swap() instead,
which will check all PTE swap mappings inside the huge swap cluster.

This fix could be folded into the patch: mm, swap: rid swapoff of
quadratic complexity in -mm patchset.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Cc: Kelley Nielsen <kelleynnn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/swapfile.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 7464d0a92869..9e6da494781f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1921,10 +1921,8 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			goto out;
 		}
 
-		if (PageSwapCache(page) && (swap_count(*swap_map) == 0))
-			delete_from_swap_cache(compound_head(page));
+		try_to_free_swap(page);
 
-		SetPageDirty(page);
 		unlock_page(page);
 		put_page(page);
 
-- 
2.18.1
