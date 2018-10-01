Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6445B6B0006
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 05:45:16 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 203-v6so8283625ybf.19
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 02:45:16 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id x8-v6si3016575ybg.584.2018.10.01.02.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 02:45:15 -0700 (PDT)
From: Ashish Mhetre <amhetre@nvidia.com>
Subject: [PATCH] mm: Avoid swapping in interrupt context
Date: Mon, 1 Oct 2018 15:15:15 +0530
Message-ID: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: vdumpa@nvidia.com, Snikam@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>, Ashish Mhetre <amhetre@nvidia.com>

From: Sri Krishna chowdary <schowdary@nvidia.com>

Pages can be swapped out from interrupt context as well.
ZRAM uses zsmalloc allocator to make room for these pages.
But zsmalloc is not made to be used from interrupt context.
This can result in a kernel Oops.

Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
Signed-off-by: Ashish Mhetre <amhetre@nvidia.com>
---
 mm/vmscan.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0b63d9a..d9d36a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -365,6 +365,16 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 
 }
 
+/* If zram is being used as swap, and zram is using zsmalloc allocator
+ * then there is a potential bug when reclaim happens from interrupt
+ * context
+ */
+static void adjust_scan_control(struct scan_control *sc)
+{
+	if (in_interrupt() && IS_ENABLED(ZSMALLOC) && total_swap_pages)
+		sc->may_swap = 0;
+}
+
 /*
  * Add a shrinker callback to be called from the vm.
  */
@@ -1519,6 +1529,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	unsigned long ret;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
+	adjust_scan_control(&sc);
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
@@ -3232,6 +3243,8 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_swap = 1,
 	};
 
+	adjust_scan_control(&sc);
+
 	/*
 	 * scan_control uses s8 fields for order, priority, and reclaim_idx.
 	 * Confirm they are large enough for max values.
@@ -3277,6 +3290,8 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	};
 	unsigned long lru_pages;
 
+	adjust_scan_control(&sc);
+
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
@@ -3322,6 +3337,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_swap = may_swap,
 	};
 
+	adjust_scan_control(&sc);
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -3518,6 +3534,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_swap = 1,
 	};
 
+	adjust_scan_control(&sc);
 	psi_memstall_enter(&pflags);
 	__fs_reclaim_acquire();
 
@@ -3891,6 +3908,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	unsigned long nr_reclaimed;
 	unsigned int noreclaim_flag;
 
+	adjust_scan_control(&sc);
 	fs_reclaim_acquire(sc.gfp_mask);
 	noreclaim_flag = memalloc_noreclaim_save();
 	reclaim_state.reclaimed_slab = 0;
@@ -4076,6 +4094,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
+	adjust_scan_control(&sc);
 	cond_resched();
 	fs_reclaim_acquire(sc.gfp_mask);
 	/*
-- 
2.1.4


-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
