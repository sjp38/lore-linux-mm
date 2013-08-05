Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 08E756B0034
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:31:21 -0400 (EDT)
Message-ID: <51FF62CB.3090906@huawei.com>
Date: Mon, 5 Aug 2013 16:31:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] cma: adjust goto branch in function cma_create_area()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Adjust the function structure, one for the success path, 
the other for the failure path.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/base/dma-contiguous.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 1bcfaed..aa72f93 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -167,26 +167,28 @@ static __init struct cma *cma_create_area(unsigned long base_pfn,
 
 	cma = kmalloc(sizeof *cma, GFP_KERNEL);
 	if (!cma)
-		return ERR_PTR(-ENOMEM);
+		goto err;
 
 	cma->base_pfn = base_pfn;
 	cma->count = count;
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
 	if (!cma->bitmap)
-		goto no_mem;
+		goto err;
 
 	ret = cma_activate_area(base_pfn, count);
 	if (ret)
-		goto error;
+		goto err;
 
 	pr_debug("%s: returned %p\n", __func__, (void *)cma);
 	return cma;
 
-error:
-	kfree(cma->bitmap);
-no_mem:
-	kfree(cma);
+err:
+	if (cma) {
+		if (cma->bitmap)
+			kfree(cma->bitmap);
+		kfree(cma);
+	}
 	return ERR_PTR(ret);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
