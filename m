Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D16B26B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:06 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so5107327wmb.3
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p27sor2195868wma.16.2018.03.05.12.08.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:05 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 14/25] slub: make ->inuse unsigned int
Date: Mon,  5 Mar 2018 23:07:19 +0300
Message-Id: <20180305200730.15812-14-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

->inuse is "the number of bytes in actual use by the object",
can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2a0eabeff78f..2287b800474f 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -98,7 +98,7 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
-	int inuse;		/* Offset to metadata */
+	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
 	unsigned int reserved;		/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
diff --git a/mm/slub.c b/mm/slub.c
index 246f0132d308..b4c07dcab0e1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4255,12 +4255,11 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
