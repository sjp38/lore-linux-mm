Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7AE6B042B
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:51:03 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 77so276016451pgc.5
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:51:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w11si10529589pfd.17.2017.03.12.22.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:51:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/26] x86/power: support p4d_t in hibernate code
Date: Mon, 13 Mar 2017 08:50:00 +0300
Message-Id: <20170313055020.69655-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
