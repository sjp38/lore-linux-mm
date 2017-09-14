Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1E76B026D
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 18:36:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so1044057pff.7
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:36:23 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w18si11588768pge.621.2017.09.14.15.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 15:36:22 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v8 09/11] x86/kasan: explicitly zero kasan shadow memory
Date: Thu, 14 Sep 2017 18:35:15 -0400
Message-Id: <20170914223517.8242-10-pasha.tatashin@oracle.com>
In-Reply-To: <20170914223517.8242-1-pasha.tatashin@oracle.com>
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

To optimize the performance of struct page initialization,
vmemmap_populate() will no longer zero memory.

We must explicitly zero the memory that is allocated by vmemmap_populate()
for kasan, as this memory does not go through struct page initialization
path.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 arch/x86/mm/kasan_init_64.c | 66 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index bc84b73684b7..cc0399032673 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -84,6 +84,66 @@ static struct notifier_block kasan_die_notifier = {
 };
 #endif
 
+/*
+ * x86 variant of vmemmap_populate() uses either PMD_SIZE pages or base pages
+ * to map allocated memory.  This routine determines the page size for the given
+ * address from vmemmap.
+ */
+static u64 get_vmemmap_pgsz(u64 addr)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_k(addr);
+	BUG_ON(pgd_none(*pgd) || pgd_large(*pgd));
+
+	p4d = p4d_offset(pgd, addr);
+	BUG_ON(p4d_none(*p4d) || p4d_large(*p4d));
+
+	pud = pud_offset(p4d, addr);
+	BUG_ON(pud_none(*pud) || pud_large(*pud));
+
+	pmd = pmd_offset(pud, addr);
+	BUG_ON(pmd_none(*pmd));
+
+	if (pmd_large(*pmd))
+		return PMD_SIZE;
+	return PAGE_SIZE;
+}
+
+/*
+ * Memory that was allocated by vmemmap_populate is not zeroed, so we must
+ * zero it here explicitly.
+ */
+static void
+zero_vmemmap_populated_memory(void)
+{
+	u64 i, start, end;
+
+	for (i = 0; i < E820_MAX_ENTRIES && pfn_mapped[i].end; i++) {
+		void *kaddr_start = pfn_to_kaddr(pfn_mapped[i].start);
+		void *kaddr_end = pfn_to_kaddr(pfn_mapped[i].end);
+
+		start = (u64)kasan_mem_to_shadow(kaddr_start);
+		end = (u64)kasan_mem_to_shadow(kaddr_end);
+
+		/* Round to the start end of the mapped pages */
+		start = rounddown(start, get_vmemmap_pgsz(start));
+		end = roundup(end, get_vmemmap_pgsz(start));
+		memset((void *)start, 0, end - start);
+	}
+
+	start = (u64)kasan_mem_to_shadow(_stext);
+	end = (u64)kasan_mem_to_shadow(_end);
+
+	/* Round to the start end of the mapped pages */
+	start = rounddown(start, get_vmemmap_pgsz(start));
+	end = roundup(end, get_vmemmap_pgsz(start));
+	memset((void *)start, 0, end - start);
+}
+
 void __init kasan_early_init(void)
 {
 	int i;
@@ -146,6 +206,12 @@ void __init kasan_init(void)
 	load_cr3(init_top_pgt);
 	__flush_tlb_all();
 
+	/*
+	 * vmemmap_populate does not zero the memory, so we need to zero it
+	 * explicitly
+	 */
+	zero_vmemmap_populated_memory();
+
 	/*
 	 * kasan_zero_page has been used as early shadow memory, thus it may
 	 * contain some garbage. Now we can clear and write protect it, since
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
