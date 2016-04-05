Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 35C226B027B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:45:47 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id zm5so17687846pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:45:47 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ix8si9895998pac.10.2016.04.05.13.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:45:46 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id fe3so17671692pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:45:46 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:45:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 04/10] tmpfs: preliminary minor tidyups
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051344260.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Make a few cleanups in mm/shmem.c, before going on to complicate it.

shmem_alloc_page() will become more complicated: we can't afford to
to have that complication duplicated between a CONFIG_NUMA version
and a !CONFIG_NUMA version, so rearrange the #ifdef'ery there to
yield a single shmem_swapin() and a single shmem_alloc_page().

Yes, it's a shame to inflict the horrid pseudo-vma on non-NUMA
configurations, but eliminating it is a larger cleanup: I have an
alloc_pages_mpol() patchset not yet ready - mpol handling is subtle
and bug-prone, and changed yet again since my last version.

Move __SetPageLocked, __SetPageSwapBacked from shmem_getpage_gfp()
to shmem_alloc_page(): that SwapBacked flag will be useful in future,
to help to distinguish different cases appropriately.

And the SGP_DIRTY variant of SGP_CACHE is hard to understand and of
little use (IIRC it dates back to when shmem_getpage() returned the
page unlocked): kill it and do the necessary in shmem_file_read_iter().

But an arm64 build then complained that info may be uninitialized
(where shmem_getpage_gfp() deletes a freshly alloced page beyond eof),
and advancing to an "sgp <= SGP_CACHE" test jogged it back to reality.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mempolicy.h |    6 +++
 mm/shmem.c                |   69 +++++++++++++-----------------------
 2 files changed, 32 insertions(+), 43 deletions(-)

--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -228,6 +228,12 @@ static inline void mpol_free_shared_poli
 {
 }
 
+static inline struct mempolicy *
+mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
+{
+	return NULL;
+}
+
 #define vma_policy(vma) NULL
 
 static inline int
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -101,7 +101,6 @@ struct shmem_falloc {
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
-	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
 	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
 	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
 };
@@ -169,7 +168,7 @@ static inline int shmem_reacct_size(unsi
 
 /*
  * ... whereas tmpfs objects are accounted incrementally as
- * pages are allocated, in order to allow huge sparse files.
+ * pages are allocated, in order to allow large sparse files.
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
@@ -947,8 +946,7 @@ redirty:
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
-#ifdef CONFIG_TMPFS
+#if defined(CONFIG_NUMA) && defined(CONFIG_TMPFS)
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
@@ -972,7 +970,18 @@ static struct mempolicy *shmem_get_sbmpo
 	}
 	return mpol;
 }
-#endif /* CONFIG_TMPFS */
+#else /* !CONFIG_NUMA || !CONFIG_TMPFS */
+static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+{
+}
+static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
+{
+	return NULL;
+}
+#endif /* CONFIG_NUMA && CONFIG_TMPFS */
+#ifndef CONFIG_NUMA
+#define vm_policy vm_private_data
+#endif
 
 static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
@@ -1008,39 +1017,17 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
-	page = alloc_page_vma(gfp, &pvma, 0);
+	page = alloc_pages_vma(gfp, 0, &pvma, 0, numa_node_id(), false);
+	if (page) {
+		__SetPageLocked(page);
+		__SetPageSwapBacked(page);
+	}
 
 	/* Drop reference taken by mpol_shared_policy_lookup() */
 	mpol_cond_put(pvma.vm_policy);
 
 	return page;
 }
-#else /* !CONFIG_NUMA */
-#ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
-{
-}
-#endif /* CONFIG_TMPFS */
-
-static inline struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
-{
-	return swapin_readahead(swap, gfp, NULL, 0);
-}
-
-static inline struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
-{
-	return alloc_page(gfp);
-}
-#endif /* CONFIG_NUMA */
-
-#if !defined(CONFIG_NUMA) || !defined(CONFIG_TMPFS)
-static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
-{
-	return NULL;
-}
-#endif
 
 /*
  * When a page is moved from swapcache to shmem filecache (either by the
@@ -1084,8 +1071,6 @@ static int shmem_replace_page(struct pag
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
 
-	__SetPageLocked(newpage);
-	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
 	set_page_private(newpage, swap_index);
 	SetPageSwapCache(newpage);
@@ -1155,7 +1140,7 @@ repeat:
 		page = NULL;
 	}
 
-	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
+	if (sgp <= SGP_CACHE &&
 	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto unlock;
@@ -1275,9 +1260,6 @@ repeat:
 			error = -ENOMEM;
 			goto decused;
 		}
-
-		__SetPageLocked(page);
-		__SetPageSwapBacked(page);
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
@@ -1321,12 +1303,10 @@ clear:
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 		}
-		if (sgp == SGP_DIRTY)
-			set_page_dirty(page);
 	}
 
 	/* Perhaps the file has been truncated since we checked */
-	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
+	if (sgp <= SGP_CACHE &&
 	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		if (alloced) {
 			ClearPageDirty(page);
@@ -1633,7 +1613,7 @@ static ssize_t shmem_file_read_iter(stru
 	 * and even mark them dirty, so it cannot exceed the max_blocks limit.
 	 */
 	if (!iter_is_iovec(to))
-		sgp = SGP_DIRTY;
+		sgp = SGP_CACHE;
 
 	index = *ppos >> PAGE_SHIFT;
 	offset = *ppos & ~PAGE_MASK;
@@ -1659,8 +1639,11 @@ static ssize_t shmem_file_read_iter(stru
 				error = 0;
 			break;
 		}
-		if (page)
+		if (page) {
+			if (sgp == SGP_CACHE)
+				set_page_dirty(page);
 			unlock_page(page);
+		}
 
 		/*
 		 * We must evaluate after, since reads (unlike writes)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
