Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9C236B0273
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:56:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25-v6so26153493pfi.20
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:56:02 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bc5-v6si30619643plb.413.2018.07.16.17.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:56:01 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH v2 7/7] swap, put_swap_page: Share more between huge/normal code path
Date: Tue, 17 Jul 2018 08:55:56 +0800
Message-Id: <20180717005556.29758-8-ying.huang@intel.com>
In-Reply-To: <20180717005556.29758-1-ying.huang@intel.com>
References: <20180717005556.29758-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

In this patch, locking related code is shared between huge/normal code
path in put_swap_page() to reduce code duplication.  And `free_entries
== 0` case is merged into more general `free_entries !=
SWAPFILE_CLUSTER` case, because the new locking method makes it easy.

The added lines is same as the removed lines.  But the code size is
increased when CONFIG_TRANSPARENT_HUGEPAGE=n.

		text	   data	    bss	    dec	    hex	filename
base:	       24215	   2028	    340	  26583	   67d7	mm/swapfile.o
unified:       24577	   2028	    340	  26945	   6941	mm/swapfile.o

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
 mm/swapfile.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index fec28f6c05b0..cd75f449896b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1280,8 +1280,8 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 	if (!si)
 		return;
 
+	ci = lock_cluster_or_swap_info(si, offset);
 	if (nr == SWAPFILE_CLUSTER) {
-		ci = lock_cluster(si, offset);
 		VM_BUG_ON(!cluster_is_huge(ci));
 		map = si->swap_map + offset;
 		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
@@ -1290,13 +1290,9 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 			if (val == SWAP_HAS_CACHE)
 				free_entries++;
 		}
-		if (!free_entries) {
-			for (i = 0; i < SWAPFILE_CLUSTER; i++)
-				map[i] &= ~SWAP_HAS_CACHE;
-		}
 		cluster_clear_huge(ci);
-		unlock_cluster(ci);
 		if (free_entries == SWAPFILE_CLUSTER) {
+			unlock_cluster_or_swap_info(si, ci);
 			spin_lock(&si->lock);
 			ci = lock_cluster(si, offset);
 			memset(map, 0, SWAPFILE_CLUSTER);
@@ -1307,12 +1303,16 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 			return;
 		}
 	}
-	if (nr == 1 || free_entries) {
-		for (i = 0; i < nr; i++, entry.val++) {
-			if (!__swap_entry_free(si, entry, SWAP_HAS_CACHE))
-				free_swap_slot(entry);
+	for (i = 0; i < nr; i++, entry.val++) {
+		if (!__swap_entry_free_locked(si, offset + i, SWAP_HAS_CACHE)) {
+			unlock_cluster_or_swap_info(si, ci);
+			free_swap_slot(entry);
+			if (i == nr - 1)
+				return;
+			lock_cluster_or_swap_info(si, offset);
 		}
 	}
+	unlock_cluster_or_swap_info(si, ci);
 }
 
 #ifdef CONFIG_THP_SWAP
-- 
2.16.4
