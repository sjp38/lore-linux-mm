Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1D146B000A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q6so9522217pgv.12
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j7-v6si15202768plk.506.2018.04.24.16.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:43:26 -0700 (PDT)
Subject: [PATCH v9 5/9] mm: fix __gup_device_huge vs unmap
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:29 -0700
Message-ID: <152461280975.17530.2817946409563456285.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: stable@vger.kernel.org, Jan Kara <jack@suse.cz>, david@fromorbit.com, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.orgjack@suse.czhch@lst.de

get_user_pages_fast() for device pages is missing the typical validation
that all page references have been taken while the mapping was valid.
Without this validation truncate operations can not reliably coordinate
against new page reference events like O_DIRECT.

Cc: <stable@vger.kernel.org>
Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Reported-by: Jan Kara <jack@suse.cz>
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
