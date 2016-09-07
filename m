Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2D6B6B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:51:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g202so74896411pfb.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:51:54 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u129si36568949pfu.78.2016.09.07.09.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:47:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v3 06/10] mm, THP, swap: Support to clear SWAP_HAS_CACHE for huge page
Date: Wed,  7 Sep 2016 09:46:05 -0700
Message-Id: <1473266769-2155-7-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
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
 mm/swapfile.c        | 32 ++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index bc0a84d..7be7599 100644
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
@@ -478,7 +478,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void __swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -549,6 +549,11 @@ static inline swp_entry_t get_huge_swap_page(void)
 
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
index 3d2bd1f..26b75fa 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -732,6 +732,26 @@ static void swap_free_huge_cluster(struct swap_info_struct *si,
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
+	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+	swap_free_huge_cluster(si, idx);
+}
+
 static unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
 {
 	unsigned long idx;
@@ -758,6 +778,11 @@ static inline unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
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
@@ -949,13 +974,16 @@ void swap_free(swp_entry_t entry)
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
