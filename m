Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4DF76B0311
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l22so6642628qtf.9
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v68si7903902qkd.300.2017.08.07.13.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:49 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 10/15] x86/kasan: explicitly zero kasan shadow memory
Date: Mon,  7 Aug 2017 16:38:44 -0400
Message-Id: <1502138329-123460-11-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

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
 arch/x86/mm/kasan_init_64.c | 67 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 02c9d7553409..ec6b2272fd80 100644
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
@@ -156,6 +216,13 @@ void __init kasan_init(void)
 		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
 		set_pte(&kasan_zero_pte[i], pte);
 	}
+
+	/*
+	 * vmemmap_populate does not zero the memory, so we need to zero it
+	 * explicitly
+	 */
+	zero_vmemmap_populated_memory();
+
 	/* Flush TLBs again to be sure that write protection applied. */
 	__flush_tlb_all();
 
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
