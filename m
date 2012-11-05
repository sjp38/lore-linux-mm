Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E575D6B002B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 01:46:52 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so6932478vbk.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 22:46:51 -0800 (PST)
From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] mm: fix NULL checking in dma_pool_create()
Date: Mon,  5 Nov 2012 01:46:36 -0500
Message-Id: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xi Wang <xi.wang@gmail.com>

First, `dev' is dereferenced in dev_to_node(dev), suggesting that it
must be non-null.  Later `dev' is checked against NULL, suggesting
the opposite.  This patch adds a NULL check before its use.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 mm/dmapool.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index c5ab33b..afbf88e 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -135,6 +135,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 {
 	struct dma_pool *retval;
 	size_t allocation;
+	int node;
 
 	if (align == 0) {
 		align = 1;
@@ -159,7 +160,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 		return NULL;
 	}
 
-	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
+	node = dev ? dev_to_node(dev) : -1;
+
+	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, node);
 	if (!retval)
 		return retval;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
