Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 30D4F6B025A
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:29:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so153051242wme.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:26 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id is6si66236829wjb.238.2015.11.30.04.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 04:29:26 -0800 (PST)
Received: by wmec201 with SMTP id c201so135834231wme.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:26 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v4 07/13] ARM: split off core mapping logic from create_mapping
Date: Mon, 30 Nov 2015 13:28:21 +0100
Message-Id: <1448886507-3216-8-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

In order to be able to reuse the core mapping logic of create_mapping
for mapping the UEFI Runtime Services into a private set of page tables,
split it off from create_mapping() into a separate function
__create_mapping which we will wire up in a subsequent patch.

Tested-by: Ryan Harkin <ryan.harkin@linaro.org>
Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/mm/mmu.c | 56 +++++++++++---------
 1 file changed, 31 insertions(+), 25 deletions(-)

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index de19f90221e2..3100de92148b 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -818,7 +818,8 @@ static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
 }
 
 #ifndef CONFIG_ARM_LPAE
-static void __init create_36bit_mapping(struct map_desc *md,
+static void __init create_36bit_mapping(struct mm_struct *mm,
+					struct map_desc *md,
 					const struct mem_type *type)
 {
 	unsigned long addr, length, end;
@@ -859,7 +860,7 @@ static void __init create_36bit_mapping(struct map_desc *md,
 	 */
 	phys |= (((md->pfn >> (32 - PAGE_SHIFT)) & 0xF) << 20);
 
-	pgd = pgd_offset_k(addr);
+	pgd = pgd_offset(mm, addr);
 	end = addr + length;
 	do {
 		pud_t *pud = pud_offset(pgd, addr);
@@ -876,33 +877,13 @@ static void __init create_36bit_mapping(struct map_desc *md,
 }
 #endif	/* !CONFIG_ARM_LPAE */
 
-/*
- * Create the page directory entries and any necessary
- * page tables for the mapping specified by `md'.  We
- * are able to cope here with varying sizes and address
- * offsets, and we take full advantage of sections and
- * supersections.
- */
-static void __init create_mapping(struct map_desc *md)
+static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md)
 {
 	unsigned long addr, length, end;
 	phys_addr_t phys;
 	const struct mem_type *type;
 	pgd_t *pgd;
 
-	if (md->virtual != vectors_base() && md->virtual < TASK_SIZE) {
-		pr_warn("BUG: not creating mapping for 0x%08llx at 0x%08lx in user region\n",
-			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
-		return;
-	}
-
-	if ((md->type == MT_DEVICE || md->type == MT_ROM) &&
-	    md->virtual >= PAGE_OFFSET && md->virtual < FIXADDR_START &&
-	    (md->virtual < VMALLOC_START || md->virtual >= VMALLOC_END)) {
-		pr_warn("BUG: mapping for 0x%08llx at 0x%08lx out of vmalloc space\n",
-			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
-	}
-
 	type = &mem_types[md->type];
 
 #ifndef CONFIG_ARM_LPAE
@@ -910,7 +891,7 @@ static void __init create_mapping(struct map_desc *md)
 	 * Catch 36-bit addresses
 	 */
 	if (md->pfn >= 0x100000) {
-		create_36bit_mapping(md, type);
+		create_36bit_mapping(mm, md, type);
 		return;
 	}
 #endif
@@ -925,7 +906,7 @@ static void __init create_mapping(struct map_desc *md)
 		return;
 	}
 
-	pgd = pgd_offset_k(addr);
+	pgd = pgd_offset(mm, addr);
 	end = addr + length;
 	do {
 		unsigned long next = pgd_addr_end(addr, end);
@@ -938,6 +919,31 @@ static void __init create_mapping(struct map_desc *md)
 }
 
 /*
+ * Create the page directory entries and any necessary
+ * page tables for the mapping specified by `md'.  We
+ * are able to cope here with varying sizes and address
+ * offsets, and we take full advantage of sections and
+ * supersections.
+ */
+static void __init create_mapping(struct map_desc *md)
+{
+	if (md->virtual != vectors_base() && md->virtual < TASK_SIZE) {
+		pr_warn("BUG: not creating mapping for 0x%08llx at 0x%08lx in user region\n",
+			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
+		return;
+	}
+
+	if ((md->type == MT_DEVICE || md->type == MT_ROM) &&
+	    md->virtual >= PAGE_OFFSET && md->virtual < FIXADDR_START &&
+	    (md->virtual < VMALLOC_START || md->virtual >= VMALLOC_END)) {
+		pr_warn("BUG: mapping for 0x%08llx at 0x%08lx out of vmalloc space\n",
+			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
+	}
+
+	__create_mapping(&init_mm, md);
+}
+
+/*
  * Create the architecture specific mappings
  */
 void __init iotable_init(struct map_desc *io_desc, int nr)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
