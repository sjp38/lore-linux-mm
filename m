Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E14C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E41C4206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E41C4206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1536B0288; Wed,  3 Apr 2019 00:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 862596B028A; Wed,  3 Apr 2019 00:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729FF6B028B; Wed,  3 Apr 2019 00:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34C736B0288
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m31so6856665edm.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=qnLEgMq1dxXlnwV474xu1ZsWxRBbzAkfiGYmeqB2/MM=;
        b=hswdLAcmQmkYI3WB95t5OIPLUFJm+VT5uA/PtalksabK0+RF1MWalUdvrUkjeUNgO+
         607s/MhoytuGT1VUG1XlJlpfN4nzbEydJxfyrTalbL82DLshlXG+PnLHQDAMfzKwmsYf
         +t6fs14hHYHsyosz+AC3mTv/T76X0Ww6L0KBsHJH+tnkIEWmo614fBWZ3AEmLjM+5uj2
         5l1p3RDTB5ZA/HZvbJpBKqDxa/RGkG2av/A6MZGeDMtJfy/WhvHqXkw67wBw+XbDbX+I
         7+XJ0IP1mMSDDxoDk9vTtjOOToEgjsCssgvVR0shKvCsp6kjhgpyo4UD7B0GEGnyPu7f
         UwkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWulynvD4ml3bBebUeCj+B8bVt3cFej2un+RaVwGWEq6DejJVKD
	2ZDRv3B5bXY2YQ0GQkmi2hxSoco4eoJUZExltGIWuroChsIr9x3ktxBNjVlkH04JDX9rm1+b2Z6
	GqGAMWWChAEk1b6KOMJdeEsEIU+Ptb2BK4b7o4lXe7LR8UQLlSdBcZoQGL9nDoWHyiQ==
X-Received: by 2002:a50:a7e5:: with SMTP id i92mr50484486edc.181.1554265827680;
        Tue, 02 Apr 2019 21:30:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO/21SsDnJ+iuMsovWWiHksEtf4p+fMpycKbI2a5obzo+NlJiPHeKq4ICf7CYcIHU4s8ue
X-Received: by 2002:a50:a7e5:: with SMTP id i92mr50484411edc.181.1554265825810;
        Tue, 02 Apr 2019 21:30:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265825; cv=none;
        d=google.com; s=arc-20160816;
        b=QZDd8xn95K1yJxi+gVtD+vuq1nvxBIkFneQVvedRmUOZcL03+Pp70e22Tg1eQr6Oh7
         L67DIJ1Wgv7adBJinnauWkjKxJXKjuGgLFmdVPypgjqQc89RomiUNL5utjZmeq9+bMbm
         e3inbd968K3mg4YQbVvWRt0fwsiR01p3PRIy4rPNSQJmU6RMBK3gbQL9qL0uXbxxInKX
         FxE2ja55TKIEmtWrsaf/QZyEigNaKCwl6QYajL8Hn9K+bupju1xFttjJe8W+gRYWf/Ac
         3P9T7i562kD32zHKzsvTPfiHqMhig90bvpcMPcwanGTEY7SiFPpP4vc6u60nP7hN9h2C
         Pe2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=qnLEgMq1dxXlnwV474xu1ZsWxRBbzAkfiGYmeqB2/MM=;
        b=XEezv5AEe5PGI6LD2OcBydsxwFzbCAPiPs9G/PaCwaB9VsOzknzHq8mqgCH44p/Qnr
         Jcs2QM7ANdFRt2//QpfTyObZYI4nEw6XH4U2phdjAxQk+9ZLKRzHKANEVyD9tJyi15pe
         avdCixlyGrt1ew6//wmH+pdz/yGBozIq4DjDH6mR7Z3EegUhPsy68xMgZF5nT2ZrI2By
         nKhkdA39aXNfQlfWVjqEa5n9e39AtwFuMldbcCTS56hfrnVjzYS10y6fxxLhovtjZKx7
         N+nWZEBULQHxhCqSNpXkFWesaF0T8e+qQlbNvamjRjlAfG5Pejg5n10/YvEs3HcvsOCQ
         Z51Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gr15si3469172ejb.302.2019.04.02.21.30.25
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A55EA1596;
	Tue,  2 Apr 2019 21:30:24 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7F0253F721;
	Tue,  2 Apr 2019 21:30:18 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 2/6] arm64/mm: Enable memory hot remove
Date: Wed,  3 Apr 2019 10:00:02 +0530
Message-Id: <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory removal from an arch perspective involves tearing down two different
kernel based mappings i.e vmemmap and linear while releasing related page
table pages allocated for the physical memory range to be removed.

Define a common kernel page table tear down helper remove_pagetable() which
can be used to unmap given kernel virtual address range. In effect it can
tear down both vmemap or kernel linear mappings. This new helper is called
from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
The argument 'direct' here identifies kernel linear mappings.

Vmemmap mappings page table pages are allocated through sparse mem helper
functions like vmemmap_alloc_block() which does not cycle the pages through
pgtable_page_ctor() constructs. Hence while removing it skips corresponding
destructor construct pgtable_page_dtor().

While here update arch_add_mempory() to handle __add_pages() failures by
just unmapping recently added kernel linear mapping. Now enable memory hot
remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.

This implementation is overall inspired from kernel page table tear down
procedure on X86 architecture.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig               |   3 +
 arch/arm64/include/asm/pgtable.h |  14 +++
 arch/arm64/mm/mmu.c              | 227 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 241 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a2418fb..db3e625 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -266,6 +266,9 @@ config HAVE_GENERIC_GUP
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 config ARCH_MEMORY_PROBE
 	bool "Enable /sys/devices/system/memory/probe interface"
 	depends on MEMORY_HOTPLUG
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1e..858098e 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -355,6 +355,18 @@ static inline int pmd_protnone(pmd_t pmd)
 }
 #endif
 
+#if (CONFIG_PGTABLE_LEVELS > 2)
+#define pmd_large(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
+#else
+#define pmd_large(pmd) 0
+#endif
+
+#if (CONFIG_PGTABLE_LEVELS > 3)
+#define pud_large(pud)	(pud_val(pud) && !(pud_val(pud) & PUD_TABLE_BIT))
+#else
+#define pud_large(pmd) 0
+#endif
+
 /*
  * THP definitions.
  */
@@ -555,6 +567,7 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
 
 #else
 
+#define pmd_index(addr) 0
 #define pud_page_paddr(pud)	({ BUILD_BUG(); 0; })
 
 /* Match pmd_offset folding in <asm/generic/pgtable-nopmd.h> */
@@ -612,6 +625,7 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
 
 #else
 
+#define pud_index(adrr)	0
 #define pgd_page_paddr(pgd)	({ BUILD_BUG(); 0;})
 
 /* Match pud_offset folding in <asm/generic/pgtable-nopud.h> */
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e97f018..ae0777b 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -714,6 +714,198 @@ int kern_addr_valid(unsigned long addr)
 
 	return pfn_valid(pte_pfn(pte));
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static void __meminit free_pagetable(struct page *page, int order)
+{
+	unsigned long magic;
+	unsigned int nr_pages = 1 << order;
+
+	if (PageReserved(page)) {
+		__ClearPageReserved(page);
+
+		magic = (unsigned long)page->freelist;
+		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
+			while (nr_pages--)
+				put_page_bootmem(page++);
+		} else
+			while (nr_pages--)
+				free_reserved_page(page++);
+	} else
+		free_pages((unsigned long)page_address(page), order);
+}
+
+#if (CONFIG_PGTABLE_LEVELS > 2)
+static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
+{
+	pte_t *pte;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		pte = pte_start + i;
+		if (!pte_none(*pte))
+			return;
+	}
+
+	if (direct)
+		pgtable_page_dtor(pmd_page(*pmd));
+	free_pagetable(pmd_page(*pmd), 0);
+	spin_lock(&init_mm.page_table_lock);
+	pmd_clear(pmd);
+	spin_unlock(&init_mm.page_table_lock);
+}
+#else
+static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
+{
+}
+#endif
+
+#if (CONFIG_PGTABLE_LEVELS > 3)
+static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
+{
+	pmd_t *pmd;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		pmd = pmd_start + i;
+		if (!pmd_none(*pmd))
+			return;
+	}
+
+	if (direct)
+		pgtable_page_dtor(pud_page(*pud));
+	free_pagetable(pud_page(*pud), 0);
+	spin_lock(&init_mm.page_table_lock);
+	pud_clear(pud);
+	spin_unlock(&init_mm.page_table_lock);
+}
+
+static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
+{
+	pud_t *pud;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		pud = pud_start + i;
+		if (!pud_none(*pud))
+			return;
+	}
+
+	if (direct)
+		pgtable_page_dtor(pgd_page(*pgd));
+	free_pagetable(pgd_page(*pgd), 0);
+	spin_lock(&init_mm.page_table_lock);
+	pgd_clear(pgd);
+	spin_unlock(&init_mm.page_table_lock);
+}
+#else
+static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
+{
+}
+
+static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
+{
+}
+#endif
+
+static void __meminit
+remove_pte_table(pte_t *pte_start, unsigned long addr,
+			unsigned long end, bool direct)
+{
+	pte_t *pte;
+
+	pte = pte_start + pte_index(addr);
+	for (; addr < end; addr += PAGE_SIZE, pte++) {
+		if (!pte_present(*pte))
+			continue;
+
+		if (!direct)
+			free_pagetable(pte_page(*pte), 0);
+		spin_lock(&init_mm.page_table_lock);
+		pte_clear(&init_mm, addr, pte);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+}
+
+static void __meminit
+remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
+			unsigned long end, bool direct)
+{
+	unsigned long next;
+	pte_t *pte_base;
+	pmd_t *pmd;
+
+	pmd = pmd_start + pmd_index(addr);
+	for (; addr < end; addr = next, pmd++) {
+		next = pmd_addr_end(addr, end);
+		if (!pmd_present(*pmd))
+			continue;
+
+		if (pmd_large(*pmd)) {
+			if (!direct)
+				free_pagetable(pmd_page(*pmd),
+						get_order(PMD_SIZE));
+			spin_lock(&init_mm.page_table_lock);
+			pmd_clear(pmd);
+			spin_unlock(&init_mm.page_table_lock);
+			continue;
+		}
+		pte_base = pte_offset_kernel(pmd, 0UL);
+		remove_pte_table(pte_base, addr, next, direct);
+		free_pte_table(pte_base, pmd, direct);
+	}
+}
+
+static void __meminit
+remove_pud_table(pud_t *pud_start, unsigned long addr,
+			unsigned long end, bool direct)
+{
+	unsigned long next;
+	pmd_t *pmd_base;
+	pud_t *pud;
+
+	pud = pud_start + pud_index(addr);
+	for (; addr < end; addr = next, pud++) {
+		next = pud_addr_end(addr, end);
+		if (!pud_present(*pud))
+			continue;
+
+		if (pud_large(*pud)) {
+			if (!direct)
+				free_pagetable(pud_page(*pud),
+						get_order(PUD_SIZE));
+			spin_lock(&init_mm.page_table_lock);
+			pud_clear(pud);
+			spin_unlock(&init_mm.page_table_lock);
+			continue;
+		}
+		pmd_base = pmd_offset(pud, 0UL);
+		remove_pmd_table(pmd_base, addr, next, direct);
+		free_pmd_table(pmd_base, pud, direct);
+	}
+}
+
+static void __meminit
+remove_pagetable(unsigned long start, unsigned long end, bool direct)
+{
+	unsigned long addr, next;
+	pud_t *pud_base;
+	pgd_t *pgd;
+
+	for (addr = start; addr < end; addr = next) {
+		next = pgd_addr_end(addr, end);
+		pgd = pgd_offset_k(addr);
+		if (!pgd_present(*pgd))
+			continue;
+
+		pud_base = pud_offset(pgd, 0UL);
+		remove_pud_table(pud_base, addr, next, direct);
+		free_pud_table(pud_base, pgd, direct);
+	}
+	flush_tlb_kernel_range(start, end);
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
@@ -758,9 +950,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 	return 0;
 }
 #endif	/* CONFIG_ARM64_64K_PAGES */
-void vmemmap_free(unsigned long start, unsigned long end,
+void __ref vmemmap_free(unsigned long start, unsigned long end,
 		struct vmem_altmap *altmap)
 {
+#ifdef CONFIG_MEMORY_HOTPLUG
+	remove_pagetable(start, end, false);
+#endif
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
 
@@ -1046,10 +1241,16 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
+{
+	WARN_ON(pgdir != init_mm.pgd);
+	remove_pagetable(start, start + size, true);
+}
+
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		    bool want_memblock)
 {
-	int flags = 0;
+	int flags = 0, ret = 0;
 
 	if (rodata_full || debug_pagealloc_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
@@ -1057,7 +1258,27 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
 			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
 
-	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+	ret = __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   altmap, want_memblock);
+	if (ret)
+		__remove_pgd_mapping(swapper_pg_dir,
+					__phys_to_virt(start), size);
+	return ret;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone = page_zone(pfn_to_page(start_pfn));
+	int ret;
+
+	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
+	if (!ret)
+		__remove_pgd_mapping(swapper_pg_dir,
+					__phys_to_virt(start), size);
+	return ret;
+}
+#endif
 #endif
-- 
2.7.4

