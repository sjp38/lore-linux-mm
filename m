Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B5106B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 17:19:20 -0500 (EST)
Date: Wed, 19 Jan 2011 23:19:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] BUG: unable to handle kernel paging request at fffba000
Message-ID: <20110119221909.GO9506@random.random>
References: <20110119124047.GA30274@kwango.lan.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110119124047.GA30274@kwango.lan.net>
Sender: owner-linux-mm@kvack.org
To: Ilya Dryomov <idryomov@gmail.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Ilya,

thanks for sending me the gdb info too.

can you test this fix? Thanks a lot! (it only affected x86 32bit
builds with highpte enabled)

====
Subject: fix pte_unmap in khugepaged for highpte x86_32

From: Andrea Arcangeli <aarcange@redhat.com>

__collapse_huge_page_copy is still dereferencing the pte passed as parameter so
we must pte_unmap after __collapse_huge_page_copy returns, not before.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 004c9c2..c4f634b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1837,9 +1837,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spin_lock(ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
 	spin_unlock(ptl);
-	pte_unmap(pte);
 
 	if (unlikely(!isolated)) {
+		pte_unmap(pte);
 		spin_lock(&mm->page_table_lock);
 		BUG_ON(!pmd_none(*pmd));
 		set_pmd_at(mm, address, pmd, _pmd);
@@ -1856,6 +1856,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	anon_vma_unlock(vma->anon_vma);
 
 	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
+	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
 	VM_BUG_ON(page_count(pgtable) != 1);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
