Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAAA6B03BA
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 07:41:31 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so8474490pbc.31
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 04:41:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id pz2si12008794pac.57.2013.10.22.04.41.29
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 04:41:30 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 17:11:23 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 81B0F8E9258
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:00:07 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVOXF46334048
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSYgP023095
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:34 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/9] powerpc: mm: Only check for _PAGE_PRESENT in set_pte/pmd functions
Date: Tue, 22 Oct 2013 16:58:15 +0530
Message-Id: <1382441300-1513-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We want to make sure we don't use these function when updating a pte
or pmd entry that have a valid hpte entry, because these functions
don't invalidate them. So limit the check to _PAGE_PRESENT bit.
Numafault core changes use these functions for updating _PAGE_NUMA bits.
That should be ok because when _PAGE_NUMA is set we can be sure that
hpte entries are not present.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/pgtable.c    | 2 +-
 arch/powerpc/mm/pgtable_64.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index edda589..10c09b6 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -187,7 +187,7 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 		pte_t pte)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(pte_present(*ptep));
+	WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
 #endif
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 536eec72..56b7586 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -686,7 +686,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 		pmd_t *pmdp, pmd_t pmd)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_none(*pmdp));
+	WARN_ON(pmd_val(*pmdp) & _PAGE_PRESENT);
 	assert_spin_locked(&mm->page_table_lock);
 	WARN_ON(!pmd_trans_huge(pmd));
 #endif
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
