Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFE26B0542
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:42 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 76so14995621ith.15
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:42 -0700 (PDT)
Received: from mail-it0-f68.google.com (mail-it0-f68.google.com. [209.85.214.68])
        by mx.google.com with ESMTPS id k123si1520913itk.103.2017.08.01.05.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:41 -0700 (PDT)
Received: by mail-it0-f68.google.com with SMTP id t78so1527860ita.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:41 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] mm, memory_hotplug: provide a more generic restrictions for memory hotplug
Date: Tue,  1 Aug 2017 14:41:08 +0200
Message-Id: <20170801124111.28881-4-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>

From: Michal Hocko <mhocko@suse.com>

arch_add_memory, __add_pages take a want_memblock which controls whether
the newly added memory should get the sysfs memblock user API (e.g.
ZONE_DEVICE users do not want/need this interface). Some callers even
want to control where do we allocate the memmap from by configuring
altmap. This is currently done quite ugly by searching for altmap down
in memory hotplug (to_vmem_altmap). It should be the caller to provide
the altmap down the call chain.

Add a more generic hotplug context for arch_add_memory and __add_pages.
struct mhp_restrictions contains flags which contains additional
features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
currently) and altmap for alternative memmap allocator.

Please note that the complete altmap propagation down to vmemmap code
is still not done in this patch. It will be done in the follow up to
reduce the churn here.

This patch shouldn't introduce any functional change.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/init.c            |  5 +++--
 arch/powerpc/mm/mem.c          |  5 +++--
 arch/s390/mm/init.c            |  5 +++--
 arch/sh/mm/init.c              |  5 +++--
 arch/x86/mm/init_32.c          |  5 +++--
 arch/x86/mm/init_64.c          |  5 +++--
 include/linux/memory_hotplug.h | 18 ++++++++++++++++--
 kernel/memremap.c              |  6 +++++-
 mm/memory_hotplug.c            | 14 +++++++++-----
 9 files changed, 48 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index a4e8d6bd9cfa..7fab6a4bdda7 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -646,13 +646,14 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index de5a90e1ceaa..dcbf278c4e5f 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -126,7 +126,8 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -143,7 +144,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 		return -EFAULT;
 	}
 
-	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index f4fb5d191562..e3db0079ebfc 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -162,7 +162,8 @@ unsigned long memory_block_size_bytes(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -172,7 +173,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, restrictions);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index bf726af5f1a5..a603e9be989b 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,14 +485,15 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 8a64a6f2848d..8465555cac90 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -823,12 +823,13 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index cfe01150f24f..da57a9c9c218 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -772,7 +772,8 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -780,7 +781,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 
 	init_memory_mapping(start, start + size);
 
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f64321b35e88..76e5bfde8050 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -129,9 +129,22 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+/*
+ * Do we want sysfs memblock files created. This will allow userspace to online
+ * and offline memory explicitly. Lack of this bit means that the caller has to
+ * call move_pfn_range_to_zone to finish the initialization.
+ */
+#define MHP_MEMBLOCK_API		1<<0
+
+/* Restrictions for the memory hotplug */
+struct mhp_restrictions {
+	unsigned long flags;	/* MHP_ flags */
+	struct vmem_altmap *altmap; /* use this alternative allocatro for memmaps */
+};
+
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn,
-	unsigned long nr_pages, bool want_memblock);
+	unsigned long nr_pages, struct mhp_restrictions *restrictions);
 
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
@@ -306,7 +319,8 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock);
+extern int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 124bed776532..02029a993329 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -286,6 +286,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid, is_ram;
+	struct mhp_restrictions restrictions = {};
 	unsigned long pfn;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -357,8 +358,11 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
+	/* We do not want any optional features only our own memmap */
+	restrictions.altmap = altmap;
+
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, false);
+	error = arch_add_memory(nid, align_start, align_size, &restrictions);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 					align_start >> PAGE_SHIFT,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8031cc41bc5c..d28883aea475 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -286,18 +286,18 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  * add the new pages.
  */
 int __ref __add_pages(int nid, unsigned long phys_start_pfn,
-			unsigned long nr_pages, bool want_memblock)
+			unsigned long nr_pages,
+			struct mhp_restrictions *restrictions)
 {
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
-	struct vmem_altmap *altmap;
+	struct vmem_altmap *altmap = restrictions->altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
-	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -312,7 +312,8 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
+		err = __add_section(nid, section_nr_to_pfn(i),
+				restrictions->flags & MHP_MEMBLOCK_API);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1114,6 +1115,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	bool new_pgdat;
 	bool new_node;
 	int ret;
+	struct mhp_restrictions restrictions = {};
 
 	start = res->start;
 	size = resource_size(res);
@@ -1145,8 +1147,10 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 			goto error;
 	}
 
+	restrictions.flags = MHP_MEMBLOCK_API;
+
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, true);
+	ret = arch_add_memory(nid, start, size, &restrictions);
 
 	if (ret < 0)
 		goto error;
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
