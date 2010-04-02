Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0233620087
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:45:58 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 41 of 41] mprotect: transparent huge page support
Message-Id: <db7ac8f36eed59da56ed.1270168928@v2.random>
In-Reply-To: <patchbomb.1270168887@v2.random>
References: <patchbomb.1270168887@v2.random>
Date: Fri, 02 Apr 2010 02:42:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
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
@@ -961,6 +961,33 @@ int mincore_huge_pmd(struct vm_area_stru
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
@@ -90,7 +90,13 @@ static inline void change_pmd_range(stru
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
 		change_pte_range(vma, pmd, addr, next, newprot, dirty_accountable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
