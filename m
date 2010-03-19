Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 21CFE6B00B4
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:16:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J8Gr2c022692
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 17:16:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C90745DE55
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 17:16:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E241E45DE4F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 17:16:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F2561DB803B
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 17:16:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DDDFE38002
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 17:16:49 +0900 (JST)
Date: Fri, 19 Mar 2010 17:13:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-Id: <20100319171310.7d82f8eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 16:27:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 19 Mar 2010 16:10:23 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 19 Mar 2010 15:26:36 +0900
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > When we look into pagemap using page-types with option -p, the value
> > > of pfn for hugepages looks wrong (see below.)
> > > This is because pte was evaluated only once for one vma
> > > although it should be updated for each hugepage. This patch fixes it.
> > > 
> > > $ page-types -p 3277 -Nl -b huge
> > > voffset   offset  len     flags
> > > 7f21e8a00 11e400  1       ___U___________H_G________________
> > > 7f21e8a01 11e401  1ff     ________________TG________________
> > > 7f21e8c00 11e400  1       ___U___________H_G________________
> > > 7f21e8c01 11e401  1ff     ________________TG________________
> > >              ^^^
> > >              should not be the same
> > > 
> > > With this patch applied:
> > > 
> > > $ page-types -p 3386 -Nl -b huge
> > > voffset   offset   len    flags
> > > 7fec7a600 112c00   1      ___UD__________H_G________________
> > > 7fec7a601 112c01   1ff    ________________TG________________
> > > 7fec7a800 113200   1      ___UD__________H_G________________
> > > 7fec7a801 113201   1ff    ________________TG________________
> > >              ^^^
> > >              OK
> > > 
> > Hmm. Is this bug ? To me, it's just shown in hugepage's pagesize, by design.
> > 
> I'm sorry it seems this is bugfix.
> 
> But, this means hugeltb_entry() is not called per hugetlb entry...isn't it ?
> 
> Why hugetlb_entry() cannot be called per hugeltb entry ? Don't we need a code
> for a case as pmd_size != hugetlb_size in walk_page_range() for generic fix ?
> 

How about this style ? This is an idea-level patch. not tested at all.
(I have no test enviroment for multiple hugepage size.)

feel free to reuse fragments from this patch.
==

Not-tested-at-all!!

Now, walk_page_range() support page-table-walk on hugetlb.
But, it assumes that hugepage-size == pmd_size and hugetlb callback
is called per pmd not per pte of hugepage.

In some arch (ia64), hugepage-size is not pmd size (by config.)

This patch modifies hugetlb callback is called per hugetlb-ptes.

---
 mm/pagewalk.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 67 insertions(+), 14 deletions(-)

Index: mmotm-2.6.34-Mar11/mm/pagewalk.c
===================================================================
--- mmotm-2.6.34-Mar11.orig/mm/pagewalk.c
+++ mmotm-2.6.34-Mar11/mm/pagewalk.c
@@ -79,7 +79,65 @@ static int walk_pud_range(pgd_t *pgd, un
 
 	return err;
 }
+#ifdef CONFIG_HUGELB_PAGE
+static unsigned long
+__hugepage_next_offset(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	struct hstate *hs = hstate_vma(vma);
+	unsigned long size = huge_page_size(hs);
+	unsigned long base = addr & huge_page_mask(hs);
+	unsigned long limit;
+	/* Hugepage is very tighty coupled with vma. */
+	if (end > vma->end)
+		limit = vma->end;
+	else
+		limit = end;
+
+	if (base + size < limit)
+		return base + size;
+	return limit;
+}
 
+static int walk_hugepage_range(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	struct hstate *hs = hstate_vma(vma);
+	unsigned long size = huge_page_size(hs);
+	
+	/*
+	 * [addr...end) is guaranteeed to be under a vma
+	 *  (see __hugepage_next_offset())
+	 */
+
+	hs = hstate_vma(vma);
+	do {
+		pte = huge_pte_offset(walk->mm, addr & huge_page_mask(hs));
+		next = (addr & huge_page_mask(hs)) + size;
+		if (next > end)
+			next = end;
+		if (pte && !huge_pte_none(huge_ptep_get(pte))
+			&& walk->hugetlb_entry)
+			err = walk->hugetlb_entry(pte, addr, next, walk);
+	} while (addr = next, addr != end);
+
+	return err;
+}
+#else
+static unsigned long
+__hugepage_next_offset(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	BUG();
+	return 0;
+}
+static int walk_hugepage_range(struct mm_struct *mm,
+	struct vm_area_struct *vma, unsigned long addr, unsigned long end)
+{
+	return 0;
+}
+#endif
 /**
  * walk_page_range - walk a memory map's page tables with a callback
  * @mm: memory map to walk
@@ -126,25 +184,20 @@ int walk_page_range(unsigned long addr, 
 		 * we can't handled it in the same manner as non-huge pages.
 		 */
 		vma = find_vma(walk->mm, addr);
-#ifdef CONFIG_HUGETLB_PAGE
-		if (vma && is_vm_hugetlb_page(vma)) {
-			pte_t *pte;
-			struct hstate *hs;
 
-			if (vma->vm_end < next)
-				next = vma->vm_end;
-			hs = hstate_vma(vma);
-			pte = huge_pte_offset(walk->mm,
-					      addr & huge_page_mask(hs));
-			if (pte && !huge_pte_none(huge_ptep_get(pte))
-			    && walk->hugetlb_entry)
-				err = walk->hugetlb_entry(pte, addr,
-							  next, walk);
+		if (vma && is_vm_hugetlb_page(vma)) {
+			/*
+			 * In many archs, hugepage-size fits pmd size. But in
+			 * some arch, we cannot assume that.
+			 */
+			next = __hugepage_next_offset(vma, addr, end);
+			err = walk_hugepage_range(walk->mm, vma, addr, next);
 			if (err)
 				break;
+			/* We don't know next's pgd == pgd+1 */
+			pgd = pgd_offset(walk->mm, next);
 			continue;
 		}
-#endif
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
