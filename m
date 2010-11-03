Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 53CFA6B00C6
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:46 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 50 of 66] mprotect: transparent huge page support
Message-Id: <2d595dc366d358c0eef2.1288798105@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>

Natively handle huge pmds when changing page tables on behalf of
mprotect().

I left out update_mmu_cache() because we do not need it on x86 anyway
but more importantly the interface works on ptes, not pmds.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -22,6 +22,8 @@ extern int zap_huge_pmd(struct mmu_gathe
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
+extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			unsigned long addr, pgprot_t newprot);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -944,6 +944,33 @@ int mincore_huge_pmd(struct vm_area_stru
 	return ret;
 }
 
+int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long addr, pgprot_t newprot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int ret = 0;
+
+	spin_lock(&mm->page_table_lock);
+	if (likely(pmd_trans_huge(*pmd))) {
+		if (unlikely(pmd_trans_splitting(*pmd))) {
+			spin_unlock(&mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, pmd);
+		} else {
+			pmd_t entry;
+
+			entry = pmdp_get_and_clear(mm, addr, pmd);
+			entry = pmd_modify(entry, newprot);
+			set_pmd_at(mm, addr, pmd, entry);
+			spin_unlock(&vma->vm_mm->page_table_lock);
+			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
+			ret = 1;
+		}
+	} else
+		spin_unlock(&vma->vm_mm->page_table_lock);
+
+	return ret;
+}
+
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -88,7 +88,13 @@ static inline void change_pmd_range(stru
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		split_huge_page_pmd(vma->vm_mm, pmd);
+		if (pmd_trans_huge(*pmd)) {
+			if (next - addr != HPAGE_PMD_SIZE)
+				split_huge_page_pmd(vma->vm_mm, pmd);
+			else if (change_huge_pmd(vma, pmd, addr, newprot))
+				continue;
+			/* fall through */
+		}
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		change_pte_range(vma->vm_mm, pmd, addr, next, newprot,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
