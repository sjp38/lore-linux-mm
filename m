Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 926E86B02B4
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 07:27:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 8so16489464wms.11
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 04:27:32 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id f42si23687071wrf.122.2017.06.02.04.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 04:27:31 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id d127so23316906wmf.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 04:27:31 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD mappings
Date: Fri,  2 Jun 2017 11:27:20 +0000
Message-Id: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, labbott@fedoraproject.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, zhongjiang@huawei.com, guohanjun@huawei.com, tanxiaojun@huawei.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

While vmalloc() itself strictly uses page mappings only on all
architectures, some of the support routines are aware of the possible
existence of PMD or PUD size mappings inside the VMALLOC region.
This is necessary given that ioremap() shares this region and the
unmap routines with vmalloc(), and ioremap() may use huge pages on
some architectures.

On arm64 running with 4 KB pages, VM_MAP mappings will exist in the
VMALLOC region that are mapped to some extent using PMD size mappings.
As reported by Zhong Jiang, this confuses the kcore code, given that
vread() does not expect having to deal with PMD mappings, resulting
in oopses.

Even though we could work around this by special casing kcore or vmalloc
code for the VM_MAP mappings used by the arm64 kernel, the fact is that
there is already a precedent for dealing with PMD/PUD mappings in the
VMALLOC region, and so we could update the vmalloc_to_page() routine to
deal with such mappings as well. This solves the problem, and brings us
a step closer to huge page support in vmalloc/vmap, which could well be
in our future anyway.

Reported-by: Zhong Jiang <zhongjiang@huawei.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 mm/vmalloc.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e46ed7..cd79e62f8011 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -12,6 +12,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/highmem.h>
+#include <linux/hugetlb.h>
 #include <linux/sched/signal.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -263,6 +264,38 @@ int is_vmalloc_or_module_addr(const void *x)
 }
 
 /*
+ * Some architectures (such as arm64) allow vmap() mappings in the
+ * vmalloc region that may consist of PMD block mappings.
+ */
+static struct page *vmalloc_to_pud_page(unsigned long addr, pud_t *pud)
+{
+	struct page *page = NULL;
+#ifdef CONFIG_HUGETLB_PAGE
+	pte_t pte = huge_ptep_get((pte_t *)pud);
+
+	if (pte_present(pte))
+		page = pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+#else
+	VIRTUAL_BUG_ON(1);
+#endif
+	return page;
+}
+
+static struct page *vmalloc_to_pmd_page(unsigned long addr, pmd_t *pmd)
+{
+	struct page *page = NULL;
+#ifdef CONFIG_HUGETLB_PAGE
+	pte_t pte = huge_ptep_get((pte_t *)pmd);
+
+	if (pte_present(pte))
+		page = pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+#else
+	VIRTUAL_BUG_ON(1);
+#endif
+	return page;
+}
+
+/*
  * Walk a vmap address to the struct page it maps.
  */
 struct page *vmalloc_to_page(const void *vmalloc_addr)
@@ -289,9 +322,13 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	pud = pud_offset(p4d, addr);
 	if (pud_none(*pud))
 		return NULL;
+	if (pud_huge(*pud))
+		return vmalloc_to_pud_page(addr, pud);
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return NULL;
+	if (pmd_huge(*pmd))
+		return vmalloc_to_pmd_page(addr, pmd);
 
 	ptep = pte_offset_map(pmd, addr);
 	pte = *ptep;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
