Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEB49681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:00:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so33271175pfw.5
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:00:10 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id e5si7762263plb.115.2017.02.16.11.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 11:00:09 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id e4so7460679pfg.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:00:09 -0800 (PST)
Date: Thu, 16 Feb 2017 11:00:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swap_cluster_info lockdep splat
In-Reply-To: <87o9y2a5ji.fsf@yhuang-dev.intel.com>
Message-ID: <alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
References: <20170216052218.GA13908@bbox> <87o9y2a5ji.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 16 Feb 2017, Huang, Ying wrote:

> Hi, Minchan,
> 
> Minchan Kim <minchan@kernel.org> writes:
> 
> > Hi Huang,
> >
> > With changing from bit lock to spinlock of swap_cluster_info, my zram
> > test failed with below message. It seems nested lock problem so need to
> > play with lockdep.
> 
> Sorry, I could not reproduce the warning in my tests.  Could you try the
> patches as below?   And could you share your test case?
> 
> Best Regards,
> Huang, Ying
> 
> ------------------------------------------------------------->
> From 2b9e2f78a6e389442f308c4f9e8d5ac40fe6aa2f Mon Sep 17 00:00:00 2001
> From: Huang Ying <ying.huang@intel.com>
> Date: Thu, 16 Feb 2017 16:38:17 +0800
> Subject: [PATCH] mm, swap: Annotate nested locking for cluster lock
> 
> There is a nested locking in cluster_list_add_tail() for cluster lock,
> which caused lockdep to complain as below.  The nested locking is safe
> because both cluster locks are only acquired when we held the
> swap_info_struct->lock.  Annotated the nested locking via
> spin_lock_nested() to fix the complain of lockdep.
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 4.10.0-rc8-next-20170214-zram #24 Not tainted
> ---------------------------------------------
> as/6557 is trying to acquire lock:
>  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811ddd03>] cluster_list_add_tail.part.31+0x33/0x70
> 
> but task is already holding lock:
>  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(&(&((cluster_info + ci)->lock))->rlock);
>   lock(&(&((cluster_info + ci)->lock))->rlock);
> 
>  *** DEADLOCK ***
> 
>  May be due to missing lock nesting notation
> 
> 3 locks held by as/6557:
>  #0:  (&(&cache->free_lock)->rlock){......}, at: [<ffffffff811c206b>] free_swap_slot+0x8b/0x110
>  #1:  (&(&p->lock)->rlock){+.+.-.}, at: [<ffffffff811df295>] swapcache_free_entries+0x75/0x330
>  #2:  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
> 
> stack backtrace:
> CPU: 3 PID: 6557 Comm: as Not tainted 4.10.0-rc8-next-20170214-zram #24
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> Call Trace:
>  dump_stack+0x85/0xc2
>  __lock_acquire+0x15ea/0x1640
>  lock_acquire+0x100/0x1f0
>  ? cluster_list_add_tail.part.31+0x33/0x70
>  _raw_spin_lock+0x38/0x50
>  ? cluster_list_add_tail.part.31+0x33/0x70
>  cluster_list_add_tail.part.31+0x33/0x70
>  swapcache_free_entries+0x2f9/0x330
>  free_swap_slot+0xf8/0x110
>  swapcache_free+0x36/0x40
>  delete_from_swap_cache+0x5f/0xa0
>  try_to_free_swap+0x6e/0xa0
>  free_pages_and_swap_cache+0x7d/0xb0
>  tlb_flush_mmu_free+0x36/0x60
>  tlb_finish_mmu+0x1c/0x50
>  exit_mmap+0xc7/0x150
>  mmput+0x51/0x110
>  do_exit+0x2b2/0xc30
>  ? trace_hardirqs_on_caller+0x129/0x1b0
>  do_group_exit+0x50/0xd0
>  SyS_exit_group+0x14/0x20
>  entry_SYSCALL_64_fastpath+0x23/0xc6
> RIP: 0033:0x2b9a2dbdf309
> RSP: 002b:00007ffe71887528 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b9a2dbdf309
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
> RBP: 00002b9a2ded8858 R08: 000000000000003c R09: 00000000000000e7
> R10: ffffffffffffff60 R11: 0000000000000246 R12: 00002b9a2ded8858
> R13: 00002b9a2dedde80 R14: 000000000255f770 R15: 0000000000000001
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  include/linux/swap.h | 6 ++++++
>  mm/swapfile.c        | 8 +++++++-
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 4d12b381821f..ef044ea8fe79 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -166,6 +166,12 @@ enum {
>  #define COUNT_CONTINUED	0x80	/* See swap_map continuation for full count */
>  #define SWAP_MAP_SHMEM	0xbf	/* Owned by shmem/tmpfs, in first swap_map */
>  
> +enum swap_cluster_lock_class
> +{
> +	SWAP_CLUSTER_LOCK_NORMAL,  /* implicitly used by plain spin_lock() APIs. */
> +	SWAP_CLUSTER_LOCK_NESTED,
> +};
> +
>  /*
>   * We use this to track usage of a cluster. A cluster is a block of swap disk
>   * space with SWAPFILE_CLUSTER pages long and naturally aligns in disk. All
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 5ac2cb40dbd3..0a52e9b2f843 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -263,6 +263,12 @@ static inline void __lock_cluster(struct swap_cluster_info *ci)
>  	spin_lock(&ci->lock);
>  }
>  
> +static inline void __lock_cluster_nested(struct swap_cluster_info *ci,
> +					 unsigned subclass)
> +{
> +	spin_lock_nested(&ci->lock, subclass);
> +}
> +
>  static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
>  						     unsigned long offset)
>  {
> @@ -336,7 +342,7 @@ static void cluster_list_add_tail(struct swap_cluster_list *list,
>  		 * only acquired when we held swap_info_struct->lock
>  		 */
>  		ci_tail = ci + tail;
> -		__lock_cluster(ci_tail);
> +		__lock_cluster_nested(ci_tail, SWAP_CLUSTER_LOCK_NESTED);
>  		cluster_set_next(ci_tail, idx);
>  		unlock_cluster(ci_tail);
>  		cluster_set_next_flag(&list->tail, idx, 0);
> -- 
> 2.11.0

I do not understand your zest for putting wrappers around every little
thing, making it all harder to follow than it need be.  Here's the patch
I've been running with (but you have a leak somewhere, and I don't have
time to search out and fix it: please try sustained swapping and swapoff).

[PATCH] mm, swap: Annotate nested locking for cluster lock

Fix swap cluster lockdep warnings.

Reported-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

--- 4.10-rc7-mm1/mm/swapfile.c	2017-02-08 10:56:23.359358518 -0800
+++ linux/mm/swapfile.c	2017-02-08 11:25:55.513241067 -0800
@@ -258,11 +258,6 @@ static inline void cluster_set_null(stru
 	info->data = 0;
 }
 
-static inline void __lock_cluster(struct swap_cluster_info *ci)
-{
-	spin_lock(&ci->lock);
-}
-
 static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
 						     unsigned long offset)
 {
@@ -271,7 +266,7 @@ static inline struct swap_cluster_info *
 	ci = si->cluster_info;
 	if (ci) {
 		ci += offset / SWAPFILE_CLUSTER;
-		__lock_cluster(ci);
+		spin_lock(&ci->lock);
 	}
 	return ci;
 }
@@ -336,7 +331,7 @@ static void cluster_list_add_tail(struct
 		 * only acquired when we held swap_info_struct->lock
 		 */
 		ci_tail = ci + tail;
-		__lock_cluster(ci_tail);
+		spin_lock_nested(&ci_tail->lock, SINGLE_DEPTH_NESTING);
 		cluster_set_next(ci_tail, idx);
 		unlock_cluster(ci_tail);
 		cluster_set_next_flag(&list->tail, idx, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
