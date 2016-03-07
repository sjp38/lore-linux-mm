Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EFC806B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 17:55:35 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so127708654wmp.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 14:55:35 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id nw5si22006238wjb.32.2016.03.07.14.55.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 14:55:34 -0800 (PST)
From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 4.2.y-ckt 176/273] x86/mm: Fix vmalloc_fault() to handle large pages properly
Date: Mon,  7 Mar 2016 14:49:27 -0800
Message-Id: <1457391064-6660-177-git-send-email-kamal@canonical.com>
In-Reply-To: <1457391064-6660-1-git-send-email-kamal@canonical.com>
References: <1457391064-6660-1-git-send-email-kamal@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, kernel-team@lists.ubuntu.com
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Ingo Molnar <mingo@kernel.org>, Kamal Mostafa <kamal@canonical.com>

4.2.8-ckt5 -stable review patch.  If anyone has any objections, please let me know.

---8<------------------------------------------------------------

From: Toshi Kani <toshi.kani@hpe.com>

commit f4eafd8bcd5229e998aa252627703b8462c3b90f upstream.

A kernel page fault oops with the callstack below was observed
when a read syscall was made to a pmem device after a huge amount
(>512GB) of vmalloc ranges was allocated by ioremap() on a x86_64
system:

     BUG: unable to handle kernel paging request at ffff880840000ff8
     IP: vmalloc_fault+0x1be/0x300
     PGD c7f03a067 PUD 0
     Oops: 0000 [#1] SM
     Call Trace:
        __do_page_fault+0x285/0x3e0
        do_page_fault+0x2f/0x80
        ? put_prev_entity+0x35/0x7a0
        page_fault+0x28/0x30
        ? memcpy_erms+0x6/0x10
        ? schedule+0x35/0x80
        ? pmem_rw_bytes+0x6a/0x190 [nd_pmem]
        ? schedule_timeout+0x183/0x240
        btt_log_read+0x63/0x140 [nd_btt]
         :
        ? __symbol_put+0x60/0x60
        ? kernel_read+0x50/0x80
        SyS_finit_module+0xb9/0xf0
        entry_SYSCALL_64_fastpath+0x1a/0xa4

Since v4.1, ioremap() supports large page (pud/pmd) mappings in
x86_64 and PAE.  vmalloc_fault() however assumes that the vmalloc
range is limited to pte mappings.

vmalloc faults do not normally happen in ioremap'd ranges since
ioremap() sets up the kernel page tables, which are shared by
user processes.  pgd_ctor() sets the kernel's PGD entries to
user's during fork().  When allocation of the vmalloc ranges
crosses a 512GB boundary, ioremap() allocates a new pud table
and updates the kernel PGD entry to point it.  If user process's
PGD entry does not have this update yet, a read/write syscall
to the range will cause a vmalloc fault, which hits the Oops
above as it does not handle a large page properly.

Following changes are made to vmalloc_fault().

64-bit:

 - No change for the PGD sync operation as it handles large
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
 - No change for the sync operation since the index3 PGD entry
   covers the entire vmalloc range, which is always valid.
   (A separate change to sync PGD entry is necessary if this
    memory layout is changed regardless of the page size.)
 - Add pmd_huge() to the validation code to handle large pages.
   This is for completeness since vmalloc_fault() won't happen
   in ioremap'd ranges as its PGD entry is always valid.

Reported-by: Henning Schild <henning.schild@siemens.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Cc: linux-nvdimm@lists.01.org
Link: http://lkml.kernel.org/r/1455758214-24623-1-git-send-email-toshi.kani@hpe.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 arch/x86/mm/fault.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9dc9098..1d3beaf 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -286,6 +286,9 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (!pmd_k)
 		return -1;
 
+	if (pmd_huge(*pmd_k))
+		return 0;
+
 	pte_k = pte_offset_kernel(pmd_k, address);
 	if (!pte_present(*pte_k))
 		return -1;
@@ -357,8 +360,6 @@ void vmalloc_sync_all(void)
  * 64-bit:
  *
  *   Handle a fault on the vmalloc area
- *
- * This assumes no large pages in there.
  */
 static noinline int vmalloc_fault(unsigned long address)
 {
@@ -400,17 +401,23 @@ static noinline int vmalloc_fault(unsigned long address)
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
