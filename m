Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C81606B0085
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:43 -0500 (EST)
Message-Id: <20100221141757.404104520@redhat.com>
Date: Sun, 21 Feb 2010 15:10:38 +0100
From: aarcange@redhat.com
Subject: [patch 29/36] page anon_vma
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=page_anon_vma
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Find the anon_vma to lock from the page rather than from the vma, after recent
anon_vma changes that allows a vma to belong to more than a single anon_vma.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -761,13 +761,14 @@ static void __split_huge_page(struct pag
 			      struct anon_vma *anon_vma)
 {
 	int mapcount, mapcount2;
-	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 
 	BUG_ON(!PageHead(page));
 	BUG_ON(PageTail(page));
 
 	mapcount = 0;
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		if (addr == -EFAULT)
 			continue;
@@ -778,7 +779,8 @@ static void __split_huge_page(struct pag
 	__split_huge_page_refcount(page);
 
 	mapcount2 = 0;
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		if (addr == -EFAULT)
 			continue;
@@ -791,29 +793,29 @@ static void __split_huge_page(struct pag
 void __split_huge_page_vma(struct vm_area_struct *vma, pmd_t *pmd)
 {
 	struct page *page;
-	struct anon_vma *anon_vma;
 	struct mm_struct *mm;
 
 	BUG_ON(vma->vm_flags & VM_HUGETLB);
 
 	mm = vma->vm_mm;
 
-	anon_vma = vma->anon_vma;
-
-	spin_lock(&anon_vma->lock);
-	BUG_ON(pmd_trans_splitting(*pmd));
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(&mm->page_table_lock);
-		spin_unlock(&anon_vma->lock);
 		return;
 	}
 	page = pmd_page(*pmd);
+	VM_BUG_ON(!page_count(page));
+	get_page(page);
 	spin_unlock(&mm->page_table_lock);
 
-	__split_huge_page(page, anon_vma);
+	/*
+	 * The vma->anon_vma->lock is the wrong lock if the page is shared,
+	 * the anon_vma->lock pointed by page->mapping is the right one.
+	 */
+	split_huge_page(page);
 
-	spin_unlock(&anon_vma->lock);
+	put_page(page);
 	BUG_ON(pmd_trans_huge(*pmd));
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
