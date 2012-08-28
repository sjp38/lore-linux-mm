Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DD3A96B0073
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 06:00:08 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v8 PATCH 12/20] memory-hotplug: introduce new function arch_remove_memory()
Date: Tue, 28 Aug 2012 18:00:19 +0800
Message-Id: <1346148027-24468-13-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

We don't call __add_pages() directly in the function add_memory()
because some other architecture related things need to be done
before or after calling __add_pages(). So we should introduce
a new function arch_remove_memory() to revert the things
done in arch_add_memory().

Note: the function for s390 is not implemented(I don't know how to
implement it for s390).

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/ia64/mm/init.c                  |   16 ++++
 arch/powerpc/mm/mem.c                |   14 +++
 arch/s390/mm/init.c                  |   12 +++
 arch/sh/mm/init.c                    |   15 +++
 arch/tile/mm/init.c                  |    8 ++
 arch/x86/include/asm/pgtable_types.h |    1 +
 arch/x86/mm/init_32.c                |   10 ++
 arch/x86/mm/init_64.c                |  160 ++++++++++++++++++++++++++++++++++
 arch/x86/mm/pageattr.c               |   47 +++++-----
 include/linux/memory_hotplug.h       |    1 +
 mm/memory_hotplug.c                  |    1 +
 11 files changed, 263 insertions(+), 22 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 0eab454..1e345ed 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -688,6 +688,22 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	return ret;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	int ret;
+
+	ret = __remove_pages(start_pfn, nr_pages);
+	if (ret)
+		pr_warn("%s: Problem encountered in __remove_pages() as"
+			" ret=%d\n", __func__,  ret);
+
+	return ret;
+}
+#endif
 #endif
 
 /*
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index fbdad0e..011170b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -133,6 +133,20 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	start = (unsigned long)__va(start);
+	if (remove_section_mapping(start, start + size))
+		return -EINVAL;
+
+	return __remove_pages(start_pfn, nr_pages);
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 /*
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 6adbc08..501b20e 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -257,4 +257,16 @@ int arch_add_memory(int nid, u64 start, u64 size)
 		vmem_remove_mapping(start, size);
 	return rc;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	/*
+	 * There is no hardware or firmware interface which could trigger a
+	 * hot memory remove on s390. So there is nothing that needs to be
+	 * implemented.
+	 */
+	return -EBUSY;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 82cc576..fc84491 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -558,4 +558,19 @@ int memory_add_physaddr_to_nid(u64 addr)
 EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	int ret;
+
+	ret = __remove_pages(start_pfn, nr_pages);
+	if (unlikely(ret))
+		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
+			ret);
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index ef29d6c..2749515 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -935,6 +935,14 @@ int remove_memory(u64 start, u64 size)
 {
 	return -EINVAL;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	/* TODO */
+	return -EBUSY;
+}
+#endif
 #endif
 
 struct kmem_cache *pgd_cache;
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 013286a..b725af2 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -334,6 +334,7 @@ static inline void update_page_count(int level, unsigned long pages) { }
  * as a pte too.
  */
 extern pte_t *lookup_address(unsigned long address, unsigned int *level);
+extern int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase);
 
 #endif	/* !__ASSEMBLY__ */
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 575d86f..41eefe8 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -842,6 +842,16 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	return __remove_pages(start_pfn, nr_pages);
+}
+#endif
 #endif
 
 /*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 2b6b4a3..e0d88ba 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -675,6 +675,166 @@ int arch_add_memory(int nid, u64 start, u64 size)
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
+static void __meminit
+phys_pte_remove(pte_t *pte_page, unsigned long addr, unsigned long end)
+{
+	unsigned pages = 0;
+	int i = pte_index(addr);
+
+	pte_t *pte = pte_page + pte_index(addr);
+
+	for (; i < PTRS_PER_PTE; i++, addr += PAGE_SIZE, pte++) {
+
+		if (addr >= end)
+			break;
+
+		if (!pte_present(*pte))
+			continue;
+
+		pages++;
+		set_pte(pte, __pte(0));
+	}
+
+	update_page_count(PG_LEVEL_4K, -pages);
+}
+
+static void __meminit
+phys_pmd_remove(pmd_t *pmd_page, unsigned long addr, unsigned long end)
+{
+	unsigned long pages = 0, next;
+	int i = pmd_index(addr);
+
+	for (; i < PTRS_PER_PMD; i++, addr = next) {
+		unsigned long pte_phys;
+		pmd_t *pmd = pmd_page + pmd_index(addr);
+		pte_t *pte;
+
+		if (addr >= end)
+			break;
+
+		next = (addr & PMD_MASK) + PMD_SIZE;
+
+		if (!pmd_present(*pmd))
+			continue;
+
+		if (pmd_large(*pmd)) {
+			if ((addr & ~PMD_MASK) == 0 && next <= end) {
+				set_pmd(pmd, __pmd(0));
+				pages++;
+				continue;
+			}
+
+			/*
+			 * We use 2M page, but we need to remove part of them,
+			 * so split 2M page to 4K page.
+			 */
+			pte = alloc_low_page(&pte_phys);
+			__split_large_page((pte_t *)pmd, addr, pte);
+
+			spin_lock(&init_mm.page_table_lock);
+			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
+			spin_unlock(&init_mm.page_table_lock);
+		}
+
+		spin_lock(&init_mm.page_table_lock);
+		pte = map_low_page((pte_t *)pmd_page_vaddr(*pmd));
+		phys_pte_remove(pte, addr, end);
+		unmap_low_page(pte);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+	update_page_count(PG_LEVEL_2M, -pages);
+}
+
+static void __meminit
+phys_pud_remove(pud_t *pud_page, unsigned long addr, unsigned long end)
+{
+	unsigned long pages = 0, next;
+	int i = pud_index(addr);
+
+	for (; i < PTRS_PER_PUD; i++, addr = next) {
+		unsigned long pmd_phys;
+		pud_t *pud = pud_page + pud_index(addr);
+		pmd_t *pmd;
+
+		if (addr >= end)
+			break;
+
+		next = (addr & PUD_MASK) + PUD_SIZE;
+
+		if (!pud_present(*pud))
+			continue;
+
+		if (pud_large(*pud)) {
+			if ((addr & ~PUD_MASK) == 0 && next <= end) {
+				set_pud(pud, __pud(0));
+				pages++;
+				continue;
+			}
+
+			/*
+			 * We use 1G page, but we need to remove part of them,
+			 * so split 1G page to 2M page.
+			 */
+			pmd = alloc_low_page(&pmd_phys);
+			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
+
+			spin_lock(&init_mm.page_table_lock);
+			pud_populate(&init_mm, pud, __va(pmd_phys));
+			spin_unlock(&init_mm.page_table_lock);
+		}
+
+		pmd = map_low_page(pmd_offset(pud, 0));
+		phys_pmd_remove(pmd, addr, end);
+		unmap_low_page(pmd);
+		__flush_tlb_all();
+	}
+	__flush_tlb_all();
+
+	update_page_count(PG_LEVEL_1G, -pages);
+}
+
+void __meminit
+kernel_physical_mapping_remove(unsigned long start, unsigned long end)
+{
+	unsigned long next;
+
+	start = (unsigned long)__va(start);
+	end = (unsigned long)__va(end);
+
+	for (; start < end; start = next) {
+		pgd_t *pgd = pgd_offset_k(start);
+		pud_t *pud;
+
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end)
+			next = end;
+
+		if (!pgd_present(*pgd))
+			continue;
+
+		pud = map_low_page((pud_t *)pgd_page_vaddr(*pgd));
+		phys_pud_remove(pud, __pa(start), __pa(end));
+		unmap_low_page(pud);
+	}
+
+	__flush_tlb_all();
+}
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int __ref arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	int ret;
+
+	ret = __remove_pages(start_pfn, nr_pages);
+	WARN_ON_ONCE(ret);
+
+	kernel_physical_mapping_remove(start, start + size);
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 static struct kcore_list kcore_vsyscall;
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a718e0d..7dcb6f9 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -501,21 +501,13 @@ out_unlock:
 	return do_split;
 }
 
-static int split_large_page(pte_t *kpte, unsigned long address)
+int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase)
 {
 	unsigned long pfn, pfninc = 1;
 	unsigned int i, level;
-	pte_t *pbase, *tmp;
+	pte_t *tmp;
 	pgprot_t ref_prot;
-	struct page *base;
-
-	if (!debug_pagealloc)
-		spin_unlock(&cpa_lock);
-	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
-	if (!debug_pagealloc)
-		spin_lock(&cpa_lock);
-	if (!base)
-		return -ENOMEM;
+	struct page *base = virt_to_page(pbase);
 
 	spin_lock(&pgd_lock);
 	/*
@@ -523,10 +515,11 @@ static int split_large_page(pte_t *kpte, unsigned long address)
 	 * up for us already:
 	 */
 	tmp = lookup_address(address, &level);
-	if (tmp != kpte)
-		goto out_unlock;
+	if (tmp != kpte) {
+		spin_unlock(&pgd_lock);
+		return 1;
+	}
 
-	pbase = (pte_t *)page_address(base);
 	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
 	ref_prot = pte_pgprot(pte_clrhuge(*kpte));
 	/*
@@ -579,17 +572,27 @@ static int split_large_page(pte_t *kpte, unsigned long address)
 	 * going on.
 	 */
 	__flush_tlb_all();
+	spin_unlock(&pgd_lock);
 
-	base = NULL;
+	return 0;
+}
 
-out_unlock:
-	/*
-	 * If we dropped out via the lookup_address check under
-	 * pgd_lock then stick the page back into the pool:
-	 */
-	if (base)
+static int split_large_page(pte_t *kpte, unsigned long address)
+{
+	pte_t *pbase;
+	struct page *base;
+
+	if (!debug_pagealloc)
+		spin_unlock(&cpa_lock);
+	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
+	if (!debug_pagealloc)
+		spin_lock(&cpa_lock);
+	if (!base)
+		return -ENOMEM;
+
+	pbase = (pte_t *)page_address(base);
+	if (__split_large_page(kpte, address, pbase))
 		__free_page(base);
-	spin_unlock(&pgd_lock);
 
 	return 0;
 }
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8bf820d..cdbbd79 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -85,6 +85,7 @@ extern void __online_page_free(struct page *page);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
+extern int arch_remove_memory(u64 start, u64 size);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages in a zone  */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 713f1b9..5f9f8c7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1075,6 +1075,7 @@ int __ref remove_memory(int nid, u64 start, u64 size)
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
 
+	arch_remove_memory(start, size);
 out:
 	unlock_memory_hotplug();
 	return ret;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
