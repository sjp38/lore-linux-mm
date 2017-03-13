Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90CE16B0402
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so283719881pgh.2
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:32 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l3si10474533pgl.298.2017.03.12.22.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/26] x86/efi: handle p4d in EFI pagetables
Date: Mon, 13 Mar 2017 08:50:02 +0300
Message-Id: <20170313055020.69655-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Allocate additional page table level and change efi_sync_low_kernel_mappings()
to make syncing logic work with additional page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/x86/platform/efi/efi_64.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 8544dae3d1b4..34d019f75239 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -135,6 +135,7 @@ static pgd_t *efi_pgd;
 int __init efi_alloc_page_tables(void)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	gfp_t gfp_mask;
 
@@ -147,15 +148,20 @@ int __init efi_alloc_page_tables(void)
 		return -ENOMEM;
 
 	pgd = efi_pgd + pgd_index(EFI_VA_END);
+	p4d = p4d_alloc(&init_mm, pgd, EFI_VA_END);
+	if (!p4d) {
+		free_page((unsigned long)efi_pgd);
+		return -ENOMEM;
+	}
 
-	pud = pud_alloc_one(NULL, 0);
+	pud = pud_alloc(&init_mm, p4d, EFI_VA_END);
 	if (!pud) {
+		if (CONFIG_PGTABLE_LEVELS > 4)
+			free_page((unsigned long) pgd_page_vaddr(*pgd));
 		free_page((unsigned long)efi_pgd);
 		return -ENOMEM;
 	}
 
-	pgd_populate(NULL, pgd, pud);
-
 	return 0;
 }
 
@@ -190,6 +196,18 @@ void efi_sync_low_kernel_mappings(void)
 	num_entries = pgd_index(EFI_VA_END) - pgd_index(PAGE_OFFSET);
 	memcpy(pgd_efi, pgd_k, sizeof(pgd_t) * num_entries);
 
+	/* The same story as with PGD entries */
+	BUILD_BUG_ON(p4d_index(EFI_VA_END) != p4d_index(MODULES_END));
+	BUILD_BUG_ON((EFI_VA_START & P4D_MASK) != (EFI_VA_END & P4D_MASK));
+
+	pgd_efi = efi_pgd + pgd_index(EFI_VA_END);
+	pgd_k = pgd_offset_k(EFI_VA_END);
+	p4d_efi = p4d_offset(pgd_efi, 0);
+	p4d_k = p4d_offset(pgd_k, 0);
+
+	num_entries = p4d_index(EFI_VA_END);
+	memcpy(p4d_efi, p4d_k, sizeof(p4d_t) * num_entries);
+
 	/*
 	 * We share all the PUD entries apart from those that map the
 	 * EFI regions. Copy around them.
@@ -197,20 +215,15 @@ void efi_sync_low_kernel_mappings(void)
 	BUILD_BUG_ON((EFI_VA_START & ~PUD_MASK) != 0);
 	BUILD_BUG_ON((EFI_VA_END & ~PUD_MASK) != 0);
 
-	pgd_efi = efi_pgd + pgd_index(EFI_VA_END);
-	p4d_efi = p4d_offset(pgd_efi, 0);
+	p4d_efi = p4d_offset(pgd_efi, EFI_VA_END);
+	p4d_k = p4d_offset(pgd_k, EFI_VA_END);
 	pud_efi = pud_offset(p4d_efi, 0);
-
-	pgd_k = pgd_offset_k(EFI_VA_END);
-	p4d_k = p4d_offset(pgd_k, 0);
 	pud_k = pud_offset(p4d_k, 0);
 
 	num_entries = pud_index(EFI_VA_END);
 	memcpy(pud_efi, pud_k, sizeof(pud_t) * num_entries);
 
-	p4d_efi = p4d_offset(pgd_efi, EFI_VA_START);
 	pud_efi = pud_offset(p4d_efi, EFI_VA_START);
-	p4d_k = p4d_offset(pgd_k, EFI_VA_START);
 	pud_k = pud_offset(p4d_k, EFI_VA_START);
 
 	num_entries = PTRS_PER_PUD - pud_index(EFI_VA_START);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
