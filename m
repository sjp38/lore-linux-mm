Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 977AA6B0260
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:08:09 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 127so5204063ity.21
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:08:09 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0091.outbound.protection.outlook.com. [104.47.1.91])
        by mx.google.com with ESMTPS id m72si9164687ioe.292.2017.10.18.10.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 10:08:08 -0700 (PDT)
Subject: Re: [PATCH v12 07/11] x86/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-8-pasha.tatashin@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f4540f92-2229-53f5-ee74-fe160bedc873@virtuozzo.com>
Date: Wed, 18 Oct 2017 20:11:09 +0300
MIME-Version: 1.0
In-Reply-To: <20171013173214.27300-8-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/13/2017 08:32 PM, Pavel Tatashin wrote:
> During early boot, kasan uses vmemmap_populate() to establish its shadow
> memory. But, that interface is intended for struct pages use.
> 
> Because of the current project, vmemmap won't be zeroed during allocation,
> but kasan expects that memory to be zeroed. We are adding a new
> kasan_map_populate() function to resolve this difference.
> 
> Therefore, we must use a new interface to allocate and map kasan shadow
> memory, that also zeroes memory for us.
> 

Nah, we should do the same as with arm64 here.
The patch bellow works for me. Could you please make sure that it works for you as well? Just in case.




From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: x86/mm/kasan: don't use vmemmap_populate() to initialize
 shadow

The kasan shadow is currently mapped using vmemmap_populate() since that
provides a semi-convenient way to map pages into init_top_pgt. However,
since that no longer zeroes the mapped pages, it is not suitable for kasan,
which requires zeroed shadow memory.

Add kasan_populate_shadow() interface and use it instead of
vmemmap_populate(). Besides, this allows us to take advantage of gigantic pages
and use them to populate the shadow, which should save us some memory
wasted on page tables and reduce TLB pressure.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/x86/Kconfig            |   2 +-
 arch/x86/mm/kasan_init_64.c | 141 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 136 insertions(+), 7 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8153cf40e5fe..e3847e472bd7 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -108,7 +108,7 @@ config X86
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_HUGE_VMAP		if X86_64 || X86_PAE
 	select HAVE_ARCH_JUMP_LABEL
-	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP
+	select HAVE_ARCH_KASAN			if X86_64
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index bc84b73684b7..f8ea02571494 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -3,19 +3,148 @@
 #include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/sched/task.h>
 #include <linux/vmalloc.h>
 
 #include <asm/e820/types.h>
+#include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
 #include <asm/pgtable.h>
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
-static int __init map_range(struct range *range)
+static __init void *early_alloc(size_t size, int nid)
+{
+	return memblock_virt_alloc_try_nid_nopanic(size, size,
+		__pa(MAX_DMA_ADDRESS), BOOTMEM_ALLOC_ACCESSIBLE, nid);
+}
+
+static void __init kasan_populate_pmd(pmd_t *pmd, unsigned long addr,
+				unsigned long end, int nid)
+{
+	pte_t *pte;
+
+	if (pmd_none(*pmd)) {
+		void *p;
+
+		if (boot_cpu_has(X86_FEATURE_PSE) &&
+		    ((end - addr) == PMD_SIZE) &&
+		    IS_ALIGNED(addr, PMD_SIZE)) {
+			p = early_alloc(PMD_SIZE, nid);
+			if (p && pmd_set_huge(pmd, __pa(p), PAGE_KERNEL))
+				return;
+			else if (p)
+				memblock_free(__pa(p), PMD_SIZE);
+		}
+
+		p = early_alloc(PAGE_SIZE, nid);
+		pmd_populate_kernel(&init_mm, pmd, p);
+	}
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		pte_t entry;
+		void *p;
+
+		if (!pte_none(*pte))
+			continue;
+
+		p = early_alloc(PAGE_SIZE, nid);
+		entry = pfn_pte(PFN_DOWN(__pa(p)), PAGE_KERNEL);
+		set_pte_at(&init_mm, addr, pte, entry);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+}
+
+
+static void __init kasan_populate_pud(pud_t *pud, unsigned long addr,
+				unsigned long end, int nid)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	if (pud_none(*pud)) {
+		void *p;
+
+		if (boot_cpu_has(X86_FEATURE_GBPAGES) &&
+		    ((end - addr) == PUD_SIZE) &&
+		    IS_ALIGNED(addr, PUD_SIZE)) {
+			p = early_alloc(PUD_SIZE, nid);
+			if (p && pud_set_huge(pud, __pa(p), PAGE_KERNEL))
+				return;
+			else if (p)
+				memblock_free(__pa(p), PUD_SIZE);
+		}
+
+		p = early_alloc(PAGE_SIZE, nid);
+		pud_populate(&init_mm, pud, p);
+	}
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (!pmd_large(*pmd))
+			kasan_populate_pmd(pmd, addr, next, nid);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void __init kasan_populate_p4d(p4d_t *p4d, unsigned long addr,
+				unsigned long end, int nid)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	if (p4d_none(*p4d)) {
+		void *p = early_alloc(PAGE_SIZE, nid);
+		p4d_populate(&init_mm, p4d, p);
+	}
+
+	pud = pud_offset(p4d, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (!pud_large(*pud))
+			kasan_populate_pud(pud, addr, next, nid);
+	} while (pud++, addr = next, addr != end);
+}
+
+static void __init kasan_populate_pgd(pgd_t *pgd, unsigned long addr,
+				unsigned long end, int nid)
+{
+	void *p;
+	p4d_t *p4d;
+	unsigned long next;
+
+	if (pgd_none(*pgd)) {
+		p = early_alloc(PAGE_SIZE, nid);
+		pgd_populate(&init_mm, pgd, p);
+	}
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		kasan_populate_p4d(p4d, addr, next, nid);
+	} while (p4d++, addr = next, addr != end);
+}
+
+static void __init kasan_populate_shadow(unsigned long addr, unsigned long end,
+					int nid)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	addr = addr & PAGE_MASK;
+	end = round_up(end, PAGE_SIZE);
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		kasan_populate_pgd(pgd, addr, next, nid);
+	} while (pgd++, addr = next, addr != end);
+}
+
+static void __init map_range(struct range *range)
 {
 	unsigned long start;
 	unsigned long end;
@@ -23,7 +152,7 @@ static int __init map_range(struct range *range)
 	start = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->start));
 	end = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->end));
 
-	return vmemmap_populate(start, end, NUMA_NO_NODE);
+	kasan_populate_shadow(start, end, early_pfn_to_nid(range->start));
 }
 
 static void __init clear_pgds(unsigned long start,
@@ -129,16 +258,16 @@ void __init kasan_init(void)
 		if (pfn_mapped[i].end == 0)
 			break;
 
-		if (map_range(&pfn_mapped[i]))
-			panic("kasan: unable to allocate shadow!");
+		map_range(&pfn_mapped[i]);
 	}
+
 	kasan_populate_zero_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		kasan_mem_to_shadow((void *)__START_KERNEL_map));
 
-	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
+	kasan_populate_shadow((unsigned long)kasan_mem_to_shadow(_stext),
 			(unsigned long)kasan_mem_to_shadow(_end),
-			NUMA_NO_NODE);
+			early_pfn_to_nid(__pa(_stext)));
 
 	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
