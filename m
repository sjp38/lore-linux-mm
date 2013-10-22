Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id F12386B03BC
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 07:41:33 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so8450396pbc.17
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 04:41:33 -0700 (PDT)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id iu9si11955032pac.321.2013.10.22.04.41.31
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 04:41:33 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 17:11:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 87A938E9259
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:00:07 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVPGO42533008
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSZDl023254
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 8/9] powerpc: mm: Support setting _PAGE_NUMA bit on pmd entry which are pointer to PTE page
Date: Tue, 22 Oct 2013 16:58:19 +0530
Message-Id: <1382441300-1513-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 46db094..f828944 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -150,8 +150,22 @@
 
 #define pmd_set(pmdp, pmdval) 	(pmd_val(*(pmdp)) = (pmdval))
 #define pmd_none(pmd)		(!pmd_val(pmd))
-#define	pmd_bad(pmd)		(!is_kernel_addr(pmd_val(pmd)) \
-				 || (pmd_val(pmd) & PMD_BAD_BITS))
+
+static inline int pmd_bad(pmd_t pmd)
+{
+#ifdef CONFIG_NUMA_BALANCING
+	/*
+	 * For numa balancing we can have this set
+	 */
+	if (pmd_val(pmd) & _PAGE_NUMA)
+		return 0;
+#endif
+	if (!is_kernel_addr(pmd_val(pmd)) ||
+	    (pmd_val(pmd) & PMD_BAD_BITS))
+		return 1;
+	return 0;
+}
+
 #define	pmd_present(pmd)	(pmd_val(pmd) != 0)
 #define	pmd_clear(pmdp)		(pmd_val(*(pmdp)) = 0)
 #define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
