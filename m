Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5TEDOpc256184
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 14:13:24 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5TEDOpY1720500
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:24 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5TEDO1V016043
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:24 +0200
Message-Id: <20070629141528.511942868@de.ibm.com>
References: <20070629135530.912094590@de.ibm.com>
Date: Fri, 29 Jun 2007 15:55:35 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/5] Optimize page_mkclean_one
Content-Disposition: inline; filename=006-page-mkclean.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

page_mkclean_one is used to clear the dirty bit and to set the write
protect bit of a pte. In additions it returns true if the pte either
has been dirty or if it has been writable. As far as I can see the
function should return true only if the pte has been dirty, or page
writeback will needlessly write a clean page.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 mm/rmap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-06-29 09:58:33.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-29 15:44:58.000000000 +0200
@@ -433,11 +433,12 @@ static int page_mkclean_one(struct page 
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		entry = ptep_clear_flush(vma, address, pte);
+		if (pte_dirty(entry))
+			ret = 1;
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
 		lazy_mmu_prot_update(entry);
-		ret = 1;
 	}
 
 	pte_unmap_unlock(pte, ptl);

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
