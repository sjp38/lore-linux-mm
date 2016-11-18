Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B346B03CA
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:17:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so9357606wms.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:17:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n13si1700681wmg.164.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/20] mm: Move handling of COW faults into DAX code
Date: Fri, 18 Nov 2016 10:17:14 +0100
Message-Id: <1479460644-25076-11-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Move final handling of COW faults from generic code into DAX fault
handler. That way generic code doesn't have to be aware of peculiarities
of DAX locking so remove that knowledge and make locking functions
private to fs/dax.c.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 61 +++++++++++++++++++++++++----------------------------
 include/linux/dax.h |  7 ------
 include/linux/mm.h  |  9 +-------
 mm/memory.c         | 13 ++++--------
 4 files changed, 34 insertions(+), 56 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 56e05af1d2bf..9be1464d1a7e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -240,6 +240,23 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	}
 }
 
+static void dax_unlock_mapping_entry(struct address_space *mapping,
+				     pgoff_t index)
+{
+	void *entry, **slot;
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
+	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
+			 !slot_locked(mapping, slot))) {
+		spin_unlock_irq(&mapping->tree_lock);
+		return;
+	}
+	unlock_slot(mapping, slot);
+	spin_unlock_irq(&mapping->tree_lock);
+	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+}
+
 static void put_locked_mapping_entry(struct address_space *mapping,
 				     pgoff_t index, void *entry)
 {
@@ -434,22 +451,6 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
-void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
-{
-	void *entry, **slot;
-
-	spin_lock_irq(&mapping->tree_lock);
-	entry = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
-			 !slot_locked(mapping, slot))) {
-		spin_unlock_irq(&mapping->tree_lock);
-		return;
-	}
-	unlock_slot(mapping, slot);
-	spin_unlock_irq(&mapping->tree_lock);
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
-}
-
 /*
  * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
  * entry to get unlocked before deleting it.
@@ -501,10 +502,8 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	/* This will replace locked radix tree entry with a hole page */
 	page = find_or_create_page(mapping, vmf->pgoff,
 				   vmf->gfp_mask | __GFP_ZERO);
-	if (!page) {
-		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+	if (!page)
 		return VM_FAULT_OOM;
-	}
 	vmf->page = page;
 	return VM_FAULT_LOCKED;
 }
@@ -953,7 +952,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	struct iomap iomap = { 0 };
 	unsigned flags = IOMAP_FAULT;
 	int error, major = 0;
-	int locked_status = 0;
+	int vmf_ret = 0;
 	void *entry;
 
 	/*
@@ -1006,13 +1005,11 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 		if (error)
 			goto finish_iomap;
-		if (!radix_tree_exceptional_entry(entry)) {
-			vmf->page = entry;
-			locked_status = VM_FAULT_LOCKED;
-		} else {
-			vmf->entry = entry;
-			locked_status = VM_FAULT_DAX_LOCKED;
-		}
+
+		__SetPageUptodate(vmf->cow_page);
+		vmf_ret = finish_fault(vmf);
+		if (!vmf_ret)
+			vmf_ret = VM_FAULT_DONE_COW;
 		goto finish_iomap;
 	}
 
@@ -1029,7 +1026,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
-			locked_status = dax_load_hole(mapping, entry, vmf);
+			vmf_ret = dax_load_hole(mapping, entry, vmf);
 			break;
 		}
 		/*FALLTHRU*/
@@ -1041,7 +1038,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
  finish_iomap:
 	if (ops->iomap_end) {
-		if (error) {
+		if (error || (vmf_ret & VM_FAULT_ERROR)) {
 			/* keep previous error */
 			ops->iomap_end(inode, pos, PAGE_SIZE, 0, flags,
 					&iomap);
@@ -1051,7 +1048,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 	}
  unlock_entry:
-	if (!locked_status || error)
+	if (vmf_ret != VM_FAULT_LOCKED || error)
 		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
  out:
 	if (error == -ENOMEM)
@@ -1059,9 +1056,9 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	/* -EBUSY is fine, somebody else faulted on the same PTE */
 	if (error < 0 && error != -EBUSY)
 		return VM_FAULT_SIGBUS | major;
-	if (locked_status) {
+	if (vmf_ret) {
 		WARN_ON_ONCE(error); /* -EBUSY from ops->iomap_end? */
-		return locked_status;
+		return vmf_ret;
 	}
 	return VM_FAULT_NOPAGE | major;
 }
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 0afade8bd3d7..f97bcfe79472 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -46,7 +46,6 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
-void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index);
 int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
 		unsigned int offset, unsigned int length);
 #else
@@ -55,12 +54,6 @@ static inline struct page *read_dax_sector(struct block_device *bdev,
 {
 	return ERR_PTR(-ENXIO);
 }
-/* Shouldn't ever be called when dax is disabled. */
-static inline void dax_unlock_mapping_entry(struct address_space *mapping,
-					    pgoff_t index)
-{
-	BUG();
-}
 static inline int __dax_zero_page_range(struct block_device *bdev,
 		sector_t sector, unsigned int offset, unsigned int length)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 482455952f03..fb128beecdac 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -308,12 +308,6 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
-	void *entry;			/* ->fault handler can alternatively
-					 * return locked DAX entry. In that
-					 * case handler should return
-					 * VM_FAULT_DAX_LOCKED and fill in
-					 * entry here.
-					 */
 	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
@@ -1104,8 +1098,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
-#define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
-#define VM_FAULT_DONE_COW   0x2000	/* ->fault has fully handled COW */
+#define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index ba49e5bacf17..e9e9224264da 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2849,7 +2849,7 @@ static int __do_fault(struct vm_fault *vmf)
 
 	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
-			    VM_FAULT_DAX_LOCKED | VM_FAULT_DONE_COW)))
+			    VM_FAULT_DONE_COW)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf->page))) {
@@ -3241,17 +3241,12 @@ static int do_cow_fault(struct vm_fault *vmf)
 	if (ret & VM_FAULT_DONE_COW)
 		return ret;
 
-	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(vmf->cow_page, vmf->page, vmf->address, vma);
+	copy_user_highpage(vmf->cow_page, vmf->page, vmf->address, vma);
 	__SetPageUptodate(vmf->cow_page);
 
 	ret |= finish_fault(vmf);
-	if (!(ret & VM_FAULT_DAX_LOCKED)) {
-		unlock_page(vmf->page);
-		put_page(vmf->page);
-	} else {
-		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
-	}
+	unlock_page(vmf->page);
+	put_page(vmf->page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 	return ret;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
