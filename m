Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 03D356B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 03:12:22 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so10586072pad.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 00:12:22 -0800 (PST)
Date: Mon, 7 Jan 2013 16:12:13 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC]x86: clearing access bit don't flush tlb
Message-ID: <20130107081213.GA21779@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mingo@redhat.com, hpa@zytor.com, riel@redhat.com


We use access bit to age a page at page reclaim. When clearing pte access bit,
we could skip tlb flush for the virtual address. The side effect is if the pte
is in tlb and pte access bit is unset, when cpu access the page again, cpu will
not set pte's access bit. So next time page reclaim can reclaim hot pages
wrongly, but this doesn't corrupt anything. And according to intel manual, tlb
has less than 1k entries, which coverers < 4M memory. In today's system,
several giga byte memory is normal. After page reclaim clears pte access bit
and before cpu access the page again, it's quite unlikely this page's pte is
still in TLB. Skiping the tlb flush for this case sounds ok to me.

And in some workloads, TLB flush overhead is very heavy. In my simple
multithread app with a lot of swap to several pcie SSD, removing the tlb flush
gives about 20% ~ 30% swapout speedup.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 arch/x86/mm/pgtable.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

Index: linux/arch/x86/mm/pgtable.c
===================================================================
--- linux.orig/arch/x86/mm/pgtable.c	2012-12-17 16:54:37.847770807 +0800
+++ linux/arch/x86/mm/pgtable.c	2013-01-07 14:59:40.898066357 +0800
@@ -376,13 +376,8 @@ int pmdp_test_and_clear_young(struct vm_
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
-	int young;
 
-	young = ptep_test_and_clear_young(vma, address, ptep);
-	if (young)
-		flush_tlb_page(vma, address);
-
-	return young;
+	return ptep_test_and_clear_young(vma, address, ptep);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
