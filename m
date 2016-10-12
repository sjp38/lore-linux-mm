Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73C6A280251
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:36 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id os4so57883242pac.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:35 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 08/17] dax: coordinate locking for offsets in PMD range
Date: Wed, 12 Oct 2016 16:50:13 -0600
Message-Id: <20161012225022.15507-9-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX radix tree locking currently locks entries based on the unique
combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
This works for PTEs, but as we move to PMDs we will need to have all the
offsets within the range covered by the PMD to map to the same bit lock.
To accomplish this, for ranges covered by a PMD entry we will instead lock
based on the page offset of the beginning of the PMD entry.  The 'mapping'
pointer is still used in the same way.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 65 +++++++++++++++++++++++++++++++++--------------------
 include/linux/dax.h |  2 +-
 mm/filemap.c        |  2 +-
 3 files changed, 43 insertions(+), 26 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 152a6e1..e103053 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -64,14 +64,6 @@ static int __init init_dax_wait_table(void)
 }
 fs_initcall(init_dax_wait_table);
 
-static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
-					      pgoff_t index)
-{
-	unsigned long hash = hash_long((unsigned long)mapping ^ index,
-				       DAX_WAIT_TABLE_BITS);
-	return wait_table + hash;
-}
-
 static long dax_map_atomic(struct block_device *bdev, struct blk_dax_ctl *dax)
 {
 	struct request_queue *q = bdev->bd_queue;
@@ -285,7 +277,7 @@ EXPORT_SYMBOL_GPL(dax_do_io);
  */
 struct exceptional_entry_key {
 	struct address_space *mapping;
-	unsigned long index;
+	pgoff_t entry_start;
 };
 
 struct wait_exceptional_entry_queue {
@@ -293,6 +285,26 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
+static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
+		pgoff_t index, void *entry, struct exceptional_entry_key *key)
+{
+	unsigned long hash;
+
+	/*
+	 * If 'entry' is a PMD, align the 'index' that we use for the wait
+	 * queue to the start of that PMD.  This ensures that all offsets in
+	 * the range covered by the PMD map to the same bit lock.
+	 */
+	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
+		index &= ~((1UL << (PMD_SHIFT - PAGE_SHIFT)) - 1);
+
+	key->mapping = mapping;
+	key->entry_start = index;
+
+	hash = hash_long((unsigned long)mapping ^ index, DAX_WAIT_TABLE_BITS);
+	return wait_table + hash;
+}
+
 static int wake_exceptional_entry_func(wait_queue_t *wait, unsigned int mode,
 				       int sync, void *keyp)
 {
@@ -301,7 +313,7 @@ static int wake_exceptional_entry_func(wait_queue_t *wait, unsigned int mode,
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
 	if (key->mapping != ewait->key.mapping ||
-	    key->index != ewait->key.index)
+	    key->entry_start != ewait->key.entry_start)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
 }
@@ -359,12 +371,10 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 {
 	void *entry, **slot;
 	struct wait_exceptional_entry_queue ewait;
-	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
+	wait_queue_head_t *wq;
 
 	init_wait(&ewait.wait);
 	ewait.wait.func = wake_exceptional_entry_func;
-	ewait.key.mapping = mapping;
-	ewait.key.index = index;
 
 	for (;;) {
 		entry = __radix_tree_lookup(&mapping->page_tree, index, NULL,
@@ -375,6 +385,8 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 				*slotp = slot;
 			return entry;
 		}
+
+		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -447,10 +459,20 @@ restart:
 	return entry;
 }
 
+/*
+ * We do not necessarily hold the mapping->tree_lock when we call this
+ * function so it is possible that 'entry' is no longer a valid item in the
+ * radix tree.  This is okay, though, because all we really need to do is to
+ * find the correct waitqueue where tasks might be sleeping waiting for that
+ * old 'entry' and wake them.
+ */
 void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-				   pgoff_t index, bool wake_all)
+		pgoff_t index, void *entry, bool wake_all)
 {
-	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
+	struct exceptional_entry_key key;
+	wait_queue_head_t *wq;
+
+	wq = dax_entry_waitqueue(mapping, index, entry, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -458,13 +480,8 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 	 * So at this point all tasks that could have seen our entry locked
 	 * must be in the waitqueue and the following check will see them.
 	 */
-	if (waitqueue_active(wq)) {
-		struct exceptional_entry_key key;
-
-		key.mapping = mapping;
-		key.index = index;
+	if (waitqueue_active(wq))
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
-	}
 }
 
 void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
@@ -480,7 +497,7 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 	}
 	unlock_slot(mapping, slot);
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
@@ -505,7 +522,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 		return;
 
 	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
 }
 
 /*
@@ -532,7 +549,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	radix_tree_delete(&mapping->page_tree, index);
 	mapping->nrexceptional--;
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, true);
+	dax_wake_mapping_entry_waiter(mapping, index, entry, true);
 
 	return 1;
 }
diff --git a/include/linux/dax.h b/include/linux/dax.h
index add6c4b..a41a747 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -22,7 +22,7 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-				   pgoff_t index, bool wake_all);
+		pgoff_t index, void *entry, bool wake_all);
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
diff --git a/mm/filemap.c b/mm/filemap.c
index 2f1175e..a596462 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -617,7 +617,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			if (node)
 				workingset_node_pages_dec(node);
 			/* Wakeup waiters for exceptional entry lock */
-			dax_wake_mapping_entry_waiter(mapping, page->index,
+			dax_wake_mapping_entry_waiter(mapping, page->index, p,
 						      false);
 		}
 	}
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
