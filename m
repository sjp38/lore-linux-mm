Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 43F046B0033
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:19:25 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSO00AH9USA6OK0@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Sep 2013 14:19:23 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v2 1/4] mm/zswap: bugfix: memory leak when re-swapon
Date: Fri, 06 Sep 2013 13:16:45 +0800
Message-id: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
so memory-leak occurs.

Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
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
