Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E49A6B0277
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:49:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so4189022plv.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:49:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x18-v6si4948122pll.193.2018.07.19.01.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:49:00 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v3 4/8] swap: Unify normal/huge code path in swap_page_trans_huge_swapped()
Date: Thu, 19 Jul 2018 16:48:38 +0800
Message-Id: <20180719084842.11385-5-ying.huang@intel.com>
In-Reply-To: <20180719084842.11385-1-ying.huang@intel.com>
References: <20180719084842.11385-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

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
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index cb0bc54e99c0..96018207b582 100644
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
@@ -1493,9 +1496,6 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 	int i;
 	bool ret = false;
 
-	if (!IS_ENABLED(CONFIG_THP_SWAP))
-		return swap_swapcount(si, entry) != 0;
-
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (!ci || !cluster_is_huge(ci)) {
 		if (swap_count(map[roffset]))
-- 
2.16.4
