Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8FB6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 06:50:30 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so8770544pac.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 03:50:30 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 28si19069687pfj.63.2015.12.04.03.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 03:50:29 -0800 (PST)
Date: Fri, 4 Dec 2015 03:49:27 -0800
From: "tip-bot for Kirill A. Shutemov" <tipbot@zytor.com>
Message-ID: <tip-70f1528747651b20c7769d3516ade369f9963237@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
        bp@alien8.de, hpa@zytor.com, toshi.kani@hpe.com, bp@suse.de,
        linux-mm@kvack.org, kirill.shutemov@linux.intel.com,
        dvlasenk@redhat.com, peterz@infradead.org, brgerst@gmail.com,
        jgross@suse.com, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, mingo@kernel.org, luto@amacapital.net,
        tglx@linutronix.de, mgorman@suse.de
In-Reply-To: <1448878233-11390-2-git-send-email-bp@alien8.de>
References: <1448878233-11390-2-git-send-email-bp@alien8.de>
Subject: [tip:x86/urgent] x86/mm: Fix regression with huge pages on PAE
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, luto@amacapital.net, tglx@linutronix.de, mgorman@suse.de, jgross@suse.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, peterz@infradead.org, dvlasenk@redhat.com, brgerst@gmail.com, boris.ostrovsky@oracle.com, linux-kernel@vger.kernel.org, hpa@zytor.com, bp@alien8.de, bp@suse.de, toshi.kani@hpe.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

Commit-ID:  70f1528747651b20c7769d3516ade369f9963237
Gitweb:     http://git.kernel.org/tip/70f1528747651b20c7769d3516ade369f9963237
Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
AuthorDate: Mon, 30 Nov 2015 11:10:33 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Fri, 4 Dec 2015 09:14:27 +0100

x86/mm: Fix regression with huge pages on PAE

Recent PAT patchset has caused issue on 32-bit PAE machines:

  page:eea45000 count:0 mapcount:-128 mapping:  (null) index:0x0 flags: 0x40000000()
  page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
  ------------[ cut here ]------------
  kernel BUG at /home/build/linux-boris/mm/huge_memory.c:1485!
  invalid opcode: 0000 [#1] SMP
  [...]
  Call Trace:
   unmap_single_vma
   ? __wake_up
   unmap_vmas
   unmap_region
   do_munmap
   vm_munmap
   SyS_munmap
   do_fast_syscall_32
   ? __do_page_fault
   sysenter_past_esp
  Code: ...
  EIP: [<c11bde80>] zap_huge_pmd+0x240/0x260 SS:ESP 0068:f6459d98

The problem is in pmd_pfn_mask() and pmd_flags_mask(). These
helpers use PMD_PAGE_MASK to calculate resulting mask.
PMD_PAGE_MASK is 'unsigned long', not 'unsigned long long' as
phys_addr_t is on 32-bit PAE (ARCH_PHYS_ADDR_T_64BIT). As a
result, the upper bits of resulting mask get truncated.

pud_pfn_mask() and pud_flags_mask() aren't problematic since we
don't have PUD page table level on 32-bit systems, but it's
reasonable to keep them consistent with PMD counterpart.

Introduce PHYSICAL_PMD_PAGE_MASK and PHYSICAL_PUD_PAGE_MASK in
addition to existing PHYSICAL_PAGE_MASK and reworks helpers to
use them.

Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[ Fix -Woverflow warnings from the realmode code. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: JA 1/4 rgen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: elliott@hpe.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT bit")
Link: http://lkml.kernel.org/r/1448878233-11390-2-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>

Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/boot/boot.h                 |  1 -
 arch/x86/boot/video-mode.c           |  2 ++
 arch/x86/boot/video.c                |  2 ++
 arch/x86/include/asm/page_types.h    | 16 +++++++++-------
 arch/x86/include/asm/pgtable_types.h | 14 ++++----------
 arch/x86/include/asm/x86_init.h      |  1 -
 6 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/arch/x86/boot/boot.h b/arch/x86/boot/boot.h
index 0033e96..9011a88 100644
--- a/arch/x86/boot/boot.h
+++ b/arch/x86/boot/boot.h
@@ -23,7 +23,6 @@
 #include <stdarg.h>
 #include <linux/types.h>
 #include <linux/edd.h>
-#include <asm/boot.h>
 #include <asm/setup.h>
 #include "bitops.h"
 #include "ctype.h"
diff --git a/arch/x86/boot/video-mode.c b/arch/x86/boot/video-mode.c
index aa8a96b..95c7a81 100644
--- a/arch/x86/boot/video-mode.c
+++ b/arch/x86/boot/video-mode.c
@@ -19,6 +19,8 @@
 #include "video.h"
 #include "vesa.h"
 
+#include <uapi/asm/boot.h>
+
 /*
  * Common variables
  */
diff --git a/arch/x86/boot/video.c b/arch/x86/boot/video.c
index 05111bb..77780e3 100644
--- a/arch/x86/boot/video.c
+++ b/arch/x86/boot/video.c
@@ -13,6 +13,8 @@
  * Select video mode
  */
 
+#include <uapi/asm/boot.h>
+
 #include "boot.h"
 #include "video.h"
 #include "vesa.h"
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index c5b7fb2..cc071c6 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -9,19 +9,21 @@
 #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK	(~(PAGE_SIZE-1))
 
+#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
+#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
+
+#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
+#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+
 #define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
 
-/* Cast PAGE_MASK to a signed type so that it is sign-extended if
+/* Cast *PAGE_MASK to a signed type so that it is sign-extended if
    virtual addresses are 32-bits but physical addresses are larger
    (ie, 32-bit PAE). */
 #define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
-
-#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
-#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
-
-#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
-#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+#define PHYSICAL_PMD_PAGE_MASK	(((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
+#define PHYSICAL_PUD_PAGE_MASK	(((signed long)PUD_PAGE_MASK) & __PHYSICAL_MASK)
 
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index dd5b0aa..a471cad 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 static inline pudval_t pud_pfn_mask(pud_t pud)
 {
 	if (native_pud_val(pud) & _PAGE_PSE)
-		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return PHYSICAL_PUD_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pudval_t pud_flags_mask(pud_t pud)
 {
-	if (native_pud_val(pud) & _PAGE_PSE)
-		return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pud_pfn_mask(pud);
 }
 
 static inline pudval_t pud_flags(pud_t pud)
@@ -300,17 +297,14 @@ static inline pudval_t pud_flags(pud_t pud)
 static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
 {
 	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return PHYSICAL_PMD_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pmdval_t pmd_flags_mask(pmd_t pmd)
 {
-	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pmd_pfn_mask(pmd);
 }
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
diff --git a/arch/x86/include/asm/x86_init.h b/arch/x86/include/asm/x86_init.h
index 48d34d2..cd0fc0c 100644
--- a/arch/x86/include/asm/x86_init.h
+++ b/arch/x86/include/asm/x86_init.h
@@ -1,7 +1,6 @@
 #ifndef _ASM_X86_PLATFORM_H
 #define _ASM_X86_PLATFORM_H
 
-#include <asm/pgtable_types.h>
 #include <asm/bootparam.h>
 
 struct mpc_bus;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
