Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 4280B6B0072
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 16:39:41 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so6040687qcq.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 13:39:40 -0800 (PST)
Message-ID: <50A2BE19.7000604@gmail.com>
Date: Tue, 13 Nov 2012 16:39:37 -0500
From: Xi Wang <xi.wang@gmail.com>
MIME-Version: 1.0
Subject: [PATCH v2] mm: fix null dev in dma_pool_create()
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
In-Reply-To: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

A few drivers invoke dma_pool_create() with a null dev.  Note that dev
is dereferenced in dev_to_node(dev), causing a null pointer dereference.

A long term solution is to disallow null dev.  Once the drivers are
fixed, we can simplify the core code here.  For now we add WARN_ON(!dev)
to notify the driver maintainers and avoid the null pointer dereference.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 mm/dmapool.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index c5ab33b..bf7f8f0 100644
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
+	node = WARN_ON(!dev) ? -1 : dev_to_node(dev);
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
