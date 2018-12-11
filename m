Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 092078E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:46:22 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so9375806pgb.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:46:21 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d2si12797074pfe.159.2018.12.11.00.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 00:46:20 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH 2/2] swap: Deal with PTE mapped THP when unuse PTE
Date: Tue, 11 Dec 2018 16:46:09 +0800
Message-Id: <20181211084609.19553-2-ying.huang@intel.com>
In-Reply-To: <20181211084609.19553-1-ying.huang@intel.com>
References: <20181211084609.19553-1-ying.huang@intel.com>
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
