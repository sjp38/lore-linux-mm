Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CD67B6B0257
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:18:33 -0500 (EST)
Received: by pasz6 with SMTP id z6so219955282pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:18:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xn5si521035pbb.194.2015.11.09.15.18.32
        for <linux-mm@kvack.org>;
        Mon, 09 Nov 2015 15:18:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/mm: fix regression with huge pages on PAE
Date: Tue, 10 Nov 2015 01:18:10 +0200
Message-Id: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org
Cc: bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Toshi Kani <toshi.kani@hpe.com>

Recent PAT patchset has caused issue on 32-bit PAE machines:

[    8.905943] page:eea45000 count:0 mapcount:-128 mapping:  (null) index:0x0
[    8.913041] flags: 0x40000000()
[    8.916293] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
[    8.923204] ------------[ cut here ]------------
[    8.927958] kernel BUG at /home/build/linux-boris/mm/huge_memory.c:1485!
[    8.934860] invalid opcode: 0000 [#1] SMP
[    8.939094] Modules linked in: ahci libahci ata_generic skge r8169 firewire_ohci mii libata qla2xxx(+) scsi_transport_fc scsi_mod radeon tpm_infineon ttm backlight wmi acpi_cpufreq tpm_tis
[    8.956548] CPU: 2 PID: 1758 Comm: modprobe Not tainted 4.3.0upstream-09269-gce5c2d2 #1
[    8.964792] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M., BIOS 080014  07/18/2008
[    8.975991] task: ed84e600 ti: f6458000 task.ti: f6458000
[    8.981552] EIP: 0060:[<c11bde80>] EFLAGS: 00010246 CPU: 2
[    8.987203] EIP is at zap_huge_pmd+0x240/0x260
[    8.991778] EAX: 00000000 EBX: f6459eb0 ECX: 00000292 EDX: 00000292
[    8.998234] ESI: f6634d98 EDI: eea45000 EBP: f6459dc8 ESP: f6459d98
[    8.998355] ata1: SATA link down (SStatus 0 SControl 300)
[    9.000330] ata2: SATA link down (SStatus 0 SControl 300)
[    9.015804]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[    9.021364] CR0: 8005003b CR2: b75b21a0 CR3: 3655b880 CR4: 000006f0
[    9.027818] Stack:
[    9.029885]  00000080 00000000 80000002 ee795000 80000002 ffe00000 00000000 ffffff7f
[    9.037930]  eee6169c f70c5e40 b6600000 f6634d98 f6459e78 c119a7c8 b6600000 80000002
[    9.045972]  00000003 c18992f4 c18992f0 00000003 00000286 f6459e0c c10db5f0 00000000
[    9.054018] Call Trace:
[    9.056537]  [<c119a7c8>] unmap_single_vma+0x6e8/0x7c0
[    9.061829]  [<c10db5f0>] ? __wake_up+0x40/0x50
[    9.063587] firewire_core 0000:08:05.0: created device fw0: GUID 000000001a1a2f03, S800
[    9.074736]  [<c119a8e7>] unmap_vmas+0x47/0x80
[    9.079312]  [<c11a0c44>] unmap_region+0x74/0xc0
[    9.084067]  [<c11a2d50>] do_munmap+0x1b0/0x280
[    9.088732]  [<c11a2e58>] vm_munmap+0x38/0x50
[    9.093218]  [<c11a2e88>] SyS_munmap+0x18/0x20
[    9.097795]  [<c1003861>] do_fast_syscall_32+0xa1/0x270
[    9.103176]  [<c1095400>] ? __do_page_fault+0x430/0x430
[    9.108559]  [<c169de51>] sysenter_past_esp+0x36/0x55
[    9.113761] Code: 00 e9 05 fe ff ff 90 8d 74 26 00 0f 0b eb fe ba 4c e1 7a c1 89 f8 e8 f0 91 fd ff 0f 0b eb fe ba 6c e1 7a c1 89 f8 e8 e0 91 fd ff <0f> 0b eb fe ba c4 e1 7a c1 89 f8 e8 d0 91 fd ff 0f 0b eb fe 8d
[    9.133727] EIP: [<c11bde80>] zap_huge_pmd+0x240/0x260 SS:ESP 0068:f6459d98
[    9.140929] ---[ end trace cba8fb1fc2e2e78a ]---

The problem is in pmd_pfn_mask() and pmd_flags_mask(). These helpers use
PMD_PAGE_MASK to calculate resulting mask. PMD_PAGE_MASK is 'unsigned
long', not 'unsigned long long' as physaddr_t. As result upper bits of
resulting mask is truncated.

The patch reworks code to use PMD_SHIFT as base of mask calculation
instead of PMD_PAGE_MASK.

pud_pfn_mask() and pud_flags_mask() aren't problematic since we don't
have PUD page table level on 32-bit systems, but they reworked too to be
consistent with PMD counterpart.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT bit")
Cc: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/include/asm/pgtable_types.h | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

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
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
