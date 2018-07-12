Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A82F6B0269
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:37:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i123-v6so11421641pfc.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:37:07 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o184-v6si21060983pga.520.2018.07.12.16.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:37:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 5/6] swap: Add __swap_entry_free_locked()
Date: Fri, 13 Jul 2018 07:36:35 +0800
Message-Id: <20180712233636.20629-6-ying.huang@intel.com>
In-Reply-To: <20180712233636.20629-1-ying.huang@intel.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

From: Huang Ying <ying.huang@intel.com>

The part of __swap_entry_free() with lock held is separated into a new
function __swap_entry_free_locked().  Because we want to reuse that
piece of code in some other places.

Just mechanical code refactoring, there is no any functional change in
this function.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index e0df8d22ac92..bc488bf36c86 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1180,16 +1180,13 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
 	return NULL;
 }
 
-static unsigned char __swap_entry_free(struct swap_info_struct *p,
-				       swp_entry_t entry, unsigned char usage)
+static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
+					      unsigned long offset,
+					      unsigned char usage)
 {
-	struct swap_cluster_info *ci;
-	unsigned long offset = swp_offset(entry);
 	unsigned char count;
 	unsigned char has_cache;
 
-	ci = lock_cluster_or_swap_info(p, offset);
-
 	count = p->swap_map[offset];
 
 	has_cache = count & SWAP_HAS_CACHE;
@@ -1217,6 +1214,17 @@ static unsigned char __swap_entry_free(struct swap_info_struct *p,
 	usage = count | has_cache;
 	p->swap_map[offset] = usage ? : SWAP_HAS_CACHE;
 
+	return usage;
+}
+
+static unsigned char __swap_entry_free(struct swap_info_struct *p,
+				       swp_entry_t entry, unsigned char usage)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+
+	ci = lock_cluster_or_swap_info(p, offset);
+	usage = __swap_entry_free_locked(p, offset, usage);
 	unlock_cluster_or_swap_info(p, ci);
 
 	return usage;
-- 
2.16.4
