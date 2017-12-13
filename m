Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 816106B0261
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:58:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v190so1388869pgv.11
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:58:16 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id p26si1225030pfh.220.2017.12.13.02.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 02:58:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 11/12] mm: Use updated pmdp_invalidate() interface to track dirty/accessed bits
Date: Wed, 13 Dec 2017 13:57:55 +0300
Message-Id: <20171213105756.69879-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
to transfer dirty and accessed bits.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c |  8 ++++----
 mm/huge_memory.c   | 29 ++++++++++++-----------------
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 339e4c1c044d..b4408c642fec 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -977,14 +977,14 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-	pmd_t pmd = *pmdp;
+	pmd_t old, pmd = *pmdp;
 
 	if (pmd_present(pmd)) {
 		/* See comment in change_huge_pmd() */
-		pmdp_invalidate(vma, addr, pmdp);
-		if (pmd_dirty(*pmdp))
+		old = pmdp_invalidate(vma, addr, pmdp);
+		if (pmd_dirty(old))
 			pmd = pmd_mkdirty(pmd);
-		if (pmd_young(*pmdp))
+		if (pmd_young(old))
 			pmd = pmd_mkyoung(pmd);
 
 		pmd = pmd_wrprotect(pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2f2f5e774902..10278d03d60f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1910,17 +1910,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -2073,8 +2063,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
 	pgtable_t pgtable;
-	pmd_t _pmd;
-	bool young, write, dirty, soft_dirty, pmd_migration = false;
+	pmd_t old, _pmd;
+	bool young, write, soft_dirty, pmd_migration = false;
 	unsigned long addr;
 	int i;
 
@@ -2130,7 +2120,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	page_ref_add(page, HPAGE_PMD_NR - 1);
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-	dirty = pmd_dirty(*pmd);
 	soft_dirty = pmd_soft_dirty(*pmd);
 
 	pmdp_huge_split_prepare(vma, haddr, pmd);
@@ -2160,8 +2149,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
 		}
-		if (dirty)
-			SetPageDirty(page + i);
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, addr, pte, entry);
@@ -2210,7 +2197,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
