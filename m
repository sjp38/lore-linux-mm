Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 416E86B002F
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w9-v6so7599442plp.0
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l2si5982383pgq.460.2018.04.14.07.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:31 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 55/63] dax: Convert dax_insert_pfn_mkwrite to XArray
Date: Sat, 14 Apr 2018 07:13:08 -0700
Message-Id: <20180414141316.7167-56-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Add some XArray-based helper functions to replace the radix tree based
metaphors currently in use.  The biggest change is that converted code
doesn't see its own lock bit; get_unlocked_entry() always returns an
entry with the lock bit clear, and locking the entry now returns void.
So we don't have to mess around loading the current entry and clearing
the lock bit; we can just store the entry that we were using.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 146 +++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 115 insertions(+), 31 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index af669ca5020a..19ac013204a1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -38,6 +38,17 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/fs_dax.h>
 
+static inline unsigned int pe_order(enum page_entry_size pe_size)
+{
+	if (pe_size == PE_SIZE_PTE)
+		return PAGE_SHIFT - PAGE_SHIFT;
+	if (pe_size == PE_SIZE_PMD)
+		return PMD_SHIFT - PAGE_SHIFT;
+	if (pe_size == PE_SIZE_PUD)
+		return PUD_SHIFT - PAGE_SHIFT;
+	return ~0;
+}
+
 /* We choose 4096 entries - same as per-zone page wait tables */
 #define DAX_WAIT_TABLE_BITS 12
 #define DAX_WAIT_TABLE_ENTRIES (1 << DAX_WAIT_TABLE_BITS)
@@ -46,6 +57,9 @@
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 #define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)
 
+/* The order of a PMD entry */
+#define PMD_ORDER	(PMD_SHIFT - PAGE_SHIFT)
+
 static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
 
 static int __init init_dax_wait_table(void)
@@ -85,10 +99,15 @@ static void *dax_mk_locked(unsigned long pfn, unsigned long flags)
 			DAX_ENTRY_LOCK);
 }
 
+static bool dax_is_locked(void *entry)
+{
+	return xa_to_value(entry) & DAX_ENTRY_LOCK;
+}
+
 static unsigned int dax_entry_order(void *entry)
 {
 	if (xa_to_value(entry) & DAX_PMD)
-		return PMD_SHIFT - PAGE_SHIFT;
+		return PMD_ORDER;
 	return 0;
 }
 
@@ -181,6 +200,79 @@ static void dax_wake_mapping_entry_waiter(struct xarray *xa,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
+static void dax_wake_entry(struct xa_state *xas, bool wake_all)
+{
+	return dax_wake_mapping_entry_waiter(xas->xa, xas->xa_index, NULL,
+								wake_all);
+}
+
+/*
+ * Look up entry in page cache, wait for it to become unlocked if it
+ * is a DAX entry and return it.  The caller must subsequently call
+ * put_unlocked_entry() if it did not lock the entry or put_locked_entry()
+ * if it did.
+ *
+ * Must be called with the i_pages lock held.
+ */
+static void *get_unlocked_entry(struct xa_state *xas)
+{
+	void *entry;
+	struct wait_exceptional_entry_queue ewait;
+	wait_queue_head_t *wq;
+
+	init_wait(&ewait.wait);
+	ewait.wait.func = wake_exceptional_entry_func;
+
+	for (;;) {
+		entry = xas_load(xas);
+		if (!entry || xa_is_internal(entry) ||
+				WARN_ON_ONCE(!xa_is_value(entry)) ||
+				!dax_is_locked(entry))
+			return entry;
+
+		wq = dax_entry_waitqueue(xas->xa, xas->xa_index, entry,
+				&ewait.key);
+		prepare_to_wait_exclusive(wq, &ewait.wait,
+					  TASK_UNINTERRUPTIBLE);
+		xas_unlock_irq(xas);
+		xas_reset(xas);
+		schedule();
+		finish_wait(wq, &ewait.wait);
+		xas_lock_irq(xas);
+	}
+}
+
+static void put_unlocked_entry(struct xa_state *xas, void *entry)
+{
+	/* We wake all waiters whenever we store a NULL entry */
+	if (!entry)
+		return;
+	dax_wake_entry(xas, false);
+}
+
+/*
+ * We must have used the xa_state to get the entry, but then we locked the
+ * entry and dropped the xa_lock, so we know the xa_state is stale and must
+ * be reset before use.
+ */
+static void put_locked_entry(struct xa_state *xas, void *entry)
+{
+	void *old;
+
+	xas_reset(xas);
+	xas_lock_irq(xas);
+	old = xas_store(xas, entry);
+	xas_unlock_irq(xas);
+	BUG_ON(!dax_is_locked(old));
+	dax_wake_entry(xas, false);
+}
+
+static void dax_lock_entry(struct xa_state *xas, void *entry)
+{
+	unsigned long v = xa_to_value(entry);
+	xas_store(xas, xa_mk_value(v | DAX_ENTRY_LOCK));
+}
+
 /*
  * Check whether the given slot is locked.  Must be called with the i_pages
  * lock held.
@@ -1521,51 +1613,48 @@ EXPORT_SYMBOL_GPL(dax_iomap_fault);
 /*
  * dax_insert_pfn_mkwrite - insert PTE or PMD entry into page tables
  * @vmf: The description of the fault
- * @pe_size: Size of entry to be inserted
  * @pfn: PFN to insert
+ * @order: Order of entry to insert.
  *
  * This function inserts a writeable PTE or PMD entry into the page tables
  * for an mmaped DAX file.  It also marks the page cache entry as dirty.
  */
-static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
-				  enum page_entry_size pe_size,
-				  pfn_t pfn)
+static
+int dax_insert_pfn_mkwrite(struct vm_fault *vmf, pfn_t pfn, unsigned int order)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
-	void *entry, **slot;
-	pgoff_t index = vmf->pgoff;
+	XA_STATE_ORDER(xas, &mapping->i_pages, vmf->pgoff, order);
+	void *entry;
 	int vmf_ret, error;
 
-	xa_lock_irq(&mapping->i_pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	xas_lock_irq(&xas);
+	entry = get_unlocked_entry(&xas);
 	/* Did we race with someone splitting entry or so? */
 	if (!entry ||
-	    (pe_size == PE_SIZE_PTE && !dax_is_pte_entry(entry)) ||
-	    (pe_size == PE_SIZE_PMD && !dax_is_pmd_entry(entry))) {
-		put_unlocked_mapping_entry(mapping, index, entry);
-		xa_unlock_irq(&mapping->i_pages);
+	    (order == 0 && !dax_is_pte_entry(entry)) ||
+	    (order == PMD_ORDER && (xa_is_internal(entry) ||
+				    !dax_is_pmd_entry(entry)))) {
+		put_unlocked_entry(&xas, entry);
+		xas_unlock_irq(&xas);
 		trace_dax_insert_pfn_mkwrite_no_entry(mapping->host, vmf,
 						      VM_FAULT_NOPAGE);
 		return VM_FAULT_NOPAGE;
 	}
-	radix_tree_tag_set(&mapping->i_pages, index, PAGECACHE_TAG_DIRTY);
-	entry = lock_slot(mapping, slot);
-	xa_unlock_irq(&mapping->i_pages);
-	switch (pe_size) {
-	case PE_SIZE_PTE:
+	xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
+	dax_lock_entry(&xas, entry);
+	xas_unlock_irq(&xas);
+	if (order == 0) {
 		error = vm_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
 		vmf_ret = dax_fault_return(error);
-		break;
 #ifdef CONFIG_FS_DAX_PMD
-	case PE_SIZE_PMD:
+	} else if (order == PMD_ORDER) {
 		vmf_ret = vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
 			pfn, true);
-		break;
 #endif
-	default:
+	} else {
 		vmf_ret = VM_FAULT_FALLBACK;
 	}
-	put_locked_mapping_entry(mapping, index);
+	put_locked_entry(&xas, entry);
 	trace_dax_insert_pfn_mkwrite(mapping->host, vmf, vmf_ret);
 	return vmf_ret;
 }
@@ -1585,17 +1674,12 @@ int dax_finish_sync_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 {
 	int err;
 	loff_t start = ((loff_t)vmf->pgoff) << PAGE_SHIFT;
-	size_t len = 0;
+	unsigned int order = pe_order(pe_size);
+	size_t len = PAGE_SIZE << order;
 
-	if (pe_size == PE_SIZE_PTE)
-		len = PAGE_SIZE;
-	else if (pe_size == PE_SIZE_PMD)
-		len = PMD_SIZE;
-	else
-		WARN_ON_ONCE(1);
 	err = vfs_fsync_range(vmf->vma->vm_file, start, start + len - 1, 1);
 	if (err)
 		return VM_FAULT_SIGBUS;
-	return dax_insert_pfn_mkwrite(vmf, pe_size, pfn);
+	return dax_insert_pfn_mkwrite(vmf, pfn, order);
 }
 EXPORT_SYMBOL_GPL(dax_finish_sync_fault);
-- 
2.17.0
