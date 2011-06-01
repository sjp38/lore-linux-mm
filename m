Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3344E6B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 17:43:22 -0400 (EDT)
Received: by ewy9 with SMTP id 9so112857ewy.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 14:43:19 -0700 (PDT)
Date: Thu, 2 Jun 2011 00:43:13 +0300
From: Maxin B John <maxin.john@gmail.com>
Subject: [PATCH] mm: dmapool: fix possible use after free in
 dmam_pool_destroy()
Message-ID: <20110601214313.GA3724@maxin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, eike-kernel@sf-tec.de, willy@linux.intel.com

"dma_pool_destroy(pool)" calls "kfree(pool)". The freed pointer "pool"
is again passed as an argument to the function "devres_destroy()".
This patch fixes the possible use after free.

Please let me know your comments.

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 03bf3bb..fbb58e3 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -500,7 +500,7 @@ void dmam_pool_destroy(struct dma_pool *pool)
 {
 	struct device *dev = pool->dev;
 
-	dma_pool_destroy(pool);
 	WARN_ON(devres_destroy(dev, dmam_pool_release, dmam_pool_match, pool));
+	dma_pool_destroy(pool);
 }
 EXPORT_SYMBOL(dmam_pool_destroy);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
