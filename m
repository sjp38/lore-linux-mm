Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 958296B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 06:36:21 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1217549dad.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2012 03:36:20 -0700 (PDT)
Date: Thu, 30 Aug 2012 18:36:12 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch v3]swap: add a simple random read swapin detection
Message-ID: <20120830103612.GA12292@kernel.org>
References: <20120827040037.GA8062@kernel.org>
 <503B8997.4040604@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <503B8997.4040604@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, akpm@linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "minchan@kernel.org" <minchan@kernel.org>

On Mon, Aug 27, 2012 at 06:52:07PM +0400, Konstantin Khlebnikov wrote:
> >--- linux.orig/include/linux/mm_types.h	2012-08-22 11:44:53.077912855 +0800
> >+++ linux/include/linux/mm_types.h	2012-08-24 13:07:11.798576941 +0800
> >@@ -279,6 +279,9 @@ struct vm_area_struct {
> >  #ifdef CONFIG_NUMA
> >  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
> >  #endif
> >+#ifdef CONFIG_SWAP
> >+	atomic_t swapra_miss;
> >+#endif
> 
> You can place this atomic on vma->anon_vma, it has perfect 4-byte
> hole right after field "refcount". vma->anon_vma already exists
> since this vma already contains anon pages.

makes sense. vma->anon_vma could be NUll (shmem), but in shmem
case, vma could NULL too, so maybe just ignore it.


Subject: swap: add a simple random read swapin detection

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

V2->V3:
move swapra_miss to 'struct anon_vma' as suggested by Konstantin. 

V1->V2:
1. Move the swap readahead accounting to separate functions as suggested by Riel.
2. Enable the logic only with CONFIG_SWAP enabled as suggested by Minchan.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/rmap.h |    3 +++
 mm/internal.h        |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c          |    3 ++-
 mm/shmem.c           |    1 +
 mm/swap_state.c      |    6 ++++++
 5 files changed, 62 insertions(+), 1 deletion(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-08-29 16:13:00.912112140 +0800
+++ linux/mm/swap_state.c	2012-08-30 18:28:24.678315187 +0800
@@ -20,6 +20,7 @@
 #include <linux/page_cgroup.h>
 
 #include <asm/pgtable.h>
+#include "internal.h"
 
 /*
  * swapper_space is a fiction, retained to simplify the path through
@@ -379,6 +380,10 @@ struct page *swapin_readahead(swp_entry_
 	unsigned long mask = (1UL << page_cluster) - 1;
 	struct blk_plug plug;
 
+	swap_cache_miss(vma);
+	if (swap_cache_skip_readahead(vma))
+		goto skip;
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -397,5 +402,6 @@ struct page *swapin_readahead(swp_entry_
 	blk_finish_plug(&plug);
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
+skip:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2012-08-29 16:13:00.920112040 +0800
+++ linux/mm/memory.c	2012-08-30 13:32:05.425830660 +0800
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
--- linux.orig/mm/internal.h	2012-08-29 16:13:00.932111888 +0800
+++ linux/mm/internal.h	2012-08-30 18:28:03.698578951 +0800
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/rmap.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -356,3 +357,52 @@ extern unsigned long vm_mmap_pgoff(struc
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
+	if (vma && vma->anon_vma)
+		atomic_dec_if_positive(&vma->anon_vma->swapra_miss);
+}
+
+static inline void swap_cache_miss(struct vm_area_struct *vma)
+{
+	if (!vma || !vma->anon_vma)
+		return;
+	if (atomic_read(&vma->anon_vma->swapra_miss) < SWAPRA_MISS * 10)
+		atomic_inc(&vma->anon_vma->swapra_miss);
+}
+
+static inline int swap_cache_skip_readahead(struct vm_area_struct *vma)
+{
+	if (!vma || !vma->anon_vma)
+		return 0;
+	return atomic_read(&vma->anon_vma->swapra_miss) > SWAPRA_MISS;
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
Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h	2012-06-01 10:10:31.686394463 +0800
+++ linux/include/linux/rmap.h	2012-08-30 18:10:12.256048781 +0800
@@ -35,6 +35,9 @@ struct anon_vma {
 	 * anon_vma if they are the last user on release
 	 */
 	atomic_t refcount;
+#ifdef CONFIG_SWAP
+	atomic_t swapra_miss;
+#endif
 
 	/*
 	 * NOTE: the LSB of the head.next is set by
Index: linux/mm/shmem.c
===================================================================
--- linux.orig/mm/shmem.c	2012-08-06 16:00:45.465441525 +0800
+++ linux/mm/shmem.c	2012-08-30 18:10:51.755553250 +0800
@@ -933,6 +933,7 @@ static struct page *shmem_swapin(swp_ent
 	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
+	pvma.anon_vma = NULL;
 	return swapin_readahead(swap, gfp, &pvma, 0);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
