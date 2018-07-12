Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9FC6B000D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:37:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g15-v6so7415204plo.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:37:06 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o184-v6si21060983pga.520.2018.07.12.16.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:37:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 3/6] swap: Unify normal/huge code path in swap_page_trans_huge_swapped()
Date: Fri, 13 Jul 2018 07:36:33 +0800
Message-Id: <20180712233636.20629-4-ying.huang@intel.com>
In-Reply-To: <20180712233636.20629-1-ying.huang@intel.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

As suggested by Dave, we should unify the code path for normal and
huge swap support if possible to avoid duplicated code, bugs, etc. and
make it easier to review code.

In this patch, the normal/huge code path in swap_page_trans_huge_swapped()
is unified, the added and removed lines are same.  And the binary size
is kept almost same when CONFIG_TRANSPARENT_HUGEPAGE=n.

		 text	   data	    bss	    dec	    hex	filename
base:		24179	   2028	    340	  26547	   67b3	mm/swapfile.o
unified:	24215	   2028	    340	  26583	   67d7	mm/swapfile.o

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 75c84aa763a3..160f78072667 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -270,7 +270,10 @@ static inline void cluster_set_null(struct swap_cluster_info *info)
 
 static inline bool cluster_is_huge(struct swap_cluster_info *info)
 {
-	return info->flags & CLUSTER_FLAG_HUGE;
+	if (IS_ENABLED(CONFIG_THP_SWAP))
+		return info->flags & CLUSTER_FLAG_HUGE;
+	else
+		return false;
 }
 
 static inline void cluster_clear_huge(struct swap_cluster_info *info)
@@ -1489,9 +1492,6 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 	int i;
 	bool ret = false;
 
-	if (!IS_ENABLED(CONFIG_THP_SWAP))
-		return swap_swapcount(si, entry) != 0;
-
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (!ci || !cluster_is_huge(ci)) {
 		if (map[roffset] != SWAP_HAS_CACHE)
-- 
2.16.4
