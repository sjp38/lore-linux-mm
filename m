Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 32C036B0038
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 13:30:42 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so2756173qaj.21
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 10:30:41 -0700 (PDT)
Received: from mail-qg0-x24a.google.com (mail-qg0-x24a.google.com [2607:f8b0:400d:c04::24a])
        by mx.google.com with ESMTPS id jz8si2759479qcb.4.2014.08.06.10.30.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 10:30:41 -0700 (PDT)
Received: by mail-qg0-f74.google.com with SMTP id z60so374123qgd.1
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 10:30:41 -0700 (PDT)
Date: Wed, 6 Aug 2014 13:30:40 -0400
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH -mm v6 06/13] pagemap: use walk->vma instead of calling
 find_vma()
Message-ID: <20140806173040.GA28526@google.com>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1406920849-25908-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406920849-25908-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 01, 2014 at 03:20:42PM -0400, Naoya Horiguchi wrote:
> Page table walker has the information of the current vma in mm_walk, so
> we don't have to call find_vma() in each pagemap_hugetlb_range() call.

You could also get rid of a bunch of code in pagemap_pte_range:

---
 fs/proc/task_mmu.c | 33 ++++++---------------------------
 1 file changed, 6 insertions(+), 27 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9b30bdd..e9af130 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1035,16 +1035,14 @@ static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemap
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = walk->vma
 	struct pagemapread *pm = walk->private;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+	pagemap_entry_t pme;
 
-	/* find the first VMA at or above 'addr' */
-	vma = find_vma(walk->mm, addr);
-	if (vma && pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1069,28 +1067,9 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	if (pmd_trans_unstable(pmd))
 		return 0;
 	for (; addr != end; addr += PAGE_SIZE) {
-		int flags2;
-
-		/* check to see if we've left 'vma' behind
-		 * and need a new, higher one */
-		if (vma && (addr >= vma->vm_end)) {
-			vma = find_vma(walk->mm, addr);
-			if (vma && (vma->vm_flags & VM_SOFTDIRTY))
-				flags2 = __PM_SOFT_DIRTY;
-			else
-				flags2 = 0;
-			pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
-		}
-
-		/* check that 'vma' actually covers this address,
-		 * and that it isn't a huge page vma */
-		if (vma && (vma->vm_start <= addr) &&
-		    !is_vm_hugetlb_page(vma)) {
-			pte = pte_offset_map(pmd, addr);
-			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
-			/* unmap before userspace copy */
-			pte_unmap(pte);
-		}
+		pte = pte_offset_map(pmd, addr);
+		pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
+		pte_unmap(pte);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
