Message-Id: <20070504221708.363027097@sgi.com>
References: <20070504221555.642061626@sgi.com>
Date: Fri, 04 May 2007 15:15:56 -0700
From: clameter@sgi.com
Subject: [RFC 1/3] SLUB: slab_ops instead of constructors / destructors
Content-Disposition: inline; filename=slabapic23
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch gets rid constructors and destructors and replaces them
with a slab operations structure that is passed into SLUB.

For backward compatibility we provide a kmem_cache_create() emulation
that can construct a slab operations structure on the fly.

The new API's to create slabs are:

Without any callbacks:

slabhandle = KMEM_CACHE(<struct>, <flags>)

Creates a slab based on the structure definition with the structure
alignment, size and name. This is cleaner because the name showing up
in /sys/slab/xxx will be the structure name. One can search the source
for the name. The common alignment attributs to the struct can control
slab alignmnet.

Note: SLAB_HWCACHE_ALIGN is *not* supported as a flag. The flags do
*not* specify alignments. The alignment is done to the structure and
please nowhere else.

Create a slabcache with slab_ops (please use only for special slabs):

KMEM_CACHE_OPS(<struct>, <flags>, <slab_ops>)

Old kmem_cache_create() support:

kmem_cache_create alone still accepts the specification of SLAB_HWCACHE_ALIGN
*if* there is no other alignment specified. In that case kmem_cache_create
will generate a proper alignment depending on the size of the structure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h     |   60 ++++++++++++++++++++++++++++++------
 include/linux/slub_def.h |    3 -
 mm/slub.c                |   77 +++++++++++++++++------------------------------
 3 files changed, 80 insertions(+), 60 deletions(-)

Index: slub/include/linux/slab.h
===================================================================
--- slub.orig/include/linux/slab.h	2007-05-03 20:53:00.000000000 -0700
+++ slub/include/linux/slab.h	2007-05-04 02:38:38.000000000 -0700
@@ -23,7 +23,6 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
-#define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
@@ -32,19 +31,21 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
-/* Flags passed to a constructor functions */
-#define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
-
 /*
  * struct kmem_cache related prototypes
  */
 void __init kmem_cache_init(void);
 int slab_is_available(void);
 
-struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			unsigned long,
-			void (*)(void *, struct kmem_cache *, unsigned long),
-			void (*)(void *, struct kmem_cache *, unsigned long));
+struct slab_ops {
+	/* FIXME: ctor should only take the object as an argument. */
+	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	/* FIXME: Remove all destructors ? */
+	void (*dtor)(void *, struct kmem_cache *, unsigned long);
+};
+
+struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
+	unsigned long, struct slab_ops *s);
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
@@ -62,9 +63,14 @@ int kmem_ptr_validate(struct kmem_cache 
  * f.e. add ____cacheline_aligned_in_smp to the struct declaration
  * then the objects will be properly aligned in SMP configurations.
  */
-#define KMEM_CACHE(__struct, __flags) kmem_cache_create(#__struct,\
+#define KMEM_CACHE(__struct, __flags) __kmem_cache_create(#__struct,\
 		sizeof(struct __struct), __alignof__(struct __struct),\
-		(__flags), NULL, NULL)
+		(__flags), NULL)
+
+#define KMEM_CACHE_OPS(__struct, __flags, __ops) \
+	__kmem_cache_create(#__struct, sizeof(struct __struct), \
+	__alignof__(struct __struct), (__flags), (__ops))
+
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
@@ -236,6 +242,40 @@ extern void *__kmalloc_node_track_caller
 extern const struct seq_operations slabinfo_op;
 ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
 
+/*
+ * Legacy functions
+ *
+ * The sole reason that these definitions are here is because of their
+ * frequent use. Remove when all call sites have been updated.
+ */
+#define SLAB_HWCACHE_ALIGN	0x8000000000UL
+#define SLAB_CTOR_CONSTRUCTOR	0x001UL
+
+static inline struct kmem_cache *kmem_cache_create(const char *s,
+		size_t size, size_t align, unsigned long flags,
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	struct slab_ops *so = NULL;
+
+	if ((flags & SLAB_HWCACHE_ALIGN) && size > L1_CACHE_BYTES / 2) {
+		/* Clear the align flag. It is no longer supported */
+		flags &= ~SLAB_HWCACHE_ALIGN;
+
+		/* Do not allow conflicting alignment specificiations */
+		BUG_ON(align);
+
+		/* And set the cacheline alignment */
+		align = L1_CACHE_BYTES;
+	}
+	if (ctor || dtor) {
+		so = kzalloc(sizeof(struct slab_ops), GFP_KERNEL);
+		so->ctor = ctor;
+		so->dtor = dtor;
+	}
+	return  __kmem_cache_create(s, size, align, flags, so);
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SLAB_H */
 
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-04 02:23:34.000000000 -0700
+++ slub/mm/slub.c	2007-05-04 02:40:13.000000000 -0700
@@ -209,6 +209,11 @@ static inline struct kmem_cache_node *ge
 #endif
 }
 
+struct slab_ops default_slab_ops = {
+	NULL,
+	NULL
+};
+
 /*
  * Object debugging
  */
@@ -809,8 +814,8 @@ static void setup_object(struct kmem_cac
 		init_tracking(s, object);
 	}
 
-	if (unlikely(s->ctor))
-		s->ctor(object, s, SLAB_CTOR_CONSTRUCTOR);
+	if (unlikely(s->slab_ops->ctor))
+		s->slab_ops->ctor(object, s, SLAB_CTOR_CONSTRUCTOR);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -867,16 +872,18 @@ out:
 static void __free_slab(struct kmem_cache *s, struct page *page)
 {
 	int pages = 1 << s->order;
+	void (*dtor)(void *, struct kmem_cache *, unsigned long) =
+		s->slab_ops->dtor;
 
-	if (unlikely(PageError(page) || s->dtor)) {
+	if (unlikely(PageError(page) || dtor)) {
 		void *start = page_address(page);
 		void *end = start + (pages << PAGE_SHIFT);
 		void *p;
 
 		slab_pad_check(s, page);
 		for (p = start; p <= end - s->size; p += s->size) {
-			if (s->dtor)
-				s->dtor(p, s, 0);
+			if (dtor)
+				dtor(p, s, 0);
 			check_object(s, page, p, 0);
 		}
 	}
@@ -1618,7 +1625,7 @@ static int calculate_sizes(struct kmem_c
 	 * then we should never poison the object itself.
 	 */
 	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
-			!s->ctor && !s->dtor)
+			s->slab_ops->ctor && !s->slab_ops->dtor)
 		s->flags |= __OBJECT_POISON;
 	else
 		s->flags &= ~__OBJECT_POISON;
@@ -1647,7 +1654,7 @@ static int calculate_sizes(struct kmem_c
 	s->inuse = size;
 
 	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
-		s->ctor || s->dtor)) {
+		s->slab_ops->ctor || s->slab_ops->dtor)) {
 		/*
 		 * Relocate free pointer after the object if it is not
 		 * permitted to overwrite the first word of the object on
@@ -1731,13 +1738,11 @@ static int __init finish_bootstrap(void)
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long),
-		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+		struct slab_ops *slab_ops)
 {
 	memset(s, 0, kmem_size);
 	s->name = name;
-	s->ctor = ctor;
-	s->dtor = dtor;
+	s->slab_ops = slab_ops;
 	s->objsize = size;
 	s->flags = flags;
 	s->align = align;
@@ -1757,7 +1762,7 @@ static int kmem_cache_open(struct kmem_c
 	if (s->size >= 65535 * sizeof(void *)) {
 		BUG_ON(flags & (SLAB_RED_ZONE | SLAB_POISON |
 				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
-		BUG_ON(ctor || dtor);
+		BUG_ON(slab_ops->ctor || slab_ops->dtor);
 	}
 	else
 		/*
@@ -1992,7 +1997,7 @@ static struct kmem_cache *create_kmalloc
 
 	down_write(&slub_lock);
 	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
-			flags, NULL, NULL))
+			flags, &default_slab_ops))
 		goto panic;
 
 	list_add(&s->list, &slab_caches);
@@ -2313,23 +2318,21 @@ static int slab_unmergeable(struct kmem_
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
-	if (s->ctor || s->dtor)
+	if (s->slab_ops != &default_slab_ops)
 		return 1;
 
 	return 0;
 }
 
 static struct kmem_cache *find_mergeable(size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long),
-		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+		size_t align, unsigned long flags, struct slab_ops *slab_ops)
 {
 	struct list_head *h;
 
 	if (slub_nomerge || (flags & SLUB_NEVER_MERGE))
 		return NULL;
 
-	if (ctor || dtor)
+	if (slab_ops != &default_slab_ops)
 		return NULL;
 
 	size = ALIGN(size, sizeof(void *));
@@ -2364,15 +2367,17 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long),
-		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+		struct slab_ops *slab_ops)
 {
 	struct kmem_cache *s;
 
+	if (!slab_ops)
+		slab_ops = &default_slab_ops;
+
 	down_write(&slub_lock);
-	s = find_mergeable(size, align, flags, dtor, ctor);
+	s = find_mergeable(size, align, flags, slab_ops);
 	if (s) {
 		s->refcount++;
 		/*
@@ -2386,7 +2391,7 @@ struct kmem_cache *kmem_cache_create(con
 	} else {
 		s = kmalloc(kmem_size, GFP_KERNEL);
 		if (s && kmem_cache_open(s, GFP_KERNEL, name,
-				size, align, flags, ctor, dtor)) {
+				size, align, flags, slab_ops)) {
 			if (sysfs_slab_add(s)) {
 				kfree(s);
 				goto err;
@@ -2406,7 +2411,7 @@ err:
 		s = NULL;
 	return s;
 }
-EXPORT_SYMBOL(kmem_cache_create);
+EXPORT_SYMBOL(__kmem_cache_create);
 
 void *kmem_cache_zalloc(struct kmem_cache *s, gfp_t flags)
 {
@@ -2961,28 +2966,6 @@ static ssize_t order_show(struct kmem_ca
 }
 SLAB_ATTR_RO(order);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
-{
-	if (s->ctor) {
-		int n = sprint_symbol(buf, (unsigned long)s->ctor);
-
-		return n + sprintf(buf + n, "\n");
-	}
-	return 0;
-}
-SLAB_ATTR_RO(ctor);
-
-static ssize_t dtor_show(struct kmem_cache *s, char *buf)
-{
-	if (s->dtor) {
-		int n = sprint_symbol(buf, (unsigned long)s->dtor);
-
-		return n + sprintf(buf + n, "\n");
-	}
-	return 0;
-}
-SLAB_ATTR_RO(dtor);
-
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", s->refcount - 1);
@@ -3213,8 +3196,6 @@ static struct attribute * slab_attrs[] =
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
-	&dtor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,
Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-04 02:23:51.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-04 02:24:27.000000000 -0700
@@ -39,8 +39,7 @@ struct kmem_cache {
 	/* Allocation and freeing of slabs */
 	int objects;		/* Number of objects in slab */
 	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(void *, struct kmem_cache *, unsigned long);
-	void (*dtor)(void *, struct kmem_cache *, unsigned long);
+	struct slab_ops *slab_ops;
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
