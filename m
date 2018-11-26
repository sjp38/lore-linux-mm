Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C76A06B41D3
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 06:05:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h86-v6so11133857pfd.2
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:05:23 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e9si50886969plt.330.2018.11.26.03.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 03:05:22 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.19 092/118] x86/mm: Move LDT remap out of KASLR region on 5-level paging
Date: Mon, 26 Nov 2018 11:51:26 +0100
Message-Id: <20181126105105.393471598@linuxfoundation.org>
In-Reply-To: <20181126105059.832485122@linuxfoundation.org>
References: <20181126105059.832485122@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, linux-mm@kvack.org, Sasha Levin <sashal@kernel.org>

4.19-stable review patch.  If anyone has any objections, please let me know.

------------------

commit d52888aa2753e3063a9d3a0c9f72f94aa9809c15 upstream

On 5-level paging the LDT remap area is placed in the middle of the KASLR
randomization region and it can overlap with the direct mapping, the
vmalloc or the vmap area.

The LDT mapping is per mm, so it cannot be moved into the P4D page table
next to the CPU_ENTRY_AREA without complicating PGD table allocation for
5-level paging.

The 4 PGD slot gap just before the direct mapping is reserved for
hypervisors, so it cannot be used.

Move the direct mapping one slot deeper and use the resulting gap for the
LDT remap area. The resulting layout is the same for 4 and 5 level paging.

[ tglx: Massaged changelog ]

Fixes: f55f0501cbf6 ("x86/pti: Put the LDT in its own PGD if PTI is on")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Andy Lutomirski <luto@kernel.org>
Cc: bp@alien8.de
Cc: hpa@zytor.com
Cc: dave.hansen@linux.intel.com
Cc: peterz@infradead.org
Cc: boris.ostrovsky@oracle.com
Cc: jgross@suse.com
Cc: bhe@redhat.com
Cc: willy@infradead.org
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181026122856.66224-2-kirill.shutemov@linux.intel.com
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 Documentation/x86/x86_64/mm.txt         | 10 ++++++----
 arch/x86/include/asm/page_64_types.h    | 12 +++++++-----
 arch/x86/include/asm/pgtable_64_types.h |  4 +---
 arch/x86/xen/mmu_pv.c                   |  6 +++---
 4 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5432a96d31ff..05ef53d83a41 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -4,8 +4,9 @@ Virtual memory map with 4 level page tables:
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
 hole caused by [47:63] sign extension
 ffff800000000000 - ffff87ffffffffff (=43 bits) guard hole, reserved for hypervisor
-ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
-ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
+ffff880000000000 - ffff887fffffffff (=39 bits) LDT remap for PTI
+ffff888000000000 - ffffc87fffffffff (=64 TB) direct mapping of all phys. memory
+ffffc88000000000 - ffffc8ffffffffff (=39 bits) hole
 ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
 ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
 ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
@@ -30,8 +31,9 @@ Virtual memory map with 5 level page tables:
 0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
 hole caused by [56:63] sign extension
 ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
-ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
-ff90000000000000 - ff9fffffffffffff (=52 bits) LDT remap for PTI
+ff10000000000000 - ff10ffffffffffff (=48 bits) LDT remap for PTI
+ff11000000000000 - ff90ffffffffffff (=55 bits) direct mapping of all phys. memory
+ff91000000000000 - ff9fffffffffffff (=3840 TB) hole
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
2.17.1
