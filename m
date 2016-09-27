Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4491280266
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b130so12649866wmc.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si3047392wjz.90.2016.09.27.09.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:33 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/20] mm: Move handling of COW faults into DAX code
Date: Tue, 27 Sep 2016 18:08:14 +0200
Message-Id: <1474992504-20133-11-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Move final handling of COW faults from generic code into DAX fault
handler. That way generic code doesn't have to be aware of peculiarities
of DAX locking so remove that knowledge.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 22 ++++++++++++++++------
 include/linux/dax.h |  7 -------
 include/linux/mm.h  |  9 +--------
 mm/memory.c         | 14 ++++----------
 4 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0dc251ca77b8..b1c503930d1d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -876,10 +876,15 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			goto unlock_entry;
 		if (!radix_tree_exceptional_entry(entry)) {
 			vmf->page = entry;
-			return VM_FAULT_LOCKED;
+			if (unlikely(PageHWPoison(entry))) {
+				put_locked_mapping_entry(mapping, vmf->pgoff,
+							 entry);
+				return VM_FAULT_HWPOISON;
+			}
 		}
-		vmf->entry = entry;
-		return VM_FAULT_DAX_LOCKED;
+		error = finish_fault(vmf);
+		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+		return error ? error : VM_FAULT_DONE_COW;
 	}
 
 	if (!buffer_mapped(&bh)) {
@@ -1430,10 +1435,15 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			goto unlock_entry;
 		if (!radix_tree_exceptional_entry(entry)) {
 			vmf->page = entry;
-			return VM_FAULT_LOCKED;
+			if (unlikely(PageHWPoison(entry))) {
+				put_locked_mapping_entry(mapping, vmf->pgoff,
+							 entry);
+				return VM_FAULT_HWPOISON;
+			}
 		}
-		vmf->entry = entry;
-		return VM_FAULT_DAX_LOCKED;
+		error = finish_fault(vmf);
+		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+		return error ? error : VM_FAULT_DONE_COW;
 	}
 
 	switch (iomap.type) {
diff --git a/include/linux/dax.h b/include/linux/dax.h
index add6c4bc568f..b1a1acd10df2 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -26,7 +26,6 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
-void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index);
 int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
 		unsigned int offset, unsigned int length);
 #else
@@ -35,12 +34,6 @@ static inline struct page *read_dax_sector(struct block_device *bdev,
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
index 919ebdd27f1e..1055f2ece80d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -310,12 +310,6 @@ struct vm_fault {
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
@@ -1118,8 +1112,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
-#define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
-#define VM_FAULT_DONE_COW   0x2000	/* ->fault has fully handled COW */
+#define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index f54cfad7fe04..a4522e8999b2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2845,7 +2845,7 @@ static int __do_fault(struct vm_fault *vmf)
 
 	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
-			    VM_FAULT_DAX_LOCKED | VM_FAULT_DONE_COW)))
+			    VM_FAULT_DONE_COW)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf->page))) {
@@ -3239,17 +3239,11 @@ static int do_cow_fault(struct vm_fault *vmf)
 	if (ret & VM_FAULT_DONE_COW)
 		return ret;
 
-	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(new_page, vmf->page, vmf->address, vma);
+	copy_user_highpage(new_page, vmf->page, vmf->address, vma);
 	__SetPageUptodate(new_page);
-
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
