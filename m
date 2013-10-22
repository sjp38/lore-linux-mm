Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E83506B00E1
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 12:00:40 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so9978204pab.18
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:00:40 -0700 (PDT)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id gn4si12078088pbc.51.2013.10.22.09.00.38
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 09:00:39 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 21:30:35 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 916E83942975
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:16 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVQ5s30015694
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:27 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSYBC023208
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 6/9] powerpc: mm: book3s: Disable hugepaged pmd format for book3s
Date: Tue, 22 Oct 2013 16:58:17 +0530
Message-Id: <1382441300-1513-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

After commit e2b3d202d1dba8f3546ed28224ce485bc50010be we have the
below possible formats for pmd entry

(1) invalid (all zeroes)
(2) pointer to next table, as normal; bottom 6 bits == 0
(3) leaf pte for huge page, bottom two bits != 00
(4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table

On book3s we don't really use the (4).  For Numa balancing we need to
tag pmd entries that are pointer to next table with _PAGE_NUMA for
performance reason (9532fec118d485ea37ab6e3ea372d68cd8b4cd0d). This
patch enables that by disabling hugepd support for book3s if
NUMA_BALANCING is enabled. We ideally want to get rid of hugepd pointer
completely.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/page.h | 11 +++++++++++
 arch/powerpc/mm/hugetlbpage.c   |  8 +++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index b9f4262..791ab56 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -369,11 +369,22 @@ typedef struct { signed long pd; } hugepd_t;
 #ifdef CONFIG_PPC_BOOK3S_64
 static inline int hugepd_ok(hugepd_t hpd)
 {
+#ifdef CONFIG_NUMA_BALANCING
+	/*
+	 * In order to enable batch handling of pte numa faults, Numa balancing
+	 * code use the _PAGE_NUMA bit even on pmd that is pointing to PTE PAGE.
+	 * 9532fec118d485ea37ab6e3ea372d68cd8b4cd0d. After commit
+	 * e2b3d202d1dba8f3546ed28224ce485bc50010be we really don't need to
+	 * support hugepd for ppc64.
+	 */
+	return 0;
+#else
 	/*
 	 * hugepd pointer, bottom two bits == 00 and next 4 bits
 	 * indicate size of table
 	 */
 	return (((hpd.pd & 0x3) == 0x0) && ((hpd.pd & HUGEPD_SHIFT_MASK) != 0));
+#endif
 }
 #else
 static inline int hugepd_ok(hugepd_t hpd)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index d67db4b..71bd214 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -235,8 +235,14 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	if (!hpdp)
 		return NULL;
 
+#ifdef CONFIG_NUMA_BALANCING
+	/*
+	 * We cannot support hugepd format with numa balancing support
+	 * enabled.
+	 */
+	return NULL;
+#endif
 	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
-
 	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
 		return NULL;
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
