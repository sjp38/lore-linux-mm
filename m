Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7911280270
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 02:53:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g1so469603307pgn.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 23:53:17 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 92si33359881plc.147.2016.12.22.23.53.16
        for <linux-mm@kvack.org>;
        Thu, 22 Dec 2016 23:53:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3] mm: pmd dirty emulation in page fault handler
Date: Fri, 23 Dec 2016 16:53:07 +0900
Message-Id: <1482479587-4823-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>

Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de

The problem is page fault handler supports only accessed flag emulation
for THP page of SW-dirty/accessed architecture.

This patch enables dirty-bit emulation for those architectures.
Without it, MADV_FREE makes application hang by repeated fault forever.

[1] b8d3c4c3009d, mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called

Cc: Jason Evans <je@fb.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
