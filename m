Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0146B0292
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 01:41:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r187so85075021pfr.8
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 22:41:56 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f83si4233583pfk.367.2017.08.06.22.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 22:41:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 1/5] mm, swap: Add swap readahead hit statistics
Date: Mon,  7 Aug 2017 13:40:34 +0800
Message-Id: <20170807054038.1843-2-ying.huang@intel.com>
In-Reply-To: <20170807054038.1843-1-ying.huang@intel.com>
References: <20170807054038.1843-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The statistics for total readahead pages and total readahead hits are
recorded and exported via the following sysfs interface.

/sys/kernel/mm/swap/ra_hits
/sys/kernel/mm/swap/ra_total

With them, the efficiency of the swap readahead could be measured, so
that the swap readahead algorithm and parameters could be tuned
accordingly.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/vm_event_item.h | 2 ++
 mm/swap_state.c               | 9 +++++++--
 mm/vmstat.c                   | 3 +++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index e02820fc2861..27e3339cfd65 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -106,6 +106,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		VMACACHE_FIND_HITS,
 		VMACACHE_FULL_FLUSHES,
 #endif
+		SWAP_RA,
+		SWAP_RA_HIT,
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index b68c93014f50..d1bdb31cab13 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -305,8 +305,10 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
-		if (TestClearPageReadahead(page))
+		if (TestClearPageReadahead(page)) {
 			atomic_inc(&swapin_readahead_hits);
+			count_vm_event(SWAP_RA_HIT);
+		}
 	}
 
 	INC_CACHE_INFO(find_total);
@@ -516,8 +518,11 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 						gfp_mask, vma, addr, false);
 		if (!page)
 			continue;
-		if (offset != entry_offset && likely(!PageTransCompound(page)))
+		if (offset != entry_offset &&
+		    likely(!PageTransCompound(page))) {
 			SetPageReadahead(page);
+			count_vm_event(SWAP_RA);
+		}
 		put_page(page);
 	}
 	blk_finish_plug(&plug);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ba9b202e8500..4c2121a8b877 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1095,6 +1095,9 @@ const char * const vmstat_text[] = {
 	"vmacache_find_hits",
 	"vmacache_full_flushes",
 #endif
+
+	"swap_ra",
+	"swap_ra_hit",
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
