Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C57B6B0266
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 16:09:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so63665919pgq.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 13:09:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 75si35260400pfv.196.2016.12.09.13.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 13:09:03 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v4 3/9] mm/swap: Split swap cache into 64MB trunks
Date: Fri,  9 Dec 2016 13:09:16 -0800
Message-Id: <4b922b23ce8026a6cdd79ecd57aaa515d8144f2a.1481317367.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1481317367.git.tim.c.chen@linux.intel.com>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1481317367.git.tim.c.chen@linux.intel.com>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>

From: "Huang, Ying" <ying.huang@intel.com>

The patch is to improve the scalability of the swap out/in via using
fine grained locks for the swap cache.  In current kernel, one address
space will be used for each swap device.  And in the common
configuration, the number of the swap device is very small (one is
typical).  This causes the heavy lock contention on the radix tree of
the address space if multiple tasks swap out/in concurrently.  But in
fact, there is no dependency between pages in the swap cache.  So that,
we can split the one shared address space for each swap device into
several address spaces to reduce the lock contention.  In the patch, the
shared address space is split into 64MB trunks.  64MB is chosen to
balance the memory space usage and effect of lock contention reduction.

The size of struct address_space on x86_64 architecture is 408B, so with
the patch, 6528B more memory will be used for every 1GB swap space on
x86_64 architecture.

One address space is still shared for the swap entries in the same 64M
trunks.  To avoid lock contention for the first round of swap space
allocation, the order of the swap clusters in the initial free clusters
list is changed.  The swap space distance between the consecutive swap
clusters in the free cluster list is at least 64M.  After the first
round of allocation, the swap clusters are expected to be freed
randomly, so the lock contention should be reduced effectively.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/swap.h | 10 ++++++--
 mm/swap.c            |  6 -----
 mm/swap_state.c      | 68 ++++++++++++++++++++++++++++++++++++++++++----------
 mm/swapfile.c        | 16 +++++++++++--
 4 files changed, 78 insertions(+), 22 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c2d6c25..5f66c84 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -370,8 +370,12 @@ int generic_swapfile_activate(struct swap_info_struct *, struct file *,
 		sector_t *);
 
 /* linux/mm/swap_state.c */
-extern struct address_space swapper_spaces[];
-#define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])
+/* One swap address space for each 64M swap space */
+#define SWAP_ADDRESS_SPACE_SHIFT	14
+#define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)
+extern struct address_space* swapper_spaces[];
+#define swap_address_space(entry)					\
+	(&swapper_spaces[swp_type(entry)][swp_offset(entry) >> SWAP_ADDRESS_SPACE_SHIFT])
 extern unsigned long total_swapcache_pages(void);
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *, struct list_head *list);
@@ -425,6 +429,8 @@ extern struct swap_info_struct *page_swap_info(struct page *);
 extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
+extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
+extern void exit_swap_address_space(unsigned int type);
 
 #else /* CONFIG_SWAP */
 
diff --git a/mm/swap.c b/mm/swap.c
index 4dcf852..5c2ea71 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -969,12 +969,6 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 void __init swap_setup(void)
 {
 	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
-#ifdef CONFIG_SWAP
-	int i;
-
-	for (i = 0; i < MAX_SWAPFILES; i++)
-		spin_lock_init(&swapper_spaces[i].tree_lock);
-#endif
 
 	/* Use a smaller cluster for small-memory machines */
 	if (megs < 16)
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 35d7e0e..3863acd 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -17,6 +17,7 @@
 #include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/vmalloc.h>
 
 #include <asm/pgtable.h>
 
@@ -32,15 +33,8 @@ static const struct address_space_operations swap_aops = {
 #endif
 };
 
-struct address_space swapper_spaces[MAX_SWAPFILES] = {
-	[0 ... MAX_SWAPFILES - 1] = {
-		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-		.i_mmap_writable = ATOMIC_INIT(0),
-		.a_ops		= &swap_aops,
-		/* swap cache doesn't use writeback related tags */
-		.flags		= 1 << AS_NO_WRITEBACK_TAGS,
-	}
-};
+struct address_space *swapper_spaces[MAX_SWAPFILES];
+static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
 
@@ -53,11 +47,26 @@ static struct {
 
 unsigned long total_swapcache_pages(void)
 {
-	int i;
+	unsigned int i, j, nr;
 	unsigned long ret = 0;
+	struct address_space *spaces;
 
-	for (i = 0; i < MAX_SWAPFILES; i++)
-		ret += swapper_spaces[i].nrpages;
+	rcu_read_lock();
+	for (i = 0; i < MAX_SWAPFILES; i++) {
+		/*
+		 * The corresponding entries in nr_swapper_spaces and
+		 * swapper_spaces will be reused only after at least
+		 * one grace period.  So it is impossible for them
+		 * belongs to different usage.
+		 */
+		nr = nr_swapper_spaces[i];
+		spaces = rcu_dereference(swapper_spaces[i]);
+		if (!nr || !spaces)
+			continue;
+		for (j = 0; j < nr; j++)
+			ret += spaces[j].nrpages;
+	}
+	rcu_read_unlock();
 	return ret;
 }
 
@@ -505,3 +514,38 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 skip:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
+
+int init_swap_address_space(unsigned int type, unsigned long nr_pages)
+{
+	struct address_space *spaces, *space;
+	unsigned int i, nr;
+
+	nr = DIV_ROUND_UP(nr_pages, SWAP_ADDRESS_SPACE_PAGES);
+	spaces = vzalloc(sizeof(struct address_space) * nr);
+	if (!spaces)
+		return -ENOMEM;
+	for (i = 0; i < nr; i++) {
+		space = spaces + i;
+		INIT_RADIX_TREE(&space->page_tree, GFP_ATOMIC|__GFP_NOWARN);
+		atomic_set(&space->i_mmap_writable, 0);
+		space->a_ops = &swap_aops;
+		/* swap cache doesn't use writeback related tags */
+		mapping_set_no_writeback_tags(space);
+		spin_lock_init(&space->tree_lock);
+	}
+	nr_swapper_spaces[type] = nr;
+	rcu_assign_pointer(swapper_spaces[type], spaces);
+
+	return 0;
+}
+
+void exit_swap_address_space(unsigned int type)
+{
+	struct address_space *spaces;
+
+	spaces = swapper_spaces[type];
+	nr_swapper_spaces[type] = 0;
+	rcu_assign_pointer(swapper_spaces[type], NULL);
+	synchronize_rcu();
+	kvfree(spaces);
+}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 94828c86..eb6cba7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2076,6 +2076,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	vfree(frontswap_map);
 	/* Destroy swap account information */
 	swap_cgroup_swapoff(p->type);
+	exit_swap_address_space(p->type);
 
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
@@ -2399,8 +2400,12 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
 	return maxpages;
 }
 
-#define SWAP_CLUSTER_COLS						\
+#define SWAP_CLUSTER_INFO_COLS						\
 	DIV_ROUND_UP(L1_CACHE_BYTES, sizeof(struct swap_cluster_info))
+#define SWAP_CLUSTER_SPACE_COLS						\
+	DIV_ROUND_UP(SWAP_ADDRESS_SPACE_PAGES, SWAPFILE_CLUSTER)
+#define SWAP_CLUSTER_COLS						\
+	max_t(unsigned int, SWAP_CLUSTER_INFO_COLS, SWAP_CLUSTER_SPACE_COLS)
 
 static int setup_swap_map_and_extents(struct swap_info_struct *p,
 					union swap_header *swap_header,
@@ -2463,7 +2468,10 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 		return nr_extents;
 
 
-	/* Reduce false cache line sharing between cluster_info */
+	/*
+	 * Reduce false cache line sharing between cluster_info and
+	 * sharing same address space.
+	 */
 	for (k = 0; k < SWAP_CLUSTER_COLS; k++) {
 		j = (k + col) % SWAP_CLUSTER_COLS;
 		for (i = 0; i < DIV_ROUND_UP(nr_clusters, SWAP_CLUSTER_COLS); i++) {
@@ -2644,6 +2652,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
+	error = init_swap_address_space(p->type, maxpages);
+	if (error)
+		goto bad_swap;
+
 	mutex_lock(&swapon_mutex);
 	prio = -1;
 	if (swap_flags & SWAP_FLAG_PREFER)
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
