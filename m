Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id A15046B0143
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 20:43:04 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so979182pbc.34
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 17:43:04 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id eg2si2182708pac.18.2014.04.02.17.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 17:43:03 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so943821pdi.21
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 17:43:03 -0700 (PDT)
Date: Thu, 3 Apr 2014 08:42:50 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch]x86: clearing access bit don't flush tlb
Message-ID: <20140403004250.GA14597@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mingo@kernel.org, riel@redhat.com, hughd@google.com, mgorman@suse.de, torvalds@linux-foundation.org

Add a few acks and resend this patch.

We use access bit to age a page at page reclaim. When clearing pte access bit,
we could skip tlb flush in X86. The side effect is if the pte is in tlb and pte
access bit is unset in page table, when cpu access the page again, cpu will not
set page table pte's access bit. Next time page reclaim will think this hot
page is yong and reclaim it wrongly, but this doesn't corrupt data.

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
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Hugh Dickins <hughd@google.com>
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
