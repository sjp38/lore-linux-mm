From: clameter@sgi.com
Subject: [patch 01/10] SLUB: add support for kmem_cache_ops
Date: Fri, 18 May 2007 11:10:41 -0700
Message-ID: <20070518181118.828853654@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758569AbXERSMB@vger.kernel.org>
Content-Disposition: inline; filename=kmem_cache_ops
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

We use the parameter formerly used by the destructor to pass an optional
pointer to a kmem_cache_ops structure to kmem_cache_create.

kmem_cache_ops is created as empty. Later patches populate kmem_cache_ops.

Create a KMEM_CACHE_OPS macro that allows the specification of a the
kmem_cache_ops.

Code to handle kmem_cache_ops is added to SLUB. SLAB and SLOB are updated
to be able to take a kmem_cache_ops structure but will ignore it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h     |   13 +++++++++----
 include/linux/slub_def.h |    1 +
 mm/slab.c                |    6 +++---
 mm/slob.c                |    2 +-
 mm/slub.c                |   44 ++++++++++++++++++++++++++++++--------------
 5 files changed, 44 insertions(+), 22 deletions(-)

Index: slub/include/linux/slab.h
===================================================================
--- slub.orig/include/linux/slab.h	2007-05-15 21:19:51.000000000 -0700
+++ slub/include/linux/slab.h	2007-05-15 21:27:07.000000000 -0700
@@ -38,10 +38,13 @@ typedef struct kmem_cache kmem_cache_t _
 void __init kmem_cache_init(void);
 int slab_is_available(void);
 
+struct kmem_cache_ops {
+};
+
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *, struct kmem_cache *, unsigned long),
-			void (*)(void *, struct kmem_cache *, unsigned long));
+			const struct kmem_cache_ops *s);
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
@@ -59,9 +62,11 @@ int kmem_ptr_validate(struct kmem_cache 
  * f.e. add ____cacheline_aligned_in_smp to the struct declaration
  * then the objects will be properly aligned in SMP configurations.
  */
-#define KMEM_CACHE(__struct, __flags) kmem_cache_create(#__struct,\
-		sizeof(struct __struct), __alignof__(struct __struct),\
-		(__flags), NULL, NULL)
+#define KMEM_CACHE_OPS(__struct, __flags, __ops) \
+	kmem_cache_create(#__struct, sizeof(struct __struct), \
+	__alignof__(struct __struct), (__flags), NULL, (__ops))
+
+#define KMEM_CACHE(__struct, __flags) KMEM_CACHE_OPS(__struct, __flags, NULL)
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-15 21:25:46.000000000 -0700
+++ slub/mm/slub.c	2007-05-15 21:29:36.000000000 -0700
@@ -294,6 +294,9 @@ static inline int check_valid_pointer(st
 	return 1;
 }
 
+struct kmem_cache_ops slub_default_ops = {
+};
+
 /*
  * Slow version of get and set free pointer.
  *
@@ -2003,11 +2006,13 @@ static int calculate_sizes(struct kmem_c
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		const struct kmem_cache_ops *ops)
 {
 	memset(s, 0, kmem_size);
 	s->name = name;
 	s->ctor = ctor;
+	s->ops = ops;
 	s->objsize = size;
 	s->flags = flags;
 	s->align = align;
@@ -2191,7 +2196,7 @@ static struct kmem_cache *create_kmalloc
 
 	down_write(&slub_lock);
 	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
-			flags, NULL))
+			flags, NULL, &slub_default_ops))
 		goto panic;
 
 	list_add(&s->list, &slab_caches);
@@ -2505,12 +2510,16 @@ static int slab_unmergeable(struct kmem_
 	if (s->ctor)
 		return 1;
 
+	if (s->ops != &slub_default_ops)
+		return 1;
+
 	return 0;
 }
 
 static struct kmem_cache *find_mergeable(size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		const struct kmem_cache_ops *ops)
 {
 	struct list_head *h;
 
@@ -2520,6 +2529,9 @@ static struct kmem_cache *find_mergeable
 	if (ctor)
 		return NULL;
 
+	if (ops != &slub_default_ops)
+		return NULL;
+
 	size = ALIGN(size, sizeof(void *));
 	align = calculate_alignment(flags, align, size);
 	size = ALIGN(size, align);
@@ -2555,13 +2567,15 @@ static struct kmem_cache *find_mergeable
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags,
 		void (*ctor)(void *, struct kmem_cache *, unsigned long),
-		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+		const struct kmem_cache_ops *ops)
 {
 	struct kmem_cache *s;
 
-	BUG_ON(dtor);
+	if (!ops)
+		ops = &slub_default_ops;
+
 	down_write(&slub_lock);
-	s = find_mergeable(size, align, flags, ctor);
+	s = find_mergeable(size, align, flags, ctor, ops);
 	if (s) {
 		s->refcount++;
 		/*
@@ -2575,7 +2589,7 @@ struct kmem_cache *kmem_cache_create(con
 	} else {
 		s = kmalloc(kmem_size, GFP_KERNEL);
 		if (s && kmem_cache_open(s, GFP_KERNEL, name,
-				size, align, flags, ctor)) {
+				size, align, flags, ctor, ops)) {
 			if (sysfs_slab_add(s)) {
 				kfree(s);
 				goto err;
@@ -3206,16 +3220,18 @@ static ssize_t order_show(struct kmem_ca
 }
 SLAB_ATTR_RO(order);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
-	if (s->ctor) {
-		int n = sprint_symbol(buf, (unsigned long)s->ctor);
+	int x = 0;
 
-		return n + sprintf(buf + n, "\n");
+	if (s->ctor) {
+		x += sprintf(buf + x, "ctor : ");
+		x += sprint_symbol(buf + x, (unsigned long)s->ctor);
+		x += sprintf(buf + x, "\n");
 	}
-	return 0;
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -3447,7 +3463,7 @@ static struct attribute * slab_attrs[] =
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,
Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-15 21:21:27.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-15 21:26:13.000000000 -0700
@@ -40,6 +40,7 @@ struct kmem_cache {
 	int objects;		/* Number of objects in slab */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	const struct kmem_cache_ops *ops;
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */
Index: slub/mm/slab.c
===================================================================
--- slub.orig/mm/slab.c	2007-05-15 21:19:51.000000000 -0700
+++ slub/mm/slab.c	2007-05-15 21:26:13.000000000 -0700
@@ -2100,7 +2100,7 @@ static int setup_cpu_cache(struct kmem_c
  * @align: The required alignment for the objects.
  * @flags: SLAB flags
  * @ctor: A constructor for the objects.
- * @dtor: A destructor for the objects (not implemented anymore).
+ * @ops: A kmem_cache_ops structure (ignored).
  *
  * Returns a ptr to the cache on success, NULL on failure.
  * Cannot be called within a int, but can be interrupted.
@@ -2126,7 +2126,7 @@ struct kmem_cache *
 kmem_cache_create (const char *name, size_t size, size_t align,
 	unsigned long flags,
 	void (*ctor)(void*, struct kmem_cache *, unsigned long),
-	void (*dtor)(void*, struct kmem_cache *, unsigned long))
+	const struct kmem_cache_ops *ops)
 {
 	size_t left_over, slab_size, ralign;
 	struct kmem_cache *cachep = NULL, *pc;
@@ -2135,7 +2135,7 @@ kmem_cache_create (const char *name, siz
 	 * Sanity checks... these are all serious usage bugs.
 	 */
 	if (!name || in_interrupt() || (size < BYTES_PER_WORD) ||
-	    size > KMALLOC_MAX_SIZE || dtor) {
+	    size > KMALLOC_MAX_SIZE) {
 		printk(KERN_ERR "%s: Early error in slab %s\n", __FUNCTION__,
 				name);
 		BUG();
Index: slub/mm/slob.c
===================================================================
--- slub.orig/mm/slob.c	2007-05-15 21:17:15.000000000 -0700
+++ slub/mm/slob.c	2007-05-15 21:28:06.000000000 -0700
@@ -285,7 +285,7 @@ struct kmem_cache {
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags,
 	void (*ctor)(void*, struct kmem_cache *, unsigned long),
-	void (*dtor)(void*, struct kmem_cache *, unsigned long))
+	const struct kmem_cache_ops *o)
 {
 	struct kmem_cache *c;
 

-- 
