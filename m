Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 993856B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:27:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e5so97036526pgk.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:27:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t6si5641811pgo.14.2017.03.16.08.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:27:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/7] mm/gup: Move permission checks into helpers
Date: Thu, 16 Mar 2017 18:26:50 +0300
Message-Id: <20170316152655.37789-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation patch for transition of x86 to generic GUP_fast()
implementation.

On x86, we would need to do additional permission checks to determinate if
access is allowed.

Let's abstract it out into separate helpers.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/asm-generic/pgtable.h | 25 +++++++++++++++++++++++++
 mm/gup.c                      | 15 ++++++++++-----
 2 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 1fad160f35de..7dfa767dc680 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -341,6 +341,31 @@ static inline int pte_unused(pte_t pte)
 }
 #endif
 
+#ifndef pte_access_permitted
+#define pte_access_permitted(pte, write) \
+	(pte_present(pte) && (!(write) || pte_write(pte)))
+#endif
+
+#ifndef pmd_access_permitted
+#define pmd_access_permitted(pmd, write) \
+	(pmd_present(pmd) && (!(write) || pmd_write(pmd)))
+#endif
+
+#ifndef pud_access_permitted
+#define pud_access_permitted(pud, write) \
+	(pud_present(pud) && (!(write) || pud_write(pud)))
+#endif
+
+#ifndef p4d_access_permitted
+#define p4d_access_permitted(p4d, write) \
+	(p4d_present(p4d) && (!(write) || p4d_write(p4d)))
+#endif
+
+#ifndef pgd_access_permitted
+#define pgd_access_permitted(pgd, write) \
+	(pgd_present(pgd) && (!(write) || pgd_write(pgd)))
+#endif
+
 #ifndef __HAVE_ARCH_PMD_SAME
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
diff --git a/mm/gup.c b/mm/gup.c
index 3f2338ba3402..a62a778ce4ec 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1212,8 +1212,13 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 * Similar to the PMD case below, NUMA hinting must take slow
 		 * path using the pte_protnone check.
 		 */
-		if (!pte_present(pte) || pte_special(pte) ||
-			pte_protnone(pte) || (write && !pte_write(pte)))
+		if (pte_protnone(pte))
+			goto pte_unmap;
+
+		if (!pte_access_permitted(pte, write))
+			goto pte_unmap;
+
+		if (pte_special(pte))
 			goto pte_unmap;
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
@@ -1264,7 +1269,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	struct page *head, *page;
 	int refs;
 
-	if (write && !pmd_write(orig))
+	if (!pmd_access_permitted(orig, write))
 		return 0;
 
 	refs = 0;
@@ -1299,7 +1304,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	struct page *head, *page;
 	int refs;
 
-	if (write && !pud_write(orig))
+	if (!pud_access_permitted(orig, write))
 		return 0;
 
 	refs = 0;
@@ -1335,7 +1340,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 	int refs;
 	struct page *head, *page;
 
-	if (write && !pgd_write(orig))
+	if (!pgd_access_permitted(orig, write))
 		return 0;
 
 	refs = 0;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
