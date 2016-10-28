Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE356B0280
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:56:35 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so37403517pac.6
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 22:56:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ub3si9907965pab.52.2016.10.27.22.56.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 22:56:34 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v4 RESEND 4/9] mm, THP, swap: Add get_huge_swap_page()
Date: Fri, 28 Oct 2016 13:56:03 +0800
Message-Id: <20161028055608.1736-5-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-1-ying.huang@intel.com>
References: <20161028055608.1736-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

A variation of get_swap_page(), get_huge_swap_page(), is added to
allocate a swap cluster (HPAGE_PMD_NR swap slots) based on the swap
cluster allocation function.  A fair simple algorithm is used, that is,
only the first swap device in priority list will be tried to allocate
the swap cluster.  The function will fail if the trying is not
successful, and the caller will fallback to allocate a single swap slot
instead.  This works good enough for normal cases.

This will be used for the THP (Transparent Huge Page) swap support.
Where get_huge_swap_page() will be used to allocate one swap cluster for
each THP swapped out.

Because of the algorithm adopted, if the difference of the number of the
free swap clusters among multiple swap devices is significant, it is
possible that some THPs are split earlier than necessary.  For example,
this could be caused by big size difference among multiple swap devices.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h | 24 +++++++++++++++++++++++-
 mm/swapfile.c        | 18 ++++++++++++------
 2 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 001b506..cb8c1b0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -401,7 +401,7 @@ static inline long get_nr_swap_pages(void)
 }
 
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t __get_swap_page(bool huge);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
@@ -421,6 +421,23 @@ extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
+static inline swp_entry_t get_swap_page(void)
+{
+	return __get_swap_page(false);
+}
+
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return __get_swap_page(true);
+}
+#else
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
@@ -527,6 +544,11 @@ static inline swp_entry_t get_swap_page(void)
 	return entry;
 }
 
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+
 #endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_MEMCG
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3643049..8224150 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -760,14 +760,15 @@ static inline unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
 }
 #endif
 
-swp_entry_t get_swap_page(void)
+swp_entry_t __get_swap_page(bool huge)
 {
 	struct swap_info_struct *si, *next;
 	pgoff_t offset;
+	int nr_pages = huge_cluster_nr_entries(huge);
 
-	if (atomic_long_read(&nr_swap_pages) <= 0)
+	if (atomic_long_read(&nr_swap_pages) < nr_pages)
 		goto noswap;
-	atomic_long_dec(&nr_swap_pages);
+	atomic_long_sub(nr_pages, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
 
@@ -795,10 +796,15 @@ swp_entry_t get_swap_page(void)
 		}
 
 		/* This is called for allocating swap entry for cache */
-		offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		if (likely(nr_pages == 1))
+			offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		else
+			offset = swap_alloc_huge_cluster(si);
 		spin_unlock(&si->lock);
 		if (offset)
 			return swp_entry(si->type, offset);
+		else if (unlikely(nr_pages != 1))
+			goto fail_alloc;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 		       si->type);
 		spin_lock(&swap_avail_lock);
@@ -818,8 +824,8 @@ swp_entry_t get_swap_page(void)
 	}
 
 	spin_unlock(&swap_avail_lock);
-
-	atomic_long_inc(&nr_swap_pages);
+fail_alloc:
+	atomic_long_add(nr_pages, &nr_swap_pages);
 noswap:
 	return (swp_entry_t) {0};
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
