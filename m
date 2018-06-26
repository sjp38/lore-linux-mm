Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11ECF6B0282
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:23:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n19-v6so8778648pff.8
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:23:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x3-v6si1202539pfj.289.2018.06.26.07.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 15/18] x86/mm: Calculate direct mapping size
Date: Tue, 26 Jun 2018 17:22:42 +0300
Message-Id: <20180626142245.82850-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The kernel needs to have a way to access encrypted memory. We have two
option on how approach it:

 - Create temporary mappings every time kernel needs access to encrypted
   memory. That's basically brings highmem and its overhead back.

 - Create multiple direct mappings, one per-KeyID. In this setup we
   don't need to create temporary mappings on the fly -- encrypted
   memory is permanently available in kernel address space.

We take the second approach as it has lower overhead.

It's worth noting that with per-KeyID direct mappings compromised kernel
would give access to decrypted data right away without additional tricks
to get memory mapped with the correct KeyID.

Per-KeyID mappings require a lot more virtual address space. On 4-level
machine with 64 KeyIDs we max out 46-bit virtual address space dedicated
for direct mapping with 1TiB of RAM. Given that we round up any
calculation on direct mapping size to 1TiB, we effectively claim all
46-bit address space for direct mapping on such machine regardless of
RAM size.

Increased usage of virtual address space has implications for KASLR:
we have less space for randomization. With 64 TiB claimed for direct
mapping with 4-level we left with 27 TiB of entropy to place
page_offset_base, vmalloc_base and vmemmap_base.

5-level paging provides much wider virtual address space and KASLR
doesn't suffer significantly from per-KeyID direct mappings.

It's preferred to run MKTME with 5-level paging.

A direct mapping for each KeyID will be put next to each other in the
virtual address space. We need to have a way to find boundaries of
direct mapping for particular KeyID.

The new variable direct_mapping_size specifies the size of direct
mapping. With the value, it's trivial to find direct mapping for
KeyID-N: PAGE_OFFSET + N * direct_mapping_size.

Size of direct mapping is calculated during KASLR setup. If KALSR is
disabled it happens during MKTME initialization.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/x86_64/mm.txt |  4 ++++
 arch/x86/include/asm/page_64.h  |  1 +
 arch/x86/include/asm/setup.h    |  6 +++++
 arch/x86/kernel/head64.c        |  2 ++
 arch/x86/kernel/setup.c         |  3 +++
 arch/x86/mm/init_64.c           | 40 +++++++++++++++++++++++++++++++++
 arch/x86/mm/kaslr.c             | 11 ++++++---
 7 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5432a96d31ff..c5b92904090f 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -61,6 +61,10 @@ The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
 holes).
 
+With MKTME, we have multiple direct mappings. One per-KeyID. They are put
+next to each other. PAGE_OFFSET + N * direct_mapping_size can be used to
+find direct mapping for KeyID-N.
+
 vmalloc space is lazily synchronized into the different PML4/PML5 pages of
 the processes using the page fault handler, with init_top_pgt as
 reference.
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index 939b1cff4a7b..53c32af895ab 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -14,6 +14,7 @@ extern unsigned long phys_base;
 extern unsigned long page_offset_base;
 extern unsigned long vmalloc_base;
 extern unsigned long vmemmap_base;
+extern unsigned long direct_mapping_size;
 
 static inline unsigned long __phys_addr_nodebug(unsigned long x)
 {
diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index ae13bc974416..bcac5080cca5 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -59,6 +59,12 @@ extern void x86_ce4100_early_setup(void);
 static inline void x86_ce4100_early_setup(void) { }
 #endif
 
+#ifdef CONFIG_MEMORY_PHYSICAL_PADDING
+void calculate_direct_mapping_size(void);
+#else
+static inline void calculate_direct_mapping_size(void) { }
+#endif
+
 #ifndef _SETUP
 
 #include <asm/espfix.h>
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 8047379e575a..854e8665aba0 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -59,6 +59,8 @@ EXPORT_SYMBOL(vmalloc_base);
 unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE_L4;
 EXPORT_SYMBOL(vmemmap_base);
 #endif
+unsigned long direct_mapping_size __ro_after_init = -1UL;
+EXPORT_SYMBOL(direct_mapping_size);
 
 #define __head	__section(.head.text)
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 2f86d883dd95..09ddbd142e3c 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1053,6 +1053,9 @@ void __init setup_arch(char **cmdline_p)
 	 */
 	init_cache_modes();
 
+	 /* direct_mapping_size has to be initialized before KASLR and MKTME */
+	calculate_direct_mapping_size();
+
 	/*
 	 * Define random base addresses for memory sections after max_pfn is
 	 * defined and before each memory section base is used.
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a688617c727e..6fc506f33e58 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1399,6 +1399,46 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
 }
 
+#ifdef CONFIG_MEMORY_PHYSICAL_PADDING
+void __init calculate_direct_mapping_size(void)
+{
+	unsigned long available_va;
+
+	/* 1/4 of virtual address space is didicated for direct mapping */
+	available_va = 1UL << (__VIRTUAL_MASK_SHIFT - 1);
+
+	/* How much memory the systrem has? */
+	direct_mapping_size = max_pfn << PAGE_SHIFT;
+	direct_mapping_size = round_up(direct_mapping_size, 1UL << 40);
+
+	if (!IS_ENABLED(CONFIG_X86_INTEL_MKTME) || !mktme_nr_keyids)
+		goto out;
+
+	/*
+	 * Not enough virtual address space to address all physical memory with
+	 * MKTME enabled. Even without padding.
+	 *
+	 * Disable MKTME instead.
+	 */
+	if (direct_mapping_size > available_va / (mktme_nr_keyids + 1)) {
+		pr_err("x86/mktme: Disabled. Not enough virtual address space\n");
+		pr_err("x86/mktme: Consider switching to 5-level paging\n");
+		mktme_disable();
+		goto out;
+	}
+
+	/*
+	 * Virtual address space is divided between per-KeyID direct mappings.
+	 */
+	available_va /= mktme_nr_keyids + 1;
+out:
+	/* Add padding, if there's enough virtual address space */
+	direct_mapping_size += (1UL << 40) * CONFIG_MEMORY_PHYSICAL_PADDING;
+	if (direct_mapping_size > available_va)
+		direct_mapping_size = available_va;
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 4408cd9a3bef..bf044ff50ec0 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -101,10 +101,15 @@ void __init kernel_randomize_memory(void)
 	 * add padding if needed (especially for memory hotplug support).
 	 */
 	BUG_ON(kaslr_regions[0].base != &page_offset_base);
-	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
-		CONFIG_MEMORY_PHYSICAL_PADDING;
 
-	/* Adapt phyiscal memory region size based on available memory */
+	/*
+	 * Calculate space required to map all physical memory.
+	 * In case of MKTME, we map physical memory multiple times, one for
+	 * each KeyID. If MKTME is disabled mktme_nr_keyids is 0.
+	 */
+	memory_tb = (direct_mapping_size * (mktme_nr_keyids + 1)) >> TB_SHIFT;
+
+	/* Adapt physical memory region size based on available memory */
 	if (memory_tb < kaslr_regions[0].size_tb)
 		kaslr_regions[0].size_tb = memory_tb;
 
-- 
2.18.0
