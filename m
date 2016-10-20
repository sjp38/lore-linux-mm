Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09C106B0265
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:32:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so38049260pfz.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:32:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t27si29865312pfk.177.2016.10.20.16.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 16:32:45 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v2 5/8] mm/swap: Allocate swap slots in batches
Date: Thu, 20 Oct 2016 16:31:44 -0700
Message-Id: <12e7a32f2ded4b5a58538734f7d9df147d657292.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Currently, the swap slots are allocated one page at a time,
causing contention to the swap_info lock protecting the swap partition
on every page being swapped.

This patch adds new functions get_swap_pages and scan_swap_map_slots
to request multiple swap slots at once. This will reduces the lock
contention on the swap_info lock. Also scan_swap_map_slots can operate
more efficiently as swap slots often occurs in clusters close to each
other on a swap device and it is quicker to allocate them together.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |   2 +
 mm/swapfile.c        | 161 ++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 136 insertions(+), 27 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 13bbc5f..d2b69bd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -27,6 +27,7 @@ struct bio;
 #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
 				 SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
 				 SWAP_FLAG_DISCARD_PAGES)
+#define SWAP_BATCH 64
 
 static inline int current_is_kswapd(void)
 {
@@ -412,6 +413,7 @@ static inline long get_nr_swap_pages(void)
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
+extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 19e3ea9..00c56c9 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -501,7 +501,7 @@ scan_swap_map_ssd_cluster_conflict(struct swap_info_struct *si,
  * Try to get a swap entry from current cpu's swap entry pool (a cluster). This
  * might involve allocating a new cluster for current CPU too.
  */
-static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
+static bool scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
 	unsigned long *offset, unsigned long *scan_base)
 {
 	struct percpu_cluster *cluster;
@@ -525,7 +525,7 @@ new_cluster:
 			*scan_base = *offset = si->cluster_next;
 			goto new_cluster;
 		} else
-			return;
+			return false;
 	}
 
 	found_free = false;
@@ -557,16 +557,22 @@ new_cluster:
 	cluster->next = tmp + 1;
 	*offset = tmp;
 	*scan_base = tmp;
+	return found_free;
 }
 
-static unsigned long scan_swap_map(struct swap_info_struct *si,
-				   unsigned char usage)
+static int scan_swap_map_slots(struct swap_info_struct *si,
+				   unsigned char usage, int nr,
+				   unsigned long slots[])
 {
 	struct swap_cluster_info *ci;
 	unsigned long offset;
 	unsigned long scan_base;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
+	int n_ret = 0;
+
+	if (nr > SWAP_BATCH)
+		nr = SWAP_BATCH;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -584,8 +590,10 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 	/* SSD algorithm */
 	if (si->cluster_info) {
-		scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
-		goto checks;
+		if (scan_swap_map_try_ssd_cluster(si, &offset, &scan_base))
+			goto checks;
+		else
+			goto scan;
 	}
 
 	if (unlikely(!si->cluster_nr--)) {
@@ -629,8 +637,14 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 checks:
 	if (si->cluster_info) {
-		while (scan_swap_map_ssd_cluster_conflict(si, offset))
-			scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
+		while (scan_swap_map_ssd_cluster_conflict(si, offset)) {
+		/* take a break if we already got some slots */
+			if (n_ret)
+				goto done;
+			if (!scan_swap_map_try_ssd_cluster(si, &offset,
+							&scan_base))
+				goto scan;
+		}
 	}
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
@@ -654,8 +668,13 @@ checks:
 	}
 
 	if (si->swap_map[offset]) {
-		unlock_cluster(ci);
-		goto scan;
+		if (!n_ret) {
+			unlock_cluster(ci);
+			goto scan;
+		} else {
+			unlock_cluster(ci);
+			goto done;
+		}
 	}
 
 	if (offset == si->lowest_bit)
@@ -674,9 +693,44 @@ checks:
 	inc_cluster_info_page(si, si->cluster_info, offset);
 	unlock_cluster(ci);
 	si->cluster_next = offset + 1;
-	si->flags -= SWP_SCANNING;
+	slots[n_ret] = offset;
+	++n_ret;
+
+	/* got enough slots or reach max slots? */
+	if ((n_ret == nr) || (offset >= si->highest_bit))
+		goto done;
+
+	/* search for next available slot */
+
+	/* time to take a break? */
+	if (unlikely(--latency_ration < 0)) {
+		if (n_ret)
+			goto done;
+		spin_unlock(&si->lock);
+		cond_resched();
+		spin_lock(&si->lock);
+		latency_ration = LATENCY_LIMIT;
+	}
+
+	/* try to get more slots in cluster */
+	if (si->cluster_info) {
+		if (scan_swap_map_try_ssd_cluster(si, &offset, &scan_base))
+			goto checks;
+		else
+			goto done;
+	}
+	/* non-ssd case */
+	++offset;
 
-	return offset;
+	/* non-ssd case, still more slots in cluster? */
+	if (si->cluster_nr && !si->swap_map[offset]) {
+		--si->cluster_nr;
+		goto checks;
+	}
+
+done:
+	si->flags -= SWP_SCANNING;
+	return n_ret;
 
 scan:
 	spin_unlock(&si->lock);
@@ -714,17 +768,46 @@ scan:
 
 no_page:
 	si->flags -= SWP_SCANNING;
-	return 0;
+	return n_ret;
 }
 
-swp_entry_t get_swap_page(void)
+static unsigned long scan_swap_map(struct swap_info_struct *si,
+				   unsigned char usage)
+{
+	unsigned long slots[1];
+	int n_ret;
+
+	n_ret = scan_swap_map_slots(si, usage, 1, slots);
+
+	if (n_ret)
+		return slots[0];
+	else
+		return 0;
+
+}
+
+int get_swap_pages(int n, swp_entry_t swp_entries[])
 {
 	struct swap_info_struct *si, *next;
-	pgoff_t offset;
+	long avail_pgs;
+	unsigned long *slots;
+	int ret, i, n_ret, n_goal;
 
-	if (atomic_long_read(&nr_swap_pages) <= 0)
+	n_ret = 0;
+	avail_pgs = atomic_long_read(&nr_swap_pages);
+	if (avail_pgs <= 0)
 		goto noswap;
-	atomic_long_dec(&nr_swap_pages);
+
+	n_goal = n;
+	swp_entries[0] = (swp_entry_t) {0};
+
+	if (n_goal > SWAP_BATCH)
+		n_goal = SWAP_BATCH;
+
+	if (n_goal > avail_pgs)
+		n_goal = avail_pgs;
+
+	atomic_long_sub(n_goal, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
 
@@ -751,13 +834,27 @@ start_over:
 			goto nextsi;
 		}
 
-		/* This is called for allocating swap entry for cache */
-		offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		/* use swp_entries array to store slots returned, both same size */
+		BUILD_BUG_ON(sizeof(swp_entry_t) != sizeof(unsigned long));
+		slots = (unsigned long *) &swp_entries[n_ret];
+		ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
+						n_goal-n_ret, slots);
+		if (!ret) {
+			pr_debug("scan_swap_map of si %d failed to find offset\n",
+			       si->type);
+			goto next;
+		}
+
+		for (i = 0; i < ret; ++i)
+			swp_entries[n_ret+i] = swp_entry(si->type,
+							slots[i]);
+
+		n_ret += ret;
+next:
 		spin_unlock(&si->lock);
-		if (offset)
-			return swp_entry(si->type, offset);
-		pr_debug("scan_swap_map of si %d failed to find offset\n",
-		       si->type);
+		if (n_ret == n_goal)
+			return n_ret;
+
 		spin_lock(&swap_avail_lock);
 nextsi:
 		/*
@@ -768,17 +865,27 @@ nextsi:
 		 * up between us dropping swap_avail_lock and taking si->lock.
 		 * Since we dropped the swap_avail_lock, the swap_avail_head
 		 * list may have been modified; so if next is still in the
-		 * swap_avail_head list then try it, otherwise start over.
+		 * swap_avail_head list then try it, otherwise start over
+		 * if we have not gotten any slots.
 		 */
-		if (plist_node_empty(&next->avail_list))
+		if (plist_node_empty(&next->avail_list) && !n_ret)
 			goto start_over;
 	}
 
 	spin_unlock(&swap_avail_lock);
 
-	atomic_long_inc(&nr_swap_pages);
+	if (n_ret < n_goal)
+		atomic_long_add((long) (n_goal-n_ret), &nr_swap_pages);
 noswap:
-	return (swp_entry_t) {0};
+	return n_ret;
+}
+
+swp_entry_t get_swap_page(void)
+{
+	swp_entry_t entry;
+
+	get_swap_pages(1, &entry);
+	return entry;
 }
 
 /* The only caller of this function is now suspend routine */
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
