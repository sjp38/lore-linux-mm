Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C00946B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 02:44:32 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so835492pde.33
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 23:44:32 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id ll1si9532188pab.173.2014.01.10.23.44.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 10 Jan 2014 23:44:31 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MZ80086M864A960@mailout4.samsung.com> for
 linux-mm@kvack.org; Sat, 11 Jan 2014 16:44:28 +0900 (KST)
From: Cai Liu <cai.liu@samsung.com>
Subject: [PATCH] mm/zswap: Check all pool pages instead of one pool pages
Date: Sat, 11 Jan 2014 15:43:07 +0800
Message-id: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, akpm@linux-foundation.org, bob.liu@oracle.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, liucai.lfn@gmail.com

zswap can support multiple swapfiles. So we need to check
all zbud pool pages in zswap.

Signed-off-by: Cai Liu <cai.liu@samsung.com>
---
 mm/zswap.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index d93afa6..2438344 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -291,7 +291,6 @@ static void zswap_free_entry(struct zswap_tree *tree,
 	zbud_free(tree->pool, entry->handle);
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
 }
 
 /* caller must hold the tree lock */
@@ -405,10 +404,24 @@ cleanup:
 /*********************************
 * helpers
 **********************************/
+static u64 get_zswap_pool_pages(void)
+{
+	int i;
+	u64 pool_pages = 0;
+
+	for (i = 0; i < MAX_SWAPFILES; i++) {
+		if (zswap_trees[i])
+			pool_pages += zbud_get_pool_size(zswap_trees[i]->pool);
+	}
+	zswap_pool_pages = pool_pages;
+
+	return pool_pages;
+}
+
 static bool zswap_is_full(void)
 {
 	return (totalram_pages * zswap_max_pool_percent / 100 <
-		zswap_pool_pages);
+		get_zswap_pool_pages());
 }
 
 /*********************************
@@ -716,7 +729,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
 
 	return 0;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
