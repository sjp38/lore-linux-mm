Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 547B66B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 15:31:31 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id e4so1680702wiv.9
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 12:31:27 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bi2si360955wib.103.2014.09.11.12.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 12:31:26 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] mm: dmapool: add/remove sysfs file outside of the pool lock
Date: Thu, 11 Sep 2014 21:31:16 +0200
Message-Id: <1410463876-21265-1-git-send-email-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

cat /sys/a?|/pools followed by removal the device leads to:

|======================================================
|[ INFO: possible circular locking dependency detected ]
|3.17.0-rc4+ #1498 Not tainted
|-------------------------------------------------------
|rmmod/2505 is trying to acquire lock:
| (s_active#28){++++.+}, at: [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
|
|but task is already holding lock:
| (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
|
|which lock already depends on the new lock.

The problem is the lock order of pools_lock and kernfs_mutex in
dma_pool_destroy() vs show_pools().

This patch breaks out the creation of the sysfs file outside of the
pools_lock mutex.
In theory we would have to create the link in the error path of
device_create_file() in case the dev->dma_pools list is not empty. In
reality I doubt that there will be a single device creating dma-pools in
parallel where it would matter.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/dmapool.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 306baa594f95..0cad8ee7891f 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -132,6 +132,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 {
 	struct dma_pool *retval;
 	size_t allocation;
+	bool empty = false;
 
 	if (align == 0) {
 		align = 1;
@@ -173,14 +174,22 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	INIT_LIST_HEAD(&retval->pools);
 
 	mutex_lock(&pools_lock);
-	if (list_empty(&dev->dma_pools) &&
-	    device_create_file(dev, &dev_attr_pools)) {
-		kfree(retval);
-		return NULL;
-	} else
-		list_add(&retval->pools, &dev->dma_pools);
+	if (list_empty(&dev->dma_pools))
+		empty = true;
+	list_add(&retval->pools, &dev->dma_pools);
 	mutex_unlock(&pools_lock);
-
+	if (empty) {
+		int err;
+
+		err = device_create_file(dev, &dev_attr_pools);
+		if (err) {
+			mutex_lock(&pools_lock);
+			list_del(&retval->pools);
+			mutex_unlock(&pools_lock);
+			kfree(retval);
+			return NULL;
+		}
+	}
 	return retval;
 }
 EXPORT_SYMBOL(dma_pool_create);
@@ -251,11 +260,15 @@ static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	bool empty = false;
+
 	mutex_lock(&pools_lock);
 	list_del(&pool->pools);
 	if (pool->dev && list_empty(&pool->dev->dma_pools))
-		device_remove_file(pool->dev, &dev_attr_pools);
+		empty = true;
 	mutex_unlock(&pools_lock);
+	if (empty)
+		device_remove_file(pool->dev, &dev_attr_pools);
 
 	while (!list_empty(&pool->page_list)) {
 		struct dma_page *page;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
