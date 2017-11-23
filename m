Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5578C6B025E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v184so3998717wmf.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l195sor1742266wmd.46.2017.11.23.14.17.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:12 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 04/23] slab: create_boot_cache() only works with 32-bit sizes
Date: Fri, 24 Nov 2017 01:16:09 +0300
Message-Id: <20171123221628.8313-4-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

struct kmem_cache::size has always been "int" so all those
"size_t size" are fake.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.h        | 2 +-
 mm/slab_common.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 08f43ed41b75..6bbb7b5d1706 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -97,7 +97,7 @@ int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 struct kmem_cache *create_kmalloc_cache(const char *name, unsigned int size,
 			slab_flags_t flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, slab_flags_t flags);
+			unsigned int size, slab_flags_t flags);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fa27e0492f89..9c8c55e1e0e3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -878,7 +878,7 @@ bool slab_is_available(void)
 
 #ifndef CONFIG_SLOB
 /* Create a cache during boot when no slab services are available yet */
-void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
+void __init create_boot_cache(struct kmem_cache *s, const char *name, unsigned int size,
 		slab_flags_t flags)
 {
 	int err;
@@ -892,7 +892,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
-		panic("Creation of kmalloc slab %s size=%zu failed. Reason %d\n",
+		panic("Creation of kmalloc slab %s size=%u failed. Reason %d\n",
 					name, size, err);
 
 	s->refcount = -1;	/* Exempt from merging for now */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
