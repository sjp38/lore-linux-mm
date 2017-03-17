Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0EEE6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:55:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t87so9321288pfk.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:55:26 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f22si4550379plk.264.2017.03.17.11.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:55:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/6] x86/kexec: Add 5-level paging support
Date: Fri, 17 Mar 2017 21:55:10 +0300
Message-Id: <20170317185515.8636-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Handle additional page table level in kexec code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/kexec.h       |  1 +
 arch/x86/kernel/machine_kexec_32.c |  4 +++-
 arch/x86/kernel/machine_kexec_64.c | 14 ++++++++++++--
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index 282630e4c6ea..70ef205489f0 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -164,6 +164,7 @@ struct kimage_arch {
 };
 #else
 struct kimage_arch {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
diff --git a/arch/x86/kernel/machine_kexec_32.c b/arch/x86/kernel/machine_kexec_32.c
index 469b23d6acc2..5f43cec296c5 100644
--- a/arch/x86/kernel/machine_kexec_32.c
+++ b/arch/x86/kernel/machine_kexec_32.c
@@ -103,6 +103,7 @@ static void machine_kexec_page_table_set_one(
 	pgd_t *pgd, pmd_t *pmd, pte_t *pte,
 	unsigned long vaddr, unsigned long paddr)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 
 	pgd += pgd_index(vaddr);
@@ -110,7 +111,8 @@ static void machine_kexec_page_table_set_one(
 	if (!(pgd_val(*pgd) & _PAGE_PRESENT))
 		set_pgd(pgd, __pgd(__pa(pmd) | _PAGE_PRESENT));
 #endif
-	pud = pud_offset(pgd, vaddr);
+	p4d = p4d_offset(pgd, vaddr);
+	pud = pud_offset(p4d, vaddr);
 	pmd = pmd_offset(pud, vaddr);
 	if (!(pmd_val(*pmd) & _PAGE_PRESENT))
 		set_pmd(pmd, __pmd(__pa(pte) | _PAGE_TABLE));
diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
index 857cdbd02867..085c3b300d32 100644
--- a/arch/x86/kernel/machine_kexec_64.c
+++ b/arch/x86/kernel/machine_kexec_64.c
@@ -36,6 +36,7 @@ static struct kexec_file_ops *kexec_file_loaders[] = {
 
 static void free_transition_pgtable(struct kimage *image)
 {
+	free_page((unsigned long)image->arch.p4d);
 	free_page((unsigned long)image->arch.pud);
 	free_page((unsigned long)image->arch.pmd);
 	free_page((unsigned long)image->arch.pte);
@@ -43,6 +44,7 @@ static void free_transition_pgtable(struct kimage *image)
 
 static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -53,13 +55,21 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
 	paddr = __pa(page_address(image->control_code_page)+PAGE_SIZE);
 	pgd += pgd_index(vaddr);
 	if (!pgd_present(*pgd)) {
+		p4d = (p4d_t *)get_zeroed_page(GFP_KERNEL);
+		if (!p4d)
+			goto err;
+		image->arch.p4d = p4d;
+		set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
+	}
+	p4d = p4d_offset(pgd, vaddr);
+	if (!p4d_present(*p4d)) {
 		pud = (pud_t *)get_zeroed_page(GFP_KERNEL);
 		if (!pud)
 			goto err;
 		image->arch.pud = pud;
-		set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE));
+		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
 	}
-	pud = pud_offset(pgd, vaddr);
+	pud = pud_offset(p4d, vaddr);
 	if (!pud_present(*pud)) {
 		pmd = (pmd_t *)get_zeroed_page(GFP_KERNEL);
 		if (!pmd)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
