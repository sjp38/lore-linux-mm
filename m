Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0106128028C
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:48:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so50554285pfj.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:48:21 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id ez7si4297005pab.6.2016.09.27.13.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 13:48:20 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 07/11] dax: coordinate locking for offsets in PMD range
Date: Tue, 27 Sep 2016 14:47:58 -0600
Message-Id: <1475009282-9818-8-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX radix tree locking currently locks entries based on the unique
combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
This works for PTEs, but as we move to PMDs we will need to have all the
offsets within the range covered by the PMD to map to the same bit lock.
To accomplish this, for ranges covered by a PMD entry we will instead lock
based on the page offset of the beginning of the PMD entry.  The 'mapping'
pointer is still used in the same way.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 37 ++++++++++++++++++++++++-------------
 include/linux/dax.h |  2 +-
 mm/filemap.c        |  2 +-
 3 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index baef586..406feea 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -64,10 +64,17 @@ static int __init init_dax_wait_table(void)
 }
 fs_initcall(init_dax_wait_table);
 
+static pgoff_t dax_entry_start(pgoff_t index, void *entry)
+{
+	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
+		index &= (PMD_MASK >> PAGE_SHIFT);
+	return index;
+}
+
 static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
-					      pgoff_t index)
+					      pgoff_t entry_start)
 {
-	unsigned long hash = hash_long((unsigned long)mapping ^ index,
+	unsigned long hash = hash_long((unsigned long)mapping ^ entry_start,
 				       DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
@@ -285,7 +292,7 @@ EXPORT_SYMBOL_GPL(dax_do_io);
  */
 struct exceptional_entry_key {
 	struct address_space *mapping;
-	unsigned long index;
+	pgoff_t entry_start;
 };
 
 struct wait_exceptional_entry_queue {
@@ -301,7 +308,7 @@ static int wake_exceptional_entry_func(wait_queue_t *wait, unsigned int mode,
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
 	if (key->mapping != ewait->key.mapping ||
-	    key->index != ewait->key.index)
+	    key->entry_start != ewait->key.entry_start)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
 }
@@ -359,12 +366,10 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
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
@@ -375,6 +380,11 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 				*slotp = slot;
 			return entry;
 		}
+
+		wq = dax_entry_waitqueue(mapping,
+				dax_entry_start(index, entry));
+		ewait.key.mapping = mapping;
+		ewait.key.entry_start = dax_entry_start(index, entry);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -447,10 +457,11 @@ restart:
 	return entry;
 }
 
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
+void dax_wake_mapping_entry_waiter(void *entry, struct address_space *mapping,
 				   pgoff_t index, bool wake_all)
 {
-	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
+	wait_queue_head_t *wq = dax_entry_waitqueue(mapping,
+						dax_entry_start(index, entry));
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -462,7 +473,7 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		struct exceptional_entry_key key;
 
 		key.mapping = mapping;
-		key.index = index;
+		key.entry_start = dax_entry_start(index, entry);
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 	}
 }
@@ -480,7 +491,7 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 	}
 	unlock_slot(mapping, slot);
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(entry, mapping, index, false);
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
@@ -505,7 +516,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 		return;
 
 	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, false);
+	dax_wake_mapping_entry_waiter(entry, mapping, index, false);
 }
 
 /*
@@ -532,7 +543,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	radix_tree_delete(&mapping->page_tree, index);
 	mapping->nrexceptional--;
 	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, true);
+	dax_wake_mapping_entry_waiter(entry, mapping, index, true);
 
 	return 1;
 }
diff --git a/include/linux/dax.h b/include/linux/dax.h
index add6c4b..4065601 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -21,7 +21,7 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			struct iomap_ops *ops);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
+void dax_wake_mapping_entry_waiter(void *entry, struct address_space *mapping,
 				   pgoff_t index, bool wake_all);
 
 #ifdef CONFIG_FS_DAX
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287df..35e880d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -617,7 +617,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			if (node)
 				workingset_node_pages_dec(node);
 			/* Wakeup waiters for exceptional entry lock */
-			dax_wake_mapping_entry_waiter(mapping, page->index,
+			dax_wake_mapping_entry_waiter(p, mapping, page->index,
 						      false);
 		}
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
