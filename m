Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A38016B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:21:46 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 39-v6so459247ple.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:21:46 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f62-v6si697286pfg.165.2018.07.17.04.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 04:21:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 02/19] mm: Do not use zero page in encrypted pages
Date: Tue, 17 Jul 2018 14:20:12 +0300
Message-Id: <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Zero page is not encrypted and putting it into encrypted VMA produces
garbage.

We can map zero page with KeyID-0 into an encrypted VMA, but this would
be violation security boundary between encryption domains.

Forbid zero pages in encrypted VMAs.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/s390/include/asm/pgtable.h | 2 +-
 include/linux/mm.h              | 4 ++--
 mm/huge_memory.c                | 3 +--
 mm/memory.c                     | 3 +--
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 5ab636089c60..2e8658962aae 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -505,7 +505,7 @@ static inline int mm_alloc_pgste(struct mm_struct *mm)
  * In the case that a guest uses storage keys
  * faults should no longer be backed by zero pages
  */
-#define mm_forbids_zeropage mm_has_pgste
+#define vma_forbids_zeropage(vma) mm_has_pgste(vma->vm_mm)
 static inline int mm_uses_skeys(struct mm_struct *mm)
 {
 #ifdef CONFIG_PGSTE
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c8780c5835ad..151d6e6b16e5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -92,8 +92,8 @@ extern int mmap_rnd_compat_bits __read_mostly;
  * s390 does this to prevent multiplexing of hardware bits
  * related to the physical page in case of virtualization.
  */
-#ifndef mm_forbids_zeropage
-#define mm_forbids_zeropage(X)	(0)
+#ifndef vma_forbids_zeropage
+#define vma_forbids_zeropage(vma)	vma_keyid(vma)
 #endif
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a57a14..83f096c7299b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -676,8 +676,7 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
-	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
-			!mm_forbids_zeropage(vma->vm_mm) &&
+	if (!(vmf->flags & FAULT_FLAG_WRITE) && !vma_forbids_zeropage(vma) &&
 			transparent_hugepage_use_zero_page()) {
 		pgtable_t pgtable;
 		struct page *zero_page;
diff --git a/mm/memory.c b/mm/memory.c
index 02fbef2bd024..a705637d2ded 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3139,8 +3139,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 		return 0;
 
 	/* Use the zero-page for reads */
-	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
-			!mm_forbids_zeropage(vma->vm_mm)) {
+	if (!(vmf->flags & FAULT_FLAG_WRITE) && !vma_forbids_zeropage(vma)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
 						vma->vm_page_prot));
 		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-- 
2.18.0
