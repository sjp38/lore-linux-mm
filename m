Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0E566B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 21:35:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so129691201pfw.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 18:35:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a88si2547745pfe.90.2017.02.06.18.35.48
        for <linux-mm@kvack.org>;
        Mon, 06 Feb 2017 18:35:48 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] swapfile: initialize spinlock for swap_cluster_info
Date: Tue,  7 Feb 2017 11:35:45 +0900
Message-Id: <1486434945-29753-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>

We changed swap_cluster_info lock from bit_spin_lock to spinlock
so we need to initialize the spinlock before the using. Otherwise,
lockdep is broken.

Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Andrew,
I think it's no worth to add this patch to separate commit.
If you don't mind, it's okay to fold this patch to mm-swap-add-cluster-lock-v5.
Thanks.

 mm/swapfile.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1fc1824140e1..5ac2cb40dbd3 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2762,6 +2762,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
+		unsigned long ci, nr_cluster;
 
 		p->flags |= SWP_SOLIDSTATE;
 		/*
@@ -2769,13 +2770,17 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		 * SSD
 		 */
 		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
+		nr_cluster = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
 
-		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
-			SWAPFILE_CLUSTER) * sizeof(*cluster_info));
+		cluster_info = vzalloc(nr_cluster * sizeof(*cluster_info));
 		if (!cluster_info) {
 			error = -ENOMEM;
 			goto bad_swap;
 		}
+
+		for (ci = 0; ci < nr_cluster; ci++)
+			spin_lock_init(&((cluster_info + ci)->lock));
+
 		p->percpu_cluster = alloc_percpu(struct percpu_cluster);
 		if (!p->percpu_cluster) {
 			error = -ENOMEM;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
