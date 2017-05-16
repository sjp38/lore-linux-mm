Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57ECA6B0374
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e8so121087070pfl.4
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:24:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g23si13419046pli.273.2017.05.16.02.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:24:09 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9O4ag085635
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:08 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afnmhq139-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:07 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:23:57 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 5/9] mm/hugetlb: Move default definition of hugepd_t earlier in the header
Date: Tue, 16 May 2017 14:53:28 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This enable to use the hugepd_t type early. No functional change in this patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edab98f0a7b8..f66c1d4e0d1f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -14,6 +14,30 @@ struct ctl_table;
 struct user_struct;
 struct mmu_gather;
 
+#ifndef is_hugepd
+/*
+ * Some architectures requires a hugepage directory format that is
+ * required to support multiple hugepage sizes. For example
+ * a4fe3ce76 "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
+ * introduced the same on powerpc. This allows for a more flexible hugepage
+ * pagetable layout.
+ */
+typedef struct { unsigned long pd; } hugepd_t;
+#define is_hugepd(hugepd) (0)
+#define __hugepd(x) ((hugepd_t) { (x) })
+static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+			      unsigned pdshift, unsigned long end,
+			      int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#else
+extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		       unsigned pdshift, unsigned long end,
+		       int write, struct page **pages, int *nr);
+#endif
+
+
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
@@ -222,29 +246,6 @@ static inline int pud_write(pud_t pud)
 }
 #endif
 
-#ifndef is_hugepd
-/*
- * Some architectures requires a hugepage directory format that is
- * required to support multiple hugepage sizes. For example
- * a4fe3ce76 "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
- * introduced the same on powerpc. This allows for a more flexible hugepage
- * pagetable layout.
- */
-typedef struct { unsigned long pd; } hugepd_t;
-#define is_hugepd(hugepd) (0)
-#define __hugepd(x) ((hugepd_t) { (x) })
-static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-			      unsigned pdshift, unsigned long end,
-			      int write, struct page **pages, int *nr)
-{
-	return 0;
-}
-#else
-extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-		       unsigned pdshift, unsigned long end,
-		       int write, struct page **pages, int *nr);
-#endif
-
 #define HUGETLB_ANON_FILE "anon_hugepage"
 
 enum {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
