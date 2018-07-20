Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 188196B0007
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:19:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b9-v6so5342674pgq.17
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:19:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q90-v6si1235046pfa.272.2018.07.20.00.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:57 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 3/8] swap: Use swap_count() in swap_page_trans_huge_swapped()
Date: Fri, 20 Jul 2018 15:18:40 +0800
Message-Id: <20180720071845.17920-4-ying.huang@intel.com>
In-Reply-To: <20180720071845.17920-1-ying.huang@intel.com>
References: <20180720071845.17920-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>

In swap_page_trans_huge_swapped(), to identify whether there's any
page table mapping for a 4k sized swap entry, "si->swap_map[i] !=
SWAP_HAS_CACHE" is used.  This works correctly now, because all users
of the function will only call it after checking SWAP_HAS_CACHE.  But
as pointed out by Daniel, it is better to use "swap_count(map[i])"
here, because it works for "map[i] == 0" case too.

And this makes the implementation more consistent between normal and
huge swap entry.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-and-reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 7283104bfafa..833613e59ef7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1497,12 +1497,12 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (!ci || !cluster_is_huge(ci)) {
-		if (map[roffset] != SWAP_HAS_CACHE)
+		if (swap_count(map[roffset]))
 			ret = true;
 		goto unlock_out;
 	}
 	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		if (map[offset + i] != SWAP_HAS_CACHE) {
+		if (swap_count(map[offset + i])) {
 			ret = true;
 			break;
 		}
-- 
2.16.4
