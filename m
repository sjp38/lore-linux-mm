Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 524686B0398
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:11 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f191so41432767qka.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x13si4090552qtc.249.2017.03.16.08.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:51 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 01/16] mm/memory/hotplug: convert device bool to int to allow for more flags v3
Date: Thu, 16 Mar 2017 12:05:20 -0400
Message-Id: <1489680335-6594-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

When hotpluging memory we want more informations on the type of memory and
its properties. Replace the device boolean flag by an int and define a set
of flags.

New property for device memory is an opt-in flag to allow page migration
from and to a ZONE_DEVICE. Existing user of ZONE_DEVICE are not expecting
page migration to work for their pages. New changes to page migration i
changing that and we now need a flag to explicitly opt-in page migration.

Changes since v2:
  - pr_err() in case of hotplug failure

Changes since v1:
  - Improved commit message
  - Improved define name
  - Improved comments
  - Typos

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
 arch/ia64/mm/init.c            | 23 ++++++++++++++++++++---
 arch/powerpc/mm/mem.c          | 23 +++++++++++++++++++----
 arch/s390/mm/init.c            | 10 ++++++++--
 arch/sh/mm/init.c              | 22 +++++++++++++++++++---
 arch/tile/mm/init.c            | 10 ++++++++--
 arch/x86/mm/init_32.c          | 23 ++++++++++++++++++++---
 arch/x86/mm/init_64.c          | 23 ++++++++++++++++++++---
 include/linux/memory_hotplug.h | 24 ++++++++++++++++++++++--
 include/linux/memremap.h       | 13 +++++++++++++
 kernel/memremap.c              |  5 +++--
 mm/memory_hotplug.c            |  4 ++--
 11 files changed, 154 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 8f3efa6..1dbe5a5 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -646,18 +646,27 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	pg_data_t *pgdat;
 	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	pgdat = NODE_DATA(nid);
 
 	zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
+		zone_for_memory(nid, start, size, ZONE_NORMAL,
+				flags & MEMORY_DEVICE);
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 
 	if (ret)
@@ -668,13 +677,21 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotremove unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (ret)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 9ee536e..4669c056 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -126,16 +126,23 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	struct pglist_data *pgdata;
 	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int rc;
 
-	resize_hpt_for_hotplug(memblock_phys_mem_size());
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
 
+	resize_hpt_for_hotplug(memblock_phys_mem_size());
 	pgdata = NODE_DATA(nid);
 
 	start = (unsigned long)__va(start);
@@ -149,19 +156,27 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 
 	/* this should work for most non-highmem platforms */
 	zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, 0, for_device);
+		zone_for_memory(nid, start, size, 0, flags & MEMORY_DEVICE);
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotremove unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (ret)
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index ee506671..b858303 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -161,7 +161,7 @@ unsigned long memory_block_size_bytes(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
 	unsigned long zone_start_pfn, zone_end_pfn, nr_pages;
 	unsigned long start_pfn = PFN_DOWN(start);
@@ -170,6 +170,12 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 	struct zone *zone;
 	int rc, i;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
@@ -204,7 +210,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 7549186..30a239f 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,19 +485,27 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	pg_data_t *pgdat;
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	pgdat = NODE_DATA(nid);
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
 	ret = __add_pages(nid, pgdat->node_zones +
 			zone_for_memory(nid, start, size, ZONE_NORMAL,
-			for_device),
+					flags & MEMORY_DEVICE),
 			start_pfn, nr_pages);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
@@ -516,13 +524,21 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotremove unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	if (unlikely(ret))
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 3a97e4d..eed98e2 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -863,13 +863,19 @@ void __init mem_init(void)
  * memory to the highmem for now.
  */
 #ifndef CONFIG_NEED_MULTIPLE_NODES
-int arch_add_memory(u64 start, u64 size, bool for_device)
+int arch_add_memory(u64 start, u64 size, int flags)
 {
 	struct pglist_data *pgdata = &contig_page_data;
 	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	return __add_pages(zone, start_pfn, nr_pages);
 }
 
@@ -879,7 +885,7 @@ int remove_memory(u64 start, u64 size)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
 	/* TODO */
 	return -EBUSY;
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 2b4b53e..d7d7f9a 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -816,24 +816,41 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	struct pglist_data *pgdata = NODE_DATA(nid);
 	struct zone *zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
+		zone_for_memory(nid, start, size, ZONE_HIGHMEM,
+				flags & MEMORY_DEVICE);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
+int arch_remove_memory(u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotremove unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	zone = page_zone(pfn_to_page(start_pfn));
 	return __remove_pages(zone, start_pfn, nr_pages);
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 15173d3..0098dc9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -641,15 +641,24 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
  */
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
+		zone_for_memory(nid, start, size, ZONE_NORMAL,
+				flags & MEMORY_DEVICE);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotplug unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
@@ -946,8 +955,10 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size)
+int __ref arch_remove_memory(u64 start, u64 size, int flags)
 {
+	const int supported_flags = MEMORY_DEVICE |
+				    MEMORY_DEVICE_ALLOW_MIGRATE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
@@ -955,6 +966,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	struct zone *zone;
 	int ret;
 
+	/* Each flag need special handling so error out on un-supported flag */
+	if (flags & (~supported_flags)) {
+		pr_err("hotremove unsupported memory type 0x%08x\n", flags);
+		return -EINVAL;
+	}
+
 	/* With altmap the first mapped page is offset from @start */
 	altmap = to_vmem_altmap((unsigned long) page);
 	if (altmap)
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 134a2f6..30253da 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -104,7 +104,7 @@ extern bool memhp_auto_online;
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
-extern int arch_remove_memory(u64 start, u64 size);
+extern int arch_remove_memory(u64 start, u64 size, int flags);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -276,7 +276,27 @@ extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
+
+/*
+ * When hotpluging memory with arch_add_memory() we want more informations on
+ * the type of memory and its properties. The flags parameter allow to provide
+ * more informations on the memory which is being addedd.
+ *
+ * Provide an opt-in flag for struct page migration. Persistent device memory
+ * never relied on struct page migration so far and new user of might also
+ * prefer avoiding struct page migration.
+ *
+ * New non device memory specific flags can be added if ever needed.
+ *
+ * MEMORY_REGULAR: regular system memory
+ * DEVICE_MEMORY: device memory create a ZONE_DEVICE zone for it
+ * DEVICE_MEMORY_ALLOW_MIGRATE: page in that device memory ca be migrated
+ */
+#define MEMORY_NORMAL 0
+#define MEMORY_DEVICE (1 << 0)
+#define MEMORY_DEVICE_ALLOW_MIGRATE (1 << 1)
+
+extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 9341619..29d2cca 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -41,18 +41,26 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
+ * @flags: memory flags see MEMORY_* in memory_hotplug.h
  */
 struct dev_pagemap {
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
+	int flags;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+
+static inline bool dev_page_allow_migrate(const struct page *page)
+{
+	return ((page_zonenum(page) == ZONE_DEVICE) &&
+		(page->pgmap->flags & MEMORY_DEVICE_ALLOW_MIGRATE));
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -71,6 +79,11 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
 }
+
+static inline bool dev_page_allow_migrate(const struct page *page)
+{
+	return false;
+}
 #endif
 
 /**
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 0612323..40d4af8 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -249,7 +249,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 
 	lock_device_hotplug();
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size);
+	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
 	mem_hotplug_done();
 	unlock_device_hotplug();
 
@@ -328,6 +328,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
+	pgmap->flags = MEMORY_DEVICE;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
@@ -366,7 +367,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	lock_device_hotplug();
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
 	mem_hotplug_done();
 	unlock_device_hotplug();
 	if (error)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 295479b..46960b3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1381,7 +1381,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, false);
+	ret = arch_add_memory(nid, start, size, MEMORY_NORMAL);
 
 	if (ret < 0)
 		goto error;
@@ -2185,7 +2185,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(start, size);
+	arch_remove_memory(start, size, MEMORY_NORMAL);
 
 	try_offline_node(nid);
 
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
