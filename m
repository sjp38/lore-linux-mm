Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0A086B3F67
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:55:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h65-v6so10904260pfk.18
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 00:55:45 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j5-v6si13565094plk.406.2018.08.27.00.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 00:55:44 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH 2/3] swap: call free_swap_slot() in __swap_entry_free()
Date: Mon, 27 Aug 2018 15:55:34 +0800
Message-Id: <20180827075535.17406-3-ying.huang@intel.com>
In-Reply-To: <20180827075535.17406-1-ying.huang@intel.com>
References: <20180827075535.17406-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

This is a code cleanup patch without functionality change.

Originally, when __swap_entry_free() is called, and its return value
is 0, free_swap_slot() will always be called to free the swap entry to
the per-CPU pool.  So move the call to free_swap_slot() to
__swap_entry_free() to simplify the code.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 409926079607..ef974bbd7715 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1241,6 +1241,8 @@ static unsigned char __swap_entry_free(struct swap_info_struct *p,
 	ci = lock_cluster_or_swap_info(p, offset);
 	usage = __swap_entry_free_locked(p, offset, usage);
 	unlock_cluster_or_swap_info(p, ci);
+	if (!usage)
+		free_swap_slot(entry);
 
 	return usage;
 }
@@ -1271,10 +1273,8 @@ void swap_free(swp_entry_t entry)
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
-	if (p) {
-		if (!__swap_entry_free(p, entry, 1))
-			free_swap_slot(entry);
-	}
+	if (p)
+		__swap_entry_free(p, entry, 1);
 }
 
 /*
@@ -1705,8 +1705,6 @@ int free_swap_and_cache(swp_entry_t entry)
 		    !swap_page_trans_huge_swapped(p, entry))
 			__try_to_reclaim_swap(p, swp_offset(entry),
 					      TTRS_UNMAPPED | TTRS_FULL);
-		else if (!count)
-			free_swap_slot(entry);
 	}
 	return p != NULL;
 }
-- 
2.16.4
