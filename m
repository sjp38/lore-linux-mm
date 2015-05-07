Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 358356B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 03:23:40 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so32616393pab.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 00:23:39 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id bu7si1609022pad.180.2015.05.07.00.23.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 07 May 2015 00:23:39 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 7 May 2015 12:53:35 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B07D6125805C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 12:55:40 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t477NWYd57802936
	for <linux-mm@kvack.org>; Thu, 7 May 2015 12:53:32 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t476nOYG003645
	for <linux-mm@kvack.org>; Thu, 7 May 2015 12:19:25 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 2/2] powerpc/thp: Serialize pmd clear against a linux page table walk.
Date: Thu,  7 May 2015 12:53:28 +0530
Message-Id: <1430983408-24924-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Serialize against find_linux_pte_or_hugepte which does lock-less
lookup in page tables with local interrupts disabled. For huge pages
it casts pmd_t to pte_t. Since format of pte_t is different from
pmd_t we want to prevent transit from pmd pointing to page table
to pmd pointing to huge page (and back) while interrupts are disabled.
We clear pmd to possibly replace it with page table pointer in
different code paths. So make sure we wait for the parallel
find_linux_pte_or_hugepage to finish.

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from v1:
* Move kick_all_cpus_sync to pmdp_get_and_clear so that it handle zap_huge_pmd
  case also.

 arch/powerpc/mm/pgtable_64.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 9171c1a37290..049d961802aa 100644
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
