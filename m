Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E87CF6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 12:47:36 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id r33so2341482qkh.2
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 09:47:36 -0800 (PST)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id t70si10160679qka.408.2018.03.07.09.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 09:47:35 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Date: Wed,  7 Mar 2018 11:32:26 -0700
Message-Id: <20180307183227.17983-2-toshi.kani@hpe.com>
In-Reply-To: <20180307183227.17983-1-toshi.kani@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com
Cc: guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

On architectures with CONFIG_HAVE_ARCH_HUGE_VMAP set, ioremap()
may create pud/pmd mappings.  Kernel panic was observed on arm64
systems with Cortex-A75 in the following steps as described by
Hanjun Guo.

1. ioremap a 4K size, valid page table will build,
2. iounmap it, pte0 will set to 0;
3. ioremap the same address with 2M size, pgd/pmd is unchanged,
   then set the a new value for pmd;
4. pte0 is leaked;
5. CPU may meet exception because the old pmd is still in TLB,
   which will lead to kernel panic.

This panic is not reproducible on x86.  INVLPG, called from iounmap,
purges all levels of entries associated with purged address on x86.
x86 still has memory leak.

Add two interfaces, pud_free_pmd_page() and pmd_free_pte_page(),
which clear a given pud/pmd entry and free up a page for the lower
level entries.

This patch implements their stub functions on x86 and arm64, which
work as workaround.

Reported-by: Lei Li <lious.lilei@hisilicon.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Wang Xuefeng <wxf.wang@hisilicon.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Hanjun Guo <guohanjun@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
---
 arch/arm64/mm/mmu.c           |   10 ++++++++++
 arch/x86/mm/pgtable.c         |   20 ++++++++++++++++++++
 include/asm-generic/pgtable.h |   10 ++++++++++
 lib/ioremap.c                 |    6 ++++--
 4 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 84a019f55022..84a37b4bc28e 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -972,3 +972,13 @@ int pmd_clear_huge(pmd_t *pmdp)
 	pmd_clear(pmdp);
 	return 1;
 }
+
+int pud_free_pmd_page(pud_t *pud)
+{
+	return pud_none(*pud);
+}
+
+int pmd_free_pte_page(pmd_t *pmd)
+{
+	return pmd_none(*pmd);
+}
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 004abf9ebf12..942f4fa341f1 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -702,4 +702,24 @@ int pmd_clear_huge(pmd_t *pmd)
 
 	return 0;
 }
+
+/**
+ * pud_free_pmd_page - clear pud entry and free pmd page
+ *
+ * Returns 1 on success and 0 on failure (pud not cleared).
+ */
+int pud_free_pmd_page(pud_t *pud)
+{
+	return pud_none(*pud);
+}
+
+/**
+ * pmd_free_pte_page - clear pmd entry and free pte page
+ *
+ * Returns 1 on success and 0 on failure (pmd not cleared).
+ */
+int pmd_free_pte_page(pmd_t *pmd)
+{
+	return pmd_none(*pmd);
+}
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 2cfa3075d148..2490800f7c5a 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -983,6 +983,8 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
 int pud_clear_huge(pud_t *pud);
 int pmd_clear_huge(pmd_t *pmd);
+int pud_free_pmd_page(pud_t *pud);
+int pmd_free_pte_page(pmd_t *pmd);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
 static inline int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot)
 {
@@ -1008,6 +1010,14 @@ static inline int pmd_clear_huge(pmd_t *pmd)
 {
 	return 0;
 }
+static inline int pud_free_pmd_page(pud_t *pud)
+{
+	return 0;
+}
+static inline int pmd_free_pte_page(pud_t *pmd)
+{
+	return 0;
+}
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
 
 #ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
diff --git a/lib/ioremap.c b/lib/ioremap.c
index b808a390e4c3..54e5bbaa3200 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -91,7 +91,8 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 
 		if (ioremap_pmd_enabled() &&
 		    ((next - addr) == PMD_SIZE) &&
-		    IS_ALIGNED(phys_addr + addr, PMD_SIZE)) {
+		    IS_ALIGNED(phys_addr + addr, PMD_SIZE) &&
+		    pmd_free_pte_page(pmd)) {
 			if (pmd_set_huge(pmd, phys_addr + addr, prot))
 				continue;
 		}
@@ -117,7 +118,8 @@ static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 
 		if (ioremap_pud_enabled() &&
 		    ((next - addr) == PUD_SIZE) &&
-		    IS_ALIGNED(phys_addr + addr, PUD_SIZE)) {
+		    IS_ALIGNED(phys_addr + addr, PUD_SIZE) &&
+		    pud_free_pmd_page(pud)) {
 			if (pud_set_huge(pud, phys_addr + addr, prot))
 				continue;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
