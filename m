Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A84D06B0009
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u68so2076277wmd.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f127sor1039682wmg.27.2018.03.05.12.07.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:55 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 05/25] slab: make create_boot_cache() work with 32-bit sizes
Date: Mon,  5 Mar 2018 23:07:10 +0300
Message-Id: <20180305200730.15812-5-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

struct kmem_cache::size has always been "int", all those
"size_t size" are fake.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.h        | 4 ++--
 mm/slab_common.c | 7 ++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index c8887965491b..2a6d88044a56 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -97,8 +97,8 @@ struct kmem_cache *create_kmalloc_cache(const char *name, unsigned int size,
 			slab_flags_t flags, unsigned int useroffset,
 			unsigned int usersize);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, slab_flags_t flags, size_t useroffset,
-			size_t usersize);
+			unsigned int size, slab_flags_t flags,
+			unsigned int useroffset, unsigned int usersize);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index f9afca292858..2a7f09ce7c84 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -917,8 +917,9 @@ bool slab_is_available(void)
 
 #ifndef CONFIG_SLOB
 /* Create a cache during boot when no slab services are available yet */
-void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
-		slab_flags_t flags, size_t useroffset, size_t usersize)
+void __init create_boot_cache(struct kmem_cache *s, const char *name,
+		unsigned int size, slab_flags_t flags,
+		unsigned int useroffset, unsigned int usersize)
 {
 	int err;
 
@@ -933,7 +934,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
-		panic("Creation of kmalloc slab %s size=%zu failed. Reason %d\n",
+		panic("Creation of kmalloc slab %s size=%u failed. Reason %d\n",
 					name, size, err);
 
 	s->refcount = -1;	/* Exempt from merging for now */
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
