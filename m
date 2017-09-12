Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2A136B0305
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 22:37:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j16so8762942pga.6
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 19:37:24 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z27si6956140pgc.53.2017.09.11.19.37.21
        for <linux-mm@kvack.org>;
        Mon, 11 Sep 2017 19:37:22 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/5] mm:swap: introduce SWP_SYNCHRONOUS_IO
Date: Tue, 12 Sep 2017 11:37:11 +0900
Message-Id: <1505183833-4739-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1505183833-4739-1-git-send-email-minchan@kernel.org>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

If rw-page based fast storage is used for swap devices, we need to
detect it to enhance swap IO operations.
This patch is preparation for optimizing of swap-in operation with
next patch.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 3 ++-
 mm/swapfile.c        | 3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8a807292037f..0f54b491e118 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -170,8 +170,9 @@ enum {
 	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
+	SWP_SYNCHRONOUS_IO = (1<<11),	/* synchronous IO is efficient */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/swapfile.c b/mm/swapfile.c
index bf91dc9e7a79..1305591cde4d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3168,6 +3168,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
 		p->flags |= SWP_STABLE_WRITES;
 
+	if (bdi_cap_synchronous_io(inode_to_bdi(inode)))
+		p->flags |= SWP_SYNCHRONOUS_IO;
+
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
 		unsigned long ci, nr_cluster;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
