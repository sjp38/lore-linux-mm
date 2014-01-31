Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DC8E36B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 15:39:12 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so4683119pdj.24
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:39:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zk9si11719821pac.347.2014.01.31.12.38.56
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 12:38:56 -0800 (PST)
Date: Fri, 31 Jan 2014 12:38:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
Message-Id: <20140131123855.9a4d322c93a91a6ffd67a48c@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Weijie Yang <weijie.yang@samsung.com>


Hugh, I am awaiting your feedback on this one please.


From: Weijie Yang <weijie.yang@samsung.com>
Subject: mm/swap: fix race on swap_info reuse between swapoff and swapon

swapoff clear swap_info's SWP_USED flag prematurely and free its resources
after that.  A concurrent swapon will reuse this swap_info while its
previous resources are not cleared completely.

These late freed resources are:
- p->percpu_cluster
- swap_cgroup_ctrl[type]
- block_device setting
- inode->i_flags &= ~S_SWAPFILE

This patch clears the SWP_USED flag after all its resources are freed, so
that swapon can reuse this swap_info by alloc_swap_info() safely.

[akpm@linux-foundation.org: tidy up code comment]
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/swapfile.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff -puN mm/swapfile.c~mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon mm/swapfile.c
--- a/mm/swapfile.c~mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon
+++ a/mm/swapfile.c
@@ -1923,7 +1923,6 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	p->swap_map = NULL;
 	cluster_info = p->cluster_info;
 	p->cluster_info = NULL;
-	p->flags = 0;
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -1949,6 +1948,16 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		mutex_unlock(&inode->i_mutex);
 	}
 	filp_close(swap_file, NULL);
+
+	/*
+	 * Clear the SWP_USED flag after all resources are freed so that swapon
+	 * can reuse this swap_info in alloc_swap_info() safely.  It is ok to
+	 * not hold p->lock after we cleared its SWP_WRITEOK.
+	 */
+	spin_lock(&swap_lock);
+	p->flags = 0;
+	spin_unlock(&swap_lock);
+
 	err = 0;
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
