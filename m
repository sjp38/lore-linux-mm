Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02F146B0267
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:47:03 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so5322229wjc.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:47:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ju1si35907365wjc.128.2016.11.24.01.47.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 01:47:01 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if appropriate
Date: Thu, 24 Nov 2016 10:46:32 +0100
Message-Id: <1479980796-26161-3-git-send-email-jack@suse.cz>
In-Reply-To: <1479980796-26161-1-git-send-email-jack@suse.cz>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Currently invalidate_inode_pages2_range() and invalidate_mapping_pages()
just delete all exceptional radix tree entries they find. For DAX this
is not desirable as we track cache dirtiness in these entries and when
they are evicted, we may not flush caches although it is necessary. This
can for example manifest when we write to the same block both via mmap
and via write(2) (to different offsets) and fsync(2) then does not
properly flush CPU caches when modification via write(2) was the last
one.

Create appropriate DAX functions to handle invalidation of DAX entries
for invalidate_inode_pages2_range() and invalidate_mapping_pages() and
wire them up into the corresponding mm functions.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 71 +++++++++++++++++++++++++++++++++++++++++++++--------
 include/linux/dax.h |  3 +++
 mm/truncate.c       | 71 ++++++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 123 insertions(+), 22 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index cafd5597434b..4534f0e232e9 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -452,16 +452,37 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
+static int __dax_invalidate_mapping_entry(struct address_space *mapping,
+					  pgoff_t index, bool trunc)
+{
+	int ret = 0;
+	void *entry;
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	if (!entry || !radix_tree_exceptional_entry(entry))
+		goto out;
+	if (!trunc &&
+	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
+	     radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE)))
+		goto out;
+	radix_tree_delete(page_tree, index);
+	mapping->nrexceptional--;
+	ret = 1;
+out:
+	put_unlocked_mapping_entry(mapping, index, entry);
+	spin_unlock_irq(&mapping->tree_lock);
+	return ret;
+}
 /*
  * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
  * entry to get unlocked before deleting it.
  */
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
-	void *entry;
+	int ret = __dax_invalidate_mapping_entry(mapping, index, true);
 
-	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
 	/*
 	 * This gets called from truncate / punch_hole path. As such, the caller
 	 * must hold locks protecting against concurrent modifications of the
@@ -469,16 +490,46 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	 * caller has seen exceptional entry for this index, we better find it
 	 * at that index as well...
 	 */
-	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry))) {
-		spin_unlock_irq(&mapping->tree_lock);
-		return 0;
-	}
-	radix_tree_delete(&mapping->page_tree, index);
+	WARN_ON_ONCE(!ret);
+	return ret;
+}
+
+/*
+ * Invalidate exceptional DAX entry if easily possible. This handles DAX
+ * entries for invalidate_inode_pages() so we evict the entry only if we can
+ * do so without blocking.
+ */
+int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index)
+{
+	int ret = 0;
+	void *entry, **slot;
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = __radix_tree_lookup(page_tree, index, NULL, &slot);
+	if (!entry || !radix_tree_exceptional_entry(entry) ||
+	    slot_locked(mapping, slot))
+		goto out;
+	if (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
+	    radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
+		goto out;
+	radix_tree_delete(page_tree, index);
 	mapping->nrexceptional--;
+	ret = 1;
+out:
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, entry, true);
+	if (ret)
+		dax_wake_mapping_entry_waiter(mapping, index, entry, true);
+	return ret;
+}
 
-	return 1;
+/*
+ * Invalidate exceptional DAX entry if it is clean.
+ */
+int dax_invalidate_clean_mapping_entry(struct address_space *mapping,
+				       pgoff_t index)
+{
+	return __dax_invalidate_mapping_entry(mapping, index, false);
 }
 
 /*
diff --git a/include/linux/dax.h b/include/linux/dax.h
index f97bcfe79472..6e36b11285b0 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -41,6 +41,9 @@ ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			struct iomap_ops *ops);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
+int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index);
+int dax_invalidate_clean_mapping_entry(struct address_space *mapping,
+				       pgoff_t index);
 void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		pgoff_t index, void *entry, bool wake_all);
 
diff --git a/mm/truncate.c b/mm/truncate.c
index a01cce450a26..215c5edfd11e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -30,14 +30,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	struct radix_tree_node *node;
 	void **slot;
 
-	/* Handled by shmem itself */
-	if (shmem_mapping(mapping))
-		return;
-
-	if (dax_mapping(mapping)) {
-		dax_delete_mapping_entry(mapping, index);
-		return;
-	}
 	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * Regular page slots are stabilized by the page lock even
@@ -70,6 +62,56 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
+/*
+ * Unconditionally remove exceptional entry. Usually called from truncate path.
+ */
+static void truncate_exceptional_entry(struct address_space *mapping,
+				       pgoff_t index, void *entry)
+{
+	/* Handled by shmem itself */
+	if (shmem_mapping(mapping))
+		return;
+
+	if (dax_mapping(mapping)) {
+		dax_delete_mapping_entry(mapping, index);
+		return;
+	}
+	clear_exceptional_entry(mapping, index, entry);
+}
+
+/*
+ * Invalidate exceptional entry if easily possible. This handles exceptional
+ * entries for invalidate_inode_pages() so for DAX it evicts only unlocked and
+ * clean entries.
+ */
+static int invalidate_exceptional_entry(struct address_space *mapping,
+					pgoff_t index, void *entry)
+{
+	/* Handled by shmem itself */
+	if (shmem_mapping(mapping))
+		return 1;
+	if (dax_mapping(mapping))
+		return dax_invalidate_mapping_entry(mapping, index);
+	clear_exceptional_entry(mapping, index, entry);
+	return 1;
+}
+
+/*
+ * Invalidate exceptional entry if clean. This handles exceptional entries for
+ * invalidate_inode_pages2() so for DAX it evicts only clean entries.
+ */
+static int invalidate_exceptional_entry2(struct address_space *mapping,
+					 pgoff_t index, void *entry)
+{
+	/* Handled by shmem itself */
+	if (shmem_mapping(mapping))
+		return 1;
+	if (dax_mapping(mapping))
+		return dax_invalidate_clean_mapping_entry(mapping, index);
+	clear_exceptional_entry(mapping, index, entry);
+	return 1;
+}
+
 /**
  * do_invalidatepage - invalidate part or all of a page
  * @page: the page which is affected
@@ -277,7 +319,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
+				truncate_exceptional_entry(mapping, index,
+							   page);
 				continue;
 			}
 
@@ -366,7 +409,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			}
 
 			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
+				truncate_exceptional_entry(mapping, index,
+							   page);
 				continue;
 			}
 
@@ -485,7 +529,8 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
+				invalidate_exceptional_entry(mapping, index,
+							     page);
 				continue;
 			}
 
@@ -607,7 +652,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
+				if (!invalidate_exceptional_entry2(mapping,
+								   index, page))
+					ret = -EBUSY;
 				continue;
 			}
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
