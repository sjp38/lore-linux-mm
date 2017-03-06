Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 559096B038F
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:54:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w189so161922751pfb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:54:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 88si19119992pla.240.2017.03.06.05.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:54:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 13/33] x86/power: support p4d_t in hibernate code
Date: Mon,  6 Mar 2017 16:53:37 +0300
Message-Id: <20170306135357.3124-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

set_up_temporary_text_mapping() and relocate_restore_code() require
trivial adjustments to handle additional page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/power/hibernate_64.c | 49 ++++++++++++++++++++++++++++++-------------
 1 file changed, 35 insertions(+), 14 deletions(-)

diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index ded2e8272382..9ec941638932 100644
--- a/arch/x86/power/hibernate_64.c
+++ b/arch/x86/power/hibernate_64.c
@@ -49,6 +49,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 {
 	pmd_t *pmd;
 	pud_t *pud;
+	p4d_t *p4d;
 
 	/*
 	 * The new mapping only has to cover the page containing the image
@@ -63,6 +64,13 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 	 * the virtual address space after switching over to the original page
 	 * tables used by the image kernel.
 	 */
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d = (p4d_t *)get_safe_page(GFP_ATOMIC);
+		if (!p4d)
+			return -ENOMEM;
+	}
+
 	pud = (pud_t *)get_safe_page(GFP_ATOMIC);
 	if (!pud)
 		return -ENOMEM;
@@ -75,8 +83,15 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 		__pmd((jump_address_phys & PMD_MASK) | __PAGE_KERNEL_LARGE_EXEC));
 	set_pud(pud + pud_index(restore_jump_address),
 		__pud(__pa(pmd) | _KERNPG_TABLE));
-	set_pgd(pgd + pgd_index(restore_jump_address),
-		__pgd(__pa(pud) | _KERNPG_TABLE));
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		set_p4d(p4d + p4d_index(restore_jump_address),
+				__p4d(__pa(pud) | _KERNPG_TABLE));
+		set_pgd(pgd + pgd_index(restore_jump_address),
+				__pgd(__pa(p4d) | _KERNPG_TABLE));
+	} else {
+		set_pgd(pgd + pgd_index(restore_jump_address),
+				__pgd(__pa(pud) | _KERNPG_TABLE));
+	}
 
 	return 0;
 }
@@ -124,7 +139,10 @@ static int set_up_temporary_mappings(void)
 static int relocate_restore_code(void)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
 
 	relocated_restore_code = get_safe_page(GFP_ATOMIC);
 	if (!relocated_restore_code)
@@ -134,22 +152,25 @@ static int relocate_restore_code(void)
 
 	/* Make the page containing the relocated code executable */
 	pgd = (pgd_t *)__va(read_cr3()) + pgd_index(relocated_restore_code);
-	pud = pud_offset(pgd, relocated_restore_code);
+	p4d = p4d_offset(pgd, relocated_restore_code);
+	if (p4d_large(*p4d)) {
+		set_p4d(p4d, __p4d(p4d_val(*p4d) & ~_PAGE_NX));
+		goto out;
+	}
+	pud = pud_offset(p4d, relocated_restore_code);
 	if (pud_large(*pud)) {
 		set_pud(pud, __pud(pud_val(*pud) & ~_PAGE_NX));
-	} else {
-		pmd_t *pmd = pmd_offset(pud, relocated_restore_code);
-
-		if (pmd_large(*pmd)) {
-			set_pmd(pmd, __pmd(pmd_val(*pmd) & ~_PAGE_NX));
-		} else {
-			pte_t *pte = pte_offset_kernel(pmd, relocated_restore_code);
-
-			set_pte(pte, __pte(pte_val(*pte) & ~_PAGE_NX));
-		}
+		goto out;
+	}
+	pmd = pmd_offset(pud, relocated_restore_code);
+	if (pmd_large(*pmd)) {
+		set_pmd(pmd, __pmd(pmd_val(*pmd) & ~_PAGE_NX));
+		goto out;
 	}
+	pte = pte_offset_kernel(pmd, relocated_restore_code);
+	set_pte(pte, __pte(pte_val(*pte) & ~_PAGE_NX));
+out:
 	__flush_tlb_all();
-
 	return 0;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
