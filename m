Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45AC16B026F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:20:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so29800083wmu.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:20:31 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a15si2623014edd.136.2017.10.09.15.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 15:20:27 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v11 6/9] x86/kasan: add and use kasan_map_populate()
Date: Mon,  9 Oct 2017 18:19:28 -0400
Message-Id: <20171009221931.1481-7-pasha.tatashin@oracle.com>
In-Reply-To: <20171009221931.1481-1-pasha.tatashin@oracle.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

During early boot, kasan uses vmemmap_populate() to establish its shadow
memory. But, that interface is intended for struct pages use.

Because of the current project, vmemmap won't be zeroed during allocation,
but kasan expects that memory to be zeroed. We are adding a new
kasan_map_populate() function to resolve this difference.

Therefore, we must use a new interface to allocate and map kasan shadow
memory, that also zeroes memory for us.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/x86/mm/kasan_init_64.c | 75 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 71 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index bc84b73684b7..9778fec8a5dc 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -15,6 +15,73 @@
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
+/* Creates mappings for kasan during early boot. The mapped memory is zeroed */
+static int __meminit kasan_map_populate(unsigned long start, unsigned long end,
+					int node)
+{
+	unsigned long addr, pfn, next;
+	unsigned long long size;
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	int ret;
+
+	ret = vmemmap_populate(start, end, node);
+	/*
+	 * We might have partially populated memory, so check for no entries,
+	 * and zero only those that actually exist.
+	 */
+	for (addr = start; addr < end; addr = next) {
+		pgd = pgd_offset_k(addr);
+		if (pgd_none(*pgd)) {
+			next = pgd_addr_end(addr, end);
+			continue;
+		}
+
+		p4d = p4d_offset(pgd, addr);
+		if (p4d_none(*p4d)) {
+			next = p4d_addr_end(addr, end);
+			continue;
+		}
+
+		pud = pud_offset(p4d, addr);
+		if (pud_none(*pud)) {
+			next = pud_addr_end(addr, end);
+			continue;
+		}
+		if (pud_large(*pud)) {
+			/* This is PUD size page */
+			next = pud_addr_end(addr, end);
+			size = PUD_SIZE;
+			pfn = pud_pfn(*pud);
+		} else {
+			pmd = pmd_offset(pud, addr);
+			if (pmd_none(*pmd)) {
+				next = pmd_addr_end(addr, end);
+				continue;
+			}
+			if (pmd_large(*pmd)) {
+				/* This is PMD size page */
+				next = pmd_addr_end(addr, end);
+				size = PMD_SIZE;
+				pfn = pmd_pfn(*pmd);
+			} else {
+				pte = pte_offset_kernel(pmd, addr);
+				next = addr + PAGE_SIZE;
+				if (pte_none(*pte))
+					continue;
+				/* This is base size page */
+				size = PAGE_SIZE;
+				pfn = pte_pfn(*pte);
+			}
+		}
+		memset(phys_to_virt(PFN_PHYS(pfn)), 0, size);
+	}
+	return ret;
+}
+
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -23,7 +90,7 @@ static int __init map_range(struct range *range)
 	start = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->start));
 	end = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->end));
 
-	return vmemmap_populate(start, end, NUMA_NO_NODE);
+	return kasan_map_populate(start, end, NUMA_NO_NODE);
 }
 
 static void __init clear_pgds(unsigned long start,
@@ -136,9 +203,9 @@ void __init kasan_init(void)
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		kasan_mem_to_shadow((void *)__START_KERNEL_map));
 
-	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
-			(unsigned long)kasan_mem_to_shadow(_end),
-			NUMA_NO_NODE);
+	kasan_map_populate((unsigned long)kasan_mem_to_shadow(_stext),
+			   (unsigned long)kasan_mem_to_shadow(_end),
+			   NUMA_NO_NODE);
 
 	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
