Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 669E26B0044
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 23:40:51 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so910120pbb.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 20:40:51 -0700 (PDT)
Date: Wed, 22 Aug 2012 11:40:44 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC]swap: add a simple random read swapin detection
Message-ID: <20120822034044.GB24099@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, fengguang.wu@intel.com

The swapin readahead does a blind readahead regardless if the swapin is
sequential. This is ok for harddisk and random read, because read big size has
no penality in harddisk, and if the readahead pages are garbage, they can be
reclaimed fastly. But for SSD, big size read is more expensive than small size
read. If readahead pages are garbage, such readahead only has overhead.

This patch addes a simple random read detection like what file mmap readahead
does. If random read is detected, swapin readahead will be skipped. This
improves a lot for a swap workload with random IO in a fast SSD.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/mm_types.h |    1 +
 mm/memory.c              |    3 ++-
 mm/swap_state.c          |    9 +++++++++
 3 files changed, 12 insertions(+), 1 deletion(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-08-21 23:01:43.825613437 +0800
+++ linux/mm/swap_state.c	2012-08-22 10:38:36.687902916 +0800
@@ -351,6 +351,7 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
+#define SWAPRA_MISS  (100)
 /**
  * swapin_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
@@ -379,6 +380,13 @@ struct page *swapin_readahead(swp_entry_
 	unsigned long mask = (1UL << page_cluster) - 1;
 	struct blk_plug plug;
 
+	if (vma) {
+		if (atomic_read(&vma->swapra_miss) < SWAPRA_MISS * 10)
+			atomic_inc(&vma->swapra_miss);
+		if (atomic_read(&vma->swapra_miss) > SWAPRA_MISS)
+			goto skip;
+	}
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -397,5 +405,6 @@ struct page *swapin_readahead(swp_entry_
 	blk_finish_plug(&plug);
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
+skip:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
Index: linux/include/linux/mm_types.h
===================================================================
--- linux.orig/include/linux/mm_types.h	2012-08-21 23:02:01.969385586 +0800
+++ linux/include/linux/mm_types.h	2012-08-22 10:37:59.028376385 +0800
@@ -279,6 +279,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	atomic_t swapra_miss;
 };
 
 struct core_thread {
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2012-08-21 23:01:20.861907922 +0800
+++ linux/mm/memory.c	2012-08-22 10:39:58.638872631 +0800
@@ -2953,7 +2953,8 @@ static int do_swap_page(struct mm_struct
 		ret = VM_FAULT_HWPOISON;
 		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		goto out_release;
-	}
+	} else if (!(flags & FAULT_FLAG_TRIED))
+		atomic_dec_if_positive(&vma->swapra_miss);
 
 	locked = lock_page_or_retry(page, mm, flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
