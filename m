Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B036A6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 03:23:38 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1221841pab.13
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 00:23:38 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id l1si15881063paw.397.2014.04.18.00.23.36
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 00:23:37 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] slab: fix the type of the index on freelist index accessor
Date: Fri, 18 Apr 2014 16:24:09 +0900
Message-Id: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Steven King <sfking@fdwdc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit 8dcc774 (slab: introduce byte sized index for the freelist of
a slab) changes the size of freelist index and also changes prototype
of accessor function to freelist index. And there was a mistake.

The mistake is that although it changes the size of freelist index
correctly, it changes the size of the index of freelist index incorrectly.
With patch, freelist index can be 1 byte or 2 bytes, that means that
num of object on on a slab can be more than 255. So we need more than 1
byte for the index to find the index of free object on freelist. But,
above patch makes this index type 1 byte, so slab which have more than
255 objects cannot work properly and in consequence of it, the system
cannot boot.

This issue was reported by Steven King on m68knommu which would use
2 bytes freelist index. Please refer following link.

https://lkml.org/lkml/2014/4/16/433

To fix it is so easy. To change the type of the index of freelist index
on accessor functions is enough to fix this bug. Although 2 bytes is
enough, I use 4 bytes since it have no bad effect and make things
more easier. This fix was suggested and tested by Steven in his
original report.

Reported-by: Steven King <sfking@fdwdc.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
Hello, Pekka.

Could you send this for v3.15-rc2?
Without this patch, many architecture using 2 bytes freelist index cannot
work properly, I guess.

This patch is based on v3.15-rc1.

Thanks.

diff --git a/mm/slab.c b/mm/slab.c
index 388cb1a..d7f9f44 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2572,13 +2572,13 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 	return freelist;
 }
 
-static inline freelist_idx_t get_free_obj(struct page *page, unsigned char idx)
+static inline freelist_idx_t get_free_obj(struct page *page, unsigned int idx)
 {
 	return ((freelist_idx_t *)page->freelist)[idx];
 }
 
 static inline void set_free_obj(struct page *page,
-					unsigned char idx, freelist_idx_t val)
+					unsigned int idx, freelist_idx_t val)
 {
 	((freelist_idx_t *)(page->freelist))[idx] = val;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
