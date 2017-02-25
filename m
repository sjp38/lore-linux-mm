Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD4096B0389
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 12:13:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so95953422pgi.4
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 09:13:50 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o18si10593804pli.214.2017.02.25.09.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 09:13:50 -0800 (PST)
Subject: [PATCH 2/2] x86, mm: unify exit paths in gup_pte_range()
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 25 Feb 2017 09:08:38 -0800
Message-ID: <148804251828.36605.14910389618497006945.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>

All exit paths from gup_pte_range() require pte_unmap() of the original
pte page before returning. Refactor the code to have a single exit point
to do the unmap.

This mirrors the flow of the generic gup_pte_range() in mm/gup.c.

Cc: <x86@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/gup.c |   39 ++++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 1680768d392c..e703f09c1d78 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -106,36 +106,35 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	struct dev_pagemap *pgmap = NULL;
-	int nr_start = *nr;
-	pte_t *ptep;
+	int nr_start = *nr, ret = 0;
+	pte_t *ptep, *ptem;
 
-	ptep = pte_offset_map(&pmd, addr);
+	/*
+	 * Keep the original mapped PTE value (ptem) around since we
+	 * might increment ptep off the end of the page when finishing
+	 * our loop iteration.
+	 */
+	ptem = ptep = pte_offset_map(&pmd, addr);
 	do {
 		pte_t pte = gup_get_pte(ptep);
 		struct page *page;
 
 		/* Similar to the PMD case, NUMA hinting must take slow path */
-		if (pte_protnone(pte)) {
-			pte_unmap(ptep);
-			return 0;
-		}
+		if (pte_protnone(pte))
+			break;
 
-		if (!pte_allows_gup(pte_val(pte), write)) {
-			pte_unmap(ptep);
-			return 0;
-		}
+		if (!pte_allows_gup(pte_val(pte), write))
+			break;
 
 		if (pte_devmap(pte)) {
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
-				pte_unmap(ptep);
-				return 0;
+				break;
 			}
-		} else if (pte_special(pte)) {
-			pte_unmap(ptep);
-			return 0;
-		}
+		} else if (pte_special(pte))
+			break;
+
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 		get_page(page);
@@ -145,9 +144,11 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		(*nr)++;
 
 	} while (ptep++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(ptep - 1);
+	if (addr == end)
+		ret = 1;
+	pte_unmap(ptem);
 
-	return 1;
+	return ret;
 }
 
 static inline void get_head_page_multiple(struct page *page, int nr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
