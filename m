Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C2CA86B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:00:20 -0500 (EST)
Received: by pablf10 with SMTP id lf10so12822597pab.6
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:00:20 -0800 (PST)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id rf11si3816101pdb.199.2015.02.20.20.00.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:00:19 -0800 (PST)
Received: by pdev10 with SMTP id v10so11949360pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:00:19 -0800 (PST)
Date: Fri, 20 Feb 2015 20:00:17 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 05/24] tmpfs: preliminary minor tidyups
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502201958420.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Make a few cleanups in mm/shmem.c, before going on to complicate it.

shmem_alloc_page() will become more complicated: we can't afford to
to have that complication duplicated between a CONFIG_NUMA version
and a !CONFIG_NUMA version, so rearrange the #ifdef'ery there to
yield a single shmem_swapin() and a single shmem_alloc_page().

Yes, it's a shame to inflict the horrid pseudo-vma on non-NUMA
configurations, but one day we'll get around to eliminating it
(elsewhere I have an alloc_pages_mpol() patch, but mpol handling is
subtle and bug-prone, and changed yet again since my last version).

Move __set_page_locked __SetPageSwapBacked from shmem_getpage_gfp()
to shmem_alloc_page(): that SwapBacked flag will be useful in future,
to help it to distinguish different cases appropriately.

And the SGP_DIRTY variant of SGP_CACHE is hard to understand and of
little use (IIRC it dates back to when shmem_getpage() returned the
page unlocked): let's kill it and just do the necessary in
do_shmem_file_read().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mempolicy.h |    6 ++
 mm/shmem.c                |   73 +++++++++++++-----------------------
 2 files changed, 34 insertions(+), 45 deletions(-)

--- thpfs.orig/include/linux/mempolicy.h	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/include/linux/mempolicy.h	2015-02-20 19:33:46.112050733 -0800
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
--- thpfs.orig/mm/shmem.c	2015-02-20 19:33:35.676074594 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:33:46.116050724 -0800
@@ -6,8 +6,8 @@
  *		 2000-2001 Christoph Rohland
  *		 2000-2001 SAP AG
  *		 2002 Red Hat Inc.
- * Copyright (C) 2002-2011 Hugh Dickins.
- * Copyright (C) 2011 Google Inc.
+ * Copyright (C) 2002-2015 Hugh Dickins.
+ * Copyright (C) 2011-2015 Google Inc.
  * Copyright (C) 2002-2005 VERITAS Software Corporation.
  * Copyright (C) 2004 Andi Kleen, SuSE Labs
  *
@@ -99,7 +99,6 @@ struct shmem_falloc {
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
-	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
 	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
 	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
 };
@@ -167,7 +166,7 @@ static inline int shmem_reacct_size(unsi
 
 /*
  * ... whereas tmpfs objects are accounted incrementally as
- * pages are allocated, in order to allow huge sparse files.
+ * pages are allocated, in order to allow large sparse files.
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
@@ -849,8 +848,7 @@ redirty:
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
-#ifdef CONFIG_TMPFS
+#if defined(CONFIG_NUMA) && defined(CONFIG_TMPFS)
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
@@ -874,7 +872,18 @@ static struct mempolicy *shmem_get_sbmpo
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
@@ -910,39 +919,17 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
-	page = alloc_page_vma(gfp, &pvma, 0);
+	page = alloc_pages_vma(gfp, 0, &pvma, 0, numa_node_id());
+	if (page) {
+		__set_page_locked(page);
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
@@ -986,8 +973,6 @@ static int shmem_replace_page(struct pag
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
 
-	__set_page_locked(newpage);
-	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
 	set_page_private(newpage, swap_index);
 	SetPageSwapCache(newpage);
@@ -1177,11 +1162,6 @@ repeat:
 			goto decused;
 		}
 
-		__set_page_locked(page);
-		__SetPageSwapBacked(page);
-		if (sgp == SGP_WRITE)
-			__SetPageReferenced(page);
-
 		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
 		if (error)
 			goto decused;
@@ -1205,6 +1185,8 @@ repeat:
 		spin_unlock(&info->lock);
 		alloced = true;
 
+		if (sgp == SGP_WRITE)
+			__SetPageReferenced(page);
 		/*
 		 * Let SGP_FALLOC use the SGP_WRITE optimization on a new page.
 		 */
@@ -1221,8 +1203,6 @@ clear:
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 		}
-		if (sgp == SGP_DIRTY)
-			set_page_dirty(page);
 	}
 
 	/* Perhaps the file has been truncated since we checked */
@@ -1537,7 +1517,7 @@ static ssize_t shmem_file_read_iter(stru
 	 * and even mark them dirty, so it cannot exceed the max_blocks limit.
 	 */
 	if (!iter_is_iovec(to))
-		sgp = SGP_DIRTY;
+		sgp = SGP_CACHE;
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
 	offset = *ppos & ~PAGE_CACHE_MASK;
@@ -1563,8 +1543,11 @@ static ssize_t shmem_file_read_iter(stru
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
