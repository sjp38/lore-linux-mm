Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 86A936B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 01:55:08 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so16559050pab.37
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 22:55:08 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id pk8si9006670pac.176.2014.09.02.22.55.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 02 Sep 2014 22:55:07 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBB00EM39RE4K60@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 03 Sep 2014 14:54:50 +0900 (KST)
From: Chao Yu <chao2.yu@samsung.com>
Subject: [PATCH] zbud: avoid accessing in last unused freelist
Date: Wed, 03 Sep 2014 13:54:09 +0800
Message-id: <000001cfc73b$9340d050$b9c270f0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

For now, there are NCHUNKS of 64 freelists in zbud_pool, the last unbuddied[63]
freelist linked with all zbud pages which have free chunks of 63. Calculating
according to context of num_free_chunks(), our max chunk number of unbuddied
zbud page is 62, so none of zbud pages will be added/removed in last freelist,
but still we will try to find an unbuddied zbud page in the last unused
freelist, it is unneeded.

This patch redefines NCHUNKS to 63 as free chunk number in one zbud page, hence
we can decrease size of zpool and avoid accessing the last unused freelist
whenever failing to allocate zbud from freelist in zbud_alloc.

Signed-off-by: Chao Yu <chao2.yu@samsung.com>
---
 mm/zbud.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index f26e7fc..ecf1dbe 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -60,15 +60,17 @@
  * NCHUNKS_ORDER determines the internal allocation granularity, effectively
  * adjusting internal fragmentation.  It also determines the number of
  * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
- * allocation granularity will be in chunks of size PAGE_SIZE/64, and there
- * will be 64 freelists per pool.
+ * allocation granularity will be in chunks of size PAGE_SIZE/64. As one chunk
+ * in allocated page is occupied by zbud header, NCHUNKS will be calculated to
+ * 63 which shows the max number of free chunks in zbud page, also there will be
+ * 63 freelists per pool.
  */
 #define NCHUNKS_ORDER	6
 
 #define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
 #define CHUNK_SIZE	(1 << CHUNK_SHIFT)
-#define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
 #define ZHDR_SIZE_ALIGNED CHUNK_SIZE
+#define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
 
 /**
  * struct zbud_pool - stores metadata for each zbud pool
@@ -268,10 +270,9 @@ static int num_free_chunks(struct zbud_header *zhdr)
 {
 	/*
 	 * Rather than branch for different situations, just use the fact that
-	 * free buddies have a length of zero to simplify everything. -1 at the
-	 * end for the zbud header.
+	 * free buddies have a length of zero to simplify everything.
 	 */
-	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
+	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks;
 }
 
 /*****************
-- 
2.0.1.474.g72c7794


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
