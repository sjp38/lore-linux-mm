Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D80AF6B025D
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:29:34 -0500 (EST)
Received: by wmvv187 with SMTP id v187so154095813wmv.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:34 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id hf9si66313111wjc.36.2015.11.30.04.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 04:29:33 -0800 (PST)
Received: by wmvv187 with SMTP id v187so154095236wmv.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:33 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v4 10/13] ARM: implement create_mapping_late() for EFI use
Date: Mon, 30 Nov 2015 13:28:24 +0100
Message-Id: <1448886507-3216-11-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This implements create_mapping_late(), which we will use to populate
the UEFI Runtime Services page tables.

Tested-by: Ryan Harkin <ryan.harkin@linaro.org>
Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/include/asm/mach/map.h |  2 ++
 arch/arm/mm/mmu.c               | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/arch/arm/include/asm/mach/map.h b/arch/arm/include/asm/mach/map.h
index f98c7f32c9c8..9b7c328fb207 100644
--- a/arch/arm/include/asm/mach/map.h
+++ b/arch/arm/include/asm/mach/map.h
@@ -42,6 +42,8 @@ enum {
 extern void iotable_init(struct map_desc *, int);
 extern void vm_reserve_area_early(unsigned long addr, unsigned long size,
 				  void *caller);
+extern void create_mapping_late(struct mm_struct *mm, struct map_desc *md,
+				bool ng);
 
 #ifdef CONFIG_DEBUG_LL
 extern void debug_ll_addr(unsigned long *paddr, unsigned long *vaddr);
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 2d9f628a7fe8..8c69830e791a 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -724,6 +724,14 @@ static void __init *early_alloc(unsigned long sz)
 	return early_alloc_aligned(sz, sz);
 }
 
+static void *__init late_alloc(unsigned long sz)
+{
+	void *ptr = (void *)__get_free_pages(PGALLOC_GFP, get_order(sz));
+
+	BUG_ON(!ptr);
+	return ptr;
+}
+
 static pte_t * __init pte_alloc(pmd_t *pmd, unsigned long addr,
 				unsigned long prot,
 				void *(*alloc)(unsigned long sz))
@@ -960,6 +968,18 @@ static void __init create_mapping(struct map_desc *md)
 	__create_mapping(&init_mm, md, early_alloc, false);
 }
 
+void __init create_mapping_late(struct mm_struct *mm, struct map_desc *md,
+				bool ng)
+{
+#ifdef CONFIG_ARM_LPAE
+	pud_t *pud = pud_alloc(mm, pgd_offset(mm, md->virtual), md->virtual);
+	if (WARN_ON(!pud))
+		return;
+	pmd_alloc(mm, pud, 0);
+#endif
+	__create_mapping(mm, md, late_alloc, ng);
+}
+
 /*
  * Create the architecture specific mappings
  */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
