Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3B5C6B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:10:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 3so7942231pfo.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:10:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 8si5177208pfh.285.2017.12.15.06.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:10:17 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/17] mm: pass the vmem_altmap to arch_add_memory and __add_pages
Date: Fri, 15 Dec 2017 15:09:34 +0100
Message-Id: <20171215140947.26075-5-hch@lst.de>
In-Reply-To: <20171215140947.26075-1-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We can just pass this on instead of having to do a radix tree lookup
without proper locking 2 levels into the callchain.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/mm/init.c            |  5 +++--
 arch/powerpc/mm/mem.c          |  5 +++--
 arch/s390/mm/init.c            |  5 +++--
 arch/sh/mm/init.c              |  5 +++--
 arch/x86/mm/init_32.c          |  5 +++--
 arch/x86/mm/init_64.c          | 11 ++++++-----
 include/linux/memory_hotplug.h | 17 ++++++++++-------
 kernel/memremap.c              |  2 +-
 mm/hmm.c                       |  5 +++--
 mm/memory_hotplug.c            |  7 +++----
 10 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 7af4e05bb61e..2e2e4f532204 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -647,13 +647,14 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 4362b86ef84c..e670cfc2766e 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -127,7 +127,8 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -144,7 +145,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 		return -EFAULT;
 	}
 
-	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 671535e64aba..e12c5af50cd7 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -222,7 +222,8 @@ device_initcall(s390_cma_mem_init);
 
 #endif /* CONFIG_CMA */
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -232,7 +233,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index afc54d593a26..552afbf55bad 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,14 +485,15 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 8a64a6f2848d..cdf19ec6460c 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -823,12 +823,13 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8acdc35c2dfa..e26ade50ae18 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -772,12 +772,12 @@ static void update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int add_pages(int nid, unsigned long start_pfn,
-	      unsigned long nr_pages, bool want_memblock)
+int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
+		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, NULL, want_memblock);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
@@ -787,14 +787,15 @@ int add_pages(int nid, unsigned long start_pfn,
 	return ret;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
 	init_memory_mapping(start, start + size);
 
-	return add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 }
 
 #define PAGE_INUSE 0xFD
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 58e110aee7ab..db276afbefcc 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -13,6 +13,7 @@ struct pglist_data;
 struct mem_section;
 struct memory_block;
 struct resource;
+struct vmem_altmap;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
@@ -131,18 +132,19 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages */
-extern int __add_pages(int nid, unsigned long start_pfn,
-	unsigned long nr_pages, bool want_memblock);
+extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
+		struct vmem_altmap *altmap, bool want_memblock);
 
 #ifndef CONFIG_ARCH_HAS_ADD_PAGES
 static inline int add_pages(int nid, unsigned long start_pfn,
-			    unsigned long nr_pages, bool want_memblock)
+		unsigned long nr_pages, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
-	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 }
 #else /* ARCH_HAS_ADD_PAGES */
-int add_pages(int nid, unsigned long start_pfn,
-	      unsigned long nr_pages, bool want_memblock);
+int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
+		struct vmem_altmap *altmap, bool want_memblock);
 #endif /* ARCH_HAS_ADD_PAGES */
 
 #ifdef CONFIG_NUMA
@@ -318,7 +320,8 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock);
+extern int arch_add_memory(int nid, u64 start, u64 size,
+		struct vmem_altmap *altmap, bool want_memblock);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 403ab9cdb949..16456117a1b1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -427,7 +427,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, false);
+	error = arch_add_memory(nid, align_start, align_size, altmap, false);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 					align_start >> PAGE_SHIFT,
diff --git a/mm/hmm.c b/mm/hmm.c
index 3a5c172af560..cff2aa6910af 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -931,10 +931,11 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	 * want the linear mapping and thus use arch_add_memory().
 	 */
 	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
-		ret = arch_add_memory(nid, align_start, align_size, false);
+		ret = arch_add_memory(nid, align_start, align_size, NULL,
+				false);
 	else
 		ret = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, false);
+				align_size >> PAGE_SHIFT, NULL, false);
 	if (ret) {
 		mem_hotplug_done();
 		goto error_add_memory;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5c6f96e6b334..fc0485dcece1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -292,18 +292,17 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  * add the new pages.
  */
 int __ref __add_pages(int nid, unsigned long phys_start_pfn,
-			unsigned long nr_pages, bool want_memblock)
+		unsigned long nr_pages, struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
-	struct vmem_altmap *altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
-	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -1148,7 +1147,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, true);
+	ret = arch_add_memory(nid, start, size, NULL, true);
 
 	if (ret < 0)
 		goto error;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
