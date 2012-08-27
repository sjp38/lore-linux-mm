Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id BF78A6B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 00:00:46 -0400 (EDT)
Received: by dadi14 with SMTP id i14so2584303dad.14
        for <linux-mm@kvack.org>; Sun, 26 Aug 2012 21:00:45 -0700 (PDT)
Date: Mon, 27 Aug 2012 12:00:37 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch v2]swap: add a simple random read swapin detection
Message-ID: <20120827040037.GA8062@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, fengguang.wu@intel.com, minchan@kernel.org

The swapin readahead does a blind readahead regardless if the swapin is
sequential. This is ok for harddisk and random read, because read big size has
no penality in harddisk, and if the readahead pages are garbage, they can be
reclaimed fastly. But for SSD, big size read is more expensive than small size
read. If readahead pages are garbage, such readahead only has overhead.

This patch addes a simple random read detection like what file mmap readahead
does. If random read is detected, swapin readahead will be skipped. This
improves a lot for a swap workload with random IO in a fast SSD.

I run anonymous mmap write micro benchmark, which will triger swapin/swapout.
			runtime changes with path
randwrite harddisk	-38.7%
seqwrite harddisk	-1.1%
randwrite SSD		-46.9%
seqwrite SSD		+0.3%

For both harddisk and SSD, the randwrite swap workload run time is reduced
significant. sequential write swap workload hasn't chanage.

Interesting is the randwrite harddisk test is improved too. This might be
because swapin readahead need allocate extra memory, which further tights
memory pressure, so more swapout/swapin.

This patch depends on readahead-fault-retry-breaks-mmap-file-read-random-detection.patch

V1->V2:
1. Move the swap readahead accounting to separate functions as suggested by Riel.
2. Enable the logic only with CONFIG_SWAP enabled as suggested by Minchan.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/mm_types.h |    3 +++
 mm/internal.h            |   44 ++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c              |    3 ++-
 mm/swap_state.c          |    8 ++++++++
 4 files changed, 57 insertions(+), 1 deletion(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-08-22 11:44:53.057913107 +0800
+++ linux/mm/swap_state.c	2012-08-23 17:27:28.560013412 +0800
@@ -20,6 +20,7 @@
 #include <linux/page_cgroup.h>
 
 #include <asm/pgtable.h>
+#include "internal.h"
 
 /*
  * swapper_space is a fiction, retained to simplify the path through
@@ -379,6 +380,12 @@ struct page *swapin_readahead(swp_entry_
 	unsigned long mask = (1UL << page_cluster) - 1;
 	struct blk_plug plug;
 
+	if (vma) {
+		swap_cache_miss(vma);
+		if (swap_cache_skip_readahead(vma))
+			goto skip;
+	}
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -397,5 +404,6 @@ struct page *swapin_readahead(swp_entry_
 	blk_finish_plug(&plug);
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
+skip:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
Index: linux/include/linux/mm_types.h
===================================================================
--- linux.orig/include/linux/mm_types.h	2012-08-22 11:44:53.077912855 +0800
+++ linux/include/linux/mm_types.h	2012-08-24 13:07:11.798576941 +0800
@@ -279,6 +279,9 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+#ifdef CONFIG_SWAP
+	atomic_t swapra_miss;
+#endif
 };
 
 struct core_thread {
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2012-08-22 11:44:53.065913005 +0800
+++ linux/mm/memory.c	2012-08-23 17:27:23.424074216 +0800
@@ -2953,7 +2953,8 @@ static int do_swap_page(struct mm_struct
 		ret = VM_FAULT_HWPOISON;
 		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		goto out_release;
-	}
+	} else if (!(flags & FAULT_FLAG_TRIED))
+		swap_cache_hit(vma);
 
 	locked = lock_page_or_retry(page, mm, flags);
 
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h	2012-08-22 09:51:39.295322268 +0800
+++ linux/mm/internal.h	2012-08-27 11:51:27.447915373 +0800
@@ -356,3 +356,47 @@ extern unsigned long vm_mmap_pgoff(struc
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
+
+/*
+ * Unnecessary readahead harms performance. 1. for SSD, big size read is more
+ * expensive than small size read, so extra unnecessary read only has overhead.
+ * For harddisk, this overhead doesn't exist. 2. unnecessary readahead will
+ * allocate extra memroy, which further tights memory pressure, so more
+ * swapout/swapin.
+ * These adds a simple swap random access detection. In swap page fault, if
+ * page is found in swap cache, decrease an account of vma, otherwise we need
+ * do sync swapin and the account is increased. Optionally swapin will do
+ * readahead if the counter is below a threshold.
+ */
+#ifdef CONFIG_SWAP
+#define SWAPRA_MISS  (100)
+static inline void swap_cache_hit(struct vm_area_struct *vma)
+{
+	atomic_dec_if_positive(&vma->swapra_miss);
+}
+
+static inline void swap_cache_miss(struct vm_area_struct *vma)
+{
+	if (atomic_read(&vma->swapra_miss) < SWAPRA_MISS * 10)
+		atomic_inc(&vma->swapra_miss);
+}
+
+static inline int swap_cache_skip_readahead(struct vm_area_struct *vma)
+{
+	return atomic_read(&vma->swapra_miss) > SWAPRA_MISS;
+}
+#else
+static inline void swap_cache_hit(struct vm_area_struct *vma)
+{
+}
+
+static inline void swap_cache_miss(struct vm_area_struct *vma)
+{
+}
+
+static inline int swap_cache_skip_readahead(struct vm_area_struct *vma)
+{
+	return 0;
+}
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
