Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74C336B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:54:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 64so10896331pgc.17
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:54:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 91-v6si1525749ply.410.2018.01.31.05.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 05:54:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 3/3] x86/mm/encrypt: Rewrite sme_pgtable_calc()
Date: Wed, 31 Jan 2018 16:54:04 +0300
Message-Id: <20180131135404.40692-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180131135404.40692-1-kirill.shutemov@linux.intel.com>
References: <20180131135404.40692-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

sme_pgtable_calc() is unnecessary complex. It can be re-written in a
more stream-lined way.

As a side effect, we would get the code ready to boot-time switching
between paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Tom Lendacky <thomas.lendacky@amd.com>
Tested-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/mem_encrypt_identity.c | 42 +++++++++++---------------------------
 1 file changed, 12 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
index 4b6a2e3098c5..b4139c5ab972 100644
--- a/arch/x86/mm/mem_encrypt_identity.c
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -231,8 +231,7 @@ static void __init sme_map_range_decrypted_wp(struct sme_populate_pgd_data *ppd)
 
 static unsigned long __init sme_pgtable_calc(unsigned long len)
 {
-	unsigned long p4d_size, pud_size, pmd_size, pte_size;
-	unsigned long total;
+	unsigned long entries = 0, tables = 0;
 
 	/*
 	 * Perform a relatively simplistic calculation of the pagetable
@@ -246,42 +245,25 @@ static unsigned long __init sme_pgtable_calc(unsigned long len)
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
