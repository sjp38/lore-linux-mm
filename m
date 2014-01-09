Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED0526B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 00:41:25 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so2574610pbc.10
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 21:41:25 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id ey5si2729452pab.335.2014.01.08.21.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 08 Jan 2014 21:41:24 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MZ4003MQD4XOY50@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 09 Jan 2014 14:41:21 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm/swap: fix race on swap_info reuse between swapoff and swapon
Date: Thu, 09 Jan 2014 13:39:55 +0800
Message-id: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, hughd@google.com, 'Minchan Kim' <minchan@kernel.org>, shli@fusionio.com, 'Bob Liu' <bob.liu@oracle.com>, k.kozlowski@samsung.com, stable@vger.kernel.org, weijie.yang.kh@gmail.com

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

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/swapfile.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 612a7c9..89071c3
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1922,7 +1922,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->swap_map = NULL;
 	cluster_info = p->cluster_info;
 	p->cluster_info = NULL;
-	p->flags = 0;
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -1948,6 +1947,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		mutex_unlock(&inode->i_mutex);
 	}
 	filp_close(swap_file, NULL);
+
+	/*
+	* clear SWP_USED flag after all resources freed
+	* so that swapon can reuse this swap_info in alloc_swap_info() safely
+	* it is ok to not hold p->lock after we cleared its SWP_WRITEOK
+	*/
+	spin_lock(&swap_lock);
+	p->flags = 0;
+	spin_unlock(&swap_lock);
+
 	err = 0;
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
