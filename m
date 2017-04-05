Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBEDD6B03AC
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:41 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g57so6418229qta.5
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z59si18730208qtc.147.2017.04.05.13.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:41 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 01/16] mm/memory/hotplug: add memory type parameter to arch_add/remove_memory
Date: Wed,  5 Apr 2017 16:40:11 -0400
Message-Id: <20170405204026.3940-2-jglisse@redhat.com>
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

When hotpluging memory we want more information on the type of memory.
This is to extend ZONE_DEVICE to support new type of memory other than
the persistent memory. Existing user of ZONE_DEVICE (persistent memory)
will be left un-modified.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/ia64/mm/init.c            | 36 +++++++++++++++++++++++++++++++++---
 arch/powerpc/mm/mem.c          | 37 ++++++++++++++++++++++++++++++++++---
 arch/s390/mm/init.c            | 16 ++++++++++++++--
 arch/sh/mm/init.c              | 35 +++++++++++++++++++++++++++++++++--
 arch/x86/mm/init_32.c          | 41 +++++++++++++++++++++++++++++++++++++----
 arch/x86/mm/init_64.c          | 39 +++++++++++++++++++++++++++++++++++----
 include/linux/memory_hotplug.h | 24 ++++++++++++++++++++++--
 include/linux/memremap.h       |  2 ++
 kernel/memremap.c              |  5 +++--
 mm/memory_hotplug.c            |  4 ++--
 10 files changed, 215 insertions(+), 24 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 06cdaef..c910b3f 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -645,20 +645,36 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	pg_data_t *pgdat;
 	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	bool for_device = false;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	case MEMORY_DEVICE_PERSISTENT:
+		for_device = true;
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	pgdat = NODE_DATA(nid);
 
 	zone = pgdat->node_zones +
 		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
-
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
@@ -667,13 +683,27 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+	case MEMORY_DEVICE_PERSISTENT:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (ret)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5f84433..0933261 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -126,14 +126,31 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	struct pglist_data *pgdata;
-	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	bool for_device = false;
+	struct zone *zone;
 	int rc;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	case MEMORY_DEVICE_PERSISTENT:
+		for_device = true;
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	pgdata = NODE_DATA(nid);
 
 	start = (unsigned long)__va(start);
@@ -153,13 +170,27 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+	case MEMORY_DEVICE_PERSISTENT:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (ret)
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index bf5b8a0..20d7714 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -153,7 +153,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	unsigned long zone_start_pfn, zone_end_pfn, nr_pages;
 	unsigned long start_pfn = PFN_DOWN(start);
@@ -162,6 +162,18 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 	struct zone *zone;
 	int rc, i;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
@@ -205,7 +217,7 @@ unsigned long memory_block_size_bytes(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 7549186..f37e7a6 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,13 +485,30 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	pg_data_t *pgdat;
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	bool for_device = false;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	case MEMORY_DEVICE_PERSISTENT:
+		for_device = true;
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	pgdat = NODE_DATA(nid);
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
@@ -516,13 +533,27 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+	case MEMORY_DEVICE_PERSISTENT:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (unlikely(ret))
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index c68078f..811d631 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -826,24 +826,57 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	struct pglist_data *pgdata = NODE_DATA(nid);
-	struct zone *zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	bool for_device = false;
+	struct zone *zone;
+
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	case MEMORY_DEVICE_PERSISTENT:
+		for_device = true;
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
+	zone = pgdata->node_zones +
+		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
+	 * is not supported on this architecture.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+	case MEMORY_DEVICE_PERSISTENT:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	return __remove_pages(zone, start_pfn, nr_pages);
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7eef172..6c0b24e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -641,15 +641,33 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
  */
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	bool for_device = false;
+	struct zone *zone;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+		break;
+	case MEMORY_DEVICE_PERSISTENT:
+		for_device = true;
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
+	zone = pgdat->node_zones +
+		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
+
 	init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
@@ -946,7 +964,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size)
+int __ref arch_remove_memory(u64 start, u64 size, enum memory_type type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -955,6 +973,19 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	struct zone *zone;
 	int ret;
 
+	/*
+	 * Each memory_type needs special handling, so error out on an
+	 * unsupported type.
+	 */
+	switch (type) {
+	case MEMORY_NORMAL:
+	case MEMORY_DEVICE_PERSISTENT:
+		break;
+	default:
+		pr_err("hotplug unsupported memory type %d\n", type);
+		return -EINVAL;
+	}
+
 	/* With altmap the first mapped page is offset from @start */
 	altmap = to_vmem_altmap((unsigned long) page);
 	if (altmap)
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 134a2f6..c3999f2 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -13,6 +13,26 @@ struct mem_section;
 struct memory_block;
 struct resource;
 
+/*
+ * When hotplugging memory with arch_add_memory(), we want more information on
+ * the type of memory we are hotplugging, because depending on the type of
+ * architecture, the code might want to take different paths.
+ *
+ * MEMORY_NORMAL:
+ * Your regular system memory. Default common case.
+ *
+ * MEMORY_DEVICE_PERSISTENT:
+ * Persistent device memory (pmem): struct page might be allocated in different
+ * memory and architecture might want to perform special actions. It is similar
+ * to regular memory, in that the CPU can access it transparently. However,
+ * it is likely to have different bandwidth and latency than regular memory.
+ * See Documentation/nvdimm/nvdimm.txt for more information.
+ */
+enum memory_type {
+	MEMORY_NORMAL = 0,
+	MEMORY_DEVICE_PERSISTENT,
+};
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 /*
@@ -104,7 +124,7 @@ extern bool memhp_auto_online;
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
-extern int arch_remove_memory(u64 start, u64 size);
+extern int arch_remove_memory(u64 start, u64 size, enum memory_type type);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -276,7 +296,7 @@ extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
+extern int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 9341619..1f720f7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -41,12 +41,14 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
+ * @type: memory type see MEMORY_* in memory_hotplug.h
  */
 struct dev_pagemap {
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
+	enum memory_type type;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07e85e5..6b4505d 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -248,7 +248,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size);
+	arch_remove_memory(align_start, align_size, pgmap->type);
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
@@ -326,6 +326,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
+	pgmap->type = MEMORY_DEVICE_PERSISTENT;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
@@ -363,7 +364,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, align_start, align_size, pgmap->type);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a07a07c..d1a4326 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1384,7 +1384,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, false);
+	ret = arch_add_memory(nid, start, size, MEMORY_NORMAL);
 
 	if (ret < 0)
 		goto error;
@@ -2188,7 +2188,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(start, size);
+	arch_remove_memory(start, size, MEMORY_NORMAL);
 
 	try_offline_node(nid);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
