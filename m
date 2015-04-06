Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB5E6B00C6
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 17:32:05 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so55866886pac.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 14:32:05 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id va6si8250342pbc.52.2015.04.06.14.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 06 Apr 2015 14:32:04 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NME006BGMNYK400@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Apr 2015 22:35:58 +0100 (BST)
From: Stefan Strogin <stefan.strogin@gmail.com>
Subject: [PATCH] mm-cma-add-functions-to-get-region-pages-counters-fix-2
Date: Tue, 07 Apr 2015 00:31:46 +0300
Message-id: <1428355906-5521-1-git-send-email-stefan.strogin@gmail.com>
In-reply-to: <5522FAEA.4040707@partner.samsung.com>
References: <5522FAEA.4040707@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Strogin <stefan.strogin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stefan Strogin <s.strogin@partner.samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Michal Hocko <mhocko@suse.cz>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>

Move the code from cma_get_used() and cma_get_maxchunk() to cma_used_get()
and cma_maxchunk_get(), because cma_get_*() aren't used anywhere else, and
because of their confusing similar names.

Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
---
 mm/cma_debug.c | 51 ++++++++++++++++++---------------------------------
 1 file changed, 18 insertions(+), 33 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 56c4175..abb9d0b 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -22,37 +22,6 @@ struct cma_mem {
 
 static struct dentry *cma_debugfs_root;
 
-static unsigned long cma_get_used(struct cma *cma)
-{
-	unsigned long ret = 0;
-
-	mutex_lock(&cma->lock);
-	/* pages counter is smaller than sizeof(int) */
-	ret = bitmap_weight(cma->bitmap, (int)cma->count);
-	mutex_unlock(&cma->lock);
-
-	return ret << cma->order_per_bit;
-}
-
-static unsigned long cma_get_maxchunk(struct cma *cma)
-{
-	unsigned long maxchunk = 0;
-	unsigned long start, end = 0;
-
-	mutex_lock(&cma->lock);
-	for (;;) {
-		start = find_next_zero_bit(cma->bitmap, cma->count, end);
-		if (start >= cma->count)
-			break;
-		end = find_next_bit(cma->bitmap, cma->count, start);
-		maxchunk = max(end - start, maxchunk);
-	}
-	mutex_unlock(&cma->lock);
-
-	return maxchunk << cma->order_per_bit;
-}
-
-
 static int cma_debugfs_get(void *data, u64 *val)
 {
 	unsigned long *p = data;
@@ -66,8 +35,13 @@ DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
 static int cma_used_get(void *data, u64 *val)
 {
 	struct cma *cma = data;
+	unsigned long used;
 
-	*val = cma_get_used(cma);
+	mutex_lock(&cma->lock);
+	/* pages counter is smaller than sizeof(int) */
+	used = bitmap_weight(cma->bitmap, (int)cma->count);
+	mutex_unlock(&cma->lock);
+	*val = used << cma->order_per_bit;
 
 	return 0;
 }
@@ -76,8 +50,19 @@ DEFINE_SIMPLE_ATTRIBUTE(cma_used_fops, cma_used_get, NULL, "%llu\n");
 static int cma_maxchunk_get(void *data, u64 *val)
 {
 	struct cma *cma = data;
+	unsigned long maxchunk = 0;
+	unsigned long start, end = 0;
 
-	*val = cma_get_maxchunk(cma);
+	mutex_lock(&cma->lock);
+	for (;;) {
+		start = find_next_zero_bit(cma->bitmap, cma->count, end);
+		if (start >= cma->count)
+			break;
+		end = find_next_bit(cma->bitmap, cma->count, start);
+		maxchunk = max(end - start, maxchunk);
+	}
+	mutex_unlock(&cma->lock);
+	*val = maxchunk << cma->order_per_bit;
 
 	return 0;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
