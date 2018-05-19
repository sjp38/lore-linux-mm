Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 494FE6B06AD
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:45:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3-v6so5742934pfh.0
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:45:07 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n11-v6si8167846plp.221.2018.05.18.18.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:45:05 -0700 (PDT)
Subject: [PATCH v11 3/7] mm: fix __gup_device_huge vs unmap
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 18:35:08 -0700
Message-ID: <152669370864.34337.13815113039455146564.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: stable@vger.kernel.org, Jan Kara <jack@suse.cz>Jan Kara <jack@suse.cz>, david@fromorbit.com, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

get_user_pages_fast() for device pages is missing the typical validation
that all page references have been taken while the mapping was valid.
Without this validation truncate operations can not reliably coordinate
against new page reference events like O_DIRECT.

Cc: <stable@vger.kernel.org>
Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Reported-by: Jan Kara <jack@suse.cz>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/gup.c |   36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 76af4cfeaf68..84dd2063ca3d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1456,32 +1456,48 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 	return 1;
 }
 
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
 	unsigned long fault_pfn;
+	int nr_start = *nr;
+
+	fault_pfn = pmd_pfn(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
+		return 0;
 
-	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
+		undo_dev_pagemap(nr, nr_start, pages);
+		return 0;
+	}
+	return 1;
 }
 
-static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
+static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
 	unsigned long fault_pfn;
+	int nr_start = *nr;
+
+	fault_pfn = pud_pfn(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
+		return 0;
 
-	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
+		undo_dev_pagemap(nr, nr_start, pages);
+		return 0;
+	}
+	return 1;
 }
 #else
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
 	BUILD_BUG();
 	return 0;
 }
 
-static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
+static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
 	BUILD_BUG();
@@ -1499,7 +1515,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 
 	if (pmd_devmap(orig))
-		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
+		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -1537,7 +1553,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 
 	if (pud_devmap(orig))
-		return __gup_device_huge_pud(orig, addr, end, pages, nr);
+		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
 
 	refs = 0;
 	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
