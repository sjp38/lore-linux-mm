Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B01B16B0166
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 10:38:37 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hn9so5102403wib.10
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 07:38:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li2si9521675wjc.170.2014.03.19.07.38.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 07:38:36 -0700 (PDT)
Date: Wed, 19 Mar 2014 14:38:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: numa: Recheck for transhuge pages under lock during
 protection changes
Message-ID: <20140319143831.GA4751@suse.de>
References: <20140307182745.GD1931@suse.de>
 <20140311162845.GA30604@suse.de>
 <531F3F15.8050206@oracle.com>
 <531F4128.8020109@redhat.com>
 <531F48CC.303@oracle.com>
 <20140311180652.GM10663@suse.de>
 <531F616A.7060300@oracle.com>
 <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
 <20140312103602.GN10663@suse.de>
 <5323C5D9.2070902@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5323C5D9.2070902@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 14, 2014 at 11:15:37PM -0400, Sasha Levin wrote:
> On 03/12/2014 06:36 AM, Mel Gorman wrote:
> >Andrew, this should go with the patches
> >mmnuma-reorganize-change_pmd_range.patch
> >mmnuma-reorganize-change_pmd_range-fix.patch
> >move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
> >in mmotm please.
> >
> >Thanks.
> >
> >---8<---
> >From: Mel Gorman<mgorman@suse.de>
> >Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes
> >
> >Sasha Levin reported the following bug using trinity
> 
> I'm seeing a different issue with this patch. A NULL ptr deref occurs in the
> pte_offset_map_lock() macro right before the new recheck code:
> 

This on top?

I tried testing it but got all sorts of carnage that trinity throw up
in the mix and ordinary testing does not trigger the race. I've no idea
which of the current mess of trinity-exposed bugs you've encountered and
got fixed already.

---8<---
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes -fix

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 40 ++++++++++++++++++++++++++++++----------
 1 file changed, 30 insertions(+), 10 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 66973db..c43d557 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -36,6 +36,34 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 }
 #endif
 
+/*
+ * For a prot_numa update we only hold mmap_sem for read so there is a
+ * potential race with faulting where a pmd was temporarily none. This
+ * function checks for a transhuge pmd under the appropriate lock. It
+ * returns a pte if it was successfully locked or NULL if it raced with
+ * a transhuge insertion.
+ */
+static pte_t *lock_pte_protection(struct vm_area_struct *vma, pmd_t *pmd,
+			unsigned long addr, int prot_numa, spinlock_t **ptl)
+{
+	pte_t *pte;
+	spinlock_t *pmdl;
+
+	/* !prot_numa is protected by mmap_sem held for write */
+	if (!prot_numa)
+		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
+
+	pmdl = pmd_lock(vma->vm_mm, pmd);
+	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
+		spin_unlock(pmdl);
+		return NULL;
+	}
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
+	spin_unlock(pmdl);
+	return pte;
+}
+
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
@@ -45,17 +73,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	unsigned long pages = 0;
 
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-
-	/*
-	 * For a prot_numa update we only hold mmap_sem for read so there is a
-	 * potential race with faulting where a pmd was temporarily none so
-	 * recheck it under the lock and bail if we race
-	 */
-	if (prot_numa && unlikely(pmd_trans_huge(*pmd))) {
-		pte_unmap_unlock(pte, ptl);
+	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
+	if (!pte)
 		return 0;
-	}
 
 	arch_enter_lazy_mmu_mode();
 	do {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
