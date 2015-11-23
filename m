Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA016B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:09:05 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so111327513obb.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:09:05 -0800 (PST)
Received: from g2t2355.austin.hp.com (g2t2355.austin.hp.com. [15.217.128.54])
        by mx.google.com with ESMTPS id a76si8307895oig.88.2015.11.23.12.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:09:04 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
Date: Mon, 23 Nov 2015 13:04:42 -0700
Message-Id: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, willy@linux.intel.com, ross.zwisler@linux.intel.com, dan.j.williams@intel.com, mauricio.porto@hpe.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

The following oops was observed when mmap() with MAP_POPULATE
pre-faulted pmd mappings of a DAX file.  follow_trans_huge_pmd()
expects that a target address has a struct page.

  BUG: unable to handle kernel paging request at ffffea0012220000
  follow_trans_huge_pmd+0xba/0x390
  follow_page_mask+0x33d/0x420
  __get_user_pages+0xdc/0x800
  populate_vma_page_range+0xb5/0xe0
  __mm_populate+0xc5/0x150
  vm_mmap_pgoff+0xd5/0xe0
  SyS_mmap_pgoff+0x1c1/0x290
  SyS_mmap+0x1b/0x30

Fix it by making the PMD pre-fault handling consistent with PTE.
After pre-faulted in faultin_page(), follow_page_mask() calls
follow_trans_huge_pmd(), which is changed to call follow_pfn_pmd()
for VM_PFNMAP or VM_MIXEDMAP.  follow_pfn_pmd() handles FOLL_TOUCH
and returns with -EEXIST.

Reported-by: Mauricio Porto <mauricio.porto@hpe.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 mm/huge_memory.c |   34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d5b8920..f56e034 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1267,6 +1267,32 @@ out_unlock:
 	return ret;
 }
 
+/*
+ * Follow a pmd inserted by vmf_insert_pfn_pmd(). See follow_pfn_pte() for pte.
+ */
+static int follow_pfn_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags)
+{
+	/* No page to get reference */
+	if (flags & FOLL_GET)
+		return -EFAULT;
+
+	if (flags & FOLL_TOUCH) {
+		pmd_t entry = *pmd;
+
+		/* Set the dirty bit per follow_trans_huge_pmd() */
+		entry = pmd_mkyoung(pmd_mkdirty(entry));
+
+		if (!pmd_same(*pmd, entry)) {
+			set_pmd_at(vma->vm_mm, address, pmd, entry);
+			update_mmu_cache_pmd(vma, address, pmd);
+		}
+	}
+
+	/* Proper page table entry exists, but no corresponding struct page */
+	return -EEXIST;
+}
+
 struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 				   unsigned long addr,
 				   pmd_t *pmd,
@@ -1274,6 +1300,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page = NULL;
+	int ret;
 
 	assert_spin_locked(pmd_lockptr(mm, pmd));
 
@@ -1288,6 +1315,13 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		goto out;
 
+	/* pfn map does not have a struct page */
+	if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)) {
+		ret = follow_pfn_pmd(vma, addr, pmd, flags);
+		page = ERR_PTR(ret);
+		goto out;
+	}
+
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	if (flags & FOLL_TOUCH) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
