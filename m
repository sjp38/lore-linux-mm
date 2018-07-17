Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCCD06B026E
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:55:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d22-v6so7951111pls.4
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:55:56 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bc5-v6si30619643plb.413.2018.07.16.17.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:55:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH v2 4/7] swap: Unify normal/huge code path in swap_page_trans_huge_swapped()
Date: Tue, 17 Jul 2018 08:55:53 +0800
Message-Id: <20180717005556.29758-5-ying.huang@intel.com>
In-Reply-To: <20180717005556.29758-1-ying.huang@intel.com>
References: <20180717005556.29758-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

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
index 92c24402706c..a6d8b8117bc5 100644
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
 		if (swap_count(map[roffset]))
-- 
2.16.4
