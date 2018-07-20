Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 497B26B000D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:19:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g5-v6so5390009pgq.5
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:19:59 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a24-v6si1272473pgh.357.2018.07.20.00.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:57 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 4/8] swap: Unify normal/huge code path in swap_page_trans_huge_swapped()
Date: Fri, 20 Jul 2018 15:18:41 +0800
Message-Id: <20180720071845.17920-5-ying.huang@intel.com>
In-Reply-To: <20180720071845.17920-1-ying.huang@intel.com>
References: <20180720071845.17920-1-ying.huang@intel.com>
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
Suggested-and-acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 833613e59ef7..97814a01170d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -270,7 +270,9 @@ static inline void cluster_set_null(struct swap_cluster_info *info)
 
 static inline bool cluster_is_huge(struct swap_cluster_info *info)
 {
-	return info->flags & CLUSTER_FLAG_HUGE;
+	if (IS_ENABLED(CONFIG_THP_SWAP))
+		return info->flags & CLUSTER_FLAG_HUGE;
+	return false;
 }
 
 static inline void cluster_clear_huge(struct swap_cluster_info *info)
@@ -1492,9 +1494,6 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
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
