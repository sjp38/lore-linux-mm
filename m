Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3CF6B000A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:58 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f16so11996315wre.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d125sor2382907wmd.61.2018.03.05.12.07.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:56 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 06/25] slab: make kmem_cache_create() work with 32-bit sizes
Date: Mon,  5 Mar 2018 23:07:11 +0300
Message-Id: <20180305200730.15812-6-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

struct kmem_cache::size and ::align were always 32-bit.

Out of curiosity I created 4GB kmem_cache, it oopsed with division by 0.
kmem_cache_create(1UL<<32+1) created 1-byte cache as expected.

size_t doesn't work and never did.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h |  7 ++++---
 mm/slab.c            |  2 +-
 mm/slab.h            |  6 +++---
 mm/slab_common.c     | 19 ++++++++++---------
 mm/slub.c            |  2 +-
 5 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ad157fbf3886..d36e8f03730e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -137,11 +137,12 @@ bool slab_is_available(void);
 
 extern bool usercopy_fallback;
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size,
-			size_t align, slab_flags_t flags,
+struct kmem_cache *kmem_cache_create(const char *name, unsigned int size,
+			unsigned int align, slab_flags_t flags,
 			void (*ctor)(void *));
 struct kmem_cache *kmem_cache_create_usercopy(const char *name,
-			size_t size, size_t align, slab_flags_t flags,
+			unsigned int size, unsigned int align,
+			slab_flags_t flags,
 			size_t useroffset, size_t usersize,
 			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
diff --git a/mm/slab.c b/mm/slab.c
index 324446621b3e..cc136fcedfb9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1876,7 +1876,7 @@ slab_flags_t kmem_cache_flags(unsigned long object_size,
 }
 
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *cachep;
diff --git a/mm/slab.h b/mm/slab.h
index 2a6d88044a56..0809580428fe 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -101,11 +101,11 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
 			unsigned int useroffset, unsigned int usersize);
 
 int slab_unmergeable(struct kmem_cache *s);
-struct kmem_cache *find_mergeable(size_t size, size_t align,
+struct kmem_cache *find_mergeable(unsigned size, unsigned align,
 		slab_flags_t flags, const char *name, void (*ctor)(void *));
 #ifndef CONFIG_SLOB
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *));
 
 slab_flags_t kmem_cache_flags(unsigned long object_size,
@@ -113,7 +113,7 @@ slab_flags_t kmem_cache_flags(unsigned long object_size,
 	void (*ctor)(void *));
 #else
 static inline struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 { return NULL; }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2a7f09ce7c84..a4545a61a7c8 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -82,7 +82,7 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
 EXPORT_SYMBOL(kmem_cache_size);
 
 #ifdef CONFIG_DEBUG_VM
-static int kmem_cache_sanity_check(const char *name, size_t size)
+static int kmem_cache_sanity_check(const char *name, unsigned int size)
 {
 	struct kmem_cache *s = NULL;
 
@@ -113,7 +113,7 @@ static int kmem_cache_sanity_check(const char *name, size_t size)
 	return 0;
 }
 #else
-static inline int kmem_cache_sanity_check(const char *name, size_t size)
+static inline int kmem_cache_sanity_check(const char *name, unsigned int size)
 {
 	return 0;
 }
@@ -280,8 +280,8 @@ static inline void memcg_unlink_cache(struct kmem_cache *s)
  * Figure out what the alignment of the objects will be given a set of
  * flags, a user specified alignment and the size of the objects.
  */
-static unsigned long calculate_alignment(slab_flags_t flags,
-		unsigned long align, unsigned long size)
+static unsigned int calculate_alignment(slab_flags_t flags,
+		unsigned int align, unsigned int size)
 {
 	/*
 	 * If the user wants hardware cache aligned objects then follow that
@@ -291,7 +291,7 @@ static unsigned long calculate_alignment(slab_flags_t flags,
 	 * alignment though. If that is greater then use it.
 	 */
 	if (flags & SLAB_HWCACHE_ALIGN) {
-		unsigned long ralign;
+		unsigned int ralign;
 
 		ralign = cache_line_size();
 		while (size <= ralign / 2)
@@ -331,7 +331,7 @@ int slab_unmergeable(struct kmem_cache *s)
 	return 0;
 }
 
-struct kmem_cache *find_mergeable(size_t size, size_t align,
+struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 		slab_flags_t flags, const char *name, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
@@ -379,7 +379,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 }
 
 static struct kmem_cache *create_cache(const char *name,
-		size_t object_size, size_t size, size_t align,
+		unsigned int object_size, unsigned int size, unsigned int align,
 		slab_flags_t flags, size_t useroffset,
 		size_t usersize, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
@@ -452,7 +452,8 @@ static struct kmem_cache *create_cache(const char *name,
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create_usercopy(const char *name, size_t size, size_t align,
+kmem_cache_create_usercopy(const char *name,
+		  unsigned int size, unsigned int align,
 		  slab_flags_t flags, size_t useroffset, size_t usersize,
 		  void (*ctor)(void *))
 {
@@ -532,7 +533,7 @@ kmem_cache_create_usercopy(const char *name, size_t size, size_t align,
 EXPORT_SYMBOL(kmem_cache_create_usercopy);
 
 struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
+kmem_cache_create(const char *name, unsigned int size, unsigned int align,
 		slab_flags_t flags, void (*ctor)(void *))
 {
 	return kmem_cache_create_usercopy(name, size, align, flags, 0, 0,
diff --git a/mm/slub.c b/mm/slub.c
index e381728a3751..b2f529a33400 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4241,7 +4241,7 @@ void __init kmem_cache_init_late(void)
 }
 
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s, *c;
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
