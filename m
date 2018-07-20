Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 15B426B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:20:01 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so6688670plc.1
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:20:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a18-v6si1135668plm.122.2018.07.20.00.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:59 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 8/8] swap, put_swap_page: Share more between huge/normal code path
Date: Fri, 20 Jul 2018 15:18:45 +0800
Message-Id: <20180720071845.17920-9-ying.huang@intel.com>
In-Reply-To: <20180720071845.17920-1-ying.huang@intel.com>
References: <20180720071845.17920-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>

In this patch, locking related code is shared between huge/normal code
path in put_swap_page() to reduce code duplication.  And `free_entries
== 0` case is merged into more general `free_entries !=
SWAPFILE_CLUSTER` case, because the new locking method makes it easy.

The added lines is same as the removed lines.  But the code size is
increased when CONFIG_TRANSPARENT_HUGEPAGE=n.

		text	   data	    bss	    dec	    hex	filename
base:	       24123	   2004	    340	  26467	   6763	mm/swapfile.o
unified:       24485	   2004	    340	  26829	   68cd	mm/swapfile.o

Dig on step deeper with `size -A mm/swapfile.o` for base and unified
kernel and compare the result, yields,

  -.text                                17723      0
  +.text                                17835      0
  -.orc_unwind_ip                        1380      0
  +.orc_unwind_ip                        1480      0
  -.orc_unwind                           2070      0
  +.orc_unwind                           2220      0
  -Total                                26686
  +Total                                27048

The total difference is the same.  The text segment difference is much
smaller: 112.  More difference comes from the ORC unwinder
segments: (1480 + 2220) - (1380 + 2070) = 250.  If the frame pointer
unwinder is used, this costs nothing.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 402d52ff3e4a..f792fa902249 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1282,8 +1282,8 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 	if (!si)
 		return;
 
+	ci = lock_cluster_or_swap_info(si, offset);
 	if (size == SWAPFILE_CLUSTER) {
-		ci = lock_cluster(si, offset);
 		VM_BUG_ON(!cluster_is_huge(ci));
 		map = si->swap_map + offset;
 		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
@@ -1292,13 +1292,9 @@ void put_swap_page(struct page *page, swp_entry_t entry)
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
@@ -1309,12 +1305,16 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 			return;
 		}
 	}
-	if (size == 1 || free_entries) {
-		for (i = 0; i < size; i++, entry.val++) {
-			if (!__swap_entry_free(si, entry, SWAP_HAS_CACHE))
-				free_swap_slot(entry);
+	for (i = 0; i < size; i++, entry.val++) {
+		if (!__swap_entry_free_locked(si, offset + i, SWAP_HAS_CACHE)) {
+			unlock_cluster_or_swap_info(si, ci);
+			free_swap_slot(entry);
+			if (i == size - 1)
+				return;
+			lock_cluster_or_swap_info(si, offset);
 		}
 	}
+	unlock_cluster_or_swap_info(si, ci);
 }
 
 #ifdef CONFIG_THP_SWAP
-- 
2.16.4
