Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCE3B6B0262
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:23 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id j4so182636199uaj.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n4si6083386pan.58.2016.09.01.08.18.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 05/10] mm, THP, swap: Add get_huge_swap_page()
Date: Thu,  1 Sep 2016 08:16:58 -0700
Message-Id: <1472743023-4116-6-git-send-email-ying.huang@intel.com>
In-Reply-To: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

A variation of get_swap_page(), get_huge_swap_page(), is added to
allocate a swap cluster (512 swap slots) based on the swap cluster
allocation function.  A fair simple algorithm is used, that is, only the
first swap device in priority list will be tried to allocate the swap
cluster.  The function will fail if the trying is not successful, and
the caller will fallback to allocate a single swap slot instead.  This
works good enough for normal cases.

This will be used for the THP (Transparent Huge Page) swap support.
Where get_huge_swap_page() will be used to allocate one swap cluster for
each THP swapped out.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h | 21 ++++++++++++++++++++-
 mm/swapfile.c        | 29 +++++++++++++++++++++++------
 2 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 6988bce..95a526e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -399,7 +399,7 @@ static inline long get_nr_swap_pages(void)
 }
 
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t __get_swap_page(bool huge);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
@@ -419,6 +419,20 @@ extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
+static inline swp_entry_t get_swap_page(void)
+{
+	return __get_swap_page(false);
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern swp_entry_t get_huge_swap_page(void);
+#else
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
@@ -525,6 +539,11 @@ static inline swp_entry_t get_swap_page(void)
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
index 9f30f46..0a02211 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -747,14 +747,15 @@ static unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
 	return offset;
 }
 
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
 
@@ -782,10 +783,15 @@ start_over:
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
@@ -805,12 +811,23 @@ nextsi:
 	}
 
 	spin_unlock(&swap_avail_lock);
-
-	atomic_long_inc(&nr_swap_pages);
+fail_alloc:
+	atomic_long_add(nr_pages, &nr_swap_pages);
 noswap:
 	return (swp_entry_t) {0};
 }
 
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+swp_entry_t get_huge_swap_page(void)
+{
+	if (SWAPFILE_CLUSTER != HPAGE_PMD_NR)
+		return (swp_entry_t) {0};
+
+	return __get_swap_page(true);
+}
+#endif
+
 /* The only caller of this function is now suspend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
