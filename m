Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4C928028A
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so12993171wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si2998020wjm.249.2016.09.27.09.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/20] mm: Use pgoff in struct vm_fault instead of passing it separately
Date: Tue, 27 Sep 2016 18:08:07 +0200
Message-Id: <1474992504-20133-4-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

struct vm_fault has already pgoff entry. Use it instead of passing pgoff
as a separate argument and then assigning it later.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 447a1ef4a9e3..4c2ec9a9d8af 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2275,7 +2275,7 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
 		struct vm_fault vmf2 = {
 			.page = NULL,
-			.pgoff = linear_page_index(vma, vmf->address),
+			.pgoff = vmf->pgoff,
 			.virtual_address = vmf->address & PAGE_MASK,
 			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
 		};
@@ -2844,15 +2844,15 @@ oom:
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_fault *vmf, pgoff_t pgoff,
-		struct page *cow_page, struct page **page, void **entry)
+static int __do_fault(struct vm_fault *vmf, struct page *cow_page,
+		      struct page **page, void **entry)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct vm_fault vmf2;
 	int ret;
 
 	vmf2.virtual_address = vmf->address & PAGE_MASK;
-	vmf2.pgoff = pgoff;
+	vmf2.pgoff = vmf->pgoff;
 	vmf2.flags = vmf->flags;
 	vmf2.page = NULL;
 	vmf2.gfp_mask = __get_fault_gfp_mask(vma);
@@ -3111,9 +3111,10 @@ late_initcall(fault_around_debugfs);
  * fault_around_pages() value (and therefore to page order).  This way it's
  * easier to guarantee that we don't cross page table boundaries.
  */
-static int do_fault_around(struct vm_fault *vmf, pgoff_t start_pgoff)
+static int do_fault_around(struct vm_fault *vmf)
 {
 	unsigned long address = vmf->address, nr_pages, mask;
+	pgoff_t start_pgoff = vmf->pgoff;
 	pgoff_t end_pgoff;
 	int off, ret = 0;
 
@@ -3171,7 +3172,7 @@ out:
 	return ret;
 }
 
-static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
@@ -3183,12 +3184,12 @@ static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	 * something).
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
-		ret = do_fault_around(vmf, pgoff);
+		ret = do_fault_around(vmf);
 		if (ret)
 			return ret;
 	}
 
-	ret = __do_fault(vmf, pgoff, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3201,7 +3202,7 @@ static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	return ret;
 }
 
-static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_cow_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page, *new_page;
@@ -3222,7 +3223,7 @@ static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vmf, pgoff, new_page, &fault_page, &fault_entry);
+	ret = __do_fault(vmf, new_page, &fault_page, &fault_entry);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -3237,7 +3238,7 @@ static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 		unlock_page(fault_page);
 		put_page(fault_page);
 	} else {
-		dax_unlock_mapping_entry(vma->vm_file->f_mapping, pgoff);
+		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
 	}
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
@@ -3248,7 +3249,7 @@ uncharge_out:
 	return ret;
 }
 
-static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
@@ -3256,7 +3257,7 @@ static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vmf, pgoff, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3317,16 +3318,15 @@ static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
 static int do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	pgoff_t pgoff = linear_page_index(vma, vmf->address);
 
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
 	if (!(vmf->flags & FAULT_FLAG_WRITE))
-		return do_read_fault(vmf, pgoff);
+		return do_read_fault(vmf);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(vmf, pgoff);
-	return do_shared_fault(vmf, pgoff);
+		return do_cow_fault(vmf);
+	return do_shared_fault(vmf);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3574,6 +3574,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.vma = vma,
 		.address = address,
 		.flags = flags,
+		.pgoff = linear_page_index(vma, address),
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
