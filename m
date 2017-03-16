Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C67F56B0390
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:27:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t143so96290677pgb.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:27:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o12si5629522plg.220.2017.03.16.08.27.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:27:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/7] mm/gup: Implement dev_pagemap logic in generic get_user_pages_fast()
Date: Thu, 16 Mar 2017 18:26:53 +0300
Message-Id: <20170316152655.37789-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

This is preparation patch for transition of x86 to generic GUP_fast()
implementation.

Prepare generic GUP_fast() to handle dev_mapmap. At the moment, it's
only implemented on x86. On non-x86, the new code will be compiled out.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h |  4 +++
 mm/gup.c           | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f01c88f0800..e197d3ca3e8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -430,6 +430,10 @@ static inline int pud_devmap(pud_t pud)
 {
 	return 0;
 }
+static inline int pgd_devmap(pgd_t pgd)
+{
+	return 0;
+}
 #endif
 
 /*
diff --git a/mm/gup.c b/mm/gup.c
index f0cfe225c08f..e04f76594eb9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1200,12 +1200,23 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif
 
+static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+{
+	while ((*nr) - nr_start) {
+		struct page *page = pages[--(*nr)];
+
+		ClearPageReferenced(page);
+		put_page(page);
+	}
+}
+
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
 {
+	struct dev_pagemap *pgmap = NULL;
+	int nr_start = *nr, ret = 0;
 	pte_t *ptep, *ptem;
-	int ret = 0;
 
 	ptem = ptep = pte_offset_map(&pmd, addr);
 	do {
@@ -1222,7 +1233,13 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (!pte_access_permitted(pte, write))
 			goto pte_unmap;
 
-		if (pte_special(pte))
+		if (pte_devmap(pte)) {
+			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
+			if (unlikely(!pgmap)) {
+				undo_dev_pagemap(nr, nr_start, pages);
+				goto pte_unmap;
+			}
+		} else if (pte_special(pte))
 			goto pte_unmap;
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
@@ -1239,6 +1256,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
+		put_dev_pagemap(pgmap);
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -1269,6 +1287,48 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* __HAVE_ARCH_PTE_SPECIAL */
 
+static int __gup_device_huge(unsigned long pfn, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	int nr_start = *nr;
+	struct dev_pagemap *pgmap = NULL;
+
+	do {
+		struct page *page = pfn_to_page(pfn);
+
+		pgmap = get_dev_pagemap(pfn, pgmap);
+		if (unlikely(!pgmap)) {
+			undo_dev_pagemap(nr, nr_start, pages);
+			return 0;
+		}
+		SetPageReferenced(page);
+		pages[*nr] = page;
+		get_page(page);
+		put_dev_pagemap(pgmap);
+		(*nr)++;
+		pfn++;
+	} while (addr += PAGE_SIZE, addr != end);
+	return 1;
+}
+
+static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	unsigned long fault_pfn;
+
+	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+}
+
+static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	unsigned long fault_pfn;
+
+	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+}
+
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
@@ -1278,6 +1338,10 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, write))
 		return 0;
 
+	VM_BUG_ON(!pfn_valid(pmd_pfn(orig)));
+	if (pmd_devmap(orig))
+		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
+
 	refs = 0;
 	head = pmd_page(orig);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -1314,6 +1378,10 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (!pud_access_permitted(orig, write))
 		return 0;
 
+	VM_BUG_ON(!pfn_valid(pud_pfn(orig)));
+	if (pud_devmap(orig))
+		return __gup_device_huge_pud(orig, addr, end, pages, nr);
+
 	refs = 0;
 	head = pud_page(orig);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
@@ -1351,6 +1419,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 	if (!pgd_access_permitted(orig, write))
 		return 0;
 
+	BUILD_BUG_ON(pgd_devmap(orig));
 	refs = 0;
 	head = pgd_page(orig);
 	page = head + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
