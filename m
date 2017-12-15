Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCD006B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:35 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id h200so16742242itb.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r62si2306194itg.15.2017.12.15.14.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:34 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 59/78] dax: Convert lock_slot to XArray
Date: Fri, 15 Dec 2017 14:04:31 -0800
Message-Id: <20171215220450.7899-60-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index dd4674ce48f5..46a4d83b1b46 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -188,12 +188,11 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 /*
  * Mark the given slot as locked.  Must be called with xa_lock held.
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
 
@@ -244,7 +243,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 
 	xas_lock_irq(&xas);
 	entry = xas_load(&xas);
-	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) || !dax_locked(entry))) {
+	if (WARN_ON_ONCE(!xa_is_value(entry) || !dax_locked(entry))) {
 		xas_unlock_irq(&xas);
 		return;
 	}
@@ -303,6 +302,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		unsigned long size_flag)
 {
+	XA_STATE(xas, &mapping->pages, index);
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
 	void *entry, **slot;
 
@@ -341,7 +341,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 			 * Make sure 'entry' remains valid while we drop
 			 * xa_lock.
 			 */
-			entry = lock_slot(mapping, slot);
+			entry = lock_slot(&xas);
 		}
 
 		xa_unlock_irq(&mapping->pages);
@@ -408,7 +408,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		xa_unlock_irq(&mapping->pages);
 		return entry;
 	}
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
  out_unlock:
 	xa_unlock_irq(&mapping->pages);
 	return entry;
@@ -640,6 +640,7 @@ static int dax_writeback_one(struct block_device *bdev,
 		pgoff_t index, void *entry)
 {
 	struct radix_tree_root *pages = &mapping->pages;
+	XA_STATE(xas, pages, index);
 	void *entry2, **slot, *kaddr;
 	long ret = 0, id;
 	sector_t sector;
@@ -676,7 +677,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
 		goto put_unlocked;
 	/* Lock the entry to serialize with page faults */
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
 	/*
 	 * We can clear the tag now but we have to be careful so that concurrent
 	 * dax_writeback_one() calls for the same index cannot finish before we
@@ -1501,8 +1502,9 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 				  pfn_t pfn)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
-	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry, **slot;
 	int vmf_ret, error;
 
 	xa_lock_irq(&mapping->pages);
@@ -1518,7 +1520,7 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 		return VM_FAULT_NOPAGE;
 	}
 	radix_tree_tag_set(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
-	entry = lock_slot(mapping, slot);
+	entry = lock_slot(&xas);
 	xa_unlock_irq(&mapping->pages);
 	switch (pe_size) {
 	case PE_SIZE_PTE:
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
