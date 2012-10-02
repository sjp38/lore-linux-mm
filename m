Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id AA9F46B0080
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:27:43 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:27:41 -0400 (EDT)
Message-Id: <20121002.182741.650740858374403508.davem@davemloft.net>
Subject: [PATCH 7/8] mm: thp: Use more portable PMD clearing sequenece in
 zap_huge_pmd().
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


Invalidation sequences are handled in various ways on various
architectures.

One way, which sparc64 uses, is to let the set_*_at() functions
accumulate pending flushes into a per-cpu array.  Then the
flush_tlb_range() et al. calls process the pending TLB flushes.

In this regime, the __tlb_remove_*tlb_entry() implementations are
essentially NOPs.

The canonical PTE zap in mm/memory.c is:

			ptent = ptep_get_and_clear_full(mm, addr, pte,
							tlb->fullmm);
			tlb_remove_tlb_entry(tlb, pte, addr);

With a subsequent tlb_flush_mmu() if needed.

Mirror this in the THP PMD zapping using:

		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
		page = pmd_page(orig_pmd);
		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);

And we properly accomodate TLB flush mechanims like the one described
above.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 mm/huge_memory.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5d44785..f9d8461 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1025,9 +1025,10 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
 		struct page *page;
 		pgtable_t pgtable;
+		pmd_t orig_pmd;
 		pgtable = get_pmd_huge_pte(tlb->mm);
-		page = pmd_page(*pmd);
-		pmd_clear(pmd);
+		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
+		page = pmd_page(orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		page_remove_rmap(page);
 		VM_BUG_ON(page_mapcount(page) < 0);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
