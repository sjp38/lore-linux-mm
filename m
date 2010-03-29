Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 308F26B01F0
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:40:42 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 40 of 41] mprotect: pass vma down to page table walkers
Message-Id: <95ae2546f21c5a68c41c.1269887873@v2.random>
In-Reply-To: <patchbomb.1269887833@v2.random>
References: <patchbomb.1269887833@v2.random>
Date: Mon, 29 Mar 2010 20:37:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>

Waiting for huge pmds to finish splitting requires the vma's anon_vma,
so pass along the vma instead of the mm, we can always get the latter
when we need it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -36,10 +36,11 @@ static inline pgprot_t pgprot_modify(pgp
 }
 #endif
 
-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+static void change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 
@@ -79,7 +80,7 @@ static void change_pte_range(struct mm_s
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
+static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
@@ -89,14 +90,14 @@ static inline void change_pmd_range(stru
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		split_huge_page_pmd(mm, pmd);
+		split_huge_page_pmd(vma->vm_mm, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
+		change_pte_range(vma, pmd, addr, next, newprot, dirty_accountable);
 	} while (pmd++, addr = next, addr != end);
 }
 
-static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
+static inline void change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
@@ -108,7 +109,7 @@ static inline void change_pud_range(stru
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		change_pmd_range(mm, pud, addr, next, newprot, dirty_accountable);
+		change_pmd_range(vma, pud, addr, next, newprot, dirty_accountable);
 	} while (pud++, addr = next, addr != end);
 }
 
@@ -128,7 +129,7 @@ static void change_protection(struct vm_
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
+		change_pud_range(vma, pgd, addr, next, newprot, dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
 	flush_tlb_range(vma, start, end);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
