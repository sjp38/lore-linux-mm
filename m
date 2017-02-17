Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18372681045
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:13:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 189so62750073pfu.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:13:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q11si5933430pgf.297.2017.02.17.06.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:13:57 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/33] x86/gup: add 5-level paging support
Date: Fri, 17 Feb 2017 17:13:05 +0300
Message-Id: <20170217141328.164563-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's simply extension for one more page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/gup.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 0d4fb3ebbbac..27b92430a8cd 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -76,9 +76,9 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 }
 
 /*
- * 'pteval' can come from a pte, pmd or pud.  We only check
+ * 'pteval' can come from a pte, pmd, pud or p4d.  We only check
  * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which are the
- * same value on all 3 types.
+ * same value on all 4 types.
  */
 static inline int pte_allows_gup(unsigned long pteval, int write)
 {
@@ -270,13 +270,13 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 	return 1;
 }
 
-static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
+static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 			int write, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
 
-	pudp = pud_offset(&pgd, addr);
+	pudp = pud_offset(&p4d, addr);
 	do {
 		pud_t pud = *pudp;
 
@@ -295,6 +295,27 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 	return 1;
 }
 
+static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
+			int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	p4d_t *p4dp;
+
+	p4dp = p4d_offset(&pgd, addr);
+	do {
+		p4d_t p4d = *p4dp;
+
+		next = p4d_addr_end(addr, end);
+		if (p4d_none(p4d))
+			return 0;
+		BUILD_BUG_ON(p4d_large(p4d));
+		if (!gup_pud_range(p4d, addr, next, write, pages, nr))
+			return 0;
+	} while (p4dp++, addr = next, addr != end);
+
+	return 1;
+}
+
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
@@ -343,7 +364,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			break;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
 			break;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_restore(flags);
@@ -415,7 +436,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			goto slow;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
 			goto slow;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
