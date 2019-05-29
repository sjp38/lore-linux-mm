Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 222F0C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBF9621670
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBF9621670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537376B0266; Wed, 29 May 2019 05:16:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6C46B026A; Wed, 29 May 2019 05:16:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D6CB6B026B; Wed, 29 May 2019 05:16:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2DFC6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 05:16:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so2416525edd.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 02:16:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=bLiBWyQLr/9YLn0a0hHBHpRRb/bQ//w0i5F3N/eBaHM=;
        b=t8OYoFrRW93k2rIJauUKutnyoAG+o7d/Ojq6iKOKjMtgz9geIVMLY/lDXpGfj7H0IS
         4vi1Hz4rL5NvIPPBZtq1HZBHfAEVrhrPvqoBS21mSiR3FiuZOlCtIEhYbBNc83E/Twig
         Cforxz7GABGEznQfICwnFhrcYUxYB/n0K5+tMpv6W70rlYQviyMp2SifYnKuPkfoSUbX
         we9H0f1a5YIBqTRM+99z7YUOTw57MbRcPqKMqSQ79v5Mi6rdJCcke1Uv7rxIyFML+oc6
         b5HFn7H90iTElD/k0DfvnUl8WWaDjQRt2aGC5hzP44Qs/1IU6wD/il1jtY+B2VkB7nfL
         gGUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUBLmzy2NuBkRcy7rzHG6KMUKvqL1/pw9NabNPV3VEKzRrpYswO
	K2n3Cty3YzDndMW33QSAB3py5yxNvS7/NSV7o1/++8TF3WG03FEdlznBPTDEE9m0btGiTSePVMF
	+h2cz90jYPIo/ZsCFdsWy9VcqKAeY5Q1l9f0cfsrofRBKvzdfrgkGr3hsA93HTjbMYg==
X-Received: by 2002:a17:906:f84a:: with SMTP id ks10mr88981703ejb.65.1559121402484;
        Wed, 29 May 2019 02:16:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3wraVFtnrWaQdy4J4EMTM98mDciwUoZjcCfu119ttmOIX3NKzJTubYNG0xd5hCw6LkOd+
X-Received: by 2002:a17:906:f84a:: with SMTP id ks10mr88981634ejb.65.1559121401387;
        Wed, 29 May 2019 02:16:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559121401; cv=none;
        d=google.com; s=arc-20160816;
        b=HnSN/O+xVHcMtU6+yQlm5lpIar9yB8TfNyyvnKHYzNJLM9cRMibmBOLtfGwkpm8fuc
         Y+BUQEyRf7c7FdpbMjhS7YBtANQbElfCsnWXWcUN4HAvTh7yVA4BL45LwNkRaiVLTizw
         /yZMl0CmUW7tjG9Dp3GhWtCCo2BmAJq+ppb82qNXnPrhPm16Yn9ztPJHNNghAoCvdZq5
         dPTNjQMvKjvAQaqg/ytqtbqe8i3fE56hHO5QCsaRZivn4EqH+fk3M6QYZFKTE4xR9+Ha
         EYkGs1XxPuhDus/5K9ZBN8zKq0dC5fWZf6IiyU83dkqpRz3PdH+IN7DJuJ/EXaovZOzD
         cNlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=bLiBWyQLr/9YLn0a0hHBHpRRb/bQ//w0i5F3N/eBaHM=;
        b=aIJUxr06feq4T5nZ6OuL3vB+sOtqa3e7rEzEqdl1KESaFksxK94Sjp4R2j/5mEPJye
         6Qbw/Rw/F01o/IPC3F/IYMyOPiVKJ+KJJ26j12agxStknE4auFST2bxe7oYMgaRzR0/w
         FMvqd91X6s4U2R6yBVK13RFtCXBTiZ9wiZtVOz/oc8LTX0c2rDtitrYVZsRP9PXQfq8E
         fsWRytRvPH5rzHtw16j6t8I4FifFRDQCbRH98LJ1GNVZp71dkme22Q75wvllpXR7Da0m
         MGQULZHDCUKAmONuGAe1sGWywiOeRLI629FVtjG7Gji8DDu2PmcR4xpgIpWwBqQXQuYV
         kxgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h23si5332175edb.300.2019.05.29.02.16.40
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 02:16:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2D180165C;
	Wed, 29 May 2019 02:16:40 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.181])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id E0E943F5AF;
	Wed, 29 May 2019 02:16:34 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com
Subject: [PATCH V5 3/3] arm64/mm: Enable memory hot remove
Date: Wed, 29 May 2019 14:46:27 +0530
Message-Id: <1559121387-674-4-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The arch code for hot-remove must tear down portions of the linear map and
vmemmap corresponding to memory being removed. In both cases the page
tables mapping these regions must be freed, and when sparse vmemmap is in
use the memory backing the vmemmap must also be freed.

This patch adds a new remove_pagetable() helper which can be used to tear
down either region, and calls it from vmemmap_free() and
___remove_pgd_mapping(). The sparse_vmap argument determines whether the
backing memory will be freed.

While freeing intermediate level page table pages bail out if any of it's
entries are still valid. This can happen for partially filled kernel page
table either from a previously attempted failed memory hot add or while
removing an address range which does not span the entire page table page
range.

The vmemmap region may share levels of table with the vmalloc region. Take
the kernel ptl so that we can safely free potentially-shared tables.

While here update arch_add_memory() to handle __add_pages() failures by
just unmapping recently added kernel linear mapping. Now enable memory hot
remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.

This implementation is overall inspired from kernel page table tear down
procedure on X86 architecture.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Acked-by: David Hildenbrand <david@redhat.com>
---
 arch/arm64/Kconfig  |   3 +
 arch/arm64/mm/mmu.c | 211 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 212 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 697ea05..7f917fe 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -268,6 +268,9 @@ config HAVE_GENERIC_GUP
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 config SMP
 	def_bool y
 
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a1bfc44..4803624 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -733,6 +733,187 @@ int kern_addr_valid(unsigned long addr)
 
 	return pfn_valid(pte_pfn(pte));
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static void free_hotplug_page_range(struct page *page, ssize_t size)
+{
+	WARN_ON(PageReserved(page));
+	free_pages((unsigned long)page_address(page), get_order(size));
+}
+
+static void free_hotplug_pgtable_page(struct page *page)
+{
+	free_hotplug_page_range(page, PAGE_SIZE);
+}
+
+static void free_pte_table(pte_t *ptep, pmd_t *pmdp, unsigned long addr)
+{
+	struct page *page;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		if (!pte_none(ptep[i]))
+			return;
+	}
+
+	page = pmd_page(READ_ONCE(*pmdp));
+	pmd_clear(pmdp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void free_pmd_table(pmd_t *pmdp, pud_t *pudp, unsigned long addr)
+{
+	struct page *page;
+	int i;
+
+	if (CONFIG_PGTABLE_LEVELS <= 2)
+		return;
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (!pmd_none(pmdp[i]))
+			return;
+	}
+
+	page = pud_page(READ_ONCE(*pudp));
+	pud_clear(pudp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void free_pud_table(pud_t *pudp, pgd_t *pgdp, unsigned long addr)
+{
+	struct page *page;
+	int i;
+
+	if (CONFIG_PGTABLE_LEVELS <= 3)
+		return;
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		if (!pud_none(pudp[i]))
+			return;
+	}
+
+	page = pgd_page(READ_ONCE(*pgdp));
+	pgd_clear(pgdp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void
+remove_pte_table(pmd_t *pmdp, unsigned long addr,
+			unsigned long end, bool sparse_vmap)
+{
+	struct page *page;
+	pte_t *ptep, pte;
+	unsigned long start = addr;
+
+	for (; addr < end; addr += PAGE_SIZE) {
+		ptep = pte_offset_kernel(pmdp, addr);
+		pte = READ_ONCE(*ptep);
+
+		if (pte_none(pte))
+			continue;
+
+		WARN_ON(!pte_present(pte));
+		if (sparse_vmap) {
+			page = pte_page(pte);
+			free_hotplug_page_range(page, PAGE_SIZE);
+		}
+		pte_clear(&init_mm, addr, ptep);
+	}
+	flush_tlb_kernel_range(start, end);
+}
+
+static void
+remove_pmd_table(pud_t *pudp, unsigned long addr,
+			unsigned long end, bool sparse_vmap)
+{
+	unsigned long next;
+	struct page *page;
+	pte_t *ptep_base;
+	pmd_t *pmdp, pmd;
+
+	for (; addr < end; addr = next) {
+		next = pmd_addr_end(addr, end);
+		pmdp = pmd_offset(pudp, addr);
+		pmd = READ_ONCE(*pmdp);
+
+		if (pmd_none(pmd))
+			continue;
+
+		WARN_ON(!pmd_present(pmd));
+		if (pmd_sect(pmd)) {
+			if (sparse_vmap) {
+				page = pmd_page(pmd);
+				free_hotplug_page_range(page, PMD_SIZE);
+			}
+			pmd_clear(pmdp);
+			continue;
+		}
+		ptep_base = pte_offset_kernel(pmdp, 0UL);
+		remove_pte_table(pmdp, addr, next, sparse_vmap);
+		free_pte_table(ptep_base, pmdp, addr);
+	}
+}
+
+static void
+remove_pud_table(pgd_t *pgdp, unsigned long addr,
+			unsigned long end, bool sparse_vmap)
+{
+	unsigned long next;
+	struct page *page;
+	pmd_t *pmdp_base;
+	pud_t *pudp, pud;
+
+	for (; addr < end; addr = next) {
+		next = pud_addr_end(addr, end);
+		pudp = pud_offset(pgdp, addr);
+		pud = READ_ONCE(*pudp);
+
+		if (pud_none(pud))
+			continue;
+
+		WARN_ON(!pud_present(pud));
+		if (pud_sect(pud)) {
+			if (sparse_vmap) {
+				page = pud_page(pud);
+				free_hotplug_page_range(page, PUD_SIZE);
+			}
+			pud_clear(pudp);
+			continue;
+		}
+		pmdp_base = pmd_offset(pudp, 0UL);
+		remove_pmd_table(pudp, addr, next, sparse_vmap);
+		free_pmd_table(pmdp_base, pudp, addr);
+	}
+}
+
+static void
+remove_pagetable(unsigned long start, unsigned long end, bool sparse_vmap)
+{
+	unsigned long addr, next;
+	pud_t *pudp_base;
+	pgd_t *pgdp, pgd;
+
+	spin_lock(&init_mm.page_table_lock);
+	for (addr = start; addr < end; addr = next) {
+		next = pgd_addr_end(addr, end);
+		pgdp = pgd_offset_k(addr);
+		pgd = READ_ONCE(*pgdp);
+
+		if (pgd_none(pgd))
+			continue;
+
+		WARN_ON(!pgd_present(pgd));
+		pudp_base = pud_offset(pgdp, 0UL);
+		remove_pud_table(pgdp, addr, next, sparse_vmap);
+		free_pud_table(pudp_base, pgdp, addr);
+	}
+	spin_unlock(&init_mm.page_table_lock);
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
@@ -780,6 +961,9 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 void vmemmap_free(unsigned long start, unsigned long end,
 		struct vmem_altmap *altmap)
 {
+#ifdef CONFIG_MEMORY_HOTPLUG
+	remove_pagetable(start, end, true);
+#endif
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
 
@@ -1070,10 +1254,16 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
+{
+	WARN_ON(pgdir != init_mm.pgd);
+	remove_pagetable(start, start + size, false);
+}
+
 int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions)
 {
-	int flags = 0;
+	int ret, flags = 0;
 
 	if (rodata_full || debug_pagealloc_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
@@ -1081,7 +1271,24 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
 			     size, PAGE_KERNEL, __pgd_pgtable_alloc, flags);
 
-	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+	ret = __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   restrictions);
+	if (ret)
+		__remove_pgd_mapping(swapper_pg_dir,
+				     __phys_to_virt(start), size);
+	return ret;
+}
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+void arch_remove_memory(int nid, u64 start, u64 size,
+				struct vmem_altmap *altmap)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone = page_zone(pfn_to_page(start_pfn));
+
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pgd_mapping(swapper_pg_dir, __phys_to_virt(start), size);
 }
 #endif
+#endif
-- 
2.7.4

