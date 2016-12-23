Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3F56280264
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 10:15:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n189so141879223pga.4
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 07:15:10 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 33si34401161pli.217.2016.12.23.07.15.09
        for <linux-mm@kvack.org>;
        Fri, 23 Dec 2016 07:15:09 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4] mm: pmd dirty emulation in page fault handler
Date: Sat, 24 Dec 2016 00:14:58 +0900
Message-Id: <1482506098-6149-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andreas Schwab <schwab@suse.de>, Minchan Kim <minchan@kernel.org>, Jason Evans <je@fb.com>, Michal Hocko <mhocko@suse.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de

The problem is currently page fault handler doesn't supports dirty bit
emulation of pmd for non-HW dirty-bit architecture so that application
stucks until VM marked the pmd dirty.

How the emulation work depends on the architecture. In case of arm64,
when it set up pte firstly, it sets pte PTE_RDONLY to get a chance to
mark the pte dirty via triggering page fault when store access happens.
Once the page fault occurs, VM marks the pmd dirty and arch code for
setting pmd will clear PTE_RDONLY for application to proceed.

IOW, if VM doesn't mark the pmd dirty, application hangs forever by
repeated fault(i.e., store op but the pmd is PTE_RDONLY).

This patch enables pmd dirty-bit emulation for those architectures.

[1] b8d3c4c3009d, mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called

Cc: Jason Evans <je@fb.com>
Cc: Michal Hocko <mhocko@suse.com> 
Cc: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: <stable@vger.kernel.org> [4.5+]
Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")
Reported-and-Tested-by: Andreas Schwab <schwab@suse.de>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
  Merry Xmas!

* from v3
  * Elaborate description
* from v2
  * Add acked-by/tested-by
* from v1
  * Remove __handle_mm_fault part - Kirill
 mm/huge_memory.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 10eedbf..29ec8a4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -883,15 +883,17 @@ void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	pmd_t entry;
 	unsigned long haddr;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
 
 	vmf->ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
 	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
 		goto unlock;
 
 	entry = pmd_mkyoung(orig_pmd);
+	if (write)
+		entry = pmd_mkdirty(entry);
 	haddr = vmf->address & HPAGE_PMD_MASK;
-	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry,
-				vmf->flags & FAULT_FLAG_WRITE))
+	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry, write))
 		update_mmu_cache_pmd(vmf->vma, vmf->address, vmf->pmd);
 
 unlock:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
