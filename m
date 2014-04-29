Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 196AC6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 22:53:41 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so4266171pdb.23
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:53:40 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id rj9si9149562pbc.289.2014.04.28.19.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 19:53:40 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kq14so5885307pab.18
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:53:39 -0700 (PDT)
Date: Tue, 29 Apr 2014 11:53:10 +0900
From: Daeseok Youn <daeseok.youn@gmail.com>
Subject: [PATCH] dmapool: remove redundant NULL check for dev in
 dma_pool_create()
Message-ID: <20140429025310.GA5913@devel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: daeseok.youn@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"dev" cannot be NULL because it is already checked before
calling dma_pool_create().

Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
---
If dev can be NULL, it has NULL deferencing when kmalloc_node()
is called after enabling CONFIG_NUMA.

 mm/dmapool.c |   26 +++++++++-----------------
 1 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index c69781e..38dfcdd 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -170,24 +170,16 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	retval->boundary = boundary;
 	retval->allocation = allocation;
 
-	if (dev) {
-		int ret;
+	INIT_LIST_HEAD(&retval->pools);
 
-		mutex_lock(&pools_lock);
-		if (list_empty(&dev->dma_pools))
-			ret = device_create_file(dev, &dev_attr_pools);
-		else
-			ret = 0;
-		/* note:  not currently insisting "name" be unique */
-		if (!ret)
-			list_add(&retval->pools, &dev->dma_pools);
-		else {
-			kfree(retval);
-			retval = NULL;
-		}
-		mutex_unlock(&pools_lock);
+	mutex_lock(&pools_lock);
+	if (list_empty(&dev->dma_pools) &&
+	    device_create_file(dev, &dev_attr_pools)) {
+		kfree(retval);
+		return NULL;
 	} else
-		INIT_LIST_HEAD(&retval->pools);
+		list_add(&retval->pools, &dev->dma_pools);
+	mutex_unlock(&pools_lock);
 
 	return retval;
 }
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
