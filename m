Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 280E16B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:20:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q12-v6so5379161pgp.6
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:20:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a24-v6si1272473pgh.357.2018.07.20.00.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:57 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 6/8] swap, get_swap_pages: Use entry_size instead of cluster in parameter
Date: Fri, 20 Jul 2018 15:18:43 +0800
Message-Id: <20180720071845.17920-7-ying.huang@intel.com>
In-Reply-To: <20180720071845.17920-1-ying.huang@intel.com>
References: <20180720071845.17920-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

As suggested by Matthew Wilcox, it is better to use "int entry_size"
instead of "bool cluster" as parameter to specify whether to operate
for huge or normal swap entries.  Because this improve the flexibility
to support other swap entry size.  And Dave Hansen thinks that this
improves code readability too.

So in this patch, the "bool cluster" parameter of get_swap_pages() is
replaced by "int entry_size".

And nr_swap_entries() trick is used to reduce the binary size when
!CONFIG_TRANSPARENT_HUGE_PAGE.

       text	   data	    bss	    dec	    hex	filename
base  24215	   2028	    340	  26583	   67d7	mm/swapfile.o
head  24123	   2004	    340	  26467	   6763	mm/swapfile.o

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/swap.h |  2 +-
 mm/swap_slots.c      |  8 ++++----
 mm/swapfile.c        | 16 ++++++++--------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e20c240d6c65..34de0d8bf4fa 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -443,7 +443,7 @@ extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(struct page *page);
 extern void put_swap_page(struct page *page, swp_entry_t entry);
 extern swp_entry_t get_swap_page_of_type(int);
-extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
+extern int get_swap_pages(int n, swp_entry_t swp_entries[], int entry_size);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 008ccb22fee6..63a7b4563a57 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -269,8 +269,8 @@ static int refill_swap_slots_cache(struct swap_slots_cache *cache)
 
 	cache->cur = 0;
 	if (swap_slot_cache_active)
-		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, false,
-					   cache->slots);
+		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE,
+					   cache->slots, 1);
 
 	return cache->nr;
 }
@@ -316,7 +316,7 @@ swp_entry_t get_swap_page(struct page *page)
 
 	if (PageTransHuge(page)) {
 		if (IS_ENABLED(CONFIG_THP_SWAP))
-			get_swap_pages(1, true, &entry);
+			get_swap_pages(1, &entry, HPAGE_PMD_NR);
 		goto out;
 	}
 
@@ -350,7 +350,7 @@ swp_entry_t get_swap_page(struct page *page)
 			goto out;
 	}
 
-	get_swap_pages(1, false, &entry);
+	get_swap_pages(1, &entry, 1);
 out:
 	if (mem_cgroup_try_charge_swap(page, entry)) {
 		put_swap_page(page, entry);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index ad247c3da494..d80567dd60db 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -941,18 +941,18 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 }
 
-int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
+int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
 {
-	unsigned long nr_pages = cluster ? SWAPFILE_CLUSTER : 1;
+	unsigned long size = swap_entry_size(entry_size);
 	struct swap_info_struct *si, *next;
 	long avail_pgs;
 	int n_ret = 0;
 	int node;
 
 	/* Only single cluster request supported */
-	WARN_ON_ONCE(n_goal > 1 && cluster);
+	WARN_ON_ONCE(n_goal > 1 && size == SWAPFILE_CLUSTER);
 
-	avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
+	avail_pgs = atomic_long_read(&nr_swap_pages) / size;
 	if (avail_pgs <= 0)
 		goto noswap;
 
@@ -962,7 +962,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 	if (n_goal > avail_pgs)
 		n_goal = avail_pgs;
 
-	atomic_long_sub(n_goal * nr_pages, &nr_swap_pages);
+	atomic_long_sub(n_goal * size, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
 
@@ -989,14 +989,14 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
-		if (cluster) {
+		if (size == SWAPFILE_CLUSTER) {
 			if (!(si->flags & SWP_FILE))
 				n_ret = swap_alloc_cluster(si, swp_entries);
 		} else
 			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
 						    n_goal, swp_entries);
 		spin_unlock(&si->lock);
-		if (n_ret || cluster)
+		if (n_ret || size == SWAPFILE_CLUSTER)
 			goto check_out;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 			si->type);
@@ -1022,7 +1022,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 
 check_out:
 	if (n_ret < n_goal)
-		atomic_long_add((long)(n_goal - n_ret) * nr_pages,
+		atomic_long_add((long)(n_goal - n_ret) * size,
 				&nr_swap_pages);
 noswap:
 	return n_ret;
-- 
2.16.4
