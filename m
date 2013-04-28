Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 04D1A6B0096
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:52:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:17:00 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 621743940058
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:22:01 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJpsNL35651794
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:54 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJpxvp002441
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:52:00 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 10/10] powerpc: disable assert_pte_locked
Date: Mon, 29 Apr 2013 01:21:51 +0530
Message-Id: <1367178711-8232-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With THP we set pmd to none, before we do pte_clear. Hence we can't
walk page table to get the pte lock ptr and verify whether it is locked.
THP do take pte lock before calling pte_clear. So we don't change the locking
rules here. It is that we can't use page table walking to check whether
pte locks are help with THP.

NOTE: This needs to be re-written. Not to be merged upstream.
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/pgtable.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index 214130a..d77f94f 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -224,6 +224,7 @@ int ptep_set_access_flags(struct vm_area_struct *vma, unsigned long address,
 #ifdef CONFIG_DEBUG_VM
 void assert_pte_locked(struct mm_struct *mm, unsigned long addr)
 {
+#if 0
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -237,6 +238,7 @@ void assert_pte_locked(struct mm_struct *mm, unsigned long addr)
 	pmd = pmd_offset(pud, addr);
 	BUG_ON(!pmd_present(*pmd));
 	assert_spin_locked(pte_lockptr(mm, pmd));
+#endif
 }
 #endif /* CONFIG_DEBUG_VM */
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
