Date: Tue, 29 Apr 2008 16:16:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] slub: #ifdef simplification
Message-ID: <Pine.LNX.4.64.0804291615130.15436@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Rediffed to current git]

If we make SLUB_DEBUG depend on SYSFS then we can simplify some
#ifdefs and avoid others.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 init/Kconfig |    2 +-
 mm/slub.c    |    6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2008-04-28 21:20:43.641139595 -0700
+++ linux-2.6/init/Kconfig	2008-04-28 21:22:16.429890363 -0700
@@ -697,7 +697,7 @@ config VM_EVENT_COUNTERS
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
--- linux-2.6.orig/mm/slub.c	2008-04-28 21:21:08.983640178 -0700
+++ linux-2.6/mm/slub.c	2008-04-28 21:22:16.429890363 -0700
@@ -215,7 +215,7 @@ struct track {
 
 enum track_item { TRACK_ALLOC, TRACK_FREE };
 
-#if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
+#ifdef CONFIG_SLUB_DEBUG
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
@@ -3243,7 +3243,7 @@ void *__kmalloc_node_track_caller(size_t
 	return slab_alloc(s, gfpflags, node, caller);
 }
 
-#if (defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)) || defined(CONFIG_SLABINFO)
+#ifdef CONFIG_SLUB_DEBUG
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -3272,9 +3272,7 @@ static int count_free(struct page *page)
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
