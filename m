Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19D8C6B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:25:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b65so33274161wmg.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:25:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si9806202wmj.131.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/15] mm: Move handling of COW faults into DAX code
Date: Fri, 22 Jul 2016 14:19:32 +0200
Message-Id: <1469189981-19000-7-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Move final handling of COW faults from generic code into DAX fault
handler. That way generic code doesn't have to be aware of peculiarities
of DAX locking so remove that knowledge.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 11 ++++++++---
 include/linux/dax.h |  7 -------
 include/linux/mm.h  |  9 +--------
 mm/memory.c         | 20 +++++---------------
 4 files changed, 14 insertions(+), 33 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index e207f8f9b700..ec875683c17d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -879,10 +879,15 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
+		error = finish_fault(vma, vmf);
+		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+		return (error < 0) ? VM_FAULT_NOPAGE : VM_FAULT_DONE_COW;
 	}
 
 	if (!buffer_mapped(&bh)) {
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 43d5f0b799c7..b077983ee927 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -21,7 +21,6 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
-void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index);
 int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
 		unsigned int offset, unsigned int length);
 #else
@@ -30,12 +29,6 @@ static inline struct page *read_dax_sector(struct block_device *bdev,
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
index 21226cc2b1cd..d2f2816d78ca 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -304,12 +304,6 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
-	void *entry;			/* ->fault handler can alternatively
-					 * return locked DAX entry. In that
-					 * case handler should return
-					 * VM_FAULT_DAX_LOCKED and fill in
-					 * entry here.
-					 */
 	pmd_t *pmd;			/* PMD we fault into */
 	pte_t orig_pte;			/* Value of PTE at the time of fault */
 	/* for ->map_pages() only */
@@ -1086,8 +1080,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
-#define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
-#define VM_FAULT_DONE_COW   0x2000	/* ->fault has fully handled COW */
+#define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index b785f823caa4..cfae2d5cc1e0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2836,7 +2836,7 @@ static int __do_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
-			    VM_FAULT_DAX_LOCKED | VM_FAULT_DONE_COW)))
+			    VM_FAULT_DONE_COW)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf->page))) {
@@ -3105,26 +3105,16 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (ret & VM_FAULT_DONE_COW)
 		return ret;
 
-	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(new_page, vmf->page, address, vma);
+	copy_user_highpage(new_page, vmf->page, address, vma);
 	__SetPageUptodate(new_page);
 
 	if (unlikely(finish_fault(vma, vmf) < 0)) {
-		if (!(ret & VM_FAULT_DAX_LOCKED)) {
-			unlock_page(vmf->page);
-			put_page(vmf->page);
-		} else {
-			dax_unlock_mapping_entry(vma->vm_file->f_mapping,
-						 vmf->pgoff);
-		}
-		goto uncharge_out;
-	}
-	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
-	} else {
-		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
+		goto uncharge_out;
 	}
+	unlock_page(vmf->page);
+	put_page(vmf->page);
 	return ret;
 uncharge_out:
 	mem_cgroup_cancel_charge(new_page, memcg, false);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
