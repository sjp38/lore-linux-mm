Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D28B6B052F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:19:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k68so8694000wmd.14
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:19:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15si12660927wma.204.2017.07.28.05.19.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 05:19:44 -0700 (PDT)
Date: Fri, 28 Jul 2017 14:19:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20170728121941.GL2274@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726210657.GE21717@redhat.com>
 <20170727065652.GE20970@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727065652.GE20970@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Thu 27-07-17 08:56:52, Michal Hocko wrote:
> On Wed 26-07-17 17:06:59, Jerome Glisse wrote:
> [...]
> > This does not seems to be an opt-in change ie if i am reading patch 3
> > correctly if an altmap is not provided to __add_pages() you fallback
> > to allocating from begining of zone. This will not work with HMM ie
> > device private memory. So at very least i would like to see some way
> > to opt-out of this. Maybe a new argument like bool forbid_altmap ?
> 
> OK, I see! I will think about how to make a sane api for that.

This is what I came up with. s390 guys mentioned that I cannot simply
use the new range at this stage yet. This will need probably some other
changes but I guess we want an opt-in approach with an arch veto in general.

So what do you think about the following? Only x86 is update now and I
will split it into two parts but the idea should be clear at least.
---
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e4f749e5652f..a4a29af28bcf 100644
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
@@ -780,7 +781,9 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 
 	init_memory_mapping(start, start + size);
 
-	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+	/* newly hotadded memory range is ready to be used for the memmap */
+	restrictions->flags |= MHP_RANGE_ACCESSIBLE;
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f2636ad2d00f..928d93e2a555 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -129,9 +129,29 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+/*
+ * Do we want sysfs memblock files created. This will allow userspace to online
+ * and offline memory explicitly. Lack of this bit means that the caller has to
+ * call move_pfn_range_to_zone to finish the initialization.
+ */
+#define MHP_MEMBLOCK_API		1<<0
+
+/*
+ * Is the hotadded memory accessible directly or it needs a special handling.
+ * We will try to allocate the memmap for the range from within the added memory
+ * if the bit is set.
+ */
+#define MHP_RANGE_ACCESSIBLE		1<<1
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
@@ -306,7 +326,8 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
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
index a72eb5932d2f..cf0998cfcb13 100644
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
+	restrictions.altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
+
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, false);
+	error = arch_add_memory(nid, align_start, align_size, &restrictions);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 					align_start >> PAGE_SHIFT,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 19037d0191e5..9d11c3b5b448 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -287,12 +287,13 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
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
 	struct vmem_altmap __section_altmap = {.base_pfn = phys_start_pfn};
 
 	/* during initialize mem_map, align hot-added range to section */
@@ -301,10 +302,9 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 
 	/*
 	 * Check device specific altmap and fallback to allocating from the
-	 * begining of the section otherwise
+	 * begining of the added range otherwise
 	 */
-	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
-	if (!altmap) {
+	if (!altmap && restrictions->flags & MHP_RANGE_ACCESSIBLE) {
 		__section_altmap.free = nr_pages;
 		__section_altmap.flush_alloc_pfns = mark_vmemmap_pages;
 		altmap = &__section_altmap;
@@ -324,7 +324,9 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), want_memblock, altmap);
+		err = __add_section(nid, section_nr_to_pfn(i),
+				restrictions->flags & MHP_MEMBLOCK_API,
+				altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1160,6 +1162,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	bool new_pgdat;
 	bool new_node;
 	int ret;
+	struct mhp_restrictions restrictions = {};
 
 	start = res->start;
 	size = resource_size(res);
@@ -1191,8 +1194,10 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
