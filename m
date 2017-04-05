Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5506B03A5
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:11:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x125so2764194pgb.5
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:11:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id k129si19712016pga.293.2017.04.05.00.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 00:11:07 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2] mm, swap: Use kvzalloc to allocate some swap data structure
Date: Wed,  5 Apr 2017 15:10:58 +0800
Message-Id: <20170405071058.25223-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

Now vzalloc() is used in swap code to allocate various data
structures, such as swap cache, swap slots cache, cluster info, etc.
Because the size may be too large on some system, so that normal
kzalloc() may fail.  But using kzalloc() has some advantages, for
example, less memory fragmentation, less TLB pressure, etc.  So change
the data structure allocation in swap code to use kvzalloc() which
will try kzalloc() firstly, and fallback to vzalloc() if kzalloc()
failed.

In general, kmalloc() will have less memory fragmentation than
vmalloc().  From Dave Hansen: For example, we have a two-page data
structure.  vmalloc() takes two effectively random order-0 pages,
probably from two different 2M pages and pins them.  That "kills" two
2M pages.  kmalloc(), allocating two *contiguous* pages, is very
unlikely to cross a 2M boundary (it theoretically could).  That means
it will only "kill" the possibility of a single 2M page.  More 2M
pages == less fragmentation.

The allocation in this patch occurs during swap on time, which is
usually done during system boot, so usually we have high opportunity
to allocate the contiguous pages successfully.

The allocation for swap_map[] in struct swap_info_struct is not
changed, because that is usually quite large and vmalloc_to_page() is
used for it.  That makes it a little harder to change.

Signed-off-by: Huang Ying <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>

v2:

- Use common kvzalloc() instead of self-made swap_kvzalloc().
---
 mm/swap_slots.c | 19 +++++++++++--------
 mm/swap_state.c |  2 +-
 mm/swapfile.c   | 10 ++++++----
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index aa1c415f4abd..58f6c78f1dad 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -31,6 +31,7 @@
 #include <linux/cpumask.h>
 #include <linux/vmalloc.h>
 #include <linux/mutex.h>
+#include <linux/mm.h>
 
 #ifdef CONFIG_SWAP
 
@@ -119,16 +120,18 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 
 	/*
 	 * Do allocation outside swap_slots_cache_mutex
-	 * as vzalloc could trigger reclaim and get_swap_page,
+	 * as kvzalloc could trigger reclaim and get_swap_page,
 	 * which can lock swap_slots_cache_mutex.
 	 */
-	slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	slots = kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE,
+			 GFP_KERNEL);
 	if (!slots)
 		return -ENOMEM;
 
-	slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	slots_ret = kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE,
+			     GFP_KERNEL);
 	if (!slots_ret) {
-		vfree(slots);
+		kvfree(slots);
 		return -ENOMEM;
 	}
 
@@ -152,9 +155,9 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 out:
 	mutex_unlock(&swap_slots_cache_mutex);
 	if (slots)
-		vfree(slots);
+		kvfree(slots);
 	if (slots_ret)
-		vfree(slots_ret);
+		kvfree(slots_ret);
 	return 0;
 }
 
@@ -171,7 +174,7 @@ static void drain_slots_cache_cpu(unsigned int cpu, unsigned int type,
 		cache->cur = 0;
 		cache->nr = 0;
 		if (free_slots && cache->slots) {
-			vfree(cache->slots);
+			kvfree(cache->slots);
 			cache->slots = NULL;
 		}
 		mutex_unlock(&cache->alloc_lock);
@@ -186,7 +189,7 @@ static void drain_slots_cache_cpu(unsigned int cpu, unsigned int type,
 		}
 		spin_unlock_irq(&cache->free_lock);
 		if (slots)
-			vfree(slots);
+			kvfree(slots);
 	}
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7bfb9bd1ca21..539b8885e3d1 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -523,7 +523,7 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 	unsigned int i, nr;
 
 	nr = DIV_ROUND_UP(nr_pages, SWAP_ADDRESS_SPACE_PAGES);
-	spaces = vzalloc(sizeof(struct address_space) * nr);
+	spaces = kvzalloc(sizeof(struct address_space) * nr, GFP_KERNEL);
 	if (!spaces)
 		return -ENOMEM;
 	for (i = 0; i < nr; i++) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 53b5881ee0d6..90054f3c2cdc 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2272,8 +2272,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	free_percpu(p->percpu_cluster);
 	p->percpu_cluster = NULL;
 	vfree(swap_map);
-	vfree(cluster_info);
-	vfree(frontswap_map);
+	kvfree(cluster_info);
+	kvfree(frontswap_map);
 	/* Destroy swap account information */
 	swap_cgroup_swapoff(p->type);
 	exit_swap_address_space(p->type);
@@ -2796,7 +2796,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		nr_cluster = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
 
-		cluster_info = vzalloc(nr_cluster * sizeof(*cluster_info));
+		cluster_info = kvzalloc(nr_cluster * sizeof(*cluster_info),
+					GFP_KERNEL);
 		if (!cluster_info) {
 			error = -ENOMEM;
 			goto bad_swap;
@@ -2829,7 +2830,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
 	if (IS_ENABLED(CONFIG_FRONTSWAP))
-		frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
+		frontswap_map = kvzalloc(BITS_TO_LONGS(maxpages) * sizeof(long),
+					 GFP_KERNEL);
 
 	if (p->bdev &&(swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
