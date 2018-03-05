Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0B76B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i201so4617606wmf.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u125sor2412199wmd.7.2018.03.05.12.07.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:54 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 04/25] slab: make create_kmalloc_cache() work with 32-bit sizes
Date: Mon,  5 Mar 2018 23:07:09 +0300
Message-Id: <20180305200730.15812-4-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

KMALLOC_MAX_CACHE_SIZE is 32-bit so is the largest kmalloc cache size.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.h        | 8 ++++----
 mm/slab_common.c | 6 +++---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 51813236e773..c8887965491b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -77,7 +77,7 @@ extern struct kmem_cache *kmem_cache;
 /* A table of kmalloc cache names and sizes */
 extern const struct kmalloc_info_struct {
 	const char *name;
-	unsigned long size;
+	unsigned int size;
 } kmalloc_info[];
 
 #ifndef CONFIG_SLOB
@@ -93,9 +93,9 @@ struct kmem_cache *kmalloc_slab(size_t, gfp_t);
 /* Functions provided by the slab allocators */
 int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 
-extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
-			slab_flags_t flags, size_t useroffset,
-			size_t usersize);
+struct kmem_cache *create_kmalloc_cache(const char *name, unsigned int size,
+			slab_flags_t flags, unsigned int useroffset,
+			unsigned int usersize);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
 			size_t size, slab_flags_t flags, size_t useroffset,
 			size_t usersize);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d3f4209c297d..f9afca292858 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -939,9 +939,9 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 	s->refcount = -1;	/* Exempt from merging for now */
 }
 
-struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
-				slab_flags_t flags, size_t useroffset,
-				size_t usersize)
+struct kmem_cache *__init create_kmalloc_cache(const char *name,
+		unsigned int size, slab_flags_t flags,
+		unsigned int useroffset, unsigned int usersize)
 {
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
