Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4D506B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:52:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o74so13250427pfi.6
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:52:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y14si242047pgq.414.2017.06.15.07.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 07:52:32 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to track dirty/accessed bits
Date: Thu, 15 Jun 2017 17:52:24 +0300
Message-Id: <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
to transfer dirty and accessed bits.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c |  8 ++++----
 mm/huge_memory.c   | 29 ++++++++++++-----------------
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0c8b33d99b1..f2fc1ef5bba2 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -906,13 +906,13 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-	pmd_t pmd = *pmdp;
+	pmd_t old, pmd = *pmdp;
 
 	/* See comment in change_huge_pmd() */
-	pmdp_invalidate(vma, addr, pmdp);
-	if (pmd_dirty(*pmdp))
+	old = pmdp_invalidate(vma, addr, pmdp);
+	if (pmd_dirty(old))
 		pmd = pmd_mkdirty(pmd);
-	if (pmd_young(*pmdp))
+	if (pmd_young(old))
 		pmd = pmd_mkyoung(pmd);
 
 	pmd = pmd_wrprotect(pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a84909cf20d3..0433e73531bf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1777,17 +1777,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	 * pmdp_invalidate() is required to make sure we don't miss
 	 * dirty/young flags set by hardware.
 	 */
-	entry = *pmd;
-	pmdp_invalidate(vma, addr, pmd);
-
-	/*
-	 * Recover dirty/young flags.  It relies on pmdp_invalidate to not
-	 * corrupt them.
-	 */
-	if (pmd_dirty(*pmd))
-		entry = pmd_mkdirty(entry);
-	if (pmd_young(*pmd))
-		entry = pmd_mkyoung(entry);
+	entry = pmdp_invalidate(vma, addr, pmd);
 
 	entry = pmd_modify(entry, newprot);
 	if (preserve_write)
@@ -1927,8 +1917,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
 	pgtable_t pgtable;
-	pmd_t _pmd;
-	bool young, write, dirty, soft_dirty;
+	pmd_t old, _pmd;
+	bool young, write, soft_dirty;
 	unsigned long addr;
 	int i;
 
@@ -1965,7 +1955,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	page_ref_add(page, HPAGE_PMD_NR - 1);
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-	dirty = pmd_dirty(*pmd);
 	soft_dirty = pmd_soft_dirty(*pmd);
 
 	pmdp_huge_split_prepare(vma, haddr, pmd);
@@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
 		}
-		if (dirty)
-			SetPageDirty(page + i);
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, addr, pte, entry);
@@ -2045,7 +2032,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 * and finally we write the non-huge version of the pmd entry with
 	 * pmd_populate.
 	 */
-	pmdp_invalidate(vma, haddr, pmd);
+	old = pmdp_invalidate(vma, haddr, pmd);
+
+	/*
+	 * Transfer dirty bit using value returned by pmd_invalidate() to be
+	 * sure we don't race with CPU that can set the bit under us.
+	 */
+	if (pmd_dirty(old))
+		SetPageDirty(page);
+
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
