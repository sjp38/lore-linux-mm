Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71CF26B0008
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 12:32:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 14-v6so1181794pfk.22
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:32:10 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 65-v6si74381pgj.173.2018.10.23.09.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 09:32:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] x86/mm: Move LDT remap out of KASLR region on 5-level paging
Date: Tue, 23 Oct 2018 19:31:56 +0300
Message-Id: <20181023163157.41441-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
 Documentation/x86/x86_64/mm.txt         |  8 ++++----
 arch/x86/include/asm/page_64_types.h    | 12 +++++++-----
 arch/x86/include/asm/pgtable_64_types.h |  4 +---
 arch/x86/xen/mmu_pv.c                   |  6 +++---
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5432a96d31ff..463c48c26fb7 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -4,7 +4,8 @@ Virtual memory map with 4 level page tables:
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
 hole caused by [47:63] sign extension
 ffff800000000000 - ffff87ffffffffff (=43 bits) guard hole, reserved for hypervisor
-ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
+ffff888000000000 - ffff887fffffffff (=39 bits) LDT remap for PTI
+ffff888000000000 - ffffc87fffffffff (=64 TB) direct mapping of all phys. memory
 ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
 ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
 ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
@@ -14,7 +15,6 @@ ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
 ... unused hole ...
 				    vaddr_end for KASLR
 fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
-fffffe8000000000 - fffffeffffffffff (=39 bits) LDT remap for PTI
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
 ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
@@ -30,8 +30,8 @@ Virtual memory map with 5 level page tables:
 0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
 hole caused by [56:63] sign extension
 ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
-ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
-ff90000000000000 - ff9fffffffffffff (=52 bits) LDT remap for PTI
+ff10000000000000 - ff10ffffffffffff (=48 bits) LDT remap for PTI
+ff11000000000000 - ff90ffffffffffff (=55 bits) direct mapping of all phys. memory
 ffa0000000000000 - ffd1ffffffffffff (=54 bits) vmalloc/ioremap space (12800 TB)
 ffd2000000000000 - ffd3ffffffffffff (=49 bits) hole
 ffd4000000000000 - ffd5ffffffffffff (=49 bits) virtual memory map (512TB)
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 6afac386a434..b99d497e342d 100644
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
index dd461c0167ef..2c84c6ad8b50 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -1897,7 +1897,7 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	init_top_pgt[0] = __pgd(0);
 
 	/* Pre-constructed entries are in pfn, so convert to mfn */
-	/* L4[272] -> level3_ident_pgt  */
+	/* L4[273] -> level3_ident_pgt  */
 	/* L4[511] -> level3_kernel_pgt */
 	convert_pfn_mfn(init_top_pgt);
 
@@ -1917,8 +1917,8 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
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
