Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id DB0006B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:24:00 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id xk3so42042260obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:24:00 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id o203si4785561oig.87.2016.02.17.16.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 16:24:00 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3] x86/mm/vmfault: Make vmalloc_fault() handle large pages
Date: Wed, 17 Feb 2016 18:16:54 -0700
Message-Id: <1455758214-24623-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: henning.schild@siemens.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, stable@vger.kernel.org

A kernel page fault oops with the callstack below was observed
when a read syscall was made to a pmem device after a huge amount
(>512GB) of vmalloc ranges was allocated by ioremap() on a x86_64
system.

  vmalloc_fault
  __do_page_fault
  do_page_fault
  page_fault
  pmem_rw_bytes [nd_pmem]
  btt_log_read [nd_btt]
    :
  SyS_finit_module
  entry_SYSCALL_64_fastpath

Since 4.1, ioremap() supports large page (pud/pmd) mappings in
x86_64 and PAE.  vmalloc_fault() however assumes that the vmalloc
range is limited to pte mappings.

vmalloc faults do not normally happen in ioremap'd ranges since
ioremap() sets up the kernel page tables, which are shared by
user processes.  pgd_ctor() sets the kernel's pgd entries to
user's during fork().  When allocation of the vmalloc ranges
crosses a 512GB boundary, ioremap() allocates a new pud table
and updates the kernel pgd entry to point it.  If user process's
pgd entry does not have this update yet, a read/write syscall
to the range will cause a vmalloc fault, which hits the Oops
above as it does not handle a large page properly.

Following changes are made to vmalloc_fault().

64-bit:
- No change for the pgd sync operation as it handles large
  pages already.
- Add pud_huge() and pmd_huge() to the validation code to
  handle large pages.
- Change pud_page_vaddr() to pud_pfn() since an ioremap range
  is not directly mapped (while the if-statement still works
  with a bogus addr).
- Change pmd_page() to pmd_pfn() since an ioremap range is not
  backed by struct page (while the if-statement still works
  with a bogus addr).

32-bit:
- No change for the sync operation since the index3 pgd entry
  covers the entire vmalloc range, which is always valid.
  (A separate change to sync pgd entry is necessary if this
   memory layout is changed regardless of the page size.)
- Add pmd_huge() to the validation code to handle large pages.
  This is for completeness since vmalloc_fault() won't happen
  in ioremap'd ranges as its pgd entry is always valid.

Reported-by: Henning Schild <henning.schild@siemens.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: <stable@vger.kernel.org> # 4.1+
---
v3: Remove addresses from the callstack, and add cc to stable.
v2: Add more descriptions about the issue in the change log.
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
