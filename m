Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 704566B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:10:07 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so5535237pdj.17
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:10:07 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id xk2si10734345pab.332.2014.01.27.02.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:10:05 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200I3X1KQHHE0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:10:02 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 2/8] mm/swap: fix race on swap_info reuse between swapoff and
 swapon
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000d01cf1b47$f12e11f0$d38a35d0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

swapoff clear swap_info's SWP_USED flag prematurely and free its resources
after that. A concurrent swapon will reuse this swap_info while its previous
resources are not cleared completely.

These late freed resources are:
 - p->percpu_cluster
 - swap_cgroup_ctrl[type]
 - block_device setting
 - inode->i_flags &= ~S_SWAPFILE

This patch clear SWP_USED flag after all its resources freed, so that swapon
can reuse this swap_info by alloc_swap_info() safely.

This patch is just for a rare scenario, aim to correct of code.

Suggested-by: Heesub Shin <heesub.shin@samsung.com>
Suggested-by: Mateusz Guzik <mguzik@redhat.com>
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/swapfile.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0a623a9..4d24158 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1977,7 +1977,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->swap_map = NULL;
 	cluster_info = p->cluster_info;
 	p->cluster_info = NULL;
-	p->flags = 0;
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -2003,6 +2002,15 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		mutex_unlock(&inode->i_mutex);
 	}
 	filp_close(swap_file, NULL);
+
+	/*
+	 * clear SWP_USED flag after all resources freed so that
+	 * swapon can reuse this swap_info in alloc_swap_info() safely
+	 * it is ok to not hold any lock after we cleared SWP_WRITEOK flag
+	 */
+	smp_wmb();
+	p->flags = 0;
+
 	err = 0;
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
@@ -2050,7 +2058,7 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
 	for (type = 0; type < nr_swapfiles; type++) {
 		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
 		si = swap_info[type];
-		if (!(si->flags & SWP_USED) || !si->swap_map)
+		if (!(si->flags & SWP_WRITEOK))
 			continue;
 		if (!--l)
 			return si;
@@ -2072,7 +2080,7 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
 	for (; type < nr_swapfiles; type++) {
 		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
 		si = swap_info[type];
-		if (!(si->flags & SWP_USED) || !si->swap_map)
+		if (!(si->flags & SWP_WRITEOK))
 			continue;
 		++*pos;
 		return si;
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
