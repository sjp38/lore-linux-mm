Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAB66B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 04:51:19 -0500 (EST)
Received: by wmww144 with SMTP id w144so37015100wmw.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 01:51:18 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 127si11610268wmv.26.2015.11.11.01.51.17
        for <linux-mm@kvack.org>;
        Wed, 11 Nov 2015 01:51:17 -0800 (PST)
Date: Wed, 11 Nov 2015 10:51:01 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151111095101.GA22512@pd.tnic>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20151110170447.GH19187@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>

On Tue, Nov 10, 2015 at 06:04:47PM +0100, Borislav Petkov wrote:
> On Tue, Nov 10, 2015 at 05:07:13PM +0200, Kirill A. Shutemov wrote:
> > Yeah. Looks good to me.
> 
> It gets even cleaner. Let me run it through the *config build tests.

Hohumm, it passes. Here's what I ended up committing:

---
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Tue, 10 Nov 2015 01:18:10 +0200
Subject: [PATCH] x86/mm: Fix regression with huge pages on PAE
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Recent PAT patchset has caused issue on 32-bit PAE machines:

page:eea45000 count:0 mapcount:-128 mapping:  (null) index:0x0
flags: 0x40000000()
page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
------------[ cut here ]------------
kernel BUG at /home/build/linux-boris/mm/huge_memory.c:1485!
invalid opcode: 0000 [#1] SMP
Modules linked in: ahci libahci ata_generic skge r8169 firewire_ohci mii libata qla2xxx(+) scsi_transport_fc scsi_mod radeon tpm_infineon ttm backlight wmi acpi_cpufreq tpm_tis
CPU: 2 PID: 1758 Comm: modprobe Not tainted 4.3.0upstream-09269-gce5c2d2 #1
Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M., BIOS 080014  07/18/2008
task: ed84e600 ti: f6458000 task.ti: f6458000
EIP: 0060:[<c11bde80>] EFLAGS: 00010246 CPU: 2
EIP is at zap_huge_pmd+0x240/0x260
EAX: 00000000 EBX: f6459eb0 ECX: 00000292 EDX: 00000292
ESI: f6634d98 EDI: eea45000 EBP: f6459dc8 ESP: f6459d98
ata1: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: b75b21a0 CR3: 3655b880 CR4: 000006f0
Stack:
 ...
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
Code: 00 e9 05 fe ff ff 90 8d 74 26 00 0f 0b eb fe ba 4c e1 7a c1 89 f8 e8 f0 91 fd ff 0f 0b eb fe ba 6c e1 7a c1 89 f8 e8 e0 91 fd ff <0f> 0b eb fe ba c4 e1 7a c1 89 f8 e8 d0 91 fd ff 0f 0b eb fe 8d
EIP: [<c11bde80>] zap_huge_pmd+0x240/0x260 SS:ESP 0068:f6459d98
---[ end trace cba8fb1fc2e2e78a ]---

The problem is in pmd_pfn_mask() and pmd_flags_mask(). These helpers use
PMD_PAGE_MASK to calculate resulting mask. PMD_PAGE_MASK is 'unsigned
long', not 'unsigned long long' as phys_addr_t. As result upper bits of
resulting mask is truncated.

The patch reworks code to use PMD_SHIFT as base of mask calculation
instead of PMD_PAGE_MASK.

pud_pfn_mask() and pud_flags_mask() aren't problematic since we don't
have PUD page table level on 32-bit systems, but they are reworked too
to be consistent with PMD counterpart.

Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: elliott@hpe.com
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: JA 1/4 rgen Gross <jgross@suse.com>
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT bit")
Link: http://lkml.kernel.org/r/1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com
[ Fix -Woverflow warnings from the realmode code. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/boot/boot.h                 |  1 -
 arch/x86/boot/video-mode.c           |  2 ++
 arch/x86/boot/video.c                |  2 ++
 arch/x86/include/asm/pgtable_types.h | 14 ++++----------
 arch/x86/include/asm/x86_init.h      |  1 -
 5 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/arch/x86/boot/boot.h b/arch/x86/boot/boot.h
index 0033e96c3f09..9011a88353de 100644
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
index aa8a96b052e3..95c7a818c0ed 100644
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
index 05111bb8d018..77780e386e9b 100644
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
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index dd5b0aa9dd2f..c1e797266ce9 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 static inline pudval_t pud_pfn_mask(pud_t pud)
 {
 	if (native_pud_val(pud) & _PAGE_PSE)
-		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
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
+		return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
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
index 48d34d28f5a6..cd0fc0cc78bc 100644
--- a/arch/x86/include/asm/x86_init.h
+++ b/arch/x86/include/asm/x86_init.h
@@ -1,7 +1,6 @@
 #ifndef _ASM_X86_PLATFORM_H
 #define _ASM_X86_PLATFORM_H
 
-#include <asm/pgtable_types.h>
 #include <asm/bootparam.h>
 
 struct mpc_bus;
-- 
2.3.5

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
