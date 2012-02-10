Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B406A6B1405
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:25:49 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3571094bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:25:49 -0800 (PST)
Subject: [PATCH v2 2/3] radix-tree: rewrite gang lookup with using iterator
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:25:46 +0400
Message-ID: <20120210192546.5881.63871.stgit@zurg>
In-Reply-To: <20120210191611.5881.12646.stgit@zurg>
References: <20120210191611.5881.12646.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Rewrite radix_tree_gang_lookup_* functions with using radix-tree iterator.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 lib/radix-tree.c |  291 ++++++------------------------------------------------
 1 files changed, 33 insertions(+), 258 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7545d39..b0158a2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -964,57 +964,6 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_prev_hole);
 
-static unsigned int
-__lookup(struct radix_tree_node *slot, void ***results, unsigned long *indices,
-	unsigned long index, unsigned int max_items, unsigned long *next_index)
-{
-	unsigned int nr_found = 0;
-	unsigned int shift, height;
-	unsigned long i;
-
-	height = slot->height;
-	if (height == 0)
-		goto out;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	for ( ; height > 1; height--) {
-		i = (index >> shift) & RADIX_TREE_MAP_MASK;
-		for (;;) {
-			if (slot->slots[i] != NULL)
-				break;
-			index &= ~((1UL << shift) - 1);
-			index += 1UL << shift;
-			if (index == 0)
-				goto out;	/* 32-bit wraparound */
-			i++;
-			if (i == RADIX_TREE_MAP_SIZE)
-				goto out;
-		}
-
-		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = rcu_dereference_raw(slot->slots[i]);
-		if (slot == NULL)
-			goto out;
-	}
-
-	/* Bottom level: grab some items */
-	for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
-		if (slot->slots[i]) {
-			results[nr_found] = &(slot->slots[i]);
-			if (indices)
-				indices[nr_found] = index;
-			if (++nr_found == max_items) {
-				index++;
-				goto out;
-			}
-		}
-		index++;
-	}
-out:
-	*next_index = index;
-	return nr_found;
-}
-
 /**
  *	radix_tree_gang_lookup - perform multiple lookup on a radix tree
  *	@root:		radix tree root
@@ -1038,48 +987,19 @@ unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items)
 {
-	unsigned long max_index;
-	struct radix_tree_node *node;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
+	if (unlikely(!max_items))
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = node;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int nr_found, slots_found, i;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup(node, (void ***)results + ret, NULL,
-				cur_index, max_items - ret, &next_index);
-		nr_found = 0;
-		for (i = 0; i < slots_found; i++) {
-			struct radix_tree_node *slot;
-			slot = *(((void ***)results)[ret + i]);
-			if (!slot)
-				continue;
-			results[ret + nr_found] =
-				indirect_to_ptr(rcu_dereference_raw(slot));
-			nr_found++;
-		}
-		ret += nr_found;
-		if (next_index == 0)
+	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		if (!results[ret])
+			continue;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;
@@ -1109,112 +1029,25 @@ radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			void ***results, unsigned long *indices,
 			unsigned long first_index, unsigned int max_items)
 {
-	unsigned long max_index;
-	struct radix_tree_node *node;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
+	if (unlikely(!max_items))
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = (void **)&root->rnode;
+	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+		results[ret] = slot;
 		if (indices)
-			indices[0] = 0;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int slots_found;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup(node, results + ret,
-				indices ? indices + ret : NULL,
-				cur_index, max_items - ret, &next_index);
-		ret += slots_found;
-		if (next_index == 0)
+			indices[ret] = iter.index;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
 
-/*
- * FIXME: the two tag_get()s here should use find_next_bit() instead of
- * open-coding the search.
- */
-static unsigned int
-__lookup_tag(struct radix_tree_node *slot, void ***results, unsigned long index,
-	unsigned int max_items, unsigned long *next_index, unsigned int tag)
-{
-	unsigned int nr_found = 0;
-	unsigned int shift, height;
-
-	height = slot->height;
-	if (height == 0)
-		goto out;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	while (height > 0) {
-		unsigned long i = (index >> shift) & RADIX_TREE_MAP_MASK ;
-
-		for (;;) {
-			if (tag_get(slot, tag, i))
-				break;
-			index &= ~((1UL << shift) - 1);
-			index += 1UL << shift;
-			if (index == 0)
-				goto out;	/* 32-bit wraparound */
-			i++;
-			if (i == RADIX_TREE_MAP_SIZE)
-				goto out;
-		}
-		height--;
-		if (height == 0) {	/* Bottom level: grab some items */
-			unsigned long j = index & RADIX_TREE_MAP_MASK;
-
-			for ( ; j < RADIX_TREE_MAP_SIZE; j++) {
-				index++;
-				if (!tag_get(slot, tag, j))
-					continue;
-				/*
-				 * Even though the tag was found set, we need to
-				 * recheck that we have a non-NULL node, because
-				 * if this lookup is lockless, it may have been
-				 * subsequently deleted.
-				 *
-				 * Similar care must be taken in any place that
-				 * lookup ->slots[x] without a lock (ie. can't
-				 * rely on its value remaining the same).
-				 */
-				if (slot->slots[j]) {
-					results[nr_found++] = &(slot->slots[j]);
-					if (nr_found == max_items)
-						goto out;
-				}
-			}
-		}
-		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = rcu_dereference_raw(slot->slots[i]);
-		if (slot == NULL)
-			break;
-	}
-out:
-	*next_index = index;
-	return nr_found;
-}
-
 /**
  *	radix_tree_gang_lookup_tag - perform multiple lookup on a radix tree
  *	                             based on a tag
@@ -1233,52 +1066,19 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag)
 {
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	/* check the root's tag bit */
-	if (!root_tag_get(root, tag))
+	if (unlikely(!max_items))
 		return 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
-		return 0;
-
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = node;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int nr_found, slots_found, i;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup_tag(node, (void ***)results + ret,
-				cur_index, max_items - ret, &next_index, tag);
-		nr_found = 0;
-		for (i = 0; i < slots_found; i++) {
-			struct radix_tree_node *slot;
-			slot = *(((void ***)results)[ret + i]);
-			if (!slot)
-				continue;
-			results[ret + nr_found] =
-				indirect_to_ptr(rcu_dereference_raw(slot));
-			nr_found++;
-		}
-		ret += nr_found;
-		if (next_index == 0)
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		if (!results[ret])
+			continue;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;
@@ -1303,42 +1103,17 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag)
 {
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	/* check the root's tag bit */
-	if (!root_tag_get(root, tag))
-		return 0;
-
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
+	if (unlikely(!max_items))
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = (void **)&root->rnode;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int slots_found;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup_tag(node, results + ret,
-				cur_index, max_items - ret, &next_index, tag);
-		ret += slots_found;
-		if (next_index == 0)
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+		results[ret] = slot;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
