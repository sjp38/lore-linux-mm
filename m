Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1286B0261
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:14 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v8so12664309wrd.21
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f132sor1928719wmd.43.2017.11.23.14.17.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:13 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 05/23] slab: kmem_cache_create() only works with 32-bit sizes
Date: Fri, 24 Nov 2017 01:16:10 +0300
Message-Id: <20171123221628.8313-5-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

struct kmem_cache::size and ::align were always 32-bit.

Out of curiosity I created 4GB kmem_cache, it oopsed with division by 0.
kmem_cache_create(1UL<<32+1) created 1-byte cache as expected.

size_t doesn't work and never did.

Space savings (all cases where cache size is not known at compile time):

	add/remove: 0/0 grow/shrink: 3/21 up/down: 7/-61 (-54)
	Function                                     old     new   delta
	ext4_groupinfo_create_slab                   193     197      +4
	find_mergeable                               281     283      +2
	kmem_cache_create                            638     639      +1
	tipc_server_start                            771     770      -1
	skd_construct                               2616    2615      -1
	ovs_flow_init                                122     121      -1
	init_cifs                                   1271    1270      -1
	fork_init                                    284     283      -1
	ecryptfs_init                                405     404      -1
	dm_bufio_client_create                      1009    1008      -1
	kvm_init                                     692     690      -2
	elv_register                                 398     396      -2
	calculate_alignment                           60      58      -2
	verity_fec_ctr                               875     872      -3
	sg_pool_init                                 192     189      -3
	init_bio                                     203     200      -3
	early_amd_iommu_init                        2492    2489      -3
	__kmem_cache_alias                           164     161      -3
	jbd2_journal_load                            842     838      -4
	ccid_kmem_cache_create                       106     102      -4
	setup_conf                                  5027    5022      -5
	resize_stripes                              1607    1602      -5
	copy_pid_ns                                  825     819      -6
	create_boot_cache                            169     160      -9

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h |  2 +-
 mm/slab.c            |  2 +-
 mm/slab.h            | 10 +++++-----
 mm/slab_common.c     | 16 ++++++++--------
 mm/slub.c            |  2 +-
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index f3e4aca74406..00a2b48d9bae 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -135,7 +135,7 @@ struct mem_cgroup;
 void __init kmem_cache_init(void);
 bool slab_is_available(void);
 
-struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
+struct kmem_cache *kmem_cache_create(const char *, unsigned int, unsigned int,
 			slab_flags_t,
 			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
diff --git a/mm/slab.c b/mm/slab.c
index 183e996dde5f..78fd096362da 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1882,7 +1882,7 @@ slab_flags_t kmem_cache_flags(unsigned long object_size,
 }
 
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *cachep;
diff --git a/mm/slab.h b/mm/slab.h
index 6bbb7b5d1706..facaf949f727 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -78,8 +78,8 @@ extern const struct kmalloc_info_struct {
 	unsigned int size;
 } kmalloc_info[];
 
-unsigned long calculate_alignment(slab_flags_t flags,
-		unsigned long align, unsigned long size);
+unsigned int calculate_alignment(slab_flags_t flags,
+		unsigned int align, unsigned int size);
 
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
@@ -100,11 +100,11 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
 			unsigned int size, slab_flags_t flags);
 
 int slab_unmergeable(struct kmem_cache *s);
-struct kmem_cache *find_mergeable(size_t size, size_t align,
+struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 		slab_flags_t flags, const char *name, void (*ctor)(void *));
 #ifndef CONFIG_SLOB
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *));
 
 slab_flags_t kmem_cache_flags(unsigned long object_size,
@@ -112,7 +112,7 @@ slab_flags_t kmem_cache_flags(unsigned long object_size,
 	void (*ctor)(void *));
 #else
 static inline struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 { return NULL; }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9c8c55e1e0e3..1d46602c881e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -73,7 +73,7 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
 EXPORT_SYMBOL(kmem_cache_size);
 
 #ifdef CONFIG_DEBUG_VM
-static int kmem_cache_sanity_check(const char *name, size_t size)
+static int kmem_cache_sanity_check(const char *name, unsigned int size)
 {
 	struct kmem_cache *s = NULL;
 
@@ -104,7 +104,7 @@ static int kmem_cache_sanity_check(const char *name, size_t size)
 	return 0;
 }
 #else
-static inline int kmem_cache_sanity_check(const char *name, size_t size)
+static inline int kmem_cache_sanity_check(const char *name, unsigned int size)
 {
 	return 0;
 }
@@ -290,7 +290,7 @@ int slab_unmergeable(struct kmem_cache *s)
 	return 0;
 }
 
-struct kmem_cache *find_mergeable(size_t size, size_t align,
+struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 		slab_flags_t flags, const char *name, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
@@ -341,8 +341,8 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
  * Figure out what the alignment of the objects will be given a set of
  * flags, a user specified alignment and the size of the objects.
  */
-unsigned long calculate_alignment(slab_flags_t flags,
-		unsigned long align, unsigned long size)
+unsigned int calculate_alignment(slab_flags_t flags,
+		unsigned int align, unsigned int size)
 {
 	/*
 	 * If the user wants hardware cache aligned objects then follow that
@@ -352,7 +352,7 @@ unsigned long calculate_alignment(slab_flags_t flags,
 	 * alignment though. If that is greater then use it.
 	 */
 	if (flags & SLAB_HWCACHE_ALIGN) {
-		unsigned long ralign = cache_line_size();
+		unsigned int ralign = cache_line_size();
 		while (size <= ralign / 2)
 			ralign /= 2;
 		align = max(align, ralign);
@@ -365,7 +365,7 @@ unsigned long calculate_alignment(slab_flags_t flags,
 }
 
 static struct kmem_cache *create_cache(const char *name,
-		size_t object_size, size_t size, size_t align,
+		unsigned int object_size, unsigned int size, unsigned int align,
 		slab_flags_t flags, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
@@ -430,7 +430,7 @@ static struct kmem_cache *create_cache(const char *name,
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
+kmem_cache_create(const char *name, unsigned int size, unsigned int align,
 		  slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5a35fb..e653c4b51403 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4223,7 +4223,7 @@ void __init kmem_cache_init_late(void)
 }
 
 struct kmem_cache *
-__kmem_cache_alias(const char *name, size_t size, size_t align,
+__kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s, *c;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
