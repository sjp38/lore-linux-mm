Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F02926B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 04:25:41 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so2934382pdj.30
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 01:25:41 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTK008V4KQQ0KI0@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 23 Sep 2013 17:25:38 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v3 1/3] mm/zswap: bugfix: memory leak when re-swapon
Date: Mon, 23 Sep 2013 16:21:49 +0800
Message-id: <000301ceb836$7b4a1340$71de39c0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
so memory-leak occurs.

Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Reviewed-by: Bob Liu <bob.liu@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 mm/zswap.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..cbd9578 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -816,6 +816,10 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	}
 	tree->rbroot = RB_ROOT;
 	spin_unlock(&tree->lock);
+
+	zbud_destroy_pool(tree->pool);
+	kfree(tree);
+	zswap_trees[type] = NULL;
 }
 
 static struct zbud_ops zswap_zbud_ops = {
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
