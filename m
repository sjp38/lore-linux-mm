Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5186B03C1
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:17:31 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so9510464wmd.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:17:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a189si1722229wme.106.2016.11.18.01.17.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/20] mm: Use pgoff in struct vm_fault instead of passing it separately
Date: Fri, 18 Nov 2016 10:17:07 +0100
Message-Id: <1479460644-25076-4-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

struct vm_fault has already pgoff entry. Use it instead of passing pgoff
as a separate argument and then assigning it later.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/khugepaged.c |  1 +
 mm/memory.c     | 35 ++++++++++++++++++-----------------
 2 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index f88b2d3810a7..d7df06383b10 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -880,6 +880,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.address = address,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
+		.pgoff = linear_page_index(vma, address),
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
diff --git a/mm/memory.c b/mm/memory.c
index 80e6ffafb035..79b321dfdaf2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2279,7 +2279,7 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
 		struct vm_fault vmf2 = {
 			.page = NULL,
-			.pgoff = linear_page_index(vma, vmf->address),
+			.pgoff = vmf->pgoff,
 			.address = vmf->address,
 			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
 		};
@@ -2848,15 +2848,15 @@ static int do_anonymous_page(struct vm_fault *vmf)
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
 
 	vmf2.address = vmf->address;
-	vmf2.pgoff = pgoff;
+	vmf2.pgoff = vmf->pgoff;
 	vmf2.flags = vmf->flags;
 	vmf2.page = NULL;
 	vmf2.gfp_mask = __get_fault_gfp_mask(vma);
@@ -3115,9 +3115,10 @@ late_initcall(fault_around_debugfs);
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
 
@@ -3175,7 +3176,7 @@ static int do_fault_around(struct vm_fault *vmf, pgoff_t start_pgoff)
 	return ret;
 }
 
-static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
@@ -3187,12 +3188,12 @@ static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
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
 
@@ -3205,7 +3206,7 @@ static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	return ret;
 }
 
-static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_cow_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page, *new_page;
@@ -3226,7 +3227,7 @@ static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vmf, pgoff, new_page, &fault_page, &fault_entry);
+	ret = __do_fault(vmf, new_page, &fault_page, &fault_entry);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -3241,7 +3242,7 @@ static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 		unlock_page(fault_page);
 		put_page(fault_page);
 	} else {
-		dax_unlock_mapping_entry(vma->vm_file->f_mapping, pgoff);
+		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
 	}
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
@@ -3252,7 +3253,7 @@ static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	return ret;
 }
 
-static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
+static int do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
@@ -3260,7 +3261,7 @@ static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vmf, pgoff, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3321,16 +3322,15 @@ static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
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
@@ -3578,6 +3578,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.vma = vma,
 		.address = address & PAGE_MASK,
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
