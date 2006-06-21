Subject: [RFC] concurrent radix tree - getting rid of the writelock too.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Wed, 21 Jun 2006 21:19:47 +0200
Message-Id: <1150917588.15744.67.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

Its work in progress, although it does seem to finish both tests
successfully, still need to write more.

The approach is rather simple, add a lock to each node and ladder lock
downwards. The funny parts are where you also need to go up again, here
the shortest possible tree path is kept locked. With larger trees the
top levels should be unlocked quite easily which will allow modification
on other sub-trees.

Patch against Nick's latest RCU enhanced rtth package (dunno if its
public).

Comments?


diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/linux/radix-tree.h rtth-peterz/linux/radix-tree.h
--- rtth/linux/radix-tree.h	2006-04-08 12:48:59.000000000 +0200
+++ rtth-peterz/linux/radix-tree.h	2006-06-21 19:28:53.000000000 +0200
@@ -24,6 +24,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/rcupdate.h>
+#include <linux/spinlock.h>
 
 #define RADIX_TREE_MAX_TAGS 2
 
@@ -32,12 +33,14 @@ struct radix_tree_root {
 	unsigned int		height;
 	gfp_t			gfp_mask;
 	struct radix_tree_node	*rnode;
+	spinlock_t		lock;
 };
 
 #define RADIX_TREE_INIT(mask)	{					\
 	.height = 0,							\
 	.gfp_mask = (mask),						\
 	.rnode = NULL,							\
+	.lock = SPIN_LOCK_UNLOCKED,					\
 }
 
 #define RADIX_TREE(name, mask) \
@@ -48,6 +51,7 @@ do {									\
 	(root)->height = 0;						\
 	(root)->gfp_mask = (mask);					\
 	(root)->rnode = NULL;						\
+	spin_lock_init(&(root)->lock);					\
 } while (0)
 
 #define RADIX_TREE_DIRECT_PTR	1
@@ -83,7 +87,7 @@ static inline void radix_tree_replace_sl
 
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
-void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
+void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long, spinlock_t **);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/linux/rcupdate.h rtth-peterz/linux/rcupdate.h
--- rtth/linux/rcupdate.h	2006-04-08 08:46:13.000000000 +0200
+++ rtth-peterz/linux/rcupdate.h	2006-06-21 10:28:31.000000000 +0200
@@ -3,8 +3,7 @@
 
 #include <linux/list.h>
 
-#define smp_wmb()       __asm__ __volatile__ ("eieio" : : : "memory")
-#define smp_mb()       __asm__ __volatile__ ("sync" : : : "memory")
+#define smp_wmb()       __asm__ __volatile__ ("" : : : "memory")
 
 void rcu_init(void);
 void rcu_exit(void);
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/linux/slab.h rtth-peterz/linux/slab.h
--- rtth/linux/slab.h	2006-04-06 11:24:17.000000000 +0200
+++ rtth-peterz/linux/slab.h	2006-06-21 19:25:35.000000000 +0200
@@ -5,8 +5,10 @@
 #define SLAB_HWCACHE_ALIGN 1
 #define SLAB_PANIC 2
 
-typedef struct {
+typedef struct __kmem_cache_t {
 	int size;
+	void (*ctor)(void*, struct __kmem_cache_t*, unsigned long);
+	void (*dtor)(void*, struct __kmem_cache_t*, unsigned long);
 } kmem_cache_t;
 
 void *kmem_cache_alloc(kmem_cache_t *cachep, int flags);
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/linux/spinlock.h rtth-peterz/linux/spinlock.h
--- rtth/linux/spinlock.h	1970-01-01 01:00:00.000000000 +0100
+++ rtth-peterz/linux/spinlock.h	2006-06-21 19:48:34.000000000 +0200
@@ -0,0 +1,15 @@
+#ifndef __SPINLOCK_H__
+#define __SPINLOCK_H__
+
+#include <pthread.h>
+
+typedef pthread_spinlock_t spinlock_t;
+
+#define spin_lock_init(lock) pthread_spin_init(lock, 0)
+#define spin_lock(lock) pthread_spin_lock(lock)
+#define spin_trylock(lock) pthread_spin_trylock(lock)
+#define spin_unlock(lock) pthread_spin_unlock(lock)
+
+#define SPIN_LOCK_UNLOCKED 1
+
+#endif /* __SPINLOCK_H__ */
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/linux.c rtth-peterz/linux.c
--- rtth/linux.c	2006-04-08 11:32:10.000000000 +0200
+++ rtth-peterz/linux.c	2006-06-21 11:17:22.000000000 +0200
@@ -36,6 +36,8 @@ void *kmem_cache_alloc(kmem_cache_t *cac
 {
 	void *ret = malloc(cachep->size);
 	memset(ret, 0, cachep->size);
+	if (cachep->ctor)
+		cachep->ctor(ret, cachep, flags);
 	nr_allocated++;
 	return ret;
 }
@@ -56,5 +58,6 @@ kmem_cache_create(const char *name, size
 	kmem_cache_t *ret = malloc(sizeof(*ret));
 
 	ret->size = size;
+	ret->ctor = ctor;
 	return ret;
 }
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/Makefile rtth-peterz/Makefile
--- rtth/Makefile	2006-04-08 13:03:44.000000000 +0200
+++ rtth-peterz/Makefile	2006-06-21 20:53:28.000000000 +0200
@@ -1,5 +1,6 @@
 
-CFLAGS += -I. -O3 -fno-strict-aliasing -Wall -D_THREAD_SAFE
+#CFLAGS += -I. -O3 -fno-strict-aliasing -Wall -D_THREAD_SAFE -D_GNU_SOURCE
+CFLAGS += -I. -ggdb3 -fno-strict-aliasing -Wall -D_THREAD_SAFE -D_GNU_SOURCE
 
 OFILES = radix-tree.o linux.o test.o tag_check.o rcupdate.o
 
@@ -7,7 +8,7 @@ threaded: threaded.o $(OFILES)
 	$(CC) $(CFLAGS) -lpthread threaded.o $(OFILES) -o threaded
 
 main:	main.o $(OFILES)
-	$(CC) $(CFLAGS) main.o $(OFILES) -o main
+	$(CC) $(CFLAGS) -lpthread main.o $(OFILES) -o main
 
 clean:
 	$(RM) -f $(TARGETS) *.o main threaded
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/radix-tree.c rtth-peterz/radix-tree.c
--- rtth/radix-tree.c	2006-04-08 13:03:32.000000000 +0200
+++ rtth-peterz/radix-tree.c	2006-06-21 21:04:18.000000000 +0200
@@ -31,6 +31,7 @@
 #include <linux/string.h>
 #include <linux/bitops.h>
 #include <linux/rcupdate.h>
+#include <linux/spinlock.h>
 
 
 #ifdef __KERNEL__
@@ -51,11 +52,19 @@ struct radix_tree_node {
 	struct rcu_head	rcu_head;
 	void		*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
+	spinlock_t	lock;
 };
 
+static inline spinlock_t * radix_node_lock(struct radix_tree_root *root,
+		struct radix_tree_node *node)
+{
+	return &node->lock;
+}
+
 struct radix_tree_path {
 	struct radix_tree_node *node;
 	int offset;
+	spinlock_t *lock;
 };
 
 #define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
@@ -204,6 +213,22 @@ static inline int any_tag_set(struct rad
 	return 0;
 }
 
+static inline int any_tag_set_but(struct radix_tree_node *node, unsigned int tag,
+		int offset)
+{
+	int idx;
+	int offset_idx = offset / BITS_PER_LONG;
+	unsigned long offset_mask = ~(1 << (offset % BITS_PER_LONG));
+	for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
+		unsigned long mask = ~0UL;
+		if (idx == offset_idx)
+			mask = offset_mask;
+		if (node->tags[tag][idx] & mask)
+			return 1;
+	}
+	return 0;
+}
+
 /*
  *	Return the maximum key which can be store into a
  *	radix tree with height HEIGHT.
@@ -270,15 +295,18 @@ int radix_tree_insert(struct radix_tree_
 	struct radix_tree_node *node = NULL, *slot;
 	unsigned int height, shift;
 	int offset;
-	int error;
+	int error = 0;
+	spinlock_t *hlock, *llock = &root->lock;
 
 	BUG_ON(radix_tree_is_direct_ptr(item));
 
+	spin_lock(llock);
+
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
 		error = radix_tree_extend(root, index);
 		if (error)
-			return error;
+			goto out;
 	}
 
 	slot = root->rnode;
@@ -289,8 +317,10 @@ int radix_tree_insert(struct radix_tree_
 	while (height > 0) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
-			if (!(slot = radix_tree_node_alloc(root)))
-				return -ENOMEM;
+			if (!(slot = radix_tree_node_alloc(root))) {
+				error = -ENOMEM;
+				goto out;
+			}
 			slot->height = height;
 			if (node) {
 				rcu_assign_pointer(node->slots[offset], slot);
@@ -302,13 +332,21 @@ int radix_tree_insert(struct radix_tree_
 		/* Go a level down */
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = slot;
+
+		hlock = llock;
+		llock = radix_node_lock(root, node);
+		spin_lock(llock);
+		spin_unlock(hlock);
+
 		slot = node->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
 
-	if (slot != NULL)
-		return -EEXIST;
+	if (slot != NULL) {
+		error = -EEXIST;
+		goto out;
+	}
 
 	if (node) {
 		node->count++;
@@ -321,7 +359,9 @@ int radix_tree_insert(struct radix_tree_
 		BUG_ON(root_tag_get(root, 1));
 	}
 
-	return 0;
+out:
+	spin_unlock(llock);
+	return error;
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
@@ -339,38 +379,56 @@ EXPORT_SYMBOL(radix_tree_insert);
  *	the slot pointer would require rcu_dereference, and modifying it
  *	would require rcu_assign_pointer.
  */
-void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
+void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index,
+		spinlock_t **lock)
 {
 	unsigned int height, shift;
-	struct radix_tree_node *node, **slot;
+	struct radix_tree_node *node, **slot = NULL;
+	spinlock_t *hlock, *llock = &root->lock;
+
+	spin_lock(llock);
 
 	node = rcu_dereference(root->rnode);
 	if (node == NULL)
-		return NULL;
+		goto out;
 
 	if (radix_tree_is_direct_ptr(node)) {
-		if (index > 0)
-			return NULL;
-		return (void **)&root->rnode;
+		if (index == 0)
+			slot = &root->rnode;
+		goto out;
 	}
 
 	height = node->height;
 	if (index > radix_tree_maxindex(height))
-		return NULL;
+		goto out;
 
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
 	do {
+		hlock = llock;
+		llock = radix_node_lock(root, node);
+		spin_lock(llock);
+		spin_unlock(hlock);
+
 		slot = (struct radix_tree_node **)
 			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
 		node = rcu_dereference(*slot);
-		if (node == NULL)
-			return NULL;
+		if (node == NULL) {
+			slot = NULL;
+			goto out;
+		}
 
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	} while (height > 0);
 
+out:
+	if (slot)
+		*lock = llock;
+	else {
+		spin_unlock(llock);
+		*lock = NULL;
+	}
 	return (void **)slot;
 }
 EXPORT_SYMBOL(radix_tree_lookup_slot);
@@ -440,18 +498,30 @@ void *radix_tree_tag_set(struct radix_tr
 			unsigned long index, unsigned int tag)
 {
 	unsigned int height, shift;
-	struct radix_tree_node *slot;
+	struct radix_tree_node *slot = NULL;
+	spinlock_t *hlock, *llock = &root->lock;
+
+	spin_lock(llock);
 
 	height = root->height;
-	if (index > radix_tree_maxindex(height))
-		return NULL;
+	BUG_ON(index > radix_tree_maxindex(height));
 
 	slot = root->rnode;
+	BUG_ON(!slot);
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 
+	/* set the root's tag bit */
+	if (!root_tag_get(root, tag))
+		root_tag_set(root, tag);
+
 	while (height > 0) {
 		int offset;
 
+		hlock = llock;
+		llock = &slot->lock;
+		spin_lock(llock);
+		spin_unlock(hlock);
+
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		if (!tag_get(slot, tag, offset))
 			tag_set(slot, tag, offset);
@@ -461,10 +531,7 @@ void *radix_tree_tag_set(struct radix_tr
 		height--;
 	}
 
-	/* set the root's tag bit */
-	if (slot && !root_tag_get(root, tag))
-		root_tag_set(root, tag);
-
+	spin_unlock(llock);
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
@@ -486,10 +553,16 @@ EXPORT_SYMBOL(radix_tree_tag_set);
 void *radix_tree_tag_clear(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)
 {
-	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
+	struct radix_tree_path path[RADIX_TREE_MAX_PATH];
+	struct radix_tree_path *pathp = path, *punlock = path;
+	struct radix_tree_path *piter;
 	struct radix_tree_node *slot = NULL;
 	unsigned int height, shift;
+	spinlock_t *lock = &root->lock;
 
+	spin_lock(lock);
+
+	pathp->lock = lock;
 	height = root->height;
 	if (index > radix_tree_maxindex(height))
 		goto out;
@@ -500,15 +573,40 @@ void *radix_tree_tag_clear(struct radix_
 
 	while (height > 0) {
 		int offset;
+		int parent_tag;
 
 		if (slot == NULL)
 			goto out;
 
+		if (pathp->node)
+			parent_tag = tag_get(pathp->node, tag, pathp->offset);
+		else
+			parent_tag = root_tag_get(root, tag);
+
+		lock = radix_node_lock(root, slot);
+		spin_lock(lock);
+
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		pathp[1].offset = offset;
-		pathp[1].node = slot;
-		slot = slot->slots[offset];
 		pathp++;
+		pathp->offset = offset;
+		pathp->node = slot;
+		pathp->lock = lock;
+
+		/*
+		 * If the parent node does not have the tag set or the current 
+		 * node has slots with the tag set other than the one we're 
+		 * potentially clearing, the change can never propagate upwards
+		 * from here.
+		 */
+		if (!parent_tag || any_tag_set_but(slot, tag, offset)) {
+			for (; punlock < pathp; punlock++) {
+				BUG_ON(!punlock->lock);
+				spin_unlock(punlock->lock);
+				punlock->lock = NULL;
+			}
+		}
+
+		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -516,20 +614,19 @@ void *radix_tree_tag_clear(struct radix_
 	if (slot == NULL)
 		goto out;
 
-	while (pathp->node) {
-		if (!tag_get(pathp->node, tag, pathp->offset))
-			goto out;
-		tag_clear(pathp->node, tag, pathp->offset);
-		if (any_tag_set(pathp->node, tag))
-			goto out;
-		pathp--;
+	for (piter = pathp; piter >= punlock; piter--) {
+		BUG_ON(!punlock->lock);
+		if (piter->node)
+			tag_clear(piter->node, tag, piter->offset);
+		else
+			root_tag_clear(root, tag);
 	}
 
-	/* clear the root's tag bit */
-	if (root_tag_get(root, tag))
-		root_tag_clear(root, tag);
-
 out:
+	for (; punlock <= pathp; punlock++) {
+		BUG_ON(!punlock->lock);
+		spin_unlock(punlock->lock);
+	}
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
@@ -812,8 +909,8 @@ radix_tree_gang_lookup_tag(struct radix_
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
 
 /**
- *	radix_tree_shrink    -    shrink height of a radix tree to minimal
- *	@root		radix tree root
+ *     radix_tree_shrink    -    shrink height of a radix tree to minimal
+ *     @root           radix tree root
  */
 static inline void radix_tree_shrink(struct radix_tree_root *root)
 {
@@ -823,6 +920,7 @@ static inline void radix_tree_shrink(str
 			root->rnode->slots[0]) {
 		struct radix_tree_node *to_free = root->rnode;
 		void *newptr;
+		int tag;
 
 		/*
 		 * this doesn't need an rcu_assign_pointer, because
@@ -835,11 +933,10 @@ static inline void radix_tree_shrink(str
 		root->rnode = newptr;
 		root->height--;
 		/* must only free zeroed nodes into the slab */
-		tag_clear(to_free, 0, 0);
-		tag_clear(to_free, 1, 0);
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			tag_clear(to_free, tag, 0);
 		to_free->slots[0] = NULL;
 		to_free->count = 0;
-		radix_tree_node_free(to_free);
 	}
 }
 
@@ -854,13 +951,19 @@ static inline void radix_tree_shrink(str
  */
 void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 {
-	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
+	struct radix_tree_path path[RADIX_TREE_MAX_PATH];
+	struct radix_tree_path *pathp = path, *punlock = path;
+	struct radix_tree_path *piter;
 	struct radix_tree_node *slot = NULL;
-	struct radix_tree_node *to_free;
 	unsigned int height, shift;
 	int tag;
 	int offset;
+	spinlock_t *lock = &root->lock;
+
+	spin_lock(lock);
 
+	pathp->lock = lock;
+	pathp->node = NULL;
 	height = root->height;
 	if (index > radix_tree_maxindex(height))
 		goto out;
@@ -874,16 +977,46 @@ void *radix_tree_delete(struct radix_tre
 	}
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	pathp->node = NULL;
 
 	do {
+		int parent_tags = 0;
+		int no_tags = 0;
+
 		if (slot == NULL)
 			goto out;
 
+		lock = radix_node_lock(root, slot);
+		spin_lock(lock);
+
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
+			if (pathp->node)
+				parent_tags |= tag_get(pathp->node, tag, pathp->offset);
+			else
+				parent_tags |= root_tag_get(root, tag);
+
+			no_tags |= !any_tag_set_but(slot, tag, offset);
+		}
+
 		pathp++;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		pathp->offset = offset;
 		pathp->node = slot;
+		pathp->lock = lock;
+
+		/*
+		 * If the parent node does not have any tag set or the current 
+		 * node has slots with the tags set other than the one we're 
+		 * potentially clearing AND there are more children than just us,
+		 * the changes can never propagate upwards from here.
+		 */
+		if ((!parent_tags || !no_tags) && slot->count > 2) {
+			for (; punlock < pathp; punlock++) {
+				BUG_ON(!punlock->lock);
+				spin_unlock(punlock->lock);
+				punlock->lock = NULL;
+			}
+		}
+
 		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -896,36 +1029,45 @@ void *radix_tree_delete(struct radix_tre
 	 * Clear all tags associated with the just-deleted item
 	 */
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (tag_get(pathp->node, tag, pathp->offset))
-			radix_tree_tag_clear(root, index, tag);
+		for (piter = pathp; piter >= punlock; piter--) {
+			if (piter->node) {
+				if (!tag_get(piter->node, tag, piter->offset))
+					break;
+				tag_clear(piter->node, tag, piter->offset);
+				if (any_tag_set(piter->node, tag))
+					break;
+			} else {
+				if (root_tag_get(root, tag))
+					root_tag_clear(root, tag);
+			}
+		}
 	}
 
-	to_free = NULL;
-	/* Now free the nodes we do not need anymore */
-	while (pathp->node) {
-		if (to_free)
-			radix_tree_node_free(to_free);
-		pathp->node->slots[pathp->offset] = NULL;
-		pathp->node->count--;
+	/* Now unhook the nodes we do not need anymore */
+	for (piter = pathp; piter >= punlock && piter->node; piter--) {
+		piter->node->slots[piter->offset] = NULL;
+		piter->node->count--;
 
-		if (pathp->node->count) {
-			if (pathp->node == root->rnode)
+		if (piter->node->count) {
+			if (piter->node == root->rnode)
 				radix_tree_shrink(root);
 			goto out;
 		}
+	}
 
-		/* Node with zero slots in use so free it */
-		to_free = pathp->node;
-		pathp--;
+	BUG_ON(punlock->node || !punlock->lock);
 
-	}
 	root_tag_clear_all(root);
 	root->height = 0;
 	root->rnode = NULL;
-	if (to_free)
-		radix_tree_node_free(to_free);
 
 out:
+	for (; punlock <= pathp; punlock++) {
+		BUG_ON(!punlock->lock);
+		spin_unlock(punlock->lock);
+		if (punlock->node && punlock->node->count == 0)
+			radix_tree_node_free(punlock->node);
+	}
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_delete);
@@ -945,6 +1087,7 @@ static void
 radix_tree_node_ctor(void *node, kmem_cache_t *cachep, unsigned long flags)
 {
 	memset(node, 0, sizeof(struct radix_tree_node));
+	spin_lock_init(&((struct radix_tree_node *)node)->lock);
 }
 
 static __init unsigned long __maxindex(unsigned int height)
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/test.c rtth-peterz/test.c
--- rtth/test.c	2006-04-08 12:28:51.000000000 +0200
+++ rtth-peterz/test.c	2006-06-21 19:37:39.000000000 +0200
@@ -3,6 +3,7 @@
 #include <stdio.h>
 
 #include <linux/rcupdate.h>
+#include <linux/spinlock.h>
 
 #include "test.h"
 
@@ -73,25 +74,30 @@ struct item *item_create(unsigned long i
 void item_check_present(struct radix_tree_root *root, unsigned long index)
 {
 	struct item *item, **itemp;
+	spinlock_t *lock;
 
 	item = radix_tree_lookup(root, index);
 	assert(item != 0);
 	assert(item->index == index);
 
-	itemp = (struct item **)radix_tree_lookup_slot(root, index);
+	itemp = (struct item **)radix_tree_lookup_slot(root, index, &lock);
 	assert((item == NULL && itemp == NULL)
 			|| item == radix_tree_deref_slot(itemp));
+	if (lock)
+		spin_unlock(lock);
 }
 
 struct item *item_lookup(struct radix_tree_root *root, unsigned long index)
 {
 	struct item *item, **itemp;
+	spinlock_t *lock;
 
 	item = radix_tree_lookup(root, index);
-	itemp = (struct item **)radix_tree_lookup_slot(root, index);
+	itemp = (struct item **)radix_tree_lookup_slot(root, index, &lock);
 	assert((item == NULL && itemp == NULL)
 			|| item == radix_tree_deref_slot(itemp));
-
+	if (lock)
+		spin_unlock(lock);
 	return item;
 }
 
@@ -103,13 +109,16 @@ struct item *item_lookup_rcu(struct radi
 void item_check_absent(struct radix_tree_root *root, unsigned long index)
 {
 	struct item *item, **itemp;
+	spinlock_t *lock;
 
 	item = radix_tree_lookup(root, index);
 	assert(item == 0);
 
-	itemp = (struct item **)radix_tree_lookup_slot(root, index);
+	itemp = (struct item **)radix_tree_lookup_slot(root, index, &lock);
 	assert((item == NULL && itemp == NULL)
 			|| item == radix_tree_deref_slot(itemp));
+	if (lock)
+		spin_unlock(lock);
 }
 
 /*
diff -Naurp -x '*.o' -x '*~' -x '*.sw?' -x tags -x threaded -x main rtth/threaded.c rtth-peterz/threaded.c
--- rtth/threaded.c	2006-04-08 12:35:34.000000000 +0200
+++ rtth-peterz/threaded.c	2006-06-21 20:48:20.000000000 +0200
@@ -50,8 +50,6 @@ static void *random_updater(void *arg)
 			item_delete(&tree, idx);
 		}
 	}
-	item_kill_tree(&tree);
-	printk("after random_updater %d allocated\n", nr_allocated);
 
 	return NULL;
 }
@@ -247,6 +245,7 @@ int main()
 {
 	int i, t = 0;
 	pthread_t readers[4];
+	pthread_t writers[4];
 
 	srandom(10);
 
@@ -259,7 +258,15 @@ int main()
 	pthread_create(&readers[t++], NULL, &zeroone_reader, NULL);
 
 	simple_updater(NULL);
-	random_updater(NULL);
+
+	for (i=0; i<4; ++i)
+		pthread_create(&writers[i], NULL, &random_updater, NULL);
+	for (i=0; i<4; ++i)
+		pthread_join(writers[i], NULL);
+
+	item_kill_tree(&tree);
+	printk("after random_updater %d allocated\n", nr_allocated);
+
 	height_change_updater(NULL);
 	direct_change_updater(NULL);
 	direct_updater(NULL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
