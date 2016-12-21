Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA8D56B03DF
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:48:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so409897799pgi.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:48:30 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 64si28385782ply.171.2016.12.21.15.48.29
        for <linux-mm@kvack.org>;
        Wed, 21 Dec 2016 15:48:29 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: pmd dirty emulation in page fault handler
Date: Thu, 22 Dec 2016 08:48:21 +0900
Message-Id: <1482364101-16204-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, Andreas Schwab <schwab@suse.de>

Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de

The problem is page fault handler supports only accessed flag emulation
for THP page of SW-dirty/accessed architecture.

This patch enables dirty-bit emulation for those architectures.
Without it, MADV_FREE makes application hang by repeated fault forever.

[1] mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called

Cc: Jason Evans <je@fb.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: <stable@vger.kernel.org> [4.5+]
Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")
Reported-by: Andreas Schwab <schwab@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c |  6 ++++--
 mm/memory.c      | 18 ++++++++++--------
 2 files changed, 14 insertions(+), 10 deletions(-)

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
diff --git a/mm/memory.c b/mm/memory.c
index 36c774f..7408ddc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3637,18 +3637,20 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-			if ((vmf.flags & FAULT_FLAG_WRITE) &&
-					!pmd_write(orig_pmd)) {
-				ret = wp_huge_pmd(&vmf, orig_pmd);
-				if (!(ret & VM_FAULT_FALLBACK))
+			if (vmf.flags & FAULT_FLAG_WRITE) {
+				if (!pmd_write(orig_pmd)) {
+					ret = wp_huge_pmd(&vmf, orig_pmd);
+					if (ret == VM_FAULT_FALLBACK)
+						goto pte_fault;
 					return ret;
-			} else {
-				huge_pmd_set_accessed(&vmf, orig_pmd);
-				return 0;
+				}
 			}
+
+			huge_pmd_set_accessed(&vmf, orig_pmd);
+			return 0;
 		}
 	}
-
+pte_fault:
 	return handle_pte_fault(&vmf);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
