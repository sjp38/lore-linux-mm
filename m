Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 545CD6B0010
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:59:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v10-v6so4270729pfm.11
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:59:13 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e9-v6si4984448pgn.576.2018.07.04.23.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:59:11 -0700 (PDT)
Subject: [PATCH 02/13] mm: Enable asynchronous __add_pages() and
 vmemmap_populate_hugepages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:49:12 -0700
Message-ID: <153077335235.40830.14632656289865731741.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, vishal.l.verma@intel.com, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for allowing all ZONE_DEVICE page init to happen in the
background, enable multiple vmemmap_populate_hugepages() invocations to
run in parallel.

To date the big memory-hotplug lock has been used to serialize changes
to the linear map and vmemmap. Finer grained locking is needed to
prevent 2 parallel invocations of vmemmap_populate_hugepages()
colliding.

Given that populating vmemmap has architecture specific implications
this new asynchronous support is only added for the x86_64
arch_add_memory(), all other implementations indicate no support for
async operations by returning -EWOULDBLOCK.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: <x86@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/mm/init.c            |    5 ++-
 arch/powerpc/mm/mem.c          |    5 ++-
 arch/s390/mm/init.c            |    8 +++--
 arch/sh/mm/init.c              |    5 ++-
 arch/x86/mm/init_32.c          |    8 +++--
 arch/x86/mm/init_64.c          |   27 ++++++++++------
 drivers/nvdimm/pfn_devs.c      |    1 +
 include/linux/memmap_async.h   |   28 ++++++++++++++++
 include/linux/memory_hotplug.h |   15 ++++++---
 include/linux/memremap.h       |    2 +
 include/linux/mm.h             |    6 ++-
 kernel/memremap.c              |    4 +-
 mm/memory_hotplug.c            |   69 ++++++++++++++++++++++++++++++----------
 mm/page_alloc.c                |    3 ++
 mm/sparse-vmemmap.c            |   56 +++++++++++++++++++++++++-------
 15 files changed, 184 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/memmap_async.h

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 18278b448530..d331488dd76f 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -649,12 +649,15 @@ mem_init (void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	if (async)
+		return -EWOULDBLOCK;
+
 	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5c8530d0c611..3205a361e37a 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -118,12 +118,15 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 }
 
 int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int rc;
 
+	if (async)
+		return -EWOULDBLOCK;
+
 	resize_hpt_for_hotplug(memblock_phys_mem_size());
 
 	start = (unsigned long)__va(start);
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 3fa3e5323612..ee87085a3a58 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -223,17 +223,21 @@ device_initcall(s390_cma_mem_init);
 #endif /* CONFIG_CMA */
 
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	if (async)
+		return -EWOULDBLOCK;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock,
+			async);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 4034035fbede..534303de3ec2 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -430,12 +430,15 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	if (async)
+		return -EWOULDBLOCK;
+
 	/* We only have ZONE_NORMAL, so this is easy.. */
 	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
 	if (unlikely(ret))
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 979e0a02cbe1..1be538746010 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -852,12 +852,16 @@ void __init mem_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	if (async)
+		return -EWOULDBLOCK;
+
+	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock,
+			async);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a688617c727e..40bd9ba052fe 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -784,11 +784,13 @@ static void update_end_of_memory_vars(u64 start, u64 size)
 }
 
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock)
+		struct vmem_altmap *altmap, bool want_memblock,
+		struct memmap_async_state *async)
 {
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock,
+			async);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
@@ -799,14 +801,15 @@ int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 }
 
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
 	init_memory_mapping(start, start + size);
 
-	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock,
+			async);
 }
 
 #define PAGE_INUSE 0xFD
@@ -1412,26 +1415,30 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 {
 	unsigned long addr;
 	unsigned long next;
-	pgd_t *pgd;
-	p4d_t *p4d;
-	pud_t *pud;
+	pgd_t *pgd = NULL;
+	p4d_t *p4d = NULL;
+	pud_t *pud = NULL;
 	pmd_t *pmd;
 
 	for (addr = start; addr < end; addr = next) {
 		next = pmd_addr_end(addr, end);
 
-		pgd = vmemmap_pgd_populate(addr, node);
+		pgd = vmemmap_pgd_populate(addr, node, pgd);
 		if (!pgd)
 			return -ENOMEM;
 
-		p4d = vmemmap_p4d_populate(pgd, addr, node);
+		p4d = vmemmap_p4d_populate(pgd, addr, node, p4d);
 		if (!p4d)
 			return -ENOMEM;
 
-		pud = vmemmap_pud_populate(p4d, addr, node);
+		pud = vmemmap_pud_populate(p4d, addr, node, pud);
 		if (!pud)
 			return -ENOMEM;
 
+		/*
+		 * No lock required here as sections do not collide
+		 * below the pud level.
+		 */
 		pmd = pmd_offset(pud, addr);
 		if (pmd_none(*pmd)) {
 			void *p;
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 3f7ad5bc443e..147c62e2ef2b 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -577,6 +577,7 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 		memcpy(altmap, &__altmap, sizeof(*altmap));
 		altmap->free = PHYS_PFN(offset - SZ_8K);
 		altmap->alloc = 0;
+		spin_lock_init(&altmap->lock);
 		pgmap->altmap_valid = true;
 	} else
 		return -ENXIO;
diff --git a/include/linux/memmap_async.h b/include/linux/memmap_async.h
new file mode 100644
index 000000000000..11aa9f3a523e
--- /dev/null
+++ b/include/linux/memmap_async.h
@@ -0,0 +1,28 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __LINUX_MEMMAP_ASYNC_H
+#define __LINUX_MEMMAP_ASYNC_H
+#include <linux/async.h>
+
+struct vmem_altmap;
+
+struct memmap_init_env {
+	struct vmem_altmap *altmap;
+	bool want_memblock;
+	int nid;
+};
+
+struct memmap_init_memmap {
+	struct memmap_init_env *env;
+	async_cookie_t cookie;
+	int start_sec;
+	int end_sec;
+	int result;
+};
+
+struct memmap_async_state {
+	struct memmap_init_env env;
+	struct memmap_init_memmap memmap;
+};
+
+extern struct async_domain memmap_init_domain;
+#endif /* __LINUX_MEMMAP_ASYNC_H */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e60085b2824d..7565b2675863 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -15,6 +15,7 @@ struct memory_block;
 struct resource;
 struct vmem_altmap;
 struct dev_pagemap;
+struct memmap_async_state;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
@@ -116,18 +117,21 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+		struct vmem_altmap *altmap, bool want_memblock,
+		struct memmap_async_state *async);
 
 #ifndef CONFIG_ARCH_HAS_ADD_PAGES
 static inline int add_pages(int nid, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock,
+			async);
 }
 #else /* ARCH_HAS_ADD_PAGES */
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+		struct vmem_altmap *altmap, bool want_memblock,
+		struct memmap_async_state *async);
 #endif /* ARCH_HAS_ADD_PAGES */
 
 #ifdef CONFIG_NUMA
@@ -325,7 +329,8 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int arch_add_memory(int nid, u64 start, u64 size,
-		struct vmem_altmap *altmap, bool want_memblock);
+		struct vmem_altmap *altmap, bool want_memblock,
+		struct memmap_async_state *async);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct dev_pagemap *pgmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 71f5e7c7dfb9..bfdc7363b13b 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -16,6 +16,7 @@ struct device;
  * @free: free pages set aside in the mapping for memmap storage
  * @align: pages reserved to meet allocation alignments
  * @alloc: track pages consumed, private to vmemmap_populate()
+ * @lock: enable parallel allocations
  */
 struct vmem_altmap {
 	const unsigned long base_pfn;
@@ -23,6 +24,7 @@ struct vmem_altmap {
 	unsigned long free;
 	unsigned long align;
 	unsigned long alloc;
+	spinlock_t lock;
 };
 
 /*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 319d01372efa..0fac83ff21c5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2654,9 +2654,9 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap);
-pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
-p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
-pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
+pgd_t *vmemmap_pgd_populate(unsigned long addr, int node, pgd_t *);
+p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node, p4d_t *);
+pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node, pud_t *);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 58327259420d..b861fe909932 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -235,12 +235,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 	 */
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
 		error = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
+				align_size >> PAGE_SHIFT, NULL, false, NULL);
 	} else {
 		struct zone *zone;
 
 		error = arch_add_memory(nid, align_start, align_size, altmap,
-				false);
+				false, NULL);
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		if (!error)
 			move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index aae4e6cc65e9..18f8e2c49089 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -34,6 +34,8 @@
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
 #include <linux/bootmem.h>
+#include <linux/memmap_async.h>
+#include <linux/async.h>
 #include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
@@ -264,6 +266,32 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
 }
 
+static void __ref section_init_async(void *data, async_cookie_t cookie)
+{
+	unsigned long i;
+	struct memmap_init_memmap *args = data;
+	struct memmap_init_env *env = args->env;
+	int start_sec = args->start_sec, end_sec = args->end_sec, err;
+
+	args->result = 0;
+	for (i = start_sec; i <= end_sec; i++) {
+		err = __add_section(env->nid, section_nr_to_pfn(i), env->altmap,
+				env->want_memblock);
+
+		/*
+		 * EEXIST is finally dealt with by ioresource collision
+		 * check. see add_memory() => register_memory_resource()
+		 * Warning will be printed if there is collision.
+		 */
+		if (err && (err != -EEXIST)) {
+			args->result = err;
+			break;
+		}
+		args->result = 0;
+		cond_resched();
+	}
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -272,11 +300,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  */
 int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		bool want_memblock, struct memmap_async_state *async)
 {
-	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
+	struct memmap_init_env _env, *env;
+	struct memmap_init_memmap _args, *args;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
@@ -289,28 +318,32 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		if (altmap->base_pfn != phys_start_pfn
 				|| vmem_altmap_offset(altmap) > nr_pages) {
 			pr_warn_once("memory add fail, invalid altmap\n");
-			err = -EINVAL;
-			goto out;
+			return -EINVAL;
 		}
 		altmap->alloc = 0;
 	}
 
-	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				want_memblock);
+	env = async ? &async->env : &_env;
+	args = async ? &async->memmap : &_args;
 
-		/*
-		 * EEXIST is finally dealt with by ioresource collision
-		 * check. see add_memory() => register_memory_resource()
-		 * Warning will be printed if there is collision.
-		 */
-		if (err && (err != -EEXIST))
-			break;
-		err = 0;
-		cond_resched();
+	env->nid = nid;
+	env->altmap = altmap;
+	env->want_memblock = want_memblock;
+
+	args->env = env;
+	args->end_sec = end_sec;
+	args->start_sec = start_sec;
+
+	if (async)
+		args->cookie = async_schedule_domain(section_init_async, args,
+				&memmap_init_domain);
+	else {
+		/* call the 'async' routine synchronously */
+		section_init_async(args, 0);
+		err = args->result;
 	}
+
 	vmemmap_populate_print_last();
-out:
 	return err;
 }
 
@@ -1135,7 +1168,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, NULL, true);
+	ret = arch_add_memory(nid, start, size, NULL, true, NULL);
 
 	if (ret < 0)
 		goto error;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 545a5860cce7..f83682ef006e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
+#include <linux/async.h>
 #include <linux/nmi.h>
 
 #include <asm/sections.h>
@@ -5452,6 +5453,8 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 #endif
 }
 
+ASYNC_DOMAIN_EXCLUSIVE(memmap_init_domain);
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index bd0276d5f66b..9cdd82fb595d 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -93,6 +93,7 @@ void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 
 static unsigned long __meminit vmem_altmap_next_pfn(struct vmem_altmap *altmap)
 {
+	lockdep_assert_held(&altmap->lock);
 	return altmap->base_pfn + altmap->reserve + altmap->alloc
 		+ altmap->align;
 }
@@ -101,6 +102,7 @@ static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
 {
 	unsigned long allocated = altmap->alloc + altmap->align;
 
+	lockdep_assert_held(&altmap->lock);
 	if (altmap->free > allocated)
 		return altmap->free - allocated;
 	return 0;
@@ -124,16 +126,20 @@ void * __meminit altmap_alloc_block_buf(unsigned long size,
 		return NULL;
 	}
 
+	spin_lock(&altmap->lock);
 	pfn = vmem_altmap_next_pfn(altmap);
 	nr_pfns = size >> PAGE_SHIFT;
 	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
 	nr_align = ALIGN(pfn, nr_align) - pfn;
-	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
+	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap)) {
+		spin_unlock(&altmap->lock);
 		return NULL;
+	}
 
 	altmap->alloc += nr_pfns;
 	altmap->align += nr_align;
 	pfn += nr_align;
+	spin_unlock(&altmap->lock);
 
 	pr_debug("%s: pfn: %#lx alloc: %ld align: %ld nr: %#lx\n",
 			__func__, pfn, altmap->alloc, altmap->align, nr_pfns);
@@ -188,39 +194,63 @@ pmd_t * __meminit vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node)
 	return pmd;
 }
 
-pud_t * __meminit vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node)
+static DEFINE_MUTEX(vmemmap_pgd_lock);
+static DEFINE_MUTEX(vmemmap_p4d_lock);
+static DEFINE_MUTEX(vmemmap_pud_lock);
+
+pud_t * __meminit vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node,
+		pud_t *pud)
 {
-	pud_t *pud = pud_offset(p4d, addr);
+	pud_t *new = pud_offset(p4d, addr);
+
+	if (new == pud)
+		return pud;
+	pud = new;
+	mutex_lock(&vmemmap_pud_lock);
 	if (pud_none(*pud)) {
 		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		pud_populate(&init_mm, pud, p);
 	}
+	mutex_unlock(&vmemmap_pud_lock);
 	return pud;
 }
 
-p4d_t * __meminit vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node)
+p4d_t * __meminit vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node,
+		p4d_t * p4d)
 {
-	p4d_t *p4d = p4d_offset(pgd, addr);
+	p4d_t *new = p4d_offset(pgd, addr);
+
+	if (new == p4d)
+		return p4d;
+	p4d = new;
+	mutex_lock(&vmemmap_p4d_lock);
 	if (p4d_none(*p4d)) {
 		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		p4d_populate(&init_mm, p4d, p);
 	}
+	mutex_unlock(&vmemmap_p4d_lock);
 	return p4d;
 }
 
-pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
+pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node, pgd_t *pgd)
 {
-	pgd_t *pgd = pgd_offset_k(addr);
+	pgd_t *new = pgd_offset_k(addr);
+
+	if (new == pgd)
+		return pgd;
+	pgd = new;
+	mutex_lock(&vmemmap_pgd_lock);
 	if (pgd_none(*pgd)) {
 		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		pgd_populate(&init_mm, pgd, p);
 	}
+	mutex_unlock(&vmemmap_pgd_lock);
 	return pgd;
 }
 
@@ -228,20 +258,20 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 					 unsigned long end, int node)
 {
 	unsigned long addr = start;
-	pgd_t *pgd;
-	p4d_t *p4d;
-	pud_t *pud;
+	pgd_t *pgd = NULL;
+	p4d_t *p4d = NULL;
+	pud_t *pud = NULL;
 	pmd_t *pmd;
 	pte_t *pte;
 
 	for (; addr < end; addr += PAGE_SIZE) {
-		pgd = vmemmap_pgd_populate(addr, node);
+		pgd = vmemmap_pgd_populate(addr, node, pgd);
 		if (!pgd)
 			return -ENOMEM;
-		p4d = vmemmap_p4d_populate(pgd, addr, node);
+		p4d = vmemmap_p4d_populate(pgd, addr, node, p4d);
 		if (!p4d)
 			return -ENOMEM;
-		pud = vmemmap_pud_populate(p4d, addr, node);
+		pud = vmemmap_pud_populate(p4d, addr, node, pud);
 		if (!pud)
 			return -ENOMEM;
 		pmd = vmemmap_pmd_populate(pud, addr, node);
