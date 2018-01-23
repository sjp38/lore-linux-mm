Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC72280245
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:19:35 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 78so677342otj.15
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:19:35 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k185si12583189ioe.281.2018.01.23.09.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 09:19:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] x86/mm/encrypt: Rewrite sme_pgtable_calc()
Date: Tue, 23 Jan 2018 20:19:10 +0300
Message-Id: <20180123171910.55841-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
References: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

sme_pgtable_calc() is unnecessary complex. It can be re-written in a
more stream-lined way.

As a side effect, we would get the code ready to boot-time switching
between paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mem_encrypt.c | 42 ++++++++++++------------------------------
 1 file changed, 12 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 740b8a54f616..88e9d4b1a233 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -556,8 +556,7 @@ static void __init sme_map_range_decrypted_wp(struct sme_populate_pgd_data *ppd)
 
 static unsigned long __init sme_pgtable_calc(unsigned long len)
 {
-	unsigned long p4d_size, pud_size, pmd_size, pte_size;
-	unsigned long total;
+	unsigned long entries = 0, tables = 0;
 
 	/*
 	 * Perform a relatively simplistic calculation of the pagetable
@@ -571,42 +570,25 @@ static unsigned long __init sme_pgtable_calc(unsigned long len)
 	 * Incrementing the count for each covers the case where the addresses
 	 * cross entries.
 	 */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
-		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
-		pud_size = (ALIGN(len, P4D_SIZE) / P4D_SIZE) + 1;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	} else {
-		p4d_size = 0;
-		pud_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	}
-	pmd_size = (ALIGN(len, PUD_SIZE) / PUD_SIZE) + 1;
-	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
-	pte_size = 2 * sizeof(pte_t) * PTRS_PER_PTE;
 
-	total = p4d_size + pud_size + pmd_size + pte_size;
+	/* PGDIR_SIZE is equal to P4D_SIZE on 4-level machine. */
+	if (PTRS_PER_P4D > 1)
+		entries += (DIV_ROUND_UP(len, PGDIR_SIZE) + 1) * sizeof(p4d_t) * PTRS_PER_P4D;
+	entries += (DIV_ROUND_UP(len, P4D_SIZE) + 1) * sizeof(pud_t) * PTRS_PER_PUD;
+	entries += (DIV_ROUND_UP(len, PUD_SIZE) + 1) * sizeof(pmd_t) * PTRS_PER_PMD;
+	entries += 2 * sizeof(pte_t) * PTRS_PER_PTE;
 
 	/*
 	 * Now calculate the added pagetable structures needed to populate
 	 * the new pagetables.
 	 */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
-		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
-		pud_size = ALIGN(total, P4D_SIZE) / P4D_SIZE;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	} else {
-		p4d_size = 0;
-		pud_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	}
-	pmd_size = ALIGN(total, PUD_SIZE) / PUD_SIZE;
-	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
 
-	total += p4d_size + pud_size + pmd_size;
+	if (PTRS_PER_P4D > 1)
+		tables += DIV_ROUND_UP(entries, PGDIR_SIZE) * sizeof(p4d_t) * PTRS_PER_P4D;
+	tables += DIV_ROUND_UP(entries, P4D_SIZE) * sizeof(pud_t) * PTRS_PER_PUD;
+	tables += DIV_ROUND_UP(entries, PUD_SIZE) * sizeof(pmd_t) * PTRS_PER_PMD;
 
-	return total;
+	return entries + tables;
 }
 
 void __init __nostackprotector sme_encrypt_kernel(struct boot_params *bp)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
