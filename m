Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 727CC6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:54:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b86so17555262wmi.6
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:54:27 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id a15si3130553wme.139.2017.06.02.08.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 08:54:26 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id d127so30257649wmf.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:54:25 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD mappings
Date: Fri,  2 Jun 2017 15:54:16 +0000
Message-Id: <20170602155416.32706-1-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, labbott@fedoraproject.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, zhongjiang@huawei.com, guohanjun@huawei.com, tanxiaojun@huawei.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

While vmalloc() itself strictly uses page mappings only on all
architectures, some of the support routines are aware of the possible
existence of PMD or PUD size mappings inside the VMALLOC region.
This is necessary given that vmalloc() shares this region and the
unmap routines with ioremap(), which may use huge pages on some
architectures (HAVE_ARCH_HUGE_VMAP).

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
v2:
- simplify so we can get rid of #ifdefs (drop huge_ptep_get(), which seems
  unnecessary given that p?d_huge() can be assumed to imply p?d_present())
- use HAVE_ARCH_HUGE_VMAP Kconfig define as indicator whether huge mappings
  in the vmalloc range are to be expected, and VM_BUG_ON() otherwise

 mm/vmalloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e46ed7..451cd5cafedc 100644
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
@@ -289,9 +290,17 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	pud = pud_offset(p4d, addr);
 	if (pud_none(*pud))
 		return NULL;
+	if (pud_huge(*pud)) {
+		VM_BUG_ON(!IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP));
+		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	}
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return NULL;
+	if (pmd_huge(*pmd)) {
+		VM_BUG_ON(!IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP));
+		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	}
 
 	ptep = pte_offset_map(pmd, addr);
 	pte = *ptep;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
