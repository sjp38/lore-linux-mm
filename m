Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8709C828E2
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 18:07:37 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id s4so5420383oif.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 15:07:37 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id pq9si14462278oeb.21.2016.02.08.15.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 15:07:36 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH] x86/mm/vmfault: Make vmalloc_fault() handle large pages
Date: Mon,  8 Feb 2016 17:00:38 -0700
Message-Id: <1454976038-22486-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: henning.schild@siemens.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Since 4.1, ioremap() supports large page (pud/pmd) mappings in
x86_64 and PAE.  vmalloc_fault() however assumes that the vmalloc
range is limited to pte mappings.

pgd_ctor() sets the kernel's pgd entries to user's during fork(),
which makes user processes share the same page tables for the
kernel ranges.  When a call to ioremap() is made at run-time that
leads to allocate a new 2nd level table (pud in 64-bit and pmd in
PAE), user process needs to re-sync with the updated kernel pgd
entry with vmalloc_fault().

Following changes are made to vmalloc_fault().

64-bit:
- No change for the sync operation as set_pgd() takes care of
  huge pages as well.
- Add pud_huge() and pmd_huge() to the validation code to
  handle huge pages.
- Change pud_page_vaddr() to pud_pfn() since an ioremap range
  is not directly mapped (although the if-statement still works
  with a bogus addr).
- Change pmd_page() to pmd_pfn() since an ioremap range is not
  backed by struct page table (although the if-statement still
  works with a bogus addr).

PAE:
- No change for the sync operation since the index3 pgd entry
  covers the entire vmalloc range, which is always valid.
  (A separate change will be needed if this assumption gets
  changed regardless of the page size.)
- Add pmd_huge() to the validation code to handle huge pages.
  This is only for completeness since vmalloc_fault() won't
  happen for ioremap'd ranges as its pgd entry is always valid.
  (I was unable to test this part of the changes as a result.)

Reported-by: Henning Schild <henning.schild@siemens.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@alien8.de>
---
When this patch is accepted, please copy to stable up to 4.1.
---
 arch/x86/mm/fault.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index eef44d9..e830c71 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -287,6 +287,9 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (!pmd_k)
 		return -1;
 
+	if (pmd_huge(*pmd_k))
+		return 0;
+
 	pte_k = pte_offset_kernel(pmd_k, address);
 	if (!pte_present(*pte_k))
 		return -1;
@@ -360,8 +363,6 @@ void vmalloc_sync_all(void)
  * 64-bit:
  *
  *   Handle a fault on the vmalloc area
- *
- * This assumes no large pages in there.
  */
 static noinline int vmalloc_fault(unsigned long address)
 {
@@ -403,17 +404,23 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (pud_none(*pud_ref))
 		return -1;
 
-	if (pud_none(*pud) || pud_page_vaddr(*pud) != pud_page_vaddr(*pud_ref))
+	if (pud_none(*pud) || pud_pfn(*pud) != pud_pfn(*pud_ref))
 		BUG();
 
+	if (pud_huge(*pud))
+		return 0;
+
 	pmd = pmd_offset(pud, address);
 	pmd_ref = pmd_offset(pud_ref, address);
 	if (pmd_none(*pmd_ref))
 		return -1;
 
-	if (pmd_none(*pmd) || pmd_page(*pmd) != pmd_page(*pmd_ref))
+	if (pmd_none(*pmd) || pmd_pfn(*pmd) != pmd_pfn(*pmd_ref))
 		BUG();
 
+	if (pmd_huge(*pmd))
+		return 0;
+
 	pte_ref = pte_offset_kernel(pmd_ref, address);
 	if (!pte_present(*pte_ref))
 		return -1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
