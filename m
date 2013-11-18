Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 871876B0037
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:28:36 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so35434pbb.4
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 01:28:36 -0800 (PST)
Received: from psmtp.com ([74.125.245.123])
        by mx.google.com with SMTP id vs7si9146365pbc.235.2013.11.18.01.28.33
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 01:28:34 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 18 Nov 2013 19:28:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 99C342CE8059
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:28 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI9AhqU25755748
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:10:43 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI9SRvf019769
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:28 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 4/5] powerpc: mm: Only check for _PAGE_PRESENT in set_pte/pmd functions
Date: Mon, 18 Nov 2013 14:58:12 +0530
Message-Id: <1384766893-10189-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
index 841e0d00863c..ad90429bbd8b 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -174,7 +174,7 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 		pte_t pte)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(pte_present(*ptep));
+	WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
 #endif
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 9d95786aa80f..02e8681fb865 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -687,7 +687,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
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
