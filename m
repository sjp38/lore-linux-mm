Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6BA6B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s74so115238437pfe.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id y16si3436936pli.465.2017.06.19.16.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:46 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id x63so60694868pff.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:46 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 01/23] usercopy: Prepare for usercopy whitelisting
Date: Mon, 19 Jun 2017 16:36:15 -0700
Message-Id: <1497915397-93805-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

This patch prepares the slab allocator to handle caches having annotations
(useroffset and usersize) defining usercopy regions.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on
my understanding of the code. Changes or omissions from the original
code are mine and don't reflect the original grsecurity/PaX code.

Currently, hardened usercopy performs dynamic bounds checking on slab
cache objects.  This is good, but still leaves a lot of kernel memory
available to be copied to/from userspace in the face of bugs.  To
further restrict what memory is available for copying, this creates a
way to whitelist specific areas of a given slab cache object for copying
to/from userspace, allowing much finer granularity of access control.
Slab caches that are never exposed to userspace can declare no whitelist
for their objects, thereby keeping them unavailable to userspace via
dynamic copy operations.  (Note, an implicit form of whitelisting is the
use of constant sizes in usercopy operations and get_user()/put_user();
these bypass hardened usercopy checks since these sizes cannot change at
runtime.)

To support this whitelist annotation, usercopy region offset and size
members are added to struct kmem_cache.  The slab allocator receives a
new function that creates a new cache with a usercopy region defined,
suitable for storing objects that get copied to/from userspace.

In this patch, the default kmem_cache_create() marks the entire allocation
as whitelisted. Once all whitelists have been added, this will be changed
back to a usersize of 0.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split out a few extra kmalloc hunks]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h     |  3 +++
 include/linux/slab_def.h |  3 +++
 include/linux/slub_def.h |  3 +++
 include/linux/stddef.h   |  2 ++
 mm/slab.c                |  2 +-
 mm/slab.h                |  5 ++++-
 mm/slab_common.c         | 42 ++++++++++++++++++++++++++++++++++--------
 mm/slub.c                | 11 +++++++++--
 8 files changed, 59 insertions(+), 12 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 04a7f7993e67..a48f54238273 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -129,6 +129,9 @@ bool slab_is_available(void);
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
+struct kmem_cache *kmem_cache_create_usercopy(const char *, size_t, size_t,
+			unsigned long, size_t, size_t,
+			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 4ad2c5a26399..03eef0df8648 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -84,6 +84,9 @@ struct kmem_cache {
 	unsigned int *random_seq;
 #endif
 
+	size_t useroffset;		/* Usercopy region offset */
+	size_t usersize;		/* Usercopy region size */
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 07ef550c6627..05b7343f69eb 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -108,6 +108,9 @@ struct kmem_cache {
 	struct kasan_cache kasan_info;
 #endif
 
+	size_t useroffset;		/* Usercopy region offset */
+	size_t usersize;		/* Usercopy region size */
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/include/linux/stddef.h b/include/linux/stddef.h
index 9c61c7cda936..f00355086fb2 100644
--- a/include/linux/stddef.h
+++ b/include/linux/stddef.h
@@ -18,6 +18,8 @@ enum {
 #define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
 #endif
 
+#define sizeof_field(structure, field) sizeof((((structure *)0)->field))
+
 /**
  * offsetofend(TYPE, MEMBER)
  *
diff --git a/mm/slab.c b/mm/slab.c
index 2a31ee3c5814..cf77f1691588 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1281,7 +1281,7 @@ void __init kmem_cache_init(void)
 	create_boot_cache(kmem_cache, "kmem_cache",
 		offsetof(struct kmem_cache, node) +
 				  nr_node_ids * sizeof(struct kmem_cache_node *),
-				  SLAB_HWCACHE_ALIGN);
+				  SLAB_HWCACHE_ALIGN, 0, 0);
 	list_add(&kmem_cache->list, &slab_caches);
 	slab_state = PARTIAL;
 
diff --git a/mm/slab.h b/mm/slab.h
index 9cfcf099709c..92c0cedb296d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -21,6 +21,8 @@ struct kmem_cache {
 	unsigned int size;	/* The aligned/padded/added on size  */
 	unsigned int align;	/* Alignment as calculated */
 	unsigned long flags;	/* Active flags on the slab */
+	size_t useroffset;	/* Usercopy region offset */
+	size_t usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
@@ -96,7 +98,8 @@ extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 			unsigned long flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, unsigned long flags);
+			size_t size, unsigned long flags, size_t useroffset,
+			size_t usersize);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 01a0fe2eb332..af97465b99e6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -273,6 +273,9 @@ int slab_unmergeable(struct kmem_cache *s)
 	if (s->ctor)
 		return 1;
 
+	if (s->usersize)
+		return 1;
+
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
@@ -358,12 +361,15 @@ unsigned long calculate_alignment(unsigned long flags,
 
 static struct kmem_cache *create_cache(const char *name,
 		size_t object_size, size_t size, size_t align,
-		unsigned long flags, void (*ctor)(void *),
+		unsigned long flags, size_t useroffset,
+		size_t usersize, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s;
 	int err;
 
+	BUG_ON(useroffset + usersize > object_size);
+
 	err = -ENOMEM;
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (!s)
@@ -374,6 +380,8 @@ static struct kmem_cache *create_cache(const char *name,
 	s->size = size;
 	s->align = align;
 	s->ctor = ctor;
+	s->useroffset = useroffset;
+	s->usersize = usersize;
 
 	err = init_memcg_params(s, memcg, root_cache);
 	if (err)
@@ -398,11 +406,13 @@ static struct kmem_cache *create_cache(const char *name,
 }
 
 /*
- * kmem_cache_create - Create a cache.
+ * kmem_cache_create_usercopy - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
  * @size: The size of objects to be created in this cache.
  * @align: The required alignment for the objects.
  * @flags: SLAB flags
+ * @useroffset: Usercopy region offset
+ * @usersize: Usercopy region size
  * @ctor: A constructor for the objects.
  *
  * Returns a ptr to the cache on success, NULL on failure.
@@ -422,8 +432,9 @@ static struct kmem_cache *create_cache(const char *name,
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
-		  unsigned long flags, void (*ctor)(void *))
+kmem_cache_create_usercopy(const char *name, size_t size, size_t align,
+		  unsigned long flags, size_t useroffset, size_t usersize,
+		  void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
 	const char *cache_name;
@@ -454,7 +465,10 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	BUG_ON(!usersize && useroffset);
+	BUG_ON(size < usersize || size - usersize < useroffset);
+	if (!usersize)
+		s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
 		goto out_unlock;
 
@@ -466,7 +480,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	s = create_cache(cache_name, size, size,
 			 calculate_alignment(flags, align, size),
-			 flags, ctor, NULL, NULL);
+			 flags, useroffset, usersize, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree_const(cache_name);
@@ -492,6 +506,15 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	}
 	return s;
 }
+EXPORT_SYMBOL(kmem_cache_create_usercopy);
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t align,
+		unsigned long flags, void (*ctor)(void *))
+{
+	return kmem_cache_create_usercopy(name, size, align, flags, 0, size,
+					  ctor);
+}
 EXPORT_SYMBOL(kmem_cache_create);
 
 static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work)
@@ -604,6 +627,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	s = create_cache(cache_name, root_cache->object_size,
 			 root_cache->size, root_cache->align,
 			 root_cache->flags & CACHE_CREATE_MASK,
+			 root_cache->useroffset, root_cache->usersize,
 			 root_cache->ctor, memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
@@ -871,13 +895,15 @@ bool slab_is_available(void)
 #ifndef CONFIG_SLOB
 /* Create a cache during boot when no slab services are available yet */
 void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
-		unsigned long flags)
+		unsigned long flags, size_t useroffset, size_t usersize)
 {
 	int err;
 
 	s->name = name;
 	s->size = s->object_size = size;
 	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
+	s->useroffset = useroffset;
+	s->usersize = usersize;
 
 	slab_init_memcg_params(s);
 
@@ -898,7 +924,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);
 
-	create_boot_cache(s, name, size, flags);
+	create_boot_cache(s, name, size, flags, 0, size);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 	s->refcount = 1;
diff --git a/mm/slub.c b/mm/slub.c
index 7449593fca72..b8cbbc31b005 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4164,7 +4164,7 @@ void __init kmem_cache_init(void)
 	kmem_cache = &boot_kmem_cache;
 
 	create_boot_cache(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
+		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN, 0, 0);
 
 	register_hotmemory_notifier(&slab_memory_callback_nb);
 
@@ -4174,7 +4174,7 @@ void __init kmem_cache_init(void)
 	create_boot_cache(kmem_cache, "kmem_cache",
 			offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *),
-		       SLAB_HWCACHE_ALIGN);
+		       SLAB_HWCACHE_ALIGN, 0, 0);
 
 	kmem_cache = bootstrap(&boot_kmem_cache);
 
@@ -5040,6 +5040,12 @@ static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
 SLAB_ATTR_RO(cache_dma);
 #endif
 
+static ssize_t usercopy_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!s->usersize);
+}
+SLAB_ATTR_RO(usercopy);
+
 static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TYPESAFE_BY_RCU));
@@ -5414,6 +5420,7 @@ static struct attribute *slab_attrs[] = {
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
 #endif
+	&usercopy_attr.attr,
 
 	NULL
 };
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
