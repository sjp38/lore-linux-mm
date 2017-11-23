Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8FC76B0271
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i17so5587638wmb.7
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y3sor7345004wrd.72.2017.11.23.14.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:20 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 13/23] slub: make ->inuse unsigned int
Date: Fri, 24 Nov 2017 01:16:18 +0300
Message-Id: <20171123221628.8313-13-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

->inuse is "the number of bytes in actual use by the object",
can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index ff2d3f513d15..2383c46c88ce 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -98,7 +98,7 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
-	int inuse;		/* Offset to metadata */
+	unsigned int inuse;	/* Offset to metadata */
 	unsigned int align;	/* Alignment */
 	unsigned int reserved;	/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
diff --git a/mm/slub.c b/mm/slub.c
index ddfeb1d5c512..f5b86d86be9a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4237,12 +4237,11 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		 * the complete object on kzalloc.
 		 */
 		s->object_size = max(s->object_size, (int)size);
-		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
+		s->inuse = max(s->inuse, ALIGN(size, sizeof(void *)));
 
 		for_each_memcg_cache(c, s) {
 			c->object_size = s->object_size;
-			c->inuse = max_t(int, c->inuse,
-					 ALIGN(size, sizeof(void *)));
+			c->inuse = max(c->inuse, ALIGN(size, sizeof(void *)));
 		}
 
 		if (sysfs_slab_alias(s, name)) {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
