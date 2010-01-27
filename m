Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0A6056B009C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 19:32:46 -0500 (EST)
Date: Wed, 27 Jan 2010 01:32:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #7
Message-ID: <20100127003202.GF30452@random.random>
References: <patchbomb.1264513915@v2.random>
 <20100126175532.GA3359@redhat.com>
 <20100127000029.GC30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100127000029.GC30452@random.random>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Reading oops first thing that comes to mind is this, this is good idea
anyway but it's untested, no time right now, tomorrow continue...

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1310,12 +1310,15 @@ static void release_all_pte_pages(pte_t 
 	release_pte_pages(pte, pte + HPAGE_PMD_NR);
 }
 
-static int __collapse_huge_page_isolate(pte_t *pte)
+static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
+					unsigned long address,
+					pte_t *pte)
 {
 	struct page *page;
 	pte_t *_pte;
 	int referenced = 0, isolated = 0;
-	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
+	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
+	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (!pte_present(pteval) || !pte_write(pteval)) {
 			release_pte_pages(pte, _pte);
@@ -1324,7 +1327,11 @@ static int __collapse_huge_page_isolate(
 		/* If there is no mapped pte young don't collapse the page */
 		if (pte_young(pteval))
 			referenced = 1;
-		page = pte_page(pteval);
+		page = vm_normal_page(vma, address, pteval);
+		if (unlikely(!page)) {
+			release_pte_pages(pte, _pte);
+			goto out;
+		}
 		VM_BUG_ON(PageCompound(page));
 		BUG_ON(!PageAnon(page));
 		VM_BUG_ON(!PageSwapBacked(page));
@@ -1427,7 +1434,7 @@ static void collapse_huge_page(struct mm
 	if (!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always())
 		goto out;
 
-	if (!vma->anon_vma || vma->vm_ops)
+	if (!vma->anon_vma || vma->vm_ops || vma->vm_file)
 		goto out;
 
 	pgd = pgd_offset(mm, address);
@@ -1455,7 +1462,7 @@ static void collapse_huge_page(struct mm
 	spin_unlock(&mm->page_table_lock);
 
 	spin_lock(ptl);
-	isolated = __collapse_huge_page_isolate(pte);
+	isolated = __collapse_huge_page_isolate(vma, address, pte);
 	spin_unlock(ptl);
 	pte_unmap(pte);
 
@@ -1540,7 +1547,9 @@ static int khugepaged_scan_pmd(struct mm
 			goto out_unmap;
 		if (pte_young(pteval))
 			referenced = 1;
-		page = pte_page(pteval);
+		page = vm_normal_page(vma, address, pteval);
+		if (unlikely(!page))
+			goto out_unmap;
 		VM_BUG_ON(PageCompound(page));
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
@@ -1619,7 +1628,7 @@ static unsigned int khugepaged_scan_mm_s
 			progress++;
 			continue;
 		}
-		if (!vma->anon_vma || vma->vm_ops) {
+		if (!vma->anon_vma || vma->vm_ops || vma->vm_file) {
 			khugepaged_scan.address = vma->vm_end;
 			progress++;
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
