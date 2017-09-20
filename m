Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 054706B0284
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x78so6448667pff.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w16sor1214686plk.128.2017.09.20.13.46.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:00 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 01/31] usercopy: Prepare for usercopy whitelisting
Date: Wed, 20 Sep 2017 13:45:07 -0700
Message-Id: <1505940337-79069-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

This patch prepares the slab allocator to handle caches having annotations
(useroffset and usersize) defining usercopy regions.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on
my understanding of the code. Changes or omissions from the original
code are mine and don't reflect the original grsecurity/PaX code.

Currently, hardened usercopy performs dynamic bounds checking on slab
cache objects. This is good, but still leaves a lot of kernel memory
available to be copied to/from userspace in the face of bugs. To further
restrict what memory is available for copying, this creates a way to
whitelist specific areas of a given slab cache object for copying to/from
userspace, allowing much finer granularity of access control. Slab caches
that are never exposed to userspace can declare no whitelist for their
objects, thereby keeping them unavailable to userspace via dynamic copy
operations. (Note, an implicit form of whitelisting is the use of constant
sizes in usercopy operations and get_user()/put_user(); these bypass
hardened usercopy checks since these sizes cannot change at runtime.)

To support this whitelist annotation, usercopy region offset and size
members are added to struct kmem_cache. The slab allocator receives a
new function, kmem_cache_create_usercopy(), that creates a new cache
with a usercopy region defined, suitable for declaring spans of fields
within the objects that get copied to/from userspace.

In this patch, the default kmem_cache_create() marks the entire allocation
as whitelisted, leaving it semantically unchanged. Once all fine-grained
whitelists have been added (in subsequent patches), this will be changed
to a usersize of 0, making caches created with kmem_cache_create() not
copyable to/from userspace.

After the entire usercopy whitelist series is applied, less than 15%
of the slab cache memory remains exposed to potential usercopy bugs
after a fresh boot:

Total Slab Memory:           48074720
Usercopyable Memory:          6367532  13.2%
         task_struct                    0.2%         4480/1630720
         RAW                            0.3%            300/96000
         RAWv6                          2.1%           1408/64768
         ext4_inode_cache               3.0%       269760/8740224
         dentry                        11.1%       585984/5273856
         mm_struct                     29.1%         54912/188448
         kmalloc-8                    100.0%          24576/24576
         kmalloc-16                   100.0%          28672/28672
         kmalloc-32                   100.0%          81920/81920
         kmalloc-192                  100.0%          96768/96768
         kmalloc-128                  100.0%        143360/143360
         names_cache                  100.0%        163840/163840
         kmalloc-64                   100.0%        167936/167936
         kmalloc-256                  100.0%        339968/339968
         kmalloc-512                  100.0%        350720/350720
         kmalloc-96                   100.0%        455616/455616
         kmalloc-8192                 100.0%        655360/655360
         kmalloc-1024                 100.0%        812032/812032
         kmalloc-4096                 100.0%        819200/819200
         kmalloc-2048                 100.0%      1310720/1310720

After some kernel build workloads, the percentage (mainly driven by
dentry and inode caches expanding) drops under 10%:

Total Slab Memory:           95516184
Usercopyable Memory:          8497452   8.8%
         task_struct                    0.2%         4000/1456000
         RAW                            0.3%            300/96000
         RAWv6                          2.1%           1408/64768
         ext4_inode_cache               3.0%     1217280/39439872
         dentry                        11.1%     1623200/14608800
         mm_struct                     29.1%         73216/251264
         kmalloc-8                    100.0%          24576/24576
         kmalloc-16                   100.0%          28672/28672
         kmalloc-32                   100.0%          94208/94208
         kmalloc-192                  100.0%          96768/96768
         kmalloc-128                  100.0%        143360/143360
         names_cache                  100.0%        163840/163840
         kmalloc-64                   100.0%        245760/245760
         kmalloc-256                  100.0%        339968/339968
         kmalloc-512                  100.0%        350720/350720
         kmalloc-96                   100.0%        563520/563520
         kmalloc-8192                 100.0%        655360/655360
         kmalloc-1024                 100.0%        794624/794624
         kmalloc-4096                 100.0%        819200/819200
         kmalloc-2048                 100.0%      1257472/1257472

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split out a few extra kmalloc hunks]
[kees: add field names to function declarations]
[kees: convert BUGs to WARNs and fail closed]
[kees: add attack surface reduction analysis to commit log]
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-xfs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h     | 27 +++++++++++++++++++++------
 include/linux/slab_def.h |  3 +++
 include/linux/slub_def.h |  3 +++
 include/linux/stddef.h   |  2 ++
 mm/slab.c                |  2 +-
 mm/slab.h                |  5 ++++-
 mm/slab_common.c         | 46 ++++++++++++++++++++++++++++++++++++++--------
 mm/slub.c                | 11 +++++++++--
 8 files changed, 81 insertions(+), 18 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 41473df6dfb0..8b6cb384f8b6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -126,9 +126,13 @@ struct mem_cgroup;
 void __init kmem_cache_init(void);
 bool slab_is_available(void);
 
-struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			unsigned long,
-			void (*)(void *));
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+			size_t align, unsigned long flags,
+			void (*ctor)(void *));
+struct kmem_cache *kmem_cache_create_usercopy(const char *name,
+			size_t size, size_t align, unsigned long flags,
+			size_t useroffset, size_t usersize,
+			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
@@ -144,9 +148,20 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *);
  * f.e. add ____cacheline_aligned_in_smp to the struct declaration
  * then the objects will be properly aligned in SMP configurations.
  */
-#define KMEM_CACHE(__struct, __flags) kmem_cache_create(#__struct,\
-		sizeof(struct __struct), __alignof__(struct __struct),\
-		(__flags), NULL)
+#define KMEM_CACHE(__struct, __flags)					\
+		kmem_cache_create(#__struct, sizeof(struct __struct),	\
+			__alignof__(struct __struct), (__flags), NULL)
+
+/*
+ * To whitelist a single field for copying to/from usercopy, use this
+ * macro instead for KMEM_CACHE() above.
+ */
+#define KMEM_CACHE_USERCOPY(__struct, __flags, __field)			\
+		kmem_cache_create_usercopy(#__struct,			\
+			sizeof(struct __struct),			\
+			__alignof__(struct __struct), (__flags),	\
+			offsetof(struct __struct, __field),		\
+			sizeof_field(struct __struct, __field), NULL)
 
 /*
  * Common kmalloc functions provided by all allocators
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
index 0783b622311e..62866a1a767c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -134,6 +134,9 @@ struct kmem_cache {
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
index 04dec48c3ed7..87b6e5e0cdaf 100644
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
index 073362816acc..044755ff9632 100644
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
@@ -97,7 +99,8 @@ extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 			unsigned long flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, unsigned long flags);
+			size_t size, unsigned long flags, size_t useroffset,
+			size_t usersize);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 904a83be82de..36408f5f2a34 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -272,6 +272,9 @@ int slab_unmergeable(struct kmem_cache *s)
 	if (s->ctor)
 		return 1;
 
+	if (s->usersize)
+		return 1;
+
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
@@ -357,12 +360,16 @@ unsigned long calculate_alignment(unsigned long flags,
 
 static struct kmem_cache *create_cache(const char *name,
 		size_t object_size, size_t size, size_t align,
-		unsigned long flags, void (*ctor)(void *),
+		unsigned long flags, size_t useroffset,
+		size_t usersize, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s;
 	int err;
 
+	if (WARN_ON(useroffset + usersize > object_size))
+		useroffset = usersize = 0;
+
 	err = -ENOMEM;
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (!s)
@@ -373,6 +380,8 @@ static struct kmem_cache *create_cache(const char *name,
 	s->size = size;
 	s->align = align;
 	s->ctor = ctor;
+	s->useroffset = useroffset;
+	s->usersize = usersize;
 
 	err = init_memcg_params(s, memcg, root_cache);
 	if (err)
@@ -397,11 +406,13 @@ static struct kmem_cache *create_cache(const char *name,
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
@@ -421,8 +432,9 @@ static struct kmem_cache *create_cache(const char *name,
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
@@ -453,7 +465,13 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	/* Fail closed on bad usersize of useroffset values. */
+	if (WARN_ON(!usersize && useroffset) ||
+	    WARN_ON(size < usersize || size - usersize < useroffset))
+		usersize = useroffset = 0;
+
+	if (!usersize)
+		s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
 		goto out_unlock;
 
@@ -465,7 +483,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	s = create_cache(cache_name, size, size,
 			 calculate_alignment(flags, align, size),
-			 flags, ctor, NULL, NULL);
+			 flags, useroffset, usersize, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree_const(cache_name);
@@ -491,6 +509,15 @@ kmem_cache_create(const char *name, size_t size, size_t align,
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
@@ -603,6 +630,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	s = create_cache(cache_name, root_cache->object_size,
 			 root_cache->size, root_cache->align,
 			 root_cache->flags & CACHE_CREATE_MASK,
+			 root_cache->useroffset, root_cache->usersize,
 			 root_cache->ctor, memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
@@ -870,13 +898,15 @@ bool slab_is_available(void)
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
 
@@ -897,7 +927,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);
 
-	create_boot_cache(s, name, size, flags);
+	create_boot_cache(s, name, size, flags, 0, size);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 	s->refcount = 1;
diff --git a/mm/slub.c b/mm/slub.c
index 163352c537ab..fae637726c44 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4201,7 +4201,7 @@ void __init kmem_cache_init(void)
 	kmem_cache = &boot_kmem_cache;
 
 	create_boot_cache(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
+		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN, 0, 0);
 
 	register_hotmemory_notifier(&slab_memory_callback_nb);
 
@@ -4211,7 +4211,7 @@ void __init kmem_cache_init(void)
 	create_boot_cache(kmem_cache, "kmem_cache",
 			offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *),
-		       SLAB_HWCACHE_ALIGN);
+		       SLAB_HWCACHE_ALIGN, 0, 0);
 
 	kmem_cache = bootstrap(&boot_kmem_cache);
 
@@ -5081,6 +5081,12 @@ static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
 SLAB_ATTR_RO(cache_dma);
 #endif
 
+static ssize_t usersize_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%zu\n", s->usersize);
+}
+SLAB_ATTR_RO(usersize);
+
 static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TYPESAFE_BY_RCU));
@@ -5455,6 +5461,7 @@ static struct attribute *slab_attrs[] = {
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
 #endif
+	&usersize_attr.attr,
 
 	NULL
 };
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
