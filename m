Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5DB28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:35:46 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so19324140pdr.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:35:45 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id r15si5896482pdn.4.2015.07.14.23.35.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 23:35:45 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so19382577pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:35:45 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] mm/cma_debug: correct size input to bitmap function
Date: Wed, 15 Jul 2015 15:35:29 +0900
Message-Id: <1436942129-18020-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In CMA, 1 bit in bitmap means 1 << order_per_bits pages so
size of bitmap is cma->count >> order_per_bits rather than
just cma->count. This patch fixes it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/cma_debug.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 22190a7..f8e4b60 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -39,7 +39,7 @@ static int cma_used_get(void *data, u64 *val)
 
 	mutex_lock(&cma->lock);
 	/* pages counter is smaller than sizeof(int) */
-	used = bitmap_weight(cma->bitmap, (int)cma->count);
+	used = bitmap_weight(cma->bitmap, (int)cma_bitmap_maxno(cma));
 	mutex_unlock(&cma->lock);
 	*val = (u64)used << cma->order_per_bit;
 
@@ -52,13 +52,14 @@ static int cma_maxchunk_get(void *data, u64 *val)
 	struct cma *cma = data;
 	unsigned long maxchunk = 0;
 	unsigned long start, end = 0;
+	unsigned long bitmap_maxno = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	for (;;) {
-		start = find_next_zero_bit(cma->bitmap, cma->count, end);
+		start = find_next_zero_bit(cma->bitmap, bitmap_maxno, end);
 		if (start >= cma->count)
 			break;
-		end = find_next_bit(cma->bitmap, cma->count, start);
+		end = find_next_bit(cma->bitmap, bitmap_maxno, start);
 		maxchunk = max(end - start, maxchunk);
 	}
 	mutex_unlock(&cma->lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
