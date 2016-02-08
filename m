Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id B6521830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:53:34 -0500 (EST)
Received: by mail-lf0-f48.google.com with SMTP id m1so96952588lfg.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:53:34 -0800 (PST)
Received: from relay.sw.ru (mailhub.sw.ru. [195.214.232.25])
        by mx.google.com with ESMTPS id l71si16133481lfi.45.2016.02.08.05.53.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:53:32 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 1/2] dax: rename dax_radix_entry to dax_radix_entry_insert
Date: Mon,  8 Feb 2016 17:53:17 +0400
Message-Id: <1454939598-16238-1-git-send-email-dmonakhov@openvz.org>
In-Reply-To: <87bn7rwim2.fsf@openvz.org>
References: <87bn7rwim2.fsf@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com, Dmitry Monakhov <dmonakhov@openvz.org>

- dax_radix_entry_insert is more appropriate name for that function
- Add lockless helper __dax_radix_entry_insert, it will be used by second patch

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 fs/dax.c | 39 +++++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index fc2e314..89bb1f8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -349,7 +349,7 @@ static int copy_user_bh(struct page *to, struct inode *inode,
 #define NO_SECTOR -1
 #define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_CACHE_SHIFT))
 
-static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
+static int __dax_radix_entry_insert(struct address_space *mapping, pgoff_t index,
 		sector_t sector, bool pmd_entry, bool dirty)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
@@ -358,10 +358,6 @@ static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 	void *entry;
 
 	WARN_ON_ONCE(pmd_entry && !dirty);
-	if (dirty)
-		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-
-	spin_lock_irq(&mapping->tree_lock);
 
 	entry = radix_tree_lookup(page_tree, pmd_index);
 	if (entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD) {
@@ -374,8 +370,7 @@ static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 		type = RADIX_DAX_TYPE(entry);
 		if (WARN_ON_ONCE(type != RADIX_DAX_PTE &&
 					type != RADIX_DAX_PMD)) {
-			error = -EIO;
-			goto unlock;
+		        return -EIO;
 		}
 
 		if (!pmd_entry || type == RADIX_DAX_PMD)
@@ -402,19 +397,31 @@ static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 		 * pte_same() check will fail, eventually causing page fault
 		 * to be retried by the CPU.
 		 */
-		goto unlock;
+		return 0;
 	}
 
 	error = radix_tree_insert(page_tree, index,
 			RADIX_DAX_ENTRY(sector, pmd_entry));
 	if (error)
-		goto unlock;
+		return error;
 
 	mapping->nrexceptional++;
- dirty:
+dirty:
 	if (dirty)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
- unlock:
+	return error;
+}
+
+static int dax_radix_entry_insert(struct address_space *mapping, pgoff_t index,
+		sector_t sector, bool pmd_entry, bool dirty)
+{
+	int error;
+
+	if (dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+	error =__dax_radix_entry_insert(mapping, index, sector, pmd_entry, dirty);
 	spin_unlock_irq(&mapping->tree_lock);
 	return error;
 }
@@ -579,8 +586,8 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
-			vmf->flags & FAULT_FLAG_WRITE);
+	error = dax_radix_entry_insert(mapping, vmf->pgoff, dax.sector, false,
+				vmf->flags & FAULT_FLAG_WRITE, vmf->page);
 	if (error)
 		goto out;
 
@@ -984,7 +991,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 * the write to insert a dirty entry.
 		 */
 		if (write) {
-			error = dax_radix_entry(mapping, pgoff, dax.sector,
+			error = dax_radix_entry_insert(mapping, pgoff, dax.sector,
 					true, true);
 			if (error) {
 				dax_pmd_dbg(&bh, address,
@@ -1057,14 +1064,14 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file *file = vma->vm_file;
 
 	/*
-	 * We pass NO_SECTOR to dax_radix_entry() because we expect that a
+	 * We pass NO_SECTOR to dax_radix_entry_insert() because we expect that a
 	 * RADIX_DAX_PTE entry already exists in the radix tree from a
 	 * previous call to __dax_fault().  We just want to look up that PTE
 	 * entry using vmf->pgoff and make sure the dirty tag is set.  This
 	 * saves us from having to make a call to get_block() here to look
 	 * up the sector.
 	 */
-	dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);
+	dax_radix_entry_insert(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
