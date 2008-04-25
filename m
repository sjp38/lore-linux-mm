Date: Fri, 25 Apr 2008 12:23:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slub: #ifdef simplification
Message-ID: <Pine.LNX.4.64.0804251222570.5971@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If we make SLUB_DEBUG depend on SYSFS then we can simplify some
#ifdefs and avoid others.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 init/Kconfig |    2 +-
 mm/slub.c    |    6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2008-04-24 23:42:27.229890443 -0700
+++ linux-2.6/init/Kconfig	2008-04-24 23:55:07.371187159 -0700
@@ -701,7 +701,7 @@ config VM_EVENT_COUNTERS
 config SLUB_DEBUG
 	default y
 	bool "Enable SLUB debugging support" if EMBEDDED
-	depends on SLUB
+	depends on SLUB && SYSFS
 	help
 	  SLUB has extensive debug support features. Disabling these can
 	  result in significant savings in code size. This also disables
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-04-24 23:42:57.729889540 -0700
+++ linux-2.6/mm/slub.c	2008-04-24 23:53:47.088164300 -0700
@@ -239,7 +239,7 @@ struct track {
 
 enum track_item { TRACK_ALLOC, TRACK_FREE };
 
-#if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
+#ifdef CONFIG_SLUB_DEBUG
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
@@ -3461,7 +3461,7 @@ void *__kmalloc_node_track_caller(size_t
 	return slab_alloc(s, gfpflags, node, caller);
 }
 
-#if (defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)) || defined(CONFIG_SLABINFO)
+#ifdef CONFIG_SLUB_DEBUG
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -3490,9 +3490,7 @@ static int count_free(struct page *page)
 {
 	return page->objects - page->inuse;
 }
-#endif
 
-#if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
 static int validate_slab(struct kmem_cache *s, struct page *page,
 						unsigned long *map)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
