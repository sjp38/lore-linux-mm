Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B286B6B027C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:49:08 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m25-v6so3297795pgv.22
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:49:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x18-v6si4948122pll.193.2018.07.19.01.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:49:07 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v3 7/8] swap: Add __swap_entry_free_locked()
Date: Thu, 19 Jul 2018 16:48:41 +0800
Message-Id: <20180719084842.11385-8-ying.huang@intel.com>
In-Reply-To: <20180719084842.11385-1-ying.huang@intel.com>
References: <20180719084842.11385-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

The part of __swap_entry_free() with lock held is separated into a new
function __swap_entry_free_locked().  Because we want to reuse that
piece of code in some other places.

Just mechanical code refactoring, there is no any functional change in
this function.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 318ceb527c78..d313f7512d26 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1184,16 +1184,13 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
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
@@ -1221,6 +1218,17 @@ static unsigned char __swap_entry_free(struct swap_info_struct *p,
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
