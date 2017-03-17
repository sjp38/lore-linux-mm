Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C40806B038F
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 02:50:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 81so90520045pgh.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:50:11 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a125si7688984pgc.9.2017.03.16.23.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 23:50:10 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 4/5] mm, swap: Try kzalloc before vzalloc
Date: Fri, 17 Mar 2017 14:46:22 +0800
Message-Id: <20170317064635.12792-4-ying.huang@intel.com>
In-Reply-To: <20170317064635.12792-1-ying.huang@intel.com>
References: <20170317064635.12792-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Aaron Lu <aaron.lu@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Huang Ying <ying.huang@intel.com>

Now vzalloc() is used in swap code to allocate various data
structures, such as swap cache, swap slots cache, cluster info, etc.
Because the size may be too large on some system, so that normal
kzalloc() may fail.  But using kzalloc() has some advantages, for
example, less memory fragmentation, less TLB pressure, etc.  So change
the data structure allocation in swap code to try to use kzalloc()
firstly, and fallback to vzalloc() if kzalloc() failed.

The allocation for swap_map[] in struct swap_info_struct is not
changed, because that is usually quite large and vmalloc_to_page() is
used for it.  That makes it a little harder to change.

Signed-off-by: Huang Ying <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
---
 include/linux/swap.h |  2 ++
 mm/swap_slots.c      | 20 +++++++++++---------
 mm/swap_state.c      |  2 +-
 mm/swapfile.c        | 20 ++++++++++++++++----
 4 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index f59d6b077401..35d5b626c4bc 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -426,6 +426,8 @@ extern void exit_swap_address_space(unsigned int type);
 extern int get_swap_slots(int n, swp_entry_t *slots);
 extern void swapcache_free_batch(swp_entry_t *entries, int n);
 
+extern void *swap_kvzalloc(size_t size);
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 9b5bc86f96ad..7ae10e6f757d 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -31,6 +31,8 @@
 #include <linux/cpumask.h>
 #include <linux/vmalloc.h>
 #include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
 
 #ifdef CONFIG_SWAP
 
@@ -118,17 +120,17 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 	swp_entry_t *slots, *slots_ret;
 
 	/*
-	 * Do allocation outside swap_slots_cache_mutex
-	 * as vzalloc could trigger reclaim and get_swap_page,
+	 * Do allocation outside swap_slots_cache_mutex as
+	 * kzalloc/vzalloc could trigger reclaim and get_swap_page,
 	 * which can lock swap_slots_cache_mutex.
 	 */
-	slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	slots = swap_kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
 	if (!slots)
 		return -ENOMEM;
 
-	slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	slots_ret = swap_kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
 	if (!slots_ret) {
-		vfree(slots);
+		kvfree(slots);
 		return -ENOMEM;
 	}
 
@@ -152,9 +154,9 @@ static int alloc_swap_slot_cache(unsigned int cpu)
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
 
@@ -171,7 +173,7 @@ static void drain_slots_cache_cpu(unsigned int cpu, unsigned int type,
 		cache->cur = 0;
 		cache->nr = 0;
 		if (free_slots && cache->slots) {
-			vfree(cache->slots);
+			kvfree(cache->slots);
 			cache->slots = NULL;
 		}
 		mutex_unlock(&cache->alloc_lock);
@@ -186,7 +188,7 @@ static void drain_slots_cache_cpu(unsigned int cpu, unsigned int type,
 		}
 		spin_unlock_irq(&cache->free_lock);
 		if (slots)
-			vfree(slots);
+			kvfree(slots);
 	}
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7bfb9bd1ca21..d31017532ad5 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -523,7 +523,7 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 	unsigned int i, nr;
 
 	nr = DIV_ROUND_UP(nr_pages, SWAP_ADDRESS_SPACE_PAGES);
-	spaces = vzalloc(sizeof(struct address_space) * nr);
+	spaces = swap_kvzalloc(sizeof(struct address_space) * nr);
 	if (!spaces)
 		return -ENOMEM;
 	for (i = 0; i < nr; i++) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 53b5881ee0d6..1fb966cf2175 100644
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
@@ -2796,7 +2796,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		nr_cluster = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
 
-		cluster_info = vzalloc(nr_cluster * sizeof(*cluster_info));
+		cluster_info = swap_kvzalloc(nr_cluster * sizeof(*cluster_info));
 		if (!cluster_info) {
 			error = -ENOMEM;
 			goto bad_swap;
@@ -2829,7 +2829,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
 	if (IS_ENABLED(CONFIG_FRONTSWAP))
-		frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
+		frontswap_map =
+			swap_kvzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
 
 	if (p->bdev &&(swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
 		/*
@@ -3308,3 +3309,14 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 		}
 	}
 }
+
+void *swap_kvzalloc(size_t size)
+{
+	void *p;
+
+	p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+	if (!p)
+		p = vzalloc(size);
+
+	return p;
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
