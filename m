Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0AC76B02FD
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 21:45:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so107424670pgn.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:45:02 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l5si4691214pgu.532.2017.06.29.18.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 18:45:02 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 6/6] mm, swap: Don't use VMA based swap readahead if HDD is used as swap
Date: Fri, 30 Jun 2017 09:44:43 +0800
Message-Id: <20170630014443.23983-7-ying.huang@intel.com>
In-Reply-To: <20170630014443.23983-1-ying.huang@intel.com>
References: <20170630014443.23983-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

VMA based swap readahead will readahead the virtual pages that is
continuous in the virtual address space.  While the original swap
readahead will readahead the swap slots that is continuous in the swap
device.  Although VMA based swap readahead is more correct for the
swap slots to be readahead, it will trigger more small random
readings, which may cause the performance of HDD (hard disk) to
degrade heavily, and may finally exceed the benefit.

To avoid the issue, in this patch, if the HDD is used as swap, the VMA
based swap readahead will be disabled, and the original swap readahead
will be used instead.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/swap.h | 11 ++++++-----
 mm/swapfile.c        |  8 +++++++-
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 34fe19f9b4c6..7fa4e4030ddb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -398,16 +398,17 @@ extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 					   struct vm_fault *vmf,
 					   struct vma_swap_readahead *swap_ra);
 
-static inline bool swap_use_vma_readahead(void)
-{
-	return READ_ONCE(swap_vma_readahead);
-}
-
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
+extern atomic_t nr_rotate_swap;
 extern bool has_usable_swap(void);
 
+static inline bool swap_use_vma_readahead(void)
+{
+	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
+}
+
 /* Swap 50% full? Release swapcache more aggressively.. */
 static inline bool vm_swap_full(void)
 {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6ba4aab2db0b..2685b9951cc1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -96,6 +96,8 @@ static DECLARE_WAIT_QUEUE_HEAD(proc_poll_wait);
 /* Activity counter to indicate that a swapon or swapoff has occurred */
 static atomic_t proc_poll_event = ATOMIC_INIT(0);
 
+atomic_t nr_rotate_swap = ATOMIC_INIT(0);
+
 static inline unsigned char swap_count(unsigned char ent)
 {
 	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
@@ -2387,6 +2389,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	if (p->flags & SWP_CONTINUED)
 		free_swap_count_continuations(p);
 
+	if (!p->bdev || !blk_queue_nonrot(bdev_get_queue(p->bdev)))
+		atomic_dec(&nr_rotate_swap);
+
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
@@ -2963,7 +2968,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			cluster = per_cpu_ptr(p->percpu_cluster, cpu);
 			cluster_set_null(&cluster->index);
 		}
-	}
+	} else
+		atomic_inc(&nr_rotate_swap);
 
 	error = swap_cgroup_swapon(p->type, maxpages);
 	if (error)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
