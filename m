Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id F18616B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 18:30:38 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so1120410igb.9
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:30:38 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id l7si4474509icq.191.2014.03.26.15.30.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 15:30:38 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so1114788igb.5
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:30:38 -0700 (PDT)
Date: Thu, 27 Mar 2014 06:30:34 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch]x86: clearing access bit don't flush tlb
Message-ID: <20140326223034.GA31713@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mel@csn.ul.ie


I posted this patch a year ago or so, but it gets lost. Repost it here to check
if we can make progress this time.

We use access bit to age a page at page reclaim. When clearing pte access bit,
we could skip tlb flush in X86. The side effect is if the pte is in tlb and pte
access bit is unset in page table, when cpu access the page again, cpu will not
set page table pte's access bit. Next time page reclaim will think this hot
page is old and reclaim it wrongly, but this doesn't corrupt data.

And according to intel manual, tlb has less than 1k entries, which covers < 4M
memory. In today's system, several giga byte memory is normal. After page
reclaim clears pte access bit and before cpu access the page again, it's quite
unlikely this page's pte is still in TLB. And context swich will flush tlb too.
The chance skiping tlb flush to impact page reclaim should be very rare.

Originally (in 2.5 kernel maybe), we didn't do tlb flush after clear access bit.
Hugh added it to fix some ARM and sparc issues. Since I only change this for
x86, there should be no risk.

And in some workloads, TLB flush overhead is very heavy. In my simple
multithread app with a lot of swap to several pcie SSD, removing the tlb flush
gives about 20% ~ 30% swapout speedup.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 arch/x86/mm/pgtable.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

Index: linux/arch/x86/mm/pgtable.c
===================================================================
--- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
+++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
@@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
-	int young;
-
-	young = ptep_test_and_clear_young(vma, address, ptep);
-	if (young)
-		flush_tlb_page(vma, address);
-
-	return young;
+	/*
+	 * In X86, clearing access bit without TLB flush doesn't cause data
+	 * corruption. Doing this could cause wrong page aging and so hot pages
+	 * are reclaimed, but the chance should be very rare.
+	 */
+	return ptep_test_and_clear_young(vma, address, ptep);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
