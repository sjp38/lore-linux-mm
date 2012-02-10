Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id BB55A6B13F2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:42:32 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3584330bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:42:32 -0800 (PST)
Subject: [PATCH 3/4] shmem: use radix-tree iterator in shmem_unuse_inode()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:42:29 +0400
Message-ID: <20120210194229.6492.77259.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patch rewrites shmem swap entry searching with using radix tree iterator
and removes radix_tree_locate_item() which is used only in shmem.
Tagged radix-tree iterating would skip normal pages much more effectively.

Test: push 1Gb tmpfs file into swap and call # time swapoff.
Virtual machine: without patch: 35 seconds, with patch: 7 seconds.
Real hardware: without patch: 180 seconds, with patch: 100 seconds.
(Vm: qemu, swap on ssd, mostly all in host ram. Rh: swap on hdd.)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/radix-tree.h |    1 
 lib/radix-tree.c           |   93 --------------------------------------------
 mm/shmem.c                 |   27 ++++++++++---
 3 files changed, 22 insertions(+), 99 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f59d6c8..665396f 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -250,7 +250,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		unsigned long nr_to_tag,
 		unsigned int fromtag, unsigned int totag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item);
 
 static inline void radix_tree_preload_end(void)
 {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index b0158a2..d193d27 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1120,99 +1120,6 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
 
-#if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
-#include <linux/sched.h> /* for cond_resched() */
-
-/*
- * This linear search is at present only useful to shmem_unuse_inode().
- */
-static unsigned long __locate(struct radix_tree_node *slot, void *item,
-			      unsigned long index, unsigned long *found_index)
-{
-	unsigned int shift, height;
-	unsigned long i;
-
-	height = slot->height;
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
-	/* Bottom level: check items */
-	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
-		if (slot->slots[i] == item) {
-			*found_index = index + i;
-			index = 0;
-			goto out;
-		}
-	}
-	index += RADIX_TREE_MAP_SIZE;
-out:
-	return index;
-}
-
-/**
- *	radix_tree_locate_item - search through radix tree for item
- *	@root:		radix tree root
- *	@item:		item to be found
- *
- *	Returns index where item was found, or -1 if not found.
- *	Caller must hold no lock (since this time-consuming function needs
- *	to be preemptible), and must check afterwards if item is still there.
- */
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
-{
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = 0;
-	unsigned long found_index = -1;
-
-	do {
-		rcu_read_lock();
-		node = rcu_dereference_raw(root->rnode);
-		if (!radix_tree_is_indirect_ptr(node)) {
-			rcu_read_unlock();
-			if (node == item)
-				found_index = 0;
-			break;
-		}
-
-		node = indirect_to_ptr(node);
-		max_index = radix_tree_maxindex(node->height);
-		if (cur_index > max_index)
-			break;
-
-		cur_index = __locate(node, item, cur_index, &found_index);
-		rcu_read_unlock();
-		cond_resched();
-	} while (cur_index != 0 && cur_index <= max_index);
-
-	return found_index;
-}
-#else
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
-{
-	return -1;
-}
-#endif /* CONFIG_SHMEM && CONFIG_SWAP */
-
 /**
  *	radix_tree_shrink    -    shrink height of a radix tree to minimal
  *	@root		radix tree root
diff --git a/mm/shmem.c b/mm/shmem.c
index b8e5f90..7a3fe08 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -613,14 +613,31 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 {
 	struct address_space *mapping = info->vfs_inode.i_mapping;
 	void *radswap;
-	pgoff_t index;
+	struct radix_tree_iter iter;
+	void **slot;
 	int error;
 
 	radswap = swp_to_radix_entry(swap);
-	index = radix_tree_locate_item(&mapping->page_tree, radswap);
-	if (index == -1)
-		return 0;
 
+	rcu_read_lock();
+	radix_tree_for_each_chunk(slot, &mapping->page_tree, &iter, 0,
+				RADIX_TREE_ITER_TAGGED | SHMEM_TAG_SWAP) {
+		radix_tree_for_each_chunk_slot(slot, &iter,
+						RADIX_TREE_ITER_TAGGED) {
+			if (*slot != radswap)
+				continue;
+			rcu_read_unlock();
+			goto found;
+		}
+		rcu_read_unlock();
+		cond_resched();
+		rcu_read_lock();
+	}
+	rcu_read_unlock();
+
+	return 0;
+
+found:
 	/*
 	 * Move _head_ to start search for next from here.
 	 * But be careful: shmem_evict_inode checks list_empty without taking
@@ -635,7 +652,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
 	 * beneath us (pagelock doesn't help until the page is in pagecache).
 	 */
-	error = shmem_add_to_page_cache(page, mapping, index,
+	error = shmem_add_to_page_cache(page, mapping, iter.index,
 						GFP_NOWAIT, radswap);
 	/* which does mem_cgroup_uncharge_cache_page on error */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
