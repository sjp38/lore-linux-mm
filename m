Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE7006B0281
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:56:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so15811407pfi.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 22:56:37 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ub3si9907965pab.52.2016.10.27.22.56.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 22:56:36 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v4 RESEND 5/9] mm, THP, swap: Support to clear SWAP_HAS_CACHE for huge page
Date: Fri, 28 Oct 2016 13:56:04 +0800
Message-Id: <20161028055608.1736-6-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-1-ying.huang@intel.com>
References: <20161028055608.1736-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

__swapcache_free() is added to support to clear the SWAP_HAS_CACHE flag
for the huge page.  This will free the specified swap cluster now.
Because now this function will be called only in the error path to free
the swap cluster just allocated.  So the corresponding swap_map[i] ==
SWAP_HAS_CACHE, that is, the swap count is 0.  This makes the
implementation simpler than that of the ordinary swap entry.

This will be used for delaying splitting THP (Transparent Huge Page)
during swapping out.  Where for one THP to swap out, we will allocate a
swap cluster, add the THP into the swap cache, then split the THP.  If
anything fails after allocating the swap cluster and before splitting
the THP successfully, the swapcache_free_trans_huge() will be used to
free the swap space allocated.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  9 +++++++--
 mm/swapfile.c        | 33 +++++++++++++++++++++++++++++++--
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index cb8c1b0..b185e39 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -408,7 +408,7 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void __swapcache_free(swp_entry_t, bool);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -480,7 +480,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void __swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -551,6 +551,11 @@ static inline swp_entry_t get_huge_swap_page(void)
 
 #endif /* CONFIG_SWAP */
 
+static inline void swapcache_free(swp_entry_t entry)
+{
+	__swapcache_free(entry, false);
+}
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8224150..126c789 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -732,6 +732,27 @@ static void swap_free_huge_cluster(struct swap_info_struct *si,
 	__swap_entry_free(si, offset, true);
 }
 
+/*
+ * Caller should hold si->lock.
+ */
+static void swapcache_free_trans_huge(struct swap_info_struct *si,
+				      swp_entry_t entry)
+{
+	unsigned long offset = swp_offset(entry);
+	unsigned long idx = offset / SWAPFILE_CLUSTER;
+	unsigned char *map;
+	unsigned int i;
+
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
+		map[i] &= ~SWAP_HAS_CACHE;
+	}
+	/* Cluster size is same as huge page size */
+	mem_cgroup_uncharge_swap(entry, HPAGE_PMD_NR);
+	swap_free_huge_cluster(si, idx);
+}
+
 static unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
 {
 	unsigned long idx;
@@ -758,6 +779,11 @@ static inline unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
 {
 	return 0;
 }
+
+static inline void swapcache_free_trans_huge(struct swap_info_struct *si,
+					     swp_entry_t entry)
+{
+}
 #endif
 
 swp_entry_t __get_swap_page(bool huge)
@@ -949,13 +975,16 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry)
+void __swapcache_free(swp_entry_t entry, bool huge)
 {
 	struct swap_info_struct *p;
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry, SWAP_HAS_CACHE);
+		if (unlikely(huge))
+			swapcache_free_trans_huge(p, entry);
+		else
+			swap_entry_free(p, entry, SWAP_HAS_CACHE);
 		spin_unlock(&p->lock);
 	}
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
