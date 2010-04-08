Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 800C8620088
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:08 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 24 of 67] Do page table walks with the well-known nested loops
	we use in several
Message-Id: <a4ec9396008d51ebaa14.1270691467@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

other places already.

This avoids doing full page table walks after every pte range and also
allows to handle unmapped areas bigger than one pte range in one go.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -144,6 +144,60 @@ static void mincore_pte_range(struct vm_
 	pte_unmap_unlock(ptep - 1, ptl);
 }
 
+static void mincore_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+			unsigned long addr, unsigned long end,
+			unsigned char *vec)
+{
+	unsigned long next;
+	pmd_t *pmd;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			mincore_unmapped_range(vma, addr, next, vec);
+		else
+			mincore_pte_range(vma, pmd, addr, next, vec);
+		vec += (next - addr) >> PAGE_SHIFT;
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void mincore_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+			unsigned long addr, unsigned long end,
+			unsigned char *vec)
+{
+	unsigned long next;
+	pud_t *pud;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			mincore_unmapped_range(vma, addr, next, vec);
+		else
+			mincore_pmd_range(vma, pud, addr, next, vec);
+		vec += (next - addr) >> PAGE_SHIFT;
+	} while (pud++, addr = next, addr != end);
+}
+
+static void mincore_page_range(struct vm_area_struct *vma,
+			unsigned long addr, unsigned long end,
+			unsigned char *vec)
+{
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			mincore_unmapped_range(vma, addr, next, vec);
+		else
+			mincore_pud_range(vma, pgd, addr, next, vec);
+		vec += (next - addr) >> PAGE_SHIFT;
+	} while (pgd++, addr = next, addr != end);
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -151,9 +205,6 @@ static void mincore_pte_range(struct vm_
  */
 static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	struct vm_area_struct *vma;
 	unsigned long end;
 
@@ -170,21 +221,11 @@ static long do_mincore(unsigned long add
 
 	end = pmd_addr_end(addr, end);
 
-	pgd = pgd_offset(vma->vm_mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		goto none_mapped;
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		goto none_mapped;
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		goto none_mapped;
+	if (is_vm_hugetlb_page(vma))
+		mincore_hugetlb_page_range(vma, addr, end, vec);
+	else
+		mincore_page_range(vma, addr, end, vec);
 
-	mincore_pte_range(vma, pmd, addr, end, vec);
-	return (end - addr) >> PAGE_SHIFT;
-
-none_mapped:
-	mincore_unmapped_range(vma, addr, end, vec);
 	return (end - addr) >> PAGE_SHIFT;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
