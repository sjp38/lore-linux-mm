Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C30A56B7B55
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:21:18 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r82so599865oie.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:21:18 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x13si484031otj.215.2018.12.06.10.21.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 10:21:17 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [RESEND PATCH v4 5/5] lib/ioremap: Ensure break-before-make is used for huge p4d mappings
Date: Thu,  6 Dec 2018 18:21:35 +0000
Message-Id: <1544120495-17438-6-git-send-email-will.deacon@arm.com>
In-Reply-To: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
References: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Whilst no architectures actually enable support for huge p4d mappings
in the vmap area, the code that is implemented should be using
break-before-make, as we do for pud and pmd huge entries.

Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/mm/mmu.c           |  5 +++++
 arch/x86/mm/pgtable.c         |  8 ++++++++
 include/asm-generic/pgtable.h |  5 +++++
 lib/ioremap.c                 | 27 +++++++++++++++++++++------
 4 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 786cfa6355be..cf9a26d3d7f5 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1028,3 +1028,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
 	pmd_free(NULL, table);
 	return 1;
 }
+
+int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
+{
+	return 0;	/* Don't attempt a block mapping */
+}
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index e95a7d6ac8f8..b0284eab14dc 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -794,6 +794,14 @@ int pmd_clear_huge(pmd_t *pmd)
 	return 0;
 }
 
+/*
+ * Until we support 512GB pages, skip them in the vmap area.
+ */
+int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
+{
+	return 0;
+}
+
 #ifdef CONFIG_X86_64
 /**
  * pud_free_pmd_page - Clear pud entry and free pmd page.
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 359fb935ded6..e0381a4ce7d4 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1019,6 +1019,7 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
 int pud_clear_huge(pud_t *pud);
 int pmd_clear_huge(pmd_t *pmd);
+int p4d_free_pud_page(p4d_t *p4d, unsigned long addr);
 int pud_free_pmd_page(pud_t *pud, unsigned long addr);
 int pmd_free_pte_page(pmd_t *pmd, unsigned long addr);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
@@ -1046,6 +1047,10 @@ static inline int pmd_clear_huge(pmd_t *pmd)
 {
 	return 0;
 }
+static inline int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
+{
+	return 0;
+}
 static inline int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
 	return 0;
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 10d7c5485c39..063213685563 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -156,6 +156,25 @@ static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 	return 0;
 }
 
+static int ioremap_try_huge_p4d(p4d_t *p4d, unsigned long addr,
+				unsigned long end, phys_addr_t phys_addr,
+				pgprot_t prot)
+{
+	if (!ioremap_p4d_enabled())
+		return 0;
+
+	if ((end - addr) != P4D_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, P4D_SIZE))
+		return 0;
+
+	if (p4d_present(*p4d) && !p4d_free_pud_page(p4d, addr))
+		return 0;
+
+	return p4d_set_huge(p4d, phys_addr, prot);
+}
+
 static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
@@ -168,12 +187,8 @@ static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
 	do {
 		next = p4d_addr_end(addr, end);
 
-		if (ioremap_p4d_enabled() &&
-		    ((next - addr) == P4D_SIZE) &&
-		    IS_ALIGNED(phys_addr, P4D_SIZE)) {
-			if (p4d_set_huge(p4d, phys_addr, prot))
-				continue;
-		}
+		if (ioremap_try_huge_p4d(p4d, addr, next, phys_addr, prot))
+			continue;
 
 		if (ioremap_pud_range(p4d, addr, next, phys_addr, prot))
 			return -ENOMEM;
-- 
2.1.4
