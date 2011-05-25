Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08FA16B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:09:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8EA743EE0AE
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:09:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75A9E45DF47
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:09:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5408645DEDE
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:09:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47C64E08001
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:09:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14C1B1DB8037
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:09:50 +0900 (JST)
Message-ID: <4DDCAB35.60109@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:09:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/4] pagewalk: don't look up vma if walk->hugetlb_entry is
 unused
References: <4DDCAAC0.20102@jp.fujitsu.com>
In-Reply-To: <4DDCAAC0.20102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com

Currently, walk_page_range() call find_vma() every page table
walk iteration. but it's completely unnecessary if walk->hugetlb_entry
is unused. And we don't have to assume find_vma() is lightweight
operation. Thus this patch check walk->hugetlb_entry and avoid
find_vma() call if possible.

This patch also makes some cleanups. 1) remove ugly uninitialized_var()
and 2) #ifdef in function body.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/pagewalk.c |   43 +++++++++++++++++++++++++++++++++++++------
 1 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 606bbb4..ee4ff87 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -126,7 +126,39 @@ static int walk_hugetlb_range(struct vm_area_struct *vma,

 	return 0;
 }
-#endif
+
+static struct vm_area_struct* hugetlb_vma(unsigned long addr, struct mm_walk *walk)
+{
+	struct vm_area_struct *vma;
+
+	/* We don't need vma lookup at all. */
+	if (!walk->hugetlb_entry)
+		return NULL;
+
+	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+	vma = find_vma(walk->mm, addr);
+	if (vma && vma->vm_start <= addr && is_vm_hugetlb_page(vma))
+		return vma;
+
+	return NULL;
+}
+
+#else /* CONFIG_HUGETLB_PAGE */
+static struct vm_area_struct* hugetlb_vma(unsigned long addr, struct mm_walk *walk)
+{
+	return NULL;
+}
+
+static int walk_hugetlb_range(struct vm_area_struct *vma,
+			      unsigned long addr, unsigned long end,
+			      struct mm_walk *walk)
+{
+	return 0;
+}
+
+#endif /* CONFIG_HUGETLB_PAGE */
+
+

 /**
  * walk_page_range - walk a memory map's page tables with a callback
@@ -165,18 +197,17 @@ int walk_page_range(unsigned long addr, unsigned long end,

 	pgd = pgd_offset(walk->mm, addr);
 	do {
-		struct vm_area_struct *uninitialized_var(vma);
+		struct vm_area_struct *vma;

 		next = pgd_addr_end(addr, end);

-#ifdef CONFIG_HUGETLB_PAGE
 		/*
 		 * handle hugetlb vma individually because pagetable walk for
 		 * the hugetlb page is dependent on the architecture and
 		 * we can't handled it in the same manner as non-huge pages.
 		 */
-		vma = find_vma(walk->mm, addr);
-		if (vma && vma->vm_start <= addr && is_vm_hugetlb_page(vma)) {
+		vma = hugetlb_vma(addr, walk);
+		if (vma) {
 			if (vma->vm_end < next)
 				next = vma->vm_end;
 			/*
@@ -189,7 +220,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 			pgd = pgd_offset(walk->mm, next);
 			continue;
 		}
-#endif
+
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
