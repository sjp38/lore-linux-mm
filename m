Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473946B030A
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:29:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b16-v6so569897pfi.10
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:29:04 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id g7-v6si10736492pll.160.2018.10.26.05.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 05:29:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on 5-level paging
Date: Fri, 26 Oct 2018 15:28:54 +0300
Message-Id: <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 5-level paging LDT remap area is placed in the middle of
KASLR randomization region and it can overlap with direct mapping,
vmalloc or vmap area.

Let's move LDT just before direct mapping which makes it safe for KASLR.
This also allows us to unify layout between 4- and 5-level paging.

We don't touch 4 pgd slot gap just before the direct mapping reserved
for a hypervisor, but move direct mapping by one slot instead.

The LDT mapping is per-mm, so we cannot move it into P4D page table next
to CPU_ENTRY_AREA without complicating PGD table allocation for 5-level
paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: f55f0501cbf6 ("x86/pti: Put the LDT in its own PGD if PTI is on")
---
 Documentation/x86/x86_64/mm.txt         | 34 +++++++++++++------------
 arch/x86/include/asm/page_64_types.h    | 12 +++++----
 arch/x86/include/asm/pgtable_64_types.h |  4 +--
 arch/x86/xen/mmu_pv.c                   |  6 ++---
 4 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 702898633b00..75bff98928a8 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -34,23 +34,24 @@ __________________|____________|__________________|_________|___________________
 ____________________________________________________________|___________________________________________________________
                   |            |                  |         |
  ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole, also reserved for hypervisor
- ffff880000000000 | -120    TB | ffffc7ffffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
- ffffc80000000000 |  -56    TB | ffffc8ffffffffff |    1 TB | ... unused hole
+ ffff880000000000 | -120    TB | ffff887fffffffff |  0.5 TB | LDT remap for PTI
+ ffff888000000000 | -119.5  TB | ffffc87fffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
+ ffffc88000000000 |  -55.5  TB | ffffc8ffffffffff |  0.5 TB | ... unused hole
  ffffc90000000000 |  -55    TB | ffffe8ffffffffff |   32 TB | vmalloc/ioremap space (vmalloc_base)
  ffffe90000000000 |  -23    TB | ffffe9ffffffffff |    1 TB | ... unused hole
  ffffea0000000000 |  -22    TB | ffffeaffffffffff |    1 TB | virtual memory map (vmemmap_base)
  ffffeb0000000000 |  -21    TB | ffffebffffffffff |    1 TB | ... unused hole
  ffffec0000000000 |  -20    TB | fffffbffffffffff |   16 TB | KASAN shadow memory
- fffffc0000000000 |   -4    TB | fffffdffffffffff |    2 TB | ... unused hole
-                  |            |                  |         | vaddr_end for KASLR
- fffffe0000000000 |   -2    TB | fffffe7fffffffff |  0.5 TB | cpu_entry_area mapping
- fffffe8000000000 |   -1.5  TB | fffffeffffffffff |  0.5 TB | LDT remap for PTI
- ffffff0000000000 |   -1    TB | ffffff7fffffffff |  0.5 TB | %esp fixup stacks
 __________________|____________|__________________|_________|____________________________________________________________
                                                             |
-                                                            | Identical layout to the 47-bit one from here on:
+                                                            | Identical layout to the 56-bit one from here on:
 ____________________________________________________________|____________________________________________________________
                   |            |                  |         |
+ fffffc0000000000 |   -4    TB | fffffdffffffffff |    2 TB | ... unused hole
+                  |            |                  |         | vaddr_end for KASLR
+ fffffe0000000000 |   -2    TB | fffffe7fffffffff |  0.5 TB | cpu_entry_area mapping
+ fffffe8000000000 |   -1.5  TB | fffffeffffffffff |  0.5 TB | ... unused hole
+ ffffff0000000000 |   -1    TB | ffffff7fffffffff |  0.5 TB | %esp fixup stacks
  ffffff8000000000 | -512    GB | ffffffeeffffffff |  444 GB | ... unused hole
  ffffffef00000000 |  -68    GB | fffffffeffffffff |   64 GB | EFI region mapping space
  ffffffff00000000 |   -4    GB | ffffffff7fffffff |    2 GB | ... unused hole
@@ -83,7 +84,7 @@ Notes:
 __________________|____________|__________________|_________|___________________________________________________________
                   |            |                  |         |
  0000800000000000 |  +64    PB | ffff7fffffffffff | ~16K PB | ... huge, still almost 64 bits wide hole of non-canonical
-                  |            |                  |         |     virtual memory addresses up to the -128 TB
+                  |            |                  |         |     virtual memory addresses up to the -64 PB
                   |            |                  |         |     starting offset of kernel mappings.
 __________________|____________|__________________|_________|___________________________________________________________
                                                             |
@@ -91,23 +92,24 @@ __________________|____________|__________________|_________|___________________
 ____________________________________________________________|___________________________________________________________
                   |            |                  |         |
  ff00000000000000 |  -64    PB | ff0fffffffffffff |    4 PB | ... guard hole, also reserved for hypervisor
- ff10000000000000 |  -60    PB | ff8fffffffffffff |   32 PB | direct mapping of all physical memory (page_offset_base)
- ff90000000000000 |  -28    PB | ff9fffffffffffff |    4 PB | LDT remap for PTI
+ ff10000000000000 |  -60    PB | ff10ffffffffffff | 0.25 PB | LDT remap for PTI
+ ff11000000000000 |  -59.75 PB | ff90ffffffffffff |   32 PB | direct mapping of all physical memory (page_offset_base)
+ ff91000000000000 |  -27.75 PB | ff9fffffffffffff | 3.75 PB | ... unused hole
  ffa0000000000000 |  -24    PB | ffd1ffffffffffff | 12.5 PB | vmalloc/ioremap space (vmalloc_base)
  ffd2000000000000 |  -11.5  PB | ffd3ffffffffffff |  0.5 PB | ... unused hole
  ffd4000000000000 |  -11    PB | ffd5ffffffffffff |  0.5 PB | virtual memory map (vmemmap_base)
  ffd6000000000000 |  -10.5  PB | ffdeffffffffffff | 2.25 PB | ... unused hole
  ffdf000000000000 |   -8.25 PB | fffffdffffffffff |   ~8 PB | KASAN shadow memory
- fffffc0000000000 |   -4    TB | fffffdffffffffff |    2 TB | ... unused hole
-                  |            |                  |         | vaddr_end for KASLR
- fffffe0000000000 |   -2    TB | fffffe7fffffffff |  0.5 TB | cpu_entry_area mapping
- fffffe8000000000 |   -1.5  TB | fffffeffffffffff |  0.5 TB | ... unused hole
- ffffff0000000000 |   -1    TB | ffffff7fffffffff |  0.5 TB | %esp fixup stacks
 __________________|____________|__________________|_________|____________________________________________________________
                                                             |
                                                             | Identical layout to the 47-bit one from here on:
 ____________________________________________________________|____________________________________________________________
                   |            |                  |         |
+ fffffc0000000000 |   -4    TB | fffffdffffffffff |    2 TB | ... unused hole
+                  |            |                  |         | vaddr_end for KASLR
+ fffffe0000000000 |   -2    TB | fffffe7fffffffff |  0.5 TB | cpu_entry_area mapping
+ fffffe8000000000 |   -1.5  TB | fffffeffffffffff |  0.5 TB | ... unused hole
+ ffffff0000000000 |   -1    TB | ffffff7fffffffff |  0.5 TB | %esp fixup stacks
  ffffff8000000000 | -512    GB | ffffffeeffffffff |  444 GB | ... unused hole
  ffffffef00000000 |  -68    GB | fffffffeffffffff |   64 GB | EFI region mapping space
  ffffffff00000000 |   -4    GB | ffffffff7fffffff |    2 GB | ... unused hole
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index cd0cf1c568b4..8f657286d599 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -33,12 +33,14 @@
 
 /*
  * Set __PAGE_OFFSET to the most negative possible address +
- * PGDIR_SIZE*16 (pgd slot 272).  The gap is to allow a space for a
- * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
- * what Xen requires.
+ * PGDIR_SIZE*17 (pgd slot 273).
+ *
+ * The gap is to allow a space for LDT remap for PTI (1 pgd slot) and space for
+ * a hypervisor (16 slots). Choosing 16 slots for a hypervisor is arbitrary,
+ * but it's what Xen requires.
  */
-#define __PAGE_OFFSET_BASE_L5	_AC(0xff10000000000000, UL)
-#define __PAGE_OFFSET_BASE_L4	_AC(0xffff880000000000, UL)
+#define __PAGE_OFFSET_BASE_L5	_AC(0xff11000000000000, UL)
+#define __PAGE_OFFSET_BASE_L4	_AC(0xffff888000000000, UL)
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 #define __PAGE_OFFSET           page_offset_base
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 04edd2d58211..84bd9bdc1987 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -111,9 +111,7 @@ extern unsigned int ptrs_per_p4d;
  */
 #define MAXMEM			(1UL << MAX_PHYSMEM_BITS)
 
-#define LDT_PGD_ENTRY_L4	-3UL
-#define LDT_PGD_ENTRY_L5	-112UL
-#define LDT_PGD_ENTRY		(pgtable_l5_enabled() ? LDT_PGD_ENTRY_L5 : LDT_PGD_ENTRY_L4)
+#define LDT_PGD_ENTRY		-240UL
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #define LDT_END_ADDR		(LDT_BASE_ADDR + PGDIR_SIZE)
 
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 70ea598a37d2..7a2a74c2dd30 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -1905,7 +1905,7 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	init_top_pgt[0] = __pgd(0);
 
 	/* Pre-constructed entries are in pfn, so convert to mfn */
-	/* L4[272] -> level3_ident_pgt  */
+	/* L4[273] -> level3_ident_pgt  */
 	/* L4[511] -> level3_kernel_pgt */
 	convert_pfn_mfn(init_top_pgt);
 
@@ -1925,8 +1925,8 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	addr[0] = (unsigned long)pgd;
 	addr[1] = (unsigned long)l3;
 	addr[2] = (unsigned long)l2;
-	/* Graft it onto L4[272][0]. Note that we creating an aliasing problem:
-	 * Both L4[272][0] and L4[511][510] have entries that point to the same
+	/* Graft it onto L4[273][0]. Note that we creating an aliasing problem:
+	 * Both L4[273][0] and L4[511][510] have entries that point to the same
 	 * L2 (PMD) tables. Meaning that if you modify it in __va space
 	 * it will be also modified in the __ka space! (But if you just
 	 * modify the PMD table to point to other PTE's or none, then you
-- 
2.19.1
