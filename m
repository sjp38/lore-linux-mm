Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 263FD6B0261
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:54:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f8so24731720pgs.9
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:54:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 9si20971812plb.812.2017.12.28.23.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:54:43 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/17] mm: pass the vmem_altmap to arch_remove_memory and __remove_pages
Date: Fri, 29 Dec 2017 08:53:55 +0100
Message-Id: <20171229075406.1936-7-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We can just pass this on instead of having to do a radix tree lookup
without proper locking 2 levels into the callchain.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/mm/init.c            | 4 ++--
 arch/powerpc/mm/mem.c          | 6 ++----
 arch/s390/mm/init.c            | 2 +-
 arch/sh/mm/init.c              | 4 ++--
 arch/x86/mm/init_32.c          | 4 ++--
 arch/x86/mm/init_64.c          | 6 ++----
 include/linux/memory_hotplug.h | 5 +++--
 kernel/memremap.c              | 2 +-
 mm/hmm.c                       | 4 ++--
 mm/memory_hotplug.c            | 8 ++------
 10 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 2e2e4f532204..6a8ce9e1536e 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -663,7 +663,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -671,7 +671,7 @@ int arch_remove_memory(u64 start, u64 size)
 	int ret;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages);
+	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
 	if (ret)
 		pr_warn("%s: Problem encountered in __remove_pages() as"
 			" ret=%d\n", __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index e670cfc2766e..22aa528b78a2 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -149,11 +149,10 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct vmem_altmap *altmap;
 	struct page *page;
 	int ret;
 
@@ -162,11 +161,10 @@ int arch_remove_memory(u64 start, u64 size)
 	 * when querying the zone.
 	 */
 	page = pfn_to_page(start_pfn);
-	altmap = to_vmem_altmap((unsigned long) page);
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 
-	ret = __remove_pages(page_zone(page), start_pfn, nr_pages);
+	ret = __remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
 	if (ret)
 		return ret;
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index e12c5af50cd7..3fa3e5323612 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -240,7 +240,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 552afbf55bad..ce0bbaa7e404 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -510,7 +510,7 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -518,7 +518,7 @@ int arch_remove_memory(u64 start, u64 size)
 	int ret;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages);
+	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
 	if (unlikely(ret))
 		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
 			ret);
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 8a3091511a71..79cb066f40c0 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -839,14 +839,14 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	return __remove_pages(zone, start_pfn, nr_pages);
+	return __remove_pages(zone, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 594902ef56ef..3c046618cc7e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1132,21 +1132,19 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size)
+int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
-	struct vmem_altmap *altmap;
 	struct zone *zone;
 	int ret;
 
 	/* With altmap the first mapped page is offset from @start */
-	altmap = to_vmem_altmap((unsigned long) page);
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 	zone = page_zone(page);
-	ret = __remove_pages(zone, start_pfn, nr_pages);
+	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
 	WARN_ON_ONCE(ret);
 	kernel_physical_mapping_remove(start, start + size);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index cbdd6d52e877..e71927d0d46b 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -126,9 +126,10 @@ static inline bool movable_node_is_enabled(void)
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
-extern int arch_remove_memory(u64 start, u64 size);
+extern int arch_remove_memory(u64 start, u64 size,
+		struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages);
+	unsigned long nr_pages, struct vmem_altmap *altmap);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages */
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 8488cdeead16..380fca1c4a02 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -304,7 +304,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size);
+	arch_remove_memory(align_start, align_size, pgmap->altmap);
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
diff --git a/mm/hmm.c b/mm/hmm.c
index 231aaacd1997..5d17ba89062f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -838,10 +838,10 @@ static void hmm_devmem_release(struct device *dev, void *data)
 
 	mem_hotplug_begin();
 	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
-		__remove_pages(zone, start_pfn, npages);
+		__remove_pages(zone, start_pfn, npages, NULL);
 	else
 		arch_remove_memory(start_pfn << PAGE_SHIFT,
-				   npages << PAGE_SHIFT);
+				   npages << PAGE_SHIFT, NULL);
 	mem_hotplug_done();
 
 	hmm_devmem_radix_release(resource);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b36f1822c432..eae6bf47caf7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -569,7 +569,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
  * calling offline_pages().
  */
 int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		 unsigned long nr_pages)
+		 unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long i;
 	unsigned long map_offset = 0;
@@ -577,10 +577,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
 	if (is_dev_zone(zone)) {
-		struct page *page = pfn_to_page(phys_start_pfn);
-		struct vmem_altmap *altmap;
-
-		altmap = to_vmem_altmap((unsigned long) page);
 		if (altmap)
 			map_offset = vmem_altmap_offset(altmap);
 	} else {
@@ -1890,7 +1886,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(start, size);
+	arch_remove_memory(start, size, NULL);
 
 	try_offline_node(nid);
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
