Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CD02C6B0092
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500 (EST)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAO8a014195
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:24 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 20 of 25] add page_check_address_pmd to find the pmd mapping a
	transparent hugepage
Message-Id: <60403ce8fbd2afde28f1.1258220318@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:38 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

page_check_address_pmd is used to find the pmds that might be mapping the
hugepage through the anon_vma in order to freeze and unfreeze them.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -55,8 +55,10 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/hugetlb.h>
 
 #include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 
 #include "internal.h"
 
@@ -260,6 +262,42 @@ unsigned long page_address_in_vma(struct
 	return vma_address(page, vma);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static pmd_t *__page_check_address_pmd(struct page *page, struct mm_struct *mm,
+				       unsigned long address, int notfrozen)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd, *ret = NULL;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		goto out;
+	VM_BUG_ON(notfrozen == 1 && pmd_trans_frozen(*pmd));
+	if (pmd_trans_huge(*pmd) && pmd_pgtable(*pmd) == page) {
+		VM_BUG_ON(notfrozen == -1 && !pmd_trans_frozen(*pmd));
+		ret = pmd;
+	}
+out:
+	return ret;
+}
+
+#define page_check_address_pmd(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, 0)
+#define page_check_address_pmd_notfrozen(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, 1)
+#define page_check_address_pmd_frozen(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, -1)
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 /*
  * Check that @page is mapped at @address into @mm.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
