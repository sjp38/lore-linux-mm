Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A31B44405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:58:48 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q39so4512939wrb.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:48 -0800 (PST)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id w5si6501513wrb.70.2017.02.15.12.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 12:58:47 -0800 (PST)
Received: by mail-wr0-x243.google.com with SMTP id c4so7143193wrd.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:47 -0800 (PST)
From: Nicolai Stange <nicstange@gmail.com>
Subject: [RFC 2/3] sparse-vmemmap: make vmemmap_populate_basepages() skip HP mapped ranges
Date: Wed, 15 Feb 2017 21:58:25 +0100
Message-Id: <20170215205826.13356-3-nicstange@gmail.com>
In-Reply-To: <20170215205826.13356-1-nicstange@gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>

WARNING: this will break at least arm64 due to the lack of a pmd_large()!!!

While x86' vmemmap_populate_hugepages() checks whether the range to
populate has already been covered in part by conventional pages and falls
back to vmemmap_populate_basepages() if so, the converse is not true:
vmemmap_populate_basepages() will happily allocate conventional pages for
regions already covered by a hugepage and write the corresponding PTEs to
that hugepage, pretending that it's a PMD. At best, this results in those
conventional pages getting leaked.

Such a situation does exist: the initialization code in
arch/x86/mm/kasan_init_64.c calls into vmemmap_populate().
Since commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
populate_section_memmap()"), the latter invokes either
vmemmap_populate_basepages() or vmemmap_populate_hugepages(), depending on
the requested region's size. vmemmap_populate_basepages() invocations
on regions already covered by a hugepage have actually been obvserved in
this context.

Make vmemmap_populate_basepages() skip regions covered by hugepages
already.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 mm/sparse-vmemmap.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d45bd2714a2b..f08872b58e48 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -224,12 +224,13 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 					 unsigned long end, int node)
 {
 	unsigned long addr = start & ~(PAGE_SIZE - 1);
+	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	for (; addr < end; addr += PAGE_SIZE) {
+	for (; addr < end; addr = next) {
 		pgd = vmemmap_pgd_populate(addr, node);
 		if (!pgd)
 			return -ENOMEM;
@@ -239,10 +240,16 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 		pmd = vmemmap_pmd_populate(pud, addr, node);
 		if (!pmd)
 			return -ENOMEM;
-		pte = vmemmap_pte_populate(pmd, addr, node);
-		if (!pte)
-			return -ENOMEM;
-		vmemmap_verify(pte, node, addr, addr + PAGE_SIZE);
+		if (!pmd_large(*pmd)) {
+			pte = vmemmap_pte_populate(pmd, addr, node);
+			if (!pte)
+				return -ENOMEM;
+			next = addr + PAGE_SIZE;
+		} else {
+			pte = (pte_t *)pmd;
+			next = (addr & ~(PMD_SIZE - 1)) + PMD_SIZE;
+		}
+		vmemmap_verify(pte, node, addr, next);
 	}
 
 	return 0;
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
