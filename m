Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 954656B003C
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 18:39:27 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so1603331bkb.2
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 15:39:27 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id h2si8743839bko.267.2013.11.24.15.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 15:39:26 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 9/9] mm: keep page cache radix tree nodes in check
Date: Sun, 24 Nov 2013 18:38:28 -0500
Message-Id: <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Previously, page cache radix tree nodes were freed after reclaim
emptied out their page pointers.  But now reclaim stores shadow
entries in their place, which are only reclaimed when the inodes
themselves are reclaimed.  This is problematic for bigger files that
are still in use after they have a significant amount of their cache
reclaimed, without any of those pages actually refaulting.  The shadow
entries will just sit there and waste memory.  In the worst case, the
shadow entries will accumulate until the machine runs out of memory.

To get this under control, the VM will track radix tree nodes
exclusively containing shadow entries on a per-NUMA node list.  A
simple shrinker will reclaim these nodes on memory pressure.

A few things need to be stored in the radix tree node to implement the
shadow node LRU and allow tree deletions coming from the list:

1. There is no index available that would describe the reverse path
   from the node up to the tree root, which is needed to perform a
   deletion.  To solve this, encode in each node its offset inside the
   parent.  This can be stored in the unused upper bits of the same
   member that stores the node's height at no extra space cost.

2. The number of shadow entries needs to be counted in addition to the
   regular entries, to quickly detect when the node is ready to go to
   the shadow node LRU list.  The current entry count is an unsigned
   int but the maximum number of entries is 64, so a shadow counter
   can easily be stored in the unused upper bits.

3. Tree modification needs the lock, which is located in the address
   space, so store a backpointer to it.  The parent pointer is in a
   union with the 2-word rcu_head, so the backpointer comes at no
   extra cost as well.

4. The node needs to be linked to an LRU list, which requires a list
   head inside the node.  This does increase the size of the node, but
   it does not change the number of objects that fit into a slab page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/super.c                    |   4 +-
 fs/xfs/xfs_buf.c              |   2 +-
 fs/xfs/xfs_qm.c               |   2 +-
 include/linux/list_lru.h      |   2 +-
 include/linux/radix-tree.h    |  30 +++++++---
 include/linux/swap.h          |   1 +
 include/linux/vm_event_item.h |   1 +
 lib/radix-tree.c              |  36 +++++++-----
 mm/filemap.c                  |  70 ++++++++++++++++++++----
 mm/list_lru.c                 |   4 +-
 mm/truncate.c                 |  19 ++++++-
 mm/vmstat.c                   |   2 +
 mm/workingset.c               | 124 ++++++++++++++++++++++++++++++++++++++++++
 13 files changed, 255 insertions(+), 42 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 0225c20..a958d52 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -196,9 +196,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 
-		if (list_lru_init(&s->s_dentry_lru))
+		if (list_lru_init(&s->s_dentry_lru, NULL))
 			goto err_out;
-		if (list_lru_init(&s->s_inode_lru))
+		if (list_lru_init(&s->s_inode_lru, NULL))
 			goto err_out_dentry_lru;
 
 		INIT_LIST_HEAD(&s->s_mounts);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 2634700..c49cbce 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1670,7 +1670,7 @@ xfs_alloc_buftarg(
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
 
-	if (list_lru_init(&btp->bt_lru))
+	if (list_lru_init(&btp->bt_lru, NULL))
 		goto error;
 
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 3e6c2e6..57d6aa9 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -831,7 +831,7 @@ xfs_qm_init_quotainfo(
 
 	qinf = mp->m_quotainfo = kmem_zalloc(sizeof(xfs_quotainfo_t), KM_SLEEP);
 
-	if ((error = list_lru_init(&qinf->qi_lru))) {
+	if ((error = list_lru_init(&qinf->qi_lru, NULL))) {
 		kmem_free(qinf);
 		mp->m_quotainfo = NULL;
 		return error;
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..b970a45 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -32,7 +32,7 @@ struct list_lru {
 };
 
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init(struct list_lru *lru);
+int list_lru_init(struct list_lru *lru, struct lock_class_key *key);
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 13636c4..29df11f 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -72,21 +72,35 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 #define RADIX_TREE_TAG_LONGS	\
 	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
 
+#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
+#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
+					  RADIX_TREE_MAP_SHIFT))
+
+/* Height component in node->path */
+#define RADIX_TREE_HEIGHT_SHIFT	(RADIX_TREE_MAX_PATH + 1)
+#define RADIX_TREE_HEIGHT_MASK	((1UL << RADIX_TREE_HEIGHT_SHIFT) - 1)
+
+/* Internally used bits of node->count */
+#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
+#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
+
 struct radix_tree_node {
-	unsigned int	height;		/* Height from the bottom */
+	unsigned int	path;	/* Offset in parent & height from the bottom */
 	unsigned int	count;
 	union {
-		struct radix_tree_node *parent;	/* Used when ascending tree */
-		struct rcu_head	rcu_head;	/* Used when freeing node */
+		/* Used when ascending tree */
+		struct {
+			struct radix_tree_node *parent;
+			void *private;
+		};
+		/* Used when freeing node */
+		struct rcu_head	rcu_head;
 	};
+	struct list_head lru;
 	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
 
-#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
-#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
-					  RADIX_TREE_MAP_SHIFT))
-
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
 	unsigned int		height;
@@ -251,7 +265,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
-bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
+bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b83cf61..102e37b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -264,6 +264,7 @@ struct swap_list_t {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
+extern struct list_lru workingset_shadow_nodes;
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 1855f0a..0b15c59 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -76,6 +76,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		NR_TLB_LOCAL_FLUSH_ALL,
 		NR_TLB_LOCAL_FLUSH_ONE,
+		WORKINGSET_NODES_RECLAIMED,
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e601c56..1865cd2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -342,7 +342,8 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
 
 		/* Increase the height.  */
 		newheight = root->height+1;
-		node->height = newheight;
+		BUG_ON(newheight & ~RADIX_TREE_HEIGHT_MASK);
+		node->path = newheight;
 		node->count = 1;
 		node->parent = NULL;
 		slot = root->rnode;
@@ -400,11 +401,12 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			/* Have to add a child node.  */
 			if (!(slot = radix_tree_node_alloc(root)))
 				return -ENOMEM;
-			slot->height = height;
+			slot->path = height;
 			slot->parent = node;
 			if (node) {
 				rcu_assign_pointer(node->slots[offset], slot);
 				node->count++;
+				slot->path |= offset << RADIX_TREE_HEIGHT_SHIFT;
 			} else
 				rcu_assign_pointer(root->rnode, ptr_to_indirect(slot));
 		}
@@ -496,7 +498,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 	}
 	node = indirect_to_ptr(node);
 
-	height = node->height;
+	height = node->path & RADIX_TREE_HEIGHT_MASK;
 	if (index > radix_tree_maxindex(height))
 		return NULL;
 
@@ -702,7 +704,7 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 		return (index == 0);
 	node = indirect_to_ptr(node);
 
-	height = node->height;
+	height = node->path & RADIX_TREE_HEIGHT_MASK;
 	if (index > radix_tree_maxindex(height))
 		return 0;
 
@@ -739,7 +741,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 {
 	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
 	struct radix_tree_node *rnode, *node;
-	unsigned long index, offset;
+	unsigned long index, offset, height;
 
 	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
 		return NULL;
@@ -770,7 +772,8 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		return NULL;
 
 restart:
-	shift = (rnode->height - 1) * RADIX_TREE_MAP_SHIFT;
+	height = rnode->path & RADIX_TREE_HEIGHT_MASK;
+	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 	offset = index >> shift;
 
 	/* Index outside of the tree */
@@ -1140,7 +1143,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 	unsigned int shift, height;
 	unsigned long i;
 
-	height = slot->height;
+	height = slot->path & RADIX_TREE_HEIGHT_MASK;
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
 	for ( ; height > 1; height--) {
@@ -1203,7 +1206,8 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
 		}
 
 		node = indirect_to_ptr(node);
-		max_index = radix_tree_maxindex(node->height);
+		max_index = radix_tree_maxindex(node->path &
+						RADIX_TREE_HEIGHT_MASK);
 		if (cur_index > max_index)
 			break;
 
@@ -1297,7 +1301,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
  *
  *	Returns %true if @node was freed, %false otherwise.
  */
-bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
+bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node)
 {
 	bool deleted = false;
@@ -1316,9 +1320,10 @@ bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
 
 		parent = node->parent;
 		if (parent) {
-			index >>= RADIX_TREE_MAP_SHIFT;
+			unsigned int offset;
 
-			parent->slots[index & RADIX_TREE_MAP_MASK] = NULL;
+			offset = node->path >> RADIX_TREE_HEIGHT_SHIFT;
+			parent->slots[offset] = NULL;
 			parent->count--;
 		} else {
 			root_tag_clear_all(root);
@@ -1382,7 +1387,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	node->slots[offset] = NULL;
 	node->count--;
 
-	__radix_tree_delete_node(root, index, node);
+	__radix_tree_delete_node(root, node);
 
 	return entry;
 }
@@ -1415,9 +1420,12 @@ int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag)
 EXPORT_SYMBOL(radix_tree_tagged);
 
 static void
-radix_tree_node_ctor(void *node)
+radix_tree_node_ctor(void *arg)
 {
-	memset(node, 0, sizeof(struct radix_tree_node));
+	struct radix_tree_node *node = arg;
+
+	memset(node, 0, sizeof(*node));
+	INIT_LIST_HEAD(&node->lru);
 }
 
 static __init unsigned long __maxindex(unsigned int height)
diff --git a/mm/filemap.c b/mm/filemap.c
index 30a74be..79a7546 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -110,14 +110,48 @@
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
-	if (shadow) {
-		void **slot;
+	struct radix_tree_node *node;
+	unsigned long index;
+	unsigned int offset;
+	unsigned int tag;
+	void **slot;
 
-		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
-		radix_tree_replace_slot(slot, shadow);
+	VM_BUG_ON(!PageLocked(page));
+
+	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
+
+	if (shadow)
 		mapping->nrshadows++;
-	} else
-		radix_tree_delete(&mapping->page_tree, page->index);
+
+	if (!node) {
+		/* Clear direct pointer tags in root node */
+		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
+		radix_tree_replace_slot(slot, shadow);
+		return;
+	}
+
+	/* Clear tree tags for the removed page */
+	index = page->index;
+	offset = index & RADIX_TREE_MAP_MASK;
+	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
+		if (test_bit(offset, node->tags[tag]))
+			radix_tree_tag_clear(&mapping->page_tree, index, tag);
+	}
+
+	/* Delete page, swap shadow entry */
+	radix_tree_replace_slot(slot, shadow);
+	node->count--;
+	if (shadow)
+		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
+	else
+		if (__radix_tree_delete_node(&mapping->page_tree, node))
+			return;
+
+	/* Only shadow entries in there, keep track of this node */
+	if (!(node->count & RADIX_TREE_COUNT_MASK) && list_empty(&node->lru)) {
+		node->private = mapping;
+		list_lru_add(&workingset_shadow_nodes, &node->lru);
+	}
 }
 
 /*
@@ -463,22 +497,34 @@ EXPORT_SYMBOL_GPL(replace_page_cache_page);
 static int page_cache_tree_insert(struct address_space *mapping,
 				  struct page *page, void **shadowp)
 {
+	struct radix_tree_node *node;
 	void **slot;
+	int error;
 
-	slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
-	if (slot) {
+	error = __radix_tree_create(&mapping->page_tree, page->index,
+				    &node, &slot);
+	if (error)
+		return error;
+	if (*slot) {
 		void *p;
 
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
-		radix_tree_replace_slot(slot, page);
-		mapping->nrshadows--;
 		if (shadowp)
 			*shadowp = p;
-		return 0;
+		mapping->nrshadows--;
+		if (node)
+			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
 	}
-	return radix_tree_insert(&mapping->page_tree, page->index, page);
+	radix_tree_replace_slot(slot, page);
+	if (node) {
+		node->count++;
+		/* Installed page, can't be shadow-only anymore */
+		if (!list_empty(&node->lru))
+			list_lru_del(&workingset_shadow_nodes, &node->lru);
+	}
+	return 0;
 }
 
 static int __add_to_page_cache_locked(struct page *page,
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 72f9dec..c357e8f 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -114,7 +114,7 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init(struct list_lru *lru)
+int list_lru_init(struct list_lru *lru, struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
@@ -126,6 +126,8 @@ int list_lru_init(struct list_lru *lru)
 	nodes_clear(lru->active_nodes);
 	for (i = 0; i < nr_node_ids; i++) {
 		spin_lock_init(&lru->node[i].lock);
+		if (key)
+			lockdep_set_class(&lru->node[i].lock, key);
 		INIT_LIST_HEAD(&lru->node[i].list);
 		lru->node[i].nr_items = 0;
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index cbd0167..9cf5f88 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -25,6 +25,9 @@
 static void clear_exceptional_entry(struct address_space *mapping,
 				    pgoff_t index, void *entry)
 {
+	struct radix_tree_node *node;
+	void **slot;
+
 	/* Handled by shmem itself */
 	if (shmem_mapping(mapping))
 		return;
@@ -35,8 +38,20 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * without the tree itself locked.  These unlocked entries
 	 * need verification under the tree lock.
 	 */
-	if (radix_tree_delete_item(&mapping->page_tree, index, entry) == entry)
-		mapping->nrshadows--;
+	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
+		goto unlock;
+	if (*slot != entry)
+		goto unlock;
+	radix_tree_replace_slot(slot, NULL);
+	mapping->nrshadows--;
+	if (!node)
+		goto unlock;
+	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+	/* No more shadow entries, stop tracking the node */
+	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) && !list_empty(&node->lru))
+		list_lru_del(&workingset_shadow_nodes, &node->lru);
+	__radix_tree_delete_node(&mapping->page_tree, node);
+unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3ac830d..c5f33d2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -859,6 +859,8 @@ const char * const vmstat_text[] = {
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
 
+	"workingset_nodes_reclaimed",
+
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
diff --git a/mm/workingset.c b/mm/workingset.c
index 478060f..ba8f0dd 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -251,3 +251,127 @@ void workingset_activation(struct page *page)
 {
 	atomic_long_inc(&page_zone(page)->inactive_age);
 }
+
+/*
+ * Page cache radix tree nodes containing only shadow entries can grow
+ * excessively on certain workloads.  That's why they are tracked on
+ * per-(NUMA)node lists and pushed back by a shrinker, but with a
+ * slightly higher threshold than regular shrinkers so we don't
+ * discard the entries too eagerly - after all, during light memory
+ * pressure is exactly when we need them.
+ *
+ * The list_lru lock nests inside the IRQ-safe mapping->tree_lock, so
+ * we have to disable IRQs for any list_lru operation as well.
+ */
+
+struct list_lru workingset_shadow_nodes;
+
+static unsigned long count_shadow_nodes(struct shrinker *shrinker,
+					struct shrink_control *sc)
+{
+	unsigned long count;
+
+	local_irq_disable();
+	count = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
+	local_irq_enable();
+
+	return count;
+}
+
+#define NOIRQ_BATCH 32
+
+static enum lru_status shadow_lru_isolate(struct list_head *item,
+					  spinlock_t *lru_lock,
+					  void *arg)
+{
+	struct address_space *mapping;
+	struct radix_tree_node *node;
+	unsigned long *batch = arg;
+	unsigned int i;
+
+	node = container_of(item, struct radix_tree_node, lru);
+	mapping = node->private;
+
+	/* Don't disable IRQs for too long */
+	if (--(*batch) == 0) {
+		spin_unlock_irq(lru_lock);
+		*batch = NOIRQ_BATCH;
+		spin_lock_irq(lru_lock);
+		return LRU_RETRY;
+	}
+
+	/* Coming from the list, inverse the lock order */
+	if (!spin_trylock(&mapping->tree_lock))
+		return LRU_SKIP;
+
+	/*
+	 * The nodes should only contain one or more shadow entries,
+	 * no pages, so we expect to be able to remove them all and
+	 * delete and free the empty node afterwards.
+	 */
+
+	BUG_ON(!node->count);
+	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
+
+	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[i]) {
+			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
+			node->slots[i] = NULL;
+			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
+			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+			BUG_ON(!mapping->nrshadows);
+			mapping->nrshadows--;
+		}
+	}
+	list_del_init(&node->lru);
+	BUG_ON(node->count);
+	if (!__radix_tree_delete_node(&mapping->page_tree, node))
+		BUG();
+
+	spin_unlock(&mapping->tree_lock);
+
+	count_vm_event(WORKINGSET_NODES_RECLAIMED);
+
+	return LRU_REMOVED;
+}
+
+static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
+				       struct shrink_control *sc)
+{
+	unsigned long batch = NOIRQ_BATCH;
+	unsigned long freed;
+
+	local_irq_disable();
+	freed = list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
+				   shadow_lru_isolate, &batch, &sc->nr_to_scan);
+	local_irq_enable();
+
+	return freed;
+}
+
+static struct shrinker workingset_shadow_shrinker = {
+	.count_objects = count_shadow_nodes,
+	.scan_objects = scan_shadow_nodes,
+	.seeks = DEFAULT_SEEKS * 4,
+	.flags = SHRINKER_NUMA_AWARE,
+};
+
+static struct lock_class_key shadow_nodes_key;
+
+static int __init workingset_init(void)
+{
+	int ret;
+
+	ret = list_lru_init(&workingset_shadow_nodes, &shadow_nodes_key);
+	if (ret)
+		goto err;
+	ret = register_shrinker(&workingset_shadow_shrinker);
+	if (ret)
+		goto err_list_lru;
+	return 0;
+err_list_lru:
+	list_lru_destroy(&workingset_shadow_nodes);
+err:
+	return ret;
+}
+module_init(workingset_init);
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
