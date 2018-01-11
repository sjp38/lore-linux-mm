Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 053E16B026A
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e28so1632455pgn.23
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m73sor4582609pfj.18.2018.01.10.18.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:29 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 06/38] usercopy: Prepare for usercopy whitelisting
Date: Wed, 10 Jan 2018 18:02:38 -0800
Message-Id: <1515636190-24061-7-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

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
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-xfs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slab.h     | 27 +++++++++++++++++++++------
 include/linux/slab_def.h |  3 +++
 include/linux/slub_def.h |  3 +++
 mm/slab.c                |  2 +-
 mm/slab.h                |  5 ++++-
 mm/slab_common.c         | 46 ++++++++++++++++++++++++++++++++++++++--------
 mm/slub.c                | 11 +++++++++--
 7 files changed, 79 insertions(+), 18 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2dbeccdcb76b..8bf14d9762ec 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -135,9 +135,13 @@ struct mem_cgroup;
 void __init kmem_cache_init(void);
 bool slab_is_available(void);
 
-struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			slab_flags_t,
-			void (*)(void *));
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+			size_t align, slab_flags_t flags,
+			void (*ctor)(void *));
+struct kmem_cache *kmem_cache_create_usercopy(const char *name,
+			size_t size, size_t align, slab_flags_t flags,
+			size_t useroffset, size_t usersize,
+			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
@@ -153,9 +157,20 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *);
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
index 072e46e9e1d5..7385547c04b1 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -85,6 +85,9 @@ struct kmem_cache {
 	unsigned int *random_seq;
 #endif
 
+	size_t useroffset;		/* Usercopy region offset */
+	size_t usersize;		/* Usercopy region size */
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 0adae162dc8f..8ad99c47b19c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -135,6 +135,9 @@ struct kmem_cache {
 	struct kasan_cache kasan_info;
 #endif
 
+	size_t useroffset;		/* Usercopy region offset */
+	size_t usersize;		/* Usercopy region size */
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/mm/slab.c b/mm/slab.c
index b2beb2cc15e2..47acfe54e1ae 100644
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
index 7d29e69ac310..1897991df3fa 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -22,6 +22,8 @@ struct kmem_cache {
 	unsigned int size;	/* The aligned/padded/added on size  */
 	unsigned int align;	/* Alignment as calculated */
 	slab_flags_t flags;	/* Active flags on the slab */
+	size_t useroffset;	/* Usercopy region offset */
+	size_t usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
@@ -97,7 +99,8 @@ int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 			slab_flags_t flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, slab_flags_t flags);
+			size_t size, slab_flags_t flags, size_t useroffset,
+			size_t usersize);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c8cb36774ba1..fc3e66bdce75 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -281,6 +281,9 @@ int slab_unmergeable(struct kmem_cache *s)
 	if (s->ctor)
 		return 1;
 
+	if (s->usersize)
+		return 1;
+
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
@@ -366,12 +369,16 @@ unsigned long calculate_alignment(slab_flags_t flags,
 
 static struct kmem_cache *create_cache(const char *name,
 		size_t object_size, size_t size, size_t align,
-		slab_flags_t flags, void (*ctor)(void *),
+		slab_flags_t flags, size_t useroffset,
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
@@ -382,6 +389,8 @@ static struct kmem_cache *create_cache(const char *name,
 	s->size = size;
 	s->align = align;
 	s->ctor = ctor;
+	s->useroffset = useroffset;
+	s->usersize = usersize;
 
 	err = init_memcg_params(s, memcg, root_cache);
 	if (err)
@@ -406,11 +415,13 @@ static struct kmem_cache *create_cache(const char *name,
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
@@ -430,8 +441,9 @@ static struct kmem_cache *create_cache(const char *name,
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
-		  slab_flags_t flags, void (*ctor)(void *))
+kmem_cache_create_usercopy(const char *name, size_t size, size_t align,
+		  slab_flags_t flags, size_t useroffset, size_t usersize,
+		  void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
 	const char *cache_name;
@@ -462,7 +474,13 @@ kmem_cache_create(const char *name, size_t size, size_t align,
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
 
@@ -474,7 +492,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	s = create_cache(cache_name, size, size,
 			 calculate_alignment(flags, align, size),
-			 flags, ctor, NULL, NULL);
+			 flags, useroffset, usersize, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree_const(cache_name);
@@ -500,6 +518,15 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	}
 	return s;
 }
+EXPORT_SYMBOL(kmem_cache_create_usercopy);
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t align,
+		slab_flags_t flags, void (*ctor)(void *))
+{
+	return kmem_cache_create_usercopy(name, size, align, flags, 0, size,
+					  ctor);
+}
 EXPORT_SYMBOL(kmem_cache_create);
 
 static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work)
@@ -612,6 +639,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	s = create_cache(cache_name, root_cache->object_size,
 			 root_cache->size, root_cache->align,
 			 root_cache->flags & CACHE_CREATE_MASK,
+			 root_cache->useroffset, root_cache->usersize,
 			 root_cache->ctor, memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
@@ -879,13 +907,15 @@ bool slab_is_available(void)
 #ifndef CONFIG_SLOB
 /* Create a cache during boot when no slab services are available yet */
 void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
-		slab_flags_t flags)
+		slab_flags_t flags, size_t useroffset, size_t usersize)
 {
 	int err;
 
 	s->name = name;
 	s->size = s->object_size = size;
 	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
+	s->useroffset = useroffset;
+	s->usersize = usersize;
 
 	slab_init_memcg_params(s);
 
@@ -906,7 +936,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);
 
-	create_boot_cache(s, name, size, flags);
+	create_boot_cache(s, name, size, flags, 0, size);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 	s->refcount = 1;
diff --git a/mm/slub.c b/mm/slub.c
index bcd22332300a..f40a57164dd6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4183,7 +4183,7 @@ void __init kmem_cache_init(void)
 	kmem_cache = &boot_kmem_cache;
 
 	create_boot_cache(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
+		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN, 0, 0);
 
 	register_hotmemory_notifier(&slab_memory_callback_nb);
 
@@ -4193,7 +4193,7 @@ void __init kmem_cache_init(void)
 	create_boot_cache(kmem_cache, "kmem_cache",
 			offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *),
-		       SLAB_HWCACHE_ALIGN);
+		       SLAB_HWCACHE_ALIGN, 0, 0);
 
 	kmem_cache = bootstrap(&boot_kmem_cache);
 
@@ -5063,6 +5063,12 @@ static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
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
@@ -5437,6 +5443,7 @@ static struct attribute *slab_attrs[] = {
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
