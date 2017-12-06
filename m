Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D59146B0284
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:42:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 73so1617887pfz.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:42:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y128si984202pfy.128.2017.12.05.16.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:15 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 59/73] dax: More XArray conversion
Date: Tue,  5 Dec 2017 16:41:45 -0800
Message-Id: <20171206004159.3755-60-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This time, we want to convert get_unlocked_mapping_entry() to use the
XArray.  That has a ripple effect, causing us to change the waitqueues
to hash on the address of the xarray rather than the address of the
mapping (functionally equivalent), and create a lot of on-the-stack
xa_state which are only used as a container for passing the xarray and
the index down to deeper function calls.

Also rename dax_wake_mapping_entry_waiter() to dax_wake_entry().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 80 +++++++++++++++++++++++++++++-----------------------------------
 1 file changed, 36 insertions(+), 44 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d2007a17d257..ad984dece12e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -120,7 +120,7 @@ static int dax_is_empty_entry(void *entry)
  * DAX radix tree locking
  */
 struct exceptional_entry_key {
-	struct address_space *mapping;
+	struct xarray *xa;
 	pgoff_t entry_start;
 };
 
@@ -129,9 +129,10 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
-static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
-		pgoff_t index, void *entry, struct exceptional_entry_key *key)
+static wait_queue_head_t *dax_entry_waitqueue(struct xa_state *xas,
+		void *entry, struct exceptional_entry_key *key)
 {
+	unsigned long index = xas->xa_index;
 	unsigned long hash;
 
 	/*
@@ -142,10 +143,10 @@ static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
 	if (dax_is_pmd_entry(entry))
 		index &= ~PG_PMD_COLOUR;
 
-	key->mapping = mapping;
+	key->xa = xas->xa;
 	key->entry_start = index;
 
-	hash = hash_long((unsigned long)mapping ^ index, DAX_WAIT_TABLE_BITS);
+	hash = hash_long((unsigned long)xas->xa ^ index, DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
@@ -156,26 +157,23 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
 	struct wait_exceptional_entry_queue *ewait =
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
-	if (key->mapping != ewait->key.mapping ||
+	if (key->xa != ewait->key.xa ||
 	    key->entry_start != ewait->key.entry_start)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
 }
 
 /*
- * We do not necessarily hold the mapping xa_lock when we call this
- * function so it is possible that 'entry' is no longer a valid item in the
- * radix tree.  This is okay because all we really need to do is to find the
- * correct waitqueue where tasks might be waiting for that old 'entry' and
- * wake them.
+ * @entry may no longer be the entry at the index in the array.  The
+ * important information it's conveying is whether the entry at this
+ * index *used* to be a PMD entry..
  */
-static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-		pgoff_t index, void *entry, bool wake_all)
+static void dax_wake_entry(struct xa_state *xas, void *entry, bool wake_all)
 {
 	struct exceptional_entry_key key;
 	wait_queue_head_t *wq;
 
-	wq = dax_entry_waitqueue(mapping, index, entry, &key);
+	wq = dax_entry_waitqueue(xas, entry, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -207,10 +205,9 @@ static inline void *lock_slot(struct xa_state *xas)
  *
  * The function must be called with mapping xa_lock held.
  */
-static void *get_unlocked_mapping_entry(struct address_space *mapping,
-					pgoff_t index, void ***slotp)
+static void *get_unlocked_mapping_entry(struct xa_state *xas)
 {
-	void *entry, **slot;
+	void *entry;
 	struct wait_exceptional_entry_queue ewait;
 	wait_queue_head_t *wq;
 
@@ -218,22 +215,19 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	ewait.wait.func = wake_exceptional_entry_func;
 
 	for (;;) {
-		entry = __radix_tree_lookup(&mapping->pages, index, NULL,
-					  &slot);
-		if (!entry ||
-		    WARN_ON_ONCE(!xa_is_value(entry)) || !dax_locked(entry)) {
-			if (slotp)
-				*slotp = slot;
+		entry = xas_load(xas);
+		if (!entry || WARN_ON_ONCE(!xa_is_value(entry)) ||
+		    !dax_locked(entry))
 			return entry;
-		}
 
-		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
+		wq = dax_entry_waitqueue(xas, entry, &ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
-		xa_unlock_irq(&mapping->pages);
+		xas_pause(xas);
+		xas_unlock_irq(xas);
 		schedule();
 		finish_wait(wq, &ewait.wait);
-		xa_lock_irq(&mapping->pages);
+		xas_lock_irq(xas);
 	}
 }
 
@@ -253,7 +247,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 	xas_store(&xas, entry);
 	/* Safe to not call xas_pause here -- we don't touch the array after */
 	xas_unlock_irq(&xas);
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	dax_wake_entry(&xas, entry, false);
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
@@ -266,14 +260,13 @@ static void put_locked_mapping_entry(struct address_space *mapping,
  * Called when we are done with radix tree entry we looked up via
  * get_unlocked_mapping_entry() and which we didn't lock in the end.
  */
-static void put_unlocked_mapping_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
+static void put_unlocked_mapping_entry(struct xa_state *xas, void *entry)
 {
 	if (!entry)
 		return;
 
 	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	dax_wake_entry(xas, entry, false);
 }
 
 /*
@@ -310,7 +303,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 
 restart:
 	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	entry = get_unlocked_mapping_entry(&xas);
 
 	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
 		entry = ERR_PTR(-EIO);
@@ -320,8 +313,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	if (entry) {
 		if (size_flag & DAX_PMD) {
 			if (dax_is_pte_entry(entry)) {
-				put_unlocked_mapping_entry(mapping, index,
-						entry);
+				put_unlocked_mapping_entry(&xas, entry);
 				entry = ERR_PTR(-EEXIST);
 				goto out_unlock;
 			}
@@ -384,8 +376,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		if (pmd_downgrade) {
 			radix_tree_delete(&mapping->pages, index);
 			mapping->nrexceptional--;
-			dax_wake_mapping_entry_waiter(mapping, index, entry,
-					true);
+			dax_wake_entry(&xas, entry, true);
 		}
 
 		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
@@ -419,12 +410,13 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
+	XA_STATE(xas, &mapping->pages, index);
 	int ret = 0;
 	void *entry;
 	struct radix_tree_root *pages = &mapping->pages;
 
 	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	entry = get_unlocked_mapping_entry(&xas);
 	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
@@ -435,7 +427,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	mapping->nrexceptional--;
 	ret = 1;
 out:
-	put_unlocked_mapping_entry(mapping, index, entry);
+	put_unlocked_mapping_entry(&xas, entry);
 	xa_unlock_irq(&mapping->pages);
 	return ret;
 }
@@ -643,7 +635,7 @@ static int dax_writeback_one(struct block_device *bdev,
 {
 	struct radix_tree_root *pages = &mapping->pages;
 	XA_STATE(xas, pages, index);
-	void *entry2, **slot, *kaddr;
+	void *entry2, *kaddr;
 	long ret = 0, id;
 	sector_t sector;
 	pgoff_t pgoff;
@@ -658,7 +650,7 @@ static int dax_writeback_one(struct block_device *bdev,
 		return -EIO;
 
 	xa_lock_irq(&mapping->pages);
-	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
+	entry2 = get_unlocked_mapping_entry(&xas);
 	/* Entry got punched out / reallocated? */
 	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
 		goto put_unlocked;
@@ -736,7 +728,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	return ret;
 
  put_unlocked:
-	put_unlocked_mapping_entry(mapping, index, entry2);
+	put_unlocked_mapping_entry(&xas, entry2);
 	xa_unlock_irq(&mapping->pages);
 	return ret;
 }
@@ -1506,16 +1498,16 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	pgoff_t index = vmf->pgoff;
 	XA_STATE(xas, &mapping->pages, index);
-	void *entry, **slot;
+	void *entry;
 	int vmf_ret, error;
 
 	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	entry = get_unlocked_mapping_entry(&xas);
 	/* Did we race with someone splitting entry or so? */
 	if (!entry ||
 	    (pe_size == PE_SIZE_PTE && !dax_is_pte_entry(entry)) ||
 	    (pe_size == PE_SIZE_PMD && !dax_is_pmd_entry(entry))) {
-		put_unlocked_mapping_entry(mapping, index, entry);
+		put_unlocked_mapping_entry(&xas, entry);
 		xa_unlock_irq(&mapping->pages);
 		trace_dax_insert_pfn_mkwrite_no_entry(mapping->host, vmf,
 						      VM_FAULT_NOPAGE);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
