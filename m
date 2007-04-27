Message-Id: <20070427202859.651038123@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:38 -0700
From: clameter@sgi.com
Subject: [patch 1/8] SLUB sysfs support: fix unique id generation
Content-Disposition: inline; filename=slub_unique_id
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Generate a unique id for mergeable slabs through combining the
slab size with the flags that distinguish slabs of the same size.
That yields a unique id that is fairly short and descriptive. It no
longer includes the kmem_cache address.

Extract slab_unmergable() from find_mergeable and use that
in sysfs_add_slab to make handling more consistent.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   48 +++++++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 19 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 13:03:55.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 13:05:17.000000000 -0700
@@ -2367,6 +2367,17 @@ void __init kmem_cache_init(void)
 /*
  * Find a mergeable slab cache
  */
+static int slab_unmergeable(struct kmem_cache *s)
+{
+	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
+		return 1;
+
+	if (s->ctor || s->dtor)
+		return 1;
+
+	return 0;
+}
+
 static struct kmem_cache *find_mergeable(size_t size,
 		size_t align, unsigned long flags,
 		void (*ctor)(void *, struct kmem_cache *, unsigned long),
@@ -2388,13 +2399,10 @@ static struct kmem_cache *find_mergeable
 		struct kmem_cache *s =
 			container_of(h, struct kmem_cache, list);
 
-		if (size > s->size)
-			continue;
-
-		if (s->flags & SLUB_NEVER_MERGE)
+		if (slab_unmergeable(s))
 			continue;
 
-		if (s->dtor || s->ctor)
+		if (size > s->size)
 			continue;
 
 		if (((flags | slub_debug) & SLUB_MERGE_SAME) !=
@@ -3452,23 +3460,21 @@ static char *create_unique_id(struct kme
 
 	*p++ = ':';
 	/*
-	 * First flags affecting slabcache operations */
+	 * First flags affecting slabcache operations. We will only
+	 * get here for aliasable slabs so we do not need to support
+	 * too many flags. The flags here must cover all flags that
+	 * are matched during merging to guarantee that the id is
+	 * unique.
+	 */
 	if (s->flags & SLAB_CACHE_DMA)
 		*p++ = 'd';
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		*p++ = 'a';
-	if (s->flags & SLAB_DESTROY_BY_RCU)
-		*p++ = 'r';\
-	/* Debug flags */
-	if (s->flags & SLAB_RED_ZONE)
-		*p++ = 'Z';
-	if (s->flags & SLAB_POISON)
-		*p++ = 'P';
-	if (s->flags & SLAB_STORE_USER)
-		*p++ = 'U';
+	if (s->flags & SLAB_DEBUG_FREE)
+		*p++ = 'F';
 	if (p != name + 1)
 		*p++ = '-';
-	p += sprintf(p,"%07d:0x%p" ,s->size, s);
+	p += sprintf(p, "%07d", s->size);
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
 }
@@ -3477,12 +3483,14 @@ static int sysfs_slab_add(struct kmem_ca
 {
 	int err;
 	const char *name;
+	int unmergeable;
 
 	if (slab_state < SYSFS)
 		/* Defer until later */
 		return 0;
 
-	if (s->flags & SLUB_NEVER_MERGE) {
+	unmergeable = slab_unmergeable(s);
+	if (unmergeable) {
 		/*
 		 * Slabcache can never be merged so we can use the name proper.
 		 * This is typically the case for debug situations. In that
@@ -3490,12 +3498,13 @@ static int sysfs_slab_add(struct kmem_ca
 		 */
 		sysfs_remove_link(&slab_subsys.kset.kobj, s->name);
 		name = s->name;
-	} else
+	} else {
 		/*
 		 * Create a unique name for the slab as a target
 		 * for the symlinks.
 		 */
 		name = create_unique_id(s);
+	}
 
 	kobj_set_kset_s(s, slab_subsys);
 	kobject_set_name(&s->kobj, name);
@@ -3508,7 +3517,8 @@ static int sysfs_slab_add(struct kmem_ca
 	if (err)
 		return err;
 	kobject_uevent(&s->kobj, KOBJ_ADD);
-	if (!(s->flags & SLUB_NEVER_MERGE)) {
+	if (!unmergeable) {
+		/* Setup first alias */
 		sysfs_slab_alias(s, s->name);
 		kfree(name);
 	}

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
