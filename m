Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A8A6D6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 02:27:20 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so102178555pab.2
        for <linux-mm@kvack.org>; Sun, 10 May 2015 23:27:20 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id bf3si16638916pbd.193.2015.05.10.23.27.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 10 May 2015 23:27:19 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:27:14 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 554552CE8052
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:27:10 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4B6R1Gq45351136
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:27:10 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4B6Qbs1008368
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:26:37 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3] powerpc/thp: Serialize pmd clear against a linux page table walk.
Date: Mon, 11 May 2015 11:56:01 +0530
Message-Id: <1431325561-21396-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Serialize against find_linux_pte_or_hugepte which does lock-less
lookup in page tables with local interrupts disabled. For huge pages
it casts pmd_t to pte_t. Since format of pte_t is different from
pmd_t we want to prevent transit from pmd pointing to page table
to pmd pointing to huge page (and back) while interrupts are disabled.
We clear pmd to possibly replace it with page table pointer in
different code paths. So make sure we wait for the parallel
find_linux_pte_or_hugepage to finish.

Without this patch, a find_linux_pte_or_hugepte running in parallel to
__split_huge_zero_page_pmd or do_huge_pmd_wp_page_fallback or zap_huge_pmd
can run into the above issue. With __split_huge_zero_page_pmd and
do_huge_pmd_wp_page_fallback we clear the hugepage pte before inserting
the pmd entry with a regular pgtable address. Such a clear need to
wait for the parallel find_linux_pte_or_hugepte to finish.

With zap_huge_pmd, we can run into issues, with a hugepage pte
getting zapped due to a MADV_DONTNEED while other cpu fault it
in as small pages.

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V2:
* Drop the cleanup patch
  Will this as a separate patch and not bug fix.
* Update commit message

 arch/powerpc/mm/pgtable_64.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index b651179ac4da..1325be89e670 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -845,6 +845,17 @@ pmd_t pmdp_get_and_clear(struct mm_struct *mm,
 	 * hash fault look at them.
 	 */
 	memset(pgtable, 0, PTE_FRAG_SIZE);
+	/*
+	 * Serialize against find_linux_pte_or_hugepte which does lock-less
+	 * lookup in page tables with local interrupts disabled. For huge pages
+	 * it casts pmd_t to pte_t. Since format of pte_t is different from
+	 * pmd_t we want to prevent transit from pmd pointing to page table
+	 * to pmd pointing to huge page (and back) while interrupts are disabled.
+	 * We clear pmd to possibly replace it with page table pointer in
+	 * different code paths. So make sure we wait for the parallel
+	 * find_linux_pte_or_hugepage to finish.
+	 */
+	kick_all_cpus_sync();
 	return old_pmd;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
