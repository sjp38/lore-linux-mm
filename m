Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD326B0281
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:42:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so1500769pgv.6
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:42:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h72si990495pfj.20.2017.12.05.16.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:14 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 58/73] dax: Convert lock_slot to XArray
Date: Tue,  5 Dec 2017 16:41:44 -0800
Message-Id: <20171206004159.3755-59-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 03bfa599f75c..d2007a17d257 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -188,15 +188,13 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 }
 
 /*
- * Mark the given slot is locked. The function must be called with
- * mapping xa_lock held
+ * Mark the given slot as locked.  Must be called with xa_lock held.
  */
-static inline void *lock_slot(struct address_space *mapping, void **slot)
+static inline void *lock_slot(struct xa_state *xas)
 {
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
+	unsigned long v = xa_to_value(xas_load(xas));
 	void *entry = xa_mk_value(v | DAX_ENTRY_LOCK);
-	radix_tree_replace_slot(&mapping->pages, slot, entry);
+	xas_store(xas, entry);
 	return entry;
 }
 
@@ -247,7 +245,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 
 	xas_lock_irq(&xas);
 	entry = xas_load(&xas);
-	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) || !dax_locked(entry))) {
+	if (WARN_ON_ONCE(!xa_is_value(entry) || !dax_locked(entry))) {
 		xas_unlock_irq(&xas);
 		return;
 	}
@@ -306,6 +304,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		unsigned long size_flag)
 {
+	XA_STATE(xas, &mapping->pages, index);
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
 	void *entry, **slot;
 
@@ -344,7 +343,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 			 * Make sure 'entry' remains valid while we drop
 			 * mapping xa_lock.
 			 */
-			entry = lock_slot(mapping, slot);
+			entry = lock_slot(&xas);
 		}
 
 		xa_unlock_irq(&mapping->pages);
@@ -411,7 +410,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		xa_unlock_irq(&mapping->pages);
 		return entry;
 	}
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
  out_unlock:
 	xa_unlock_irq(&mapping->pages);
 	return entry;
@@ -643,6 +642,7 @@ static int dax_writeback_one(struct block_device *bdev,
 		pgoff_t index, void *entry)
 {
 	struct radix_tree_root *pages = &mapping->pages;
+	XA_STATE(xas, pages, index);
 	void *entry2, **slot, *kaddr;
 	long ret = 0, id;
 	sector_t sector;
@@ -679,7 +679,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
 		goto put_unlocked;
 	/* Lock the entry to serialize with page faults */
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
 	/*
 	 * We can clear the tag now but we have to be careful so that concurrent
 	 * dax_writeback_one() calls for the same index cannot finish before we
@@ -1504,8 +1504,9 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 				  pfn_t pfn)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
-	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry, **slot;
 	int vmf_ret, error;
 
 	xa_lock_irq(&mapping->pages);
@@ -1521,7 +1522,7 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 		return VM_FAULT_NOPAGE;
 	}
 	radix_tree_tag_set(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
 	xa_unlock_irq(&mapping->pages);
 	switch (pe_size) {
 	case PE_SIZE_PTE:
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
