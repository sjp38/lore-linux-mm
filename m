Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3CED16B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:09:42 -0500 (EST)
Received: by oixx65 with SMTP id x65so139551153oix.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:09:42 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id go3si8773056obb.4.2015.11.23.12.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:09:41 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH] dax: Split pmd map when fallback on COW
Date: Mon, 23 Nov 2015 13:05:20 -0700
Message-Id: <1448309120-20911-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com
Cc: kirill.shutemov@linux.intel.com, willy@linux.intel.com, ross.zwisler@linux.intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

An infinite loop of PMD faults was observed when attempted to
mlock() a private read-only PMD mmap'd range of a DAX file.

__dax_pmd_fault() simply returns with VM_FAULT_FALLBACK when
falling back to PTE on COW.  However, __handle_mm_fault()
returns without falling back to handle_pte_fault() because
a PMD map is present in this case.

Change __dax_pmd_fault() to split the PMD map, if present,
before returning with VM_FAULT_FALLBACK.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 43671b6..3405583 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -546,8 +546,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		return VM_FAULT_FALLBACK;
 
 	/* Fall back to PTEs if we're going to COW */
-	if (write && !(vma->vm_flags & VM_SHARED))
+	if (write && !(vma->vm_flags & VM_SHARED)) {
+		split_huge_page_pmd(vma, address, pmd);
 		return VM_FAULT_FALLBACK;
+	}
 	/* If the PMD would extend outside the VMA */
 	if (pmd_addr < vma->vm_start)
 		return VM_FAULT_FALLBACK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
