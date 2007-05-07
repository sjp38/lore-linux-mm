Message-Id: <20070507212410.856576904@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:55 -0700
From: clameter@sgi.com
Subject: [patch 15/17] SLUB: Add CONFIG_SLUB_DEBUG
Content-Disposition: inline; filename=slub_debug
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_SLUB_DEBUG can be used to switch off the debugging and sysfs components
of SLUB. Thus SLUB will be able to replace SLOB. SLUB can arrange objects in a
denser way than SLOB and the code size should be minimal without debugging and
sysfs support.

Note that CONFIG_SLUB_DEBUG is materially different from CONFIG_SLAB_DEBUG.
CONFIG_SLAB_DEBUG is used to enable slab debugging in SLAB. SLUB enables
debugging via a boot parameter. SLUB debug code should always be present.

CONFIG_SLUB_DEBUG can be modified in the embedded config section.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 init/Kconfig |    9 ++
 mm/slub.c    |  189 +++++++++++++++++++++++++++++++++++------------------------
 2 files changed, 123 insertions(+), 75 deletions(-)

Index: slub/init/Kconfig
===================================================================
--- slub.orig/init/Kconfig	2007-05-07 13:51:41.000000000 -0700
+++ slub/init/Kconfig	2007-05-07 13:57:34.000000000 -0700
@@ -566,6 +566,15 @@ config VM_EVENT_COUNTERS
 	  on EMBEDDED systems.  /proc/vmstat will only show page counts
 	  if VM event counters are disabled.
 
+config SLUB_DEBUG
+	default y
+	bool "Enable SLUB debugging support" if EMBEDDED
+	help
+	  SLUB has extensive debug support features. Disabling these can
+	  result in significant savings in code size. This also disables
+	  SLUB sysfs support. /sys/slab will not exist and there will be
+	  no support for cache validation etc.
+
 choice
 	prompt "Choose SLAB allocator"
 	default SLUB
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:57:30.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:57:34.000000000 -0700
@@ -89,17 +89,25 @@
 
 static inline int SlabDebug(struct page *page)
 {
+#ifdef CONFIG_SLUB_DEBUG
 	return PageError(page);
+#else
+	return 0;
+#endif
 }
 
 static inline void SetSlabDebug(struct page *page)
 {
+#ifdef CONFIG_SLUB_DEBUG
 	SetPageError(page);
+#endif
 }
 
 static inline void ClearSlabDebug(struct page *page)
 {
+#ifdef CONFIG_SLUB_DEBUG
 	ClearPageError(page);
+#endif
 }
 
 /*
@@ -209,7 +217,7 @@ struct track {
 
 enum track_item { TRACK_ALLOC, TRACK_FREE };
 
-#ifdef CONFIG_SYSFS
+#if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
@@ -286,6 +294,14 @@ static inline int slab_index(void *p, st
 	return (p - addr) / s->size;
 }
 
+#ifdef CONFIG_SLUB_DEBUG
+/*
+ * Debug settings:
+ */
+static int slub_debug;
+
+static char *slub_debug_slabs;
+
 /*
  * Object debugging
  */
@@ -823,6 +839,97 @@ static void trace(struct kmem_cache *s, 
 	}
 }
 
+static int __init setup_slub_debug(char *str)
+{
+	if (!str || *str != '=')
+		slub_debug = DEBUG_DEFAULT_FLAGS;
+	else {
+		str++;
+		if (*str == 0 || *str == ',')
+			slub_debug = DEBUG_DEFAULT_FLAGS;
+		else
+		for( ;*str && *str != ','; str++)
+			switch (*str) {
+			case 'f' : case 'F' :
+				slub_debug |= SLAB_DEBUG_FREE;
+				break;
+			case 'z' : case 'Z' :
+				slub_debug |= SLAB_RED_ZONE;
+				break;
+			case 'p' : case 'P' :
+				slub_debug |= SLAB_POISON;
+				break;
+			case 'u' : case 'U' :
+				slub_debug |= SLAB_STORE_USER;
+				break;
+			case 't' : case 'T' :
+				slub_debug |= SLAB_TRACE;
+				break;
+			default:
+				printk(KERN_ERR "slub_debug option '%c' "
+					"unknown. skipped\n",*str);
+			}
+	}
+
+	if (*str == ',')
+		slub_debug_slabs = str + 1;
+	return 1;
+}
+
+__setup("slub_debug", setup_slub_debug);
+
+static void kmem_cache_open_debug_check(struct kmem_cache *s)
+{
+	/*
+	 * The page->offset field is only 16 bit wide. This is an offset
+	 * in units of words from the beginning of an object. If the slab
+	 * size is bigger then we cannot move the free pointer behind the
+	 * object anymore.
+	 *
+	 * On 32 bit platforms the limit is 256k. On 64bit platforms
+	 * the limit is 512k.
+	 *
+	 * Debugging or ctor/dtors may create a need to move the free
+	 * pointer. Fail if this happens.
+	 */
+	if (s->size >= 65535 * sizeof(void *)) {
+		BUG_ON(s->flags & (SLAB_RED_ZONE | SLAB_POISON |
+				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
+		BUG_ON(s->ctor || s->dtor);
+	}
+	else
+		/*
+		 * Enable debugging if selected on the kernel commandline.
+		 */
+		if (slub_debug && (!slub_debug_slabs ||
+		    strncmp(slub_debug_slabs, s->name,
+		    	strlen(slub_debug_slabs)) == 0))
+				s->flags |= slub_debug;
+}
+#else
+
+static inline int alloc_object_checks(struct kmem_cache *s,
+		struct page *page, void *object) { return 0; }
+
+static inline int free_object_checks(struct kmem_cache *s,
+		struct page *page, void *object) { return 0; }
+
+static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct page *page) {}
+static inline void trace(struct kmem_cache *s, struct page *page,
+			void *object, int alloc) {}
+static inline void init_object(struct kmem_cache *s,
+			void *object, int active) {}
+static inline void init_tracking(struct kmem_cache *s, void *object) {}
+static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
+			{ return 1; }
+static inline int check_object(struct kmem_cache *s, struct page *page,
+			void *object, int active) { return 1; }
+static inline void set_track(struct kmem_cache *s, void *object,
+			enum track_item alloc, void *addr) {}
+static inline void kmem_cache_open_debug_check(struct kmem_cache *s) {}
+#define slub_debug 0
+#endif
 /*
  * Slab allocation and freeing
  */
@@ -1453,13 +1560,6 @@ static int slub_min_objects = DEFAULT_MI
 static int slub_nomerge;
 
 /*
- * Debug settings:
- */
-static int slub_debug;
-
-static char *slub_debug_slabs;
-
-/*
  * Calculate the order of allocation given an slab object size.
  *
  * The order of allocation has significant impact on performance and other
@@ -1667,6 +1767,7 @@ static int calculate_sizes(struct kmem_c
 	 */
 	size = ALIGN(size, sizeof(void *));
 
+#ifdef CONFIG_SLUB_DEBUG
 	/*
 	 * If we are Redzoning then check if there is some space between the
 	 * end of the object and the free pointer. If not then add an
@@ -1674,6 +1775,7 @@ static int calculate_sizes(struct kmem_c
 	 */
 	if ((flags & SLAB_RED_ZONE) && size == s->objsize)
 		size += sizeof(void *);
+#endif
 
 	/*
 	 * With that we have determined the number of bytes in actual use
@@ -1681,6 +1783,7 @@ static int calculate_sizes(struct kmem_c
 	 */
 	s->inuse = size;
 
+#ifdef CONFIG_SLUB_DEBUG
 	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
 		s->ctor || s->dtor)) {
 		/*
@@ -1711,6 +1814,7 @@ static int calculate_sizes(struct kmem_c
 		 * of the object.
 		 */
 		size += sizeof(void *);
+#endif
 
 	/*
 	 * Determine the alignment based on various parameters that the
@@ -1760,32 +1864,7 @@ static int kmem_cache_open(struct kmem_c
 	s->objsize = size;
 	s->flags = flags;
 	s->align = align;
-
-	/*
-	 * The page->offset field is only 16 bit wide. This is an offset
-	 * in units of words from the beginning of an object. If the slab
-	 * size is bigger then we cannot move the free pointer behind the
-	 * object anymore.
-	 *
-	 * On 32 bit platforms the limit is 256k. On 64bit platforms
-	 * the limit is 512k.
-	 *
-	 * Debugging or ctor/dtors may create a need to move the free
-	 * pointer. Fail if this happens.
-	 */
-	if (s->size >= 65535 * sizeof(void *)) {
-		BUG_ON(flags & (SLAB_RED_ZONE | SLAB_POISON |
-				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
-		BUG_ON(ctor || dtor);
-	}
-	else
-		/*
-		 * Enable debugging if selected on the kernel commandline.
-		 */
-		if (slub_debug && (!slub_debug_slabs ||
-		    strncmp(slub_debug_slabs, name,
-		    	strlen(slub_debug_slabs)) == 0))
-				s->flags |= slub_debug;
+	kmem_cache_open_debug_check(s);
 
 	if (!calculate_sizes(s))
 		goto error;
@@ -1956,45 +2035,6 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static int __init setup_slub_debug(char *str)
-{
-	if (!str || *str != '=')
-		slub_debug = DEBUG_DEFAULT_FLAGS;
-	else {
-		str++;
-		if (*str == 0 || *str == ',')
-			slub_debug = DEBUG_DEFAULT_FLAGS;
-		else
-		for( ;*str && *str != ','; str++)
-			switch (*str) {
-			case 'f' : case 'F' :
-				slub_debug |= SLAB_DEBUG_FREE;
-				break;
-			case 'z' : case 'Z' :
-				slub_debug |= SLAB_RED_ZONE;
-				break;
-			case 'p' : case 'P' :
-				slub_debug |= SLAB_POISON;
-				break;
-			case 'u' : case 'U' :
-				slub_debug |= SLAB_STORE_USER;
-				break;
-			case 't' : case 'T' :
-				slub_debug |= SLAB_TRACE;
-				break;
-			default:
-				printk(KERN_ERR "slub_debug option '%c' "
-					"unknown. skipped\n",*str);
-			}
-	}
-
-	if (*str == ',')
-		slub_debug_slabs = str + 1;
-	return 1;
-}
-
-__setup("slub_debug", setup_slub_debug);
-
 static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
 		const char *name, int size, gfp_t gfp_flags)
 {
@@ -2487,8 +2527,7 @@ void *__kmalloc_node_track_caller(size_t
 	return slab_alloc(s, gfpflags, node, caller);
 }
 
-#ifdef CONFIG_SYSFS
-
+#if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
 static int validate_slab(struct kmem_cache *s, struct page *page)
 {
 	void *p;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
