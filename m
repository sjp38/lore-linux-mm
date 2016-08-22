Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB3746B0261
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:28:00 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m130so305012671ioa.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:28:00 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id n69si6970586itn.1.2016.08.22.01.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 01:28:00 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 4/4] vmscan.c: zram: add non swap support for shmem file pages
Date: Mon, 22 Aug 2016 16:25:09 +0800
Message-ID: <1471854309-30414-5-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, zhuhui@xiaomi.com, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

This patch add the whole support for shmem file pages non swap.
To make sure a page is shmem file page, check mapping->a_ops == &shmem_aops.
I think it is really a hack way.

There are not a lot of shmem file pages will be swapped out.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 drivers/block/zram/zram_drv.c |  3 +-
 include/linux/shmem_fs.h      |  6 ++++
 mm/page_io.c                  |  2 +-
 mm/rmap.c                     |  5 ---
 mm/shmem.c                    | 77 ++++++++++++++++++++++++++++++++++---------
 mm/vmscan.c                   | 27 +++++++++++----
 6 files changed, 89 insertions(+), 31 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 8f7f1ec..914c096 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -715,8 +715,7 @@ compress_again:
 	}
 
 #ifdef CONFIG_ZRAM_NON_SWAP
-	if (!is_partial_io(bvec) && PageAnon(page) &&
-	    zram->non_swap && clen > zram->non_swap) {
+	if (!is_partial_io(bvec) && zram->non_swap && clen > zram->non_swap) {
 		ret = 0;
 		SetPageNonSwap(page);
 		goto out;
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff078e7..fd44473 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -124,4 +124,10 @@ static inline bool shmem_huge_enabled(struct vm_area_struct *vma)
 }
 #endif
 
+extern const struct address_space_operations shmem_aops;
+
+#ifdef CONFIG_LATE_UNMAP
+extern void shmem_page_unmap(struct page *page);
+#endif
+
 #endif
diff --git a/mm/page_io.c b/mm/page_io.c
index adaf801..5fd3069 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -238,7 +238,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 	int ret = 0;
 
 #ifdef CONFIG_LATE_UNMAP
-	if (!(PageAnon(page) && page_mapped(page)))
+	if (!page_mapped(page))
 #endif
 		if (try_to_free_swap(page)) {
 			unlock_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index d484f95..418f731 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1490,13 +1490,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 #ifdef CONFIG_LATE_UNMAP
 	if ((flags & TTU_CHECK_DIRTY) || (flags & TTU_READONLY)) {
-		BUG_ON(!PageAnon(page));
-
 		pteval = *pte;
 
-		BUG_ON(pte_write(pteval) &&
-		       page_mapcount(page) + page_swapcount(page) > 1);
-
 		if ((flags & TTU_CHECK_DIRTY) && pte_dirty(pteval)) {
 			set_page_dirty(page);
 			pteval = pte_mkclean(pteval);
diff --git a/mm/shmem.c b/mm/shmem.c
index fd8b2b5..556d853 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -182,7 +182,6 @@ static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -1178,6 +1177,55 @@ out:
 	return error;
 }
 
+#define SHMEM_WRITEPAGE_LOCK				\
+	do {						\
+		mutex_lock(&shmem_swaplist_mutex);	\
+		if (list_empty(&info->swaplist))	\
+			list_add_tail(&info->swaplist,	\
+				      &shmem_swaplist);	\
+	} while (0)
+
+#define SHMEM_WRITEPAGE_SWAP						\
+	do {								\
+		spin_lock(&info->lock);					\
+		shmem_recalc_inode(inode);				\
+		info->swapped++;					\
+		spin_unlock(&info->lock);				\
+		swap_shmem_alloc(swap);					\
+		shmem_delete_from_page_cache(page,			\
+					     swp_to_radix_entry(swap));	\
+	} while (0)
+
+#define SHMEM_WRITEPAGE_UNLOCK				\
+	do {						\
+		mutex_unlock(&shmem_swaplist_mutex);	\
+	} while (0)
+
+#define SHMEM_WRITEPAGE_BUG_ON				\
+	do {						\
+		BUG_ON(page_mapped(page));		\
+	} while (0)
+
+#ifdef CONFIG_LATE_UNMAP
+void
+shmem_page_unmap(struct page *page)
+{
+	struct shmem_inode_info *info;
+	struct address_space *mapping;
+	struct inode *inode;
+	swp_entry_t swap = { .val = page_private(page) };
+
+	mapping = page->mapping;
+	inode = mapping->host;
+	info = SHMEM_I(inode);
+
+	SHMEM_WRITEPAGE_LOCK;
+	SHMEM_WRITEPAGE_SWAP;
+	SHMEM_WRITEPAGE_UNLOCK;
+	SHMEM_WRITEPAGE_BUG_ON;
+}
+#endif
+
 /*
  * Move the page from the page cache to the swap cache.
  */
@@ -1259,26 +1307,23 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	 * we've incremented swapped, because shmem_unuse_inode() will
 	 * prune a !swapped inode from the swaplist under this mutex.
 	 */
-	mutex_lock(&shmem_swaplist_mutex);
-	if (list_empty(&info->swaplist))
-		list_add_tail(&info->swaplist, &shmem_swaplist);
+#ifndef CONFIG_LATE_UNMAP
+	SHMEM_WRITEPAGE_LOCK;
+#endif
 
 	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
-		spin_lock_irq(&info->lock);
-		shmem_recalc_inode(inode);
-		info->swapped++;
-		spin_unlock_irq(&info->lock);
-
-		swap_shmem_alloc(swap);
-		shmem_delete_from_page_cache(page, swp_to_radix_entry(swap));
-
-		mutex_unlock(&shmem_swaplist_mutex);
-		BUG_ON(page_mapped(page));
+#ifndef CONFIG_LATE_UNMAP
+		SHMEM_WRITEPAGE_SWAP;
+		SHMEM_WRITEPAGE_UNLOCK;
+		SHMEM_WRITEPAGE_BUG_ON;
+#endif
 		swap_writepage(page, wbc);
 		return 0;
 	}
 
-	mutex_unlock(&shmem_swaplist_mutex);
+#ifndef CONFIG_LATE_UNMAP
+	SHMEM_WRITEPAGE_UNLOCK;
+#endif
 free_swap:
 	swapcache_free(swap);
 redirty:
@@ -3764,7 +3809,7 @@ static void shmem_destroy_inodecache(void)
 	kmem_cache_destroy(shmem_inode_cachep);
 }
 
-static const struct address_space_operations shmem_aops = {
+const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 14d49cd..effb6c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -54,6 +54,8 @@
 #include <linux/swapops.h>
 #include <linux/balloon_compaction.h>
 
+#include <linux/shmem_fs.h>
+
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -492,12 +494,13 @@ void drop_slab(void)
 		drop_slab_node(nid);
 }
 
-static inline int is_page_cache_freeable(struct page *page)
+static inline int is_page_cache_freeable(struct page *page,
+					 struct address_space *mapping)
 {
 	int count = page_count(page) - page_has_private(page);
 
 #ifdef CONFIG_LATE_UNMAP
-	if (PageAnon(page))
+	if (PageAnon(page) || (mapping && mapping->a_ops == &shmem_aops))
 		count -= page_mapcount(page);
 #endif
 
@@ -576,7 +579,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * swap_backing_dev_info is bust: it doesn't reflect the
 	 * congestion state of the swapdevs.  Easy to fix, if needed.
 	 */
-	if (!is_page_cache_freeable(page))
+	if (!is_page_cache_freeable(page, mapping))
 		return PAGE_KEEP;
 	if (!mapping) {
 		/*
@@ -972,7 +975,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct page *page;
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
-		bool dirty, writeback, anon;
+		bool dirty, writeback, anon, late_unmap;
 		bool lazyfree = false;
 		int ret = SWAP_SUCCESS;
 
@@ -1109,6 +1112,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		anon = PageAnon(page);
+		if (anon)
+			late_unmap = true;
+		else
+			late_unmap = false;
 
 		/*
 		 * Anonymous process memory has backing store?
@@ -1144,13 +1151,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			enum ttu_flags l_ttu_flags = ttu_flags;
 
 #ifdef CONFIG_LATE_UNMAP
+			if (mapping->a_ops == &shmem_aops)
+				late_unmap = true;
+
 			/* Hanle the pte_dirty
 			   and change pte to readonly.
 			   Write behavior before unmap will make
 			   pte dirty again.  Then we can check
 			   pte_dirty before unmap to make sure
 			   the page was written or not.  */
-			if (anon)
+			if (late_unmap)
 				l_ttu_flags |= TTU_CHECK_DIRTY | TTU_READONLY;
 #endif
 			TRY_TO_UNMAP(page, l_ttu_flags);
@@ -1211,7 +1221,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					goto keep_locked;
 
 #ifdef CONFIG_LATE_UNMAP
-				if (anon) {
+				if (late_unmap) {
 					if (!PageSwapCache(page))
 						goto keep_locked;
 
@@ -1231,8 +1241,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					}
 #endif
 
-					if (page_mapped(page) && mapping)
+					if (page_mapped(page) && mapping) {
 						TRY_TO_UNMAP(page, ttu_flags);
+						if (!anon)
+							shmem_page_unmap(page);
+					}
 				}
 #endif
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
