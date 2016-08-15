Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9147828F3
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:10:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so116543571pab.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:10:03 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.54
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:54 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 5/7] dax: lock based on slot instead of [mapping, index]
Date: Mon, 15 Aug 2016 13:09:16 -0600
Message-Id: <20160815190918.20672-6-ross.zwisler@linux.intel.com>
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

DAX radix tree locking currently locks entries based on the unique
combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
This works for PTEs, but as we move to PMDs we will need to have all the
offsets within the range covered by the PMD to map to the same bit lock.
To accomplish this, lock based on the 'slot' pointer in the radix tree
instead of [mapping, index].

When a PMD entry is present in the tree, all offsets will map to the same
'slot' via radix tree lookups, and they will all share the same locking.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 59 +++++++++++++++++++++--------------------------------
 include/linux/dax.h |  3 +--
 mm/filemap.c        |  3 +--
 3 files changed, 25 insertions(+), 40 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index fed6a52..0f1d053 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -62,11 +62,10 @@ static int __init init_dax_wait_table(void)
 }
 fs_initcall(init_dax_wait_table);
 
-static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
-					      pgoff_t index)
+static wait_queue_head_t *dax_entry_waitqueue(void **slot)
 {
-	unsigned long hash = hash_long((unsigned long)mapping ^ index,
-				       DAX_WAIT_TABLE_BITS);
+	unsigned long hash = hash_long((unsigned long)slot,
+					DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
@@ -281,25 +280,19 @@ EXPORT_SYMBOL_GPL(dax_do_io);
 /*
  * DAX radix tree locking
  */
-struct exceptional_entry_key {
-	struct address_space *mapping;
-	unsigned long index;
-};
-
 struct wait_exceptional_entry_queue {
 	wait_queue_t wait;
-	struct exceptional_entry_key key;
+	void **slot;
 };
 
 static int wake_exceptional_entry_func(wait_queue_t *wait, unsigned int mode,
 				       int sync, void *keyp)
 {
-	struct exceptional_entry_key *key = keyp;
+	void **slot = keyp;
 	struct wait_exceptional_entry_queue *ewait =
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
-	if (key->mapping != ewait->key.mapping ||
-	    key->index != ewait->key.index)
+	if (slot != ewait->slot)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
 }
@@ -357,12 +350,10 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 {
 	void *ret, **slot;
 	struct wait_exceptional_entry_queue ewait;
-	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
+	wait_queue_head_t *wq;
 
 	init_wait(&ewait.wait);
 	ewait.wait.func = wake_exceptional_entry_func;
-	ewait.key.mapping = mapping;
-	ewait.key.index = index;
 
 	for (;;) {
 		ret = __radix_tree_lookup(&mapping->page_tree, index, NULL,
@@ -373,6 +364,9 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 				*slotp = slot;
 			return ret;
 		}
+
+		wq = dax_entry_waitqueue(slot);
+		ewait.slot = slot;
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -445,10 +439,9 @@ restart:
 	return entry;
 }
 
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-				   pgoff_t index, bool wake_all)
+void dax_wake_mapping_entry_waiter(void **slot, bool wake_all)
 {
-	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
+	wait_queue_head_t *wq = dax_entry_waitqueue(slot);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -456,13 +449,8 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 	 * So at this point all tasks that could have seen our entry locked
 	 * must be in the waitqueue and the following check will see them.
 	 */
-	if (waitqueue_active(wq)) {
-		struct exceptional_entry_key key;
-
-		key.mapping = mapping;
-		key.index = index;
-		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
-	}
+	if (waitqueue_active(wq))
+		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, slot);
 }
 
 void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
@@ -478,7 +466,7 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 	}
 	unlock_slot(mapping, slot);
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(slot, false);
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
@@ -496,14 +484,13 @@ static void put_locked_mapping_entry(struct address_space *mapping,
  * Called when we are done with radix tree entry we looked up via
  * get_unlocked_mapping_entry() and which we didn't lock in the end.
  */
-static void put_unlocked_mapping_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
+static void put_unlocked_mapping_entry(void **slot, void *entry)
 {
 	if (!radix_tree_exceptional_entry(entry))
 		return;
 
 	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(slot, false);
 }
 
 /*
@@ -512,10 +499,10 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
  */
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
-	void *entry;
+	void *entry, **slot;
 
 	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 	/*
 	 * This gets called from truncate / punch_hole path. As such, the caller
 	 * must hold locks protecting against concurrent modifications of the
@@ -530,7 +517,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	radix_tree_delete(&mapping->page_tree, index);
 	mapping->nrexceptional--;
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, true);
+	dax_wake_mapping_entry_waiter(slot, true);
 
 	return 1;
 }
@@ -1118,15 +1105,15 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
-	void *entry;
+	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
 
 	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 	if (!entry || !radix_tree_exceptional_entry(entry))
 		goto out;
 	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
-	put_unlocked_mapping_entry(mapping, index, entry);
+	put_unlocked_mapping_entry(slot, entry);
 out:
 	spin_unlock_irq(&mapping->tree_lock);
 	return VM_FAULT_NOPAGE;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 9c6dc77..8bcb852 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -15,8 +15,7 @@ int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-				   pgoff_t index, bool wake_all);
+void dax_wake_mapping_entry_waiter(void **slot, bool wake_all);
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287df..56c4ac7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -617,8 +617,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			if (node)
 				workingset_node_pages_dec(node);
 			/* Wakeup waiters for exceptional entry lock */
-			dax_wake_mapping_entry_waiter(mapping, page->index,
-						      false);
+			dax_wake_mapping_entry_waiter(slot, false);
 		}
 	}
 	radix_tree_replace_slot(slot, page);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
