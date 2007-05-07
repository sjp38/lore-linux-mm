Message-Id: <20070507212410.623072827@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:54 -0700
From: clameter@sgi.com
Subject: [patch 14/17] SLUB: Move tracking definitions and check_valid_pointer() away from debug code
Content-Disposition: inline; filename=move_tracking
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move the tracking definitions and the check_valid_pointer() function away
from the debugging related functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   58 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:57:04.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:57:30.000000000 -0700
@@ -197,6 +197,18 @@ static enum {
 static DECLARE_RWSEM(slub_lock);
 LIST_HEAD(slab_caches);
 
+/*
+ * Tracking user of a slab.
+ */
+struct track {
+	void *addr;		/* Called from address */
+	int cpu;		/* Was running on cpu */
+	int pid;		/* Pid context */
+	unsigned long when;	/* When did the operation occur */
+};
+
+enum track_item { TRACK_ALLOC, TRACK_FREE };
+
 #ifdef CONFIG_SYSFS
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
@@ -225,6 +237,23 @@ static inline struct kmem_cache_node *ge
 #endif
 }
 
+static inline int check_valid_pointer(struct kmem_cache *s,
+				struct page *page, const void *object)
+{
+	void *base;
+
+	if (!object)
+		return 1;
+
+	base = page_address(page);
+	if (object < base || object >= base + s->objects * s->size ||
+		(object - base) % s->size) {
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Slow version of get and set free pointer.
  *
@@ -292,18 +321,6 @@ static void print_section(char *text, u8
 	}
 }
 
-/*
- * Tracking user of a slab.
- */
-struct track {
-	void *addr;		/* Called from address */
-	int cpu;		/* Was running on cpu */
-	int pid;		/* Pid context */
-	unsigned long when;	/* When did the operation occur */
-};
-
-enum track_item { TRACK_ALLOC, TRACK_FREE };
-
 static struct track *get_track(struct kmem_cache *s, void *object,
 	enum track_item alloc)
 {
@@ -438,23 +455,6 @@ static int check_bytes(u8 *start, unsign
 	return 1;
 }
 
-static inline int check_valid_pointer(struct kmem_cache *s,
-				struct page *page, const void *object)
-{
-	void *base;
-
-	if (!object)
-		return 1;
-
-	base = page_address(page);
-	if (object < base || object >= base + s->objects * s->size ||
-		(object - base) % s->size) {
-		return 0;
-	}
-
-	return 1;
-}
-
 /*
  * Object layout:
  *

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
