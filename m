Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C783C6B0264
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:28 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so163528847pab.1
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h28si6132403pfk.146.2016.09.01.08.18.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 06/10] mm, THP, swap: Support to clear SWAP_HAS_CACHE for huge page
Date: Thu,  1 Sep 2016 08:16:59 -0700
Message-Id: <1472743023-4116-7-git-send-email-ying.huang@intel.com>
In-Reply-To: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
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
 mm/swapfile.c        | 27 +++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 95a526e..04d963f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -406,7 +406,7 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void __swapcache_free(swp_entry_t, bool);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -475,7 +475,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void __swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -546,6 +546,11 @@ static inline swp_entry_t get_huge_swap_page(void)
 
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
index 0a02211..3bbfb24 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -945,15 +945,38 @@ void swap_free(swp_entry_t entry)
 }
 
 /*
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
+	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+	swap_free_huge_cluster(si, idx);
+}
+
+/*
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
