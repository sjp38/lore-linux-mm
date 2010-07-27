Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF8A1600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 20:41:33 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S349709Ab0G0AlN (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 27 Jul 2010 02:41:13 +0200
Date: Tue, 27 Jul 2010 02:41:13 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - fully working version
Message-ID: <20100727004113.GA3714@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: jeremy@goop.org, gregkh@suse.de, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Currently there is fully working version.
It has been tested on Xen Ver. 4.0.0 in PV
guest i386/x86_64 with Linux kernel Ver. 2.6.32.16
and Ver. 2.6.34.1. This patch cleanly applys
to Ver. 2.6.34.1 (also as attachment because
I received some reports that my patches are
mangled). All found bugs have been removed
(Sorry however I am sure that some hidden
still exists :-((().

This patch enables two modes of operation:
  - enabled by CONFIG_XEN_MEMORY_HOTPLUG config option:
      - set memory limit for chosen domU from dom0:
          xm mem-max <domU> <new_memory_size_limit>
      - add memory in chosen domU: echo <unused_address> > \
          /sys/devices/system/memory/probe; memory is added
        in sections which sizes differ from arch to arch
        (i386: 512 MiB, x86_64: 128 MiB; it could by checked
        by cat /sys/devices/system/memory/block_size_bytes;
        this value is in HEX); it is preffered to choose
        address at section boundary,
      - online memory in chosen domU: echo online > \
          /sys/devices/system/memory/memory<section_number>/state;
        <section_number> could be established in following manner:
        (int)(<unused_address> / <section_size>)
  - enabled by CONFIG_XEN_BALLOON_MEMORY_HOTPLUG config option:
      - set memory limit for chosen domU from dom0:
          xm mem-max <domU> <new_memory_size_limit>
      - add memory for chosen domU from dom0:
          xm mem-set <domU> <new_memory_size>

If you have a questions please drop me a line.

Daniel

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/Kconfig               |    2 +-
 drivers/base/memory.c          |   23 +++++
 drivers/xen/Kconfig            |   10 ++
 drivers/xen/balloon.c          |  196 +++++++++++++++++++++++++++++++++++++++-
 include/linux/memory_hotplug.h |    8 ++
 include/xen/balloon.h          |    6 ++
 mm/Kconfig                     |    9 ++
 mm/memory_hotplug.c            |  140 ++++++++++++++++++++++++++++
 8 files changed, 390 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9458685..38434da 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	depends on ARCH_SPARSEMEM_ENABLE
 
 config ARCH_MEMORY_PROBE
-	def_bool X86_64
+	def_bool y
 	depends on MEMORY_HOTPLUG
 
 config ILLEGAL_POINTER_VALUE
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 933442f..709457b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -27,6 +27,14 @@
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+#include <xen/xen.h>
+#endif
+
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+#include <xen/balloon.h>
+#endif
+
 #define MEMORY_CLASS_NAME	"memory"
 
 static struct sysdev_class memory_sysdev_class = {
@@ -215,6 +223,10 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 		case MEM_ONLINE:
 			start_pfn = page_to_pfn(first_page);
 			ret = online_pages(start_pfn, PAGES_PER_SECTION);
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+			if (xen_domain() && !ret)
+				balloon_update_stats(PAGES_PER_SECTION);
+#endif
 			break;
 		case MEM_OFFLINE:
 			mem->state = MEM_GOING_OFFLINE;
@@ -225,6 +237,10 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 				mem->state = old_state;
 				break;
 			}
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+			if (xen_domain())
+				balloon_update_stats(-PAGES_PER_SECTION);
+#endif
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
@@ -341,6 +357,13 @@ memory_probe_store(struct class *class, struct class_attribute *attr,
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+	if (xen_domain()) {
+		ret = xen_memory_probe(phys_addr);
+		return ret ? ret : count;
+	}
+#endif
+
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index fad3df2..9713048 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -9,6 +9,16 @@ config XEN_BALLOON
 	  the system to expand the domain's memory allocation, or alternatively
 	  return unneeded memory to the system.
 
+config XEN_BALLOON_MEMORY_HOTPLUG
+	bool "Xen memory balloon driver with memory hotplug support"
+	depends on EXPERIMENTAL && XEN_BALLOON && MEMORY_HOTPLUG
+	default n
+	help
+	  Xen memory balloon driver with memory hotplug support allows expanding
+	  memory available for the system above limit declared at system startup.
+	  It is very useful on critical systems which require long run without
+	  rebooting.
+
 config XEN_SCRUB_PAGES
 	bool "Scrub pages before returning them to system"
 	depends on XEN_BALLOON
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 1a0d8c2..f80bba0 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -6,6 +6,7 @@
  * Copyright (c) 2003, B Dragovic
  * Copyright (c) 2003-2004, M Williamson, K Fraser
  * Copyright (c) 2005 Dan M. Smith, IBM Corporation
+ * Copyright (c) 2010 Daniel Kiper
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -61,6 +62,10 @@
 #include <xen/features.h>
 #include <xen/page.h>
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+#include <linux/memory.h>
+#endif
+
 #define PAGES2KB(_p) ((_p)<<(PAGE_SHIFT-10))
 
 #define BALLOON_CLASS_NAME "xen_memory"
@@ -77,6 +82,11 @@ struct balloon_stats {
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	unsigned long boot_max_pfn;
+	u64 hotplug_start_paddr;
+	u64 hotplug_size;
+#endif
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -184,6 +194,12 @@ static void balloon_alarm(unsigned long unused)
 	schedule_work(&balloon_worker);
 }
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static inline unsigned long current_target(void)
+{
+	return balloon_stats.target_pages;
+}
+#else
 static unsigned long current_target(void)
 {
 	unsigned long target = balloon_stats.target_pages;
@@ -195,11 +211,12 @@ static unsigned long current_target(void)
 
 	return target;
 }
+#endif
 
 static int increase_reservation(unsigned long nr_pages)
 {
-	unsigned long  pfn, i, flags;
-	struct page   *page;
+	unsigned long  uninitialized_var(pfn), i, flags;
+	struct page    *uninitialized_var(page);
 	long           rc;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
@@ -207,11 +224,63 @@ static int increase_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	resource_size_t r_min, r_size;
+	struct resource *r;
+#endif
+
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
 	spin_lock_irqsave(&balloon_lock, flags);
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
+		if (!balloon_stats.hotplug_start_paddr) {
+
+			/*
+			 * Look for first unused memory region starting
+			 * at page boundary. Skip last memory section created
+			 * at boot time becuase it may contains unused memory
+			 * pages with PG_reserved bit not set (online_pages
+			 * require PG_reserved bit set).
+			 */
+
+			r = kzalloc(sizeof(struct resource), GFP_KERNEL);
+
+			if (!r) {
+				rc = -ENOMEM;
+				goto out;
+			}
+
+			r->name = "System RAM";
+			r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+			r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
+			r_size = (balloon_stats.target_pages - balloon_stats.current_pages) << PAGE_SHIFT;
+
+			rc = allocate_resource(&iomem_resource, r,
+						r_size, r_min, ULONG_MAX,
+						PAGE_SIZE, NULL, NULL);
+
+			if (rc < 0) {
+				kfree(r);
+				goto out;
+			}
+
+			balloon_stats.hotplug_start_paddr = r->start;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr +
+					balloon_stats.hotplug_size);
+
+		for (i = 0; i < nr_pages; ++i, ++pfn)
+			frame_list[i] = pfn;
+
+		pfn -= nr_pages + 1;
+		goto populate_physmap;
+	}
+#endif
+
 	page = balloon_first_page();
 	for (i = 0; i < nr_pages; i++) {
 		BUG_ON(page == NULL);
@@ -219,6 +288,9 @@ static int increase_reservation(unsigned long nr_pages)
 		page = balloon_next_page(page);
 	}
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+populate_physmap:
+#endif
 	set_xen_guest_handle(reservation.extent_start, frame_list);
 	reservation.nr_extents = nr_pages;
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
@@ -226,17 +298,33 @@ static int increase_reservation(unsigned long nr_pages)
 		goto out;
 
 	for (i = 0; i < rc; i++) {
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+		if (balloon_stats.hotplug_start_paddr) {
+			++pfn;
+			goto set_p2m;
+		}
+#endif
+
 		page = balloon_retrieve();
 		BUG_ON(page == NULL);
 
 		pfn = page_to_pfn(page);
+
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+set_p2m:
+#endif
 		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
 		       phys_to_machine_mapping_valid(pfn));
 
 		set_phys_to_machine(pfn, frame_list[i]);
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+		if (balloon_stats.hotplug_start_paddr)
+			continue;
+#endif
+
 		/* Link back into the page tables if not highmem. */
-		if (pfn < max_low_pfn) {
+		if (!PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
@@ -251,6 +339,11 @@ static int increase_reservation(unsigned long nr_pages)
 		__free_page(page);
 	}
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (balloon_stats.hotplug_start_paddr)
+		balloon_stats.hotplug_size += rc << PAGE_SHIFT;
+#endif
+
 	balloon_stats.current_pages += rc;
 
  out:
@@ -331,6 +424,12 @@ static void balloon_process(struct work_struct *work)
 	int need_sleep = 0;
 	long credit;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	int nid, ret;
+	struct memory_block *mem;
+	unsigned long pfn, pfn_limit;
+#endif
+
 	mutex_lock(&balloon_mutex);
 
 	do {
@@ -349,10 +448,93 @@ static void balloon_process(struct work_struct *work)
 	/* Schedule more work if there is some still to be done. */
 	if (current_target() != balloon_stats.current_pages)
 		mod_timer(&balloon_timer, jiffies + HZ);
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	else if (balloon_stats.hotplug_start_paddr) {
+		nid = memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
+
+		ret = xen_add_memory(nid, balloon_stats.hotplug_start_paddr,
+						balloon_stats.hotplug_size);
+
+		if (ret) {
+			printk(KERN_ERR "%s: xen_add_memory: "
+					"Memory hotplug failed: %i\n",
+					__func__, ret);
+			goto error;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		for (; pfn < pfn_limit; ++pfn)
+			if (!PageHighMem(pfn_to_page(pfn)))
+				BUG_ON(HYPERVISOR_update_va_mapping(
+					(unsigned long)__va(pfn << PAGE_SHIFT),
+					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0));
+
+		ret = online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr),
+					balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		if (ret) {
+			printk(KERN_ERR "%s: online_pages: Failed: %i\n",
+					__func__, ret);
+			goto error;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		for (; pfn < pfn_limit; pfn += PAGES_PER_SECTION) {
+			mem = find_memory_block(__pfn_to_section(pfn));
+			BUG_ON(!mem);
+			BUG_ON(!present_section_nr(mem->phys_index));
+			mutex_lock(&mem->state_mutex);
+			mem->state = MEM_ONLINE;
+			mutex_unlock(&mem->state_mutex);
+		}
+
+		goto out;
+
+error:
+		balloon_stats.current_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+		balloon_stats.target_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+
+out:
+		balloon_stats.hotplug_start_paddr = 0;
+		balloon_stats.hotplug_size = 0;
+	}
+#endif
 
 	mutex_unlock(&balloon_mutex);
 }
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+
+/* Resets the Xen limit, sets new target, and kicks off processing. */
+static void balloon_set_new_target(unsigned long target)
+{
+	mutex_lock(&balloon_mutex);
+	balloon_stats.target_pages = target;
+	mutex_unlock(&balloon_mutex);
+
+	schedule_work(&balloon_worker);
+}
+
+void balloon_update_stats(long nr_pages)
+{
+	mutex_lock(&balloon_mutex);
+
+	balloon_stats.current_pages += nr_pages;
+	balloon_stats.target_pages += nr_pages;
+
+	xenbus_printf(XBT_NIL, "memory", "target", "%llu",
+			(unsigned long long)balloon_stats.target_pages << (PAGE_SHIFT - 10));
+
+	mutex_unlock(&balloon_mutex);
+}
+EXPORT_SYMBOL_GPL(balloon_update_stats);
+
+#else
+
 /* Resets the Xen limit, sets new target, and kicks off processing. */
 static void balloon_set_new_target(unsigned long target)
 {
@@ -361,6 +543,8 @@ static void balloon_set_new_target(unsigned long target)
 	schedule_work(&balloon_worker);
 }
 
+#endif
+
 static struct xenbus_watch target_watch =
 {
 	.node = "memory/target"
@@ -416,6 +600,12 @@ static int __init balloon_init(void)
 	balloon_stats.balloon_high  = 0;
 	balloon_stats.driver_pages  = 0UL;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	balloon_stats.boot_max_pfn = max_pfn;
+	balloon_stats.hotplug_start_paddr = 0;
+	balloon_stats.hotplug_size = 0;
+#endif
+
 	init_timer(&balloon_timer);
 	balloon_timer.data = 0;
 	balloon_timer.function = balloon_alarm;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 35b07b7..04e67b8 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -211,4 +211,12 @@ extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
+extern int xen_add_memory(int nid, u64 start, u64 size);
+#endif
+
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+extern int xen_memory_probe(u64 phys_addr);
+#endif
+
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
new file mode 100644
index 0000000..84b17b7
--- /dev/null
+++ b/include/xen/balloon.h
@@ -0,0 +1,6 @@
+#ifndef _XEN_BALLOON_H
+#define _XEN_BALLOON_H
+
+extern void balloon_update_stats(long nr_pages);
+
+#endif	/* _XEN_BALLOON_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 9c61158..b04f3a8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -144,6 +144,15 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config XEN_MEMORY_HOTPLUG
+	bool "Allow for memory hot-add in Xen guests"
+	depends on EXPERIMENTAL && ARCH_MEMORY_PROBE && XEN
+	default n
+	help
+	  Memory hotplug allows expanding memory available for the system
+	  above limit declared at system startup. It is very useful on critical
+	  systems which require long run without rebooting.
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index be211a5..1c73703 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -32,6 +32,14 @@
 
 #include <asm/tlbflush.h>
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+#include <asm/xen/hypercall.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/memory.h>
+#include <xen/features.h>
+#include <xen/page.h>
+#endif
+
 #include "internal.h"
 
 /* add this memory to iomem resource */
@@ -542,6 +550,138 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
+/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+int __ref xen_add_memory(int nid, u64 start, u64 size)
+{
+	pg_data_t *pgdat = NULL;
+	int new_pgdat = 0, ret;
+
+	lock_system_sleep();
+
+	if (!node_online(nid)) {
+		pgdat = hotadd_new_pgdat(nid, start);
+		ret = -ENOMEM;
+		if (!pgdat)
+			goto out;
+		new_pgdat = 1;
+	}
+
+	/* call arch's memory hotadd */
+	ret = arch_add_memory(nid, start, size);
+
+	if (ret < 0)
+		goto error;
+
+	/* we online node here. we can't roll back from here. */
+	node_set_online(nid);
+
+	if (new_pgdat) {
+		ret = register_one_node(nid);
+		/*
+		 * If sysfs file of new node can't create, cpu on the node
+		 * can't be hot-added. There is no rollback way now.
+		 * So, check by BUG_ON() to catch it reluctantly..
+		 */
+		BUG_ON(ret);
+	}
+
+	goto out;
+
+error:
+	/* rollback pgdat allocation */
+	if (new_pgdat)
+		rollback_node_hotadd(nid, pgdat);
+
+out:
+	unlock_system_sleep();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xen_add_memory);
+#endif
+
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+int xen_memory_probe(u64 phys_addr)
+{
+	int nr_pages, ret;
+	struct resource *r;
+	struct xen_memory_reservation reservation = {
+		.address_bits = 0,
+		.extent_order = 0,
+		.domid = DOMID_SELF,
+		.nr_extents = PAGES_PER_SECTION
+	};
+	unsigned long *frame_list, i, pfn;
+
+	r = register_memory_resource(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+
+	if (!r)
+		return -EEXIST;
+
+	frame_list = vmalloc(PAGES_PER_SECTION * sizeof(unsigned long));
+
+	if (!frame_list) {
+		printk(KERN_ERR "%s: vmalloc: Out of memory\n", __func__);
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	set_xen_guest_handle(reservation.extent_start, frame_list);
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
+		frame_list[i] = pfn;
+
+	ret = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+
+	if (ret < PAGES_PER_SECTION) {
+		if (ret > 0) {
+			printk(KERN_ERR "%s: PHYSMAP is not fully "
+					"populated: %i/%lu\n", __func__,
+					ret, PAGES_PER_SECTION);
+			reservation.nr_extents = nr_pages = ret;
+			ret = HYPERVISOR_memory_op(XENMEM_decrease_reservation, &reservation);
+			BUG_ON(ret != nr_pages);
+			ret = -ENOMEM;
+		} else {
+			ret = (ret < 0) ? ret : -ENOMEM;
+			printk(KERN_ERR "%s: Can't populate PHYSMAP: %i\n", __func__, ret);
+		}
+		goto error;
+	}
+
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn) {
+		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
+			phys_to_machine_mapping_valid(pfn));
+		set_phys_to_machine(pfn, frame_list[i]);
+	}
+
+	ret = xen_add_memory(memory_add_physaddr_to_nid(phys_addr), phys_addr,
+				PAGES_PER_SECTION << PAGE_SHIFT);
+
+	if (ret) {
+		printk(KERN_ERR "%s: xen_add_memory: Memory hotplug "
+				"failed: %i\n", __func__, ret);
+		goto out;
+	}
+
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
+		if (!PageHighMem(pfn_to_page(pfn)))
+			BUG_ON(HYPERVISOR_update_va_mapping(
+				(unsigned long)__va(pfn << PAGE_SHIFT),
+				mfn_pte(frame_list[i], PAGE_KERNEL), 0));
+
+	goto out;
+
+error:
+	release_memory_resource(r);
+
+out:
+	vfree(frame_list);
+
+	return (ret < 0) ? ret : 0;
+}
+EXPORT_SYMBOL_GPL(xen_memory_probe);
+#endif
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy

--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6.34.1-xen-memory-hotplug.r0.patch"

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/Kconfig               |    2 +-
 drivers/base/memory.c          |   23 +++++
 drivers/xen/Kconfig            |   10 ++
 drivers/xen/balloon.c          |  196 +++++++++++++++++++++++++++++++++++++++-
 include/linux/memory_hotplug.h |    8 ++
 include/xen/balloon.h          |    6 ++
 mm/Kconfig                     |    9 ++
 mm/memory_hotplug.c            |  140 ++++++++++++++++++++++++++++
 8 files changed, 390 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9458685..38434da 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	depends on ARCH_SPARSEMEM_ENABLE
 
 config ARCH_MEMORY_PROBE
-	def_bool X86_64
+	def_bool y
 	depends on MEMORY_HOTPLUG
 
 config ILLEGAL_POINTER_VALUE
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 933442f..709457b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -27,6 +27,14 @@
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+#include <xen/xen.h>
+#endif
+
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+#include <xen/balloon.h>
+#endif
+
 #define MEMORY_CLASS_NAME	"memory"
 
 static struct sysdev_class memory_sysdev_class = {
@@ -215,6 +223,10 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 		case MEM_ONLINE:
 			start_pfn = page_to_pfn(first_page);
 			ret = online_pages(start_pfn, PAGES_PER_SECTION);
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+			if (xen_domain() && !ret)
+				balloon_update_stats(PAGES_PER_SECTION);
+#endif
 			break;
 		case MEM_OFFLINE:
 			mem->state = MEM_GOING_OFFLINE;
@@ -225,6 +237,10 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 				mem->state = old_state;
 				break;
 			}
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
+			if (xen_domain())
+				balloon_update_stats(-PAGES_PER_SECTION);
+#endif
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
@@ -341,6 +357,13 @@ memory_probe_store(struct class *class, struct class_attribute *attr,
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+	if (xen_domain()) {
+		ret = xen_memory_probe(phys_addr);
+		return ret ? ret : count;
+	}
+#endif
+
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index fad3df2..9713048 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -9,6 +9,16 @@ config XEN_BALLOON
 	  the system to expand the domain's memory allocation, or alternatively
 	  return unneeded memory to the system.
 
+config XEN_BALLOON_MEMORY_HOTPLUG
+	bool "Xen memory balloon driver with memory hotplug support"
+	depends on EXPERIMENTAL && XEN_BALLOON && MEMORY_HOTPLUG
+	default n
+	help
+	  Xen memory balloon driver with memory hotplug support allows expanding
+	  memory available for the system above limit declared at system startup.
+	  It is very useful on critical systems which require long run without
+	  rebooting.
+
 config XEN_SCRUB_PAGES
 	bool "Scrub pages before returning them to system"
 	depends on XEN_BALLOON
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 1a0d8c2..f80bba0 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -6,6 +6,7 @@
  * Copyright (c) 2003, B Dragovic
  * Copyright (c) 2003-2004, M Williamson, K Fraser
  * Copyright (c) 2005 Dan M. Smith, IBM Corporation
+ * Copyright (c) 2010 Daniel Kiper
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -61,6 +62,10 @@
 #include <xen/features.h>
 #include <xen/page.h>
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+#include <linux/memory.h>
+#endif
+
 #define PAGES2KB(_p) ((_p)<<(PAGE_SHIFT-10))
 
 #define BALLOON_CLASS_NAME "xen_memory"
@@ -77,6 +82,11 @@ struct balloon_stats {
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	unsigned long boot_max_pfn;
+	u64 hotplug_start_paddr;
+	u64 hotplug_size;
+#endif
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -184,6 +194,12 @@ static void balloon_alarm(unsigned long unused)
 	schedule_work(&balloon_worker);
 }
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static inline unsigned long current_target(void)
+{
+	return balloon_stats.target_pages;
+}
+#else
 static unsigned long current_target(void)
 {
 	unsigned long target = balloon_stats.target_pages;
@@ -195,11 +211,12 @@ static unsigned long current_target(void)
 
 	return target;
 }
+#endif
 
 static int increase_reservation(unsigned long nr_pages)
 {
-	unsigned long  pfn, i, flags;
-	struct page   *page;
+	unsigned long  uninitialized_var(pfn), i, flags;
+	struct page    *uninitialized_var(page);
 	long           rc;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
@@ -207,11 +224,63 @@ static int increase_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	resource_size_t r_min, r_size;
+	struct resource *r;
+#endif
+
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
 	spin_lock_irqsave(&balloon_lock, flags);
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
+		if (!balloon_stats.hotplug_start_paddr) {
+
+			/*
+			 * Look for first unused memory region starting
+			 * at page boundary. Skip last memory section created
+			 * at boot time becuase it may contains unused memory
+			 * pages with PG_reserved bit not set (online_pages
+			 * require PG_reserved bit set).
+			 */
+
+			r = kzalloc(sizeof(struct resource), GFP_KERNEL);
+
+			if (!r) {
+				rc = -ENOMEM;
+				goto out;
+			}
+
+			r->name = "System RAM";
+			r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+			r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
+			r_size = (balloon_stats.target_pages - balloon_stats.current_pages) << PAGE_SHIFT;
+
+			rc = allocate_resource(&iomem_resource, r,
+						r_size, r_min, ULONG_MAX,
+						PAGE_SIZE, NULL, NULL);
+
+			if (rc < 0) {
+				kfree(r);
+				goto out;
+			}
+
+			balloon_stats.hotplug_start_paddr = r->start;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr +
+					balloon_stats.hotplug_size);
+
+		for (i = 0; i < nr_pages; ++i, ++pfn)
+			frame_list[i] = pfn;
+
+		pfn -= nr_pages + 1;
+		goto populate_physmap;
+	}
+#endif
+
 	page = balloon_first_page();
 	for (i = 0; i < nr_pages; i++) {
 		BUG_ON(page == NULL);
@@ -219,6 +288,9 @@ static int increase_reservation(unsigned long nr_pages)
 		page = balloon_next_page(page);
 	}
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+populate_physmap:
+#endif
 	set_xen_guest_handle(reservation.extent_start, frame_list);
 	reservation.nr_extents = nr_pages;
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
@@ -226,17 +298,33 @@ static int increase_reservation(unsigned long nr_pages)
 		goto out;
 
 	for (i = 0; i < rc; i++) {
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+		if (balloon_stats.hotplug_start_paddr) {
+			++pfn;
+			goto set_p2m;
+		}
+#endif
+
 		page = balloon_retrieve();
 		BUG_ON(page == NULL);
 
 		pfn = page_to_pfn(page);
+
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+set_p2m:
+#endif
 		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
 		       phys_to_machine_mapping_valid(pfn));
 
 		set_phys_to_machine(pfn, frame_list[i]);
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+		if (balloon_stats.hotplug_start_paddr)
+			continue;
+#endif
+
 		/* Link back into the page tables if not highmem. */
-		if (pfn < max_low_pfn) {
+		if (!PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
@@ -251,6 +339,11 @@ static int increase_reservation(unsigned long nr_pages)
 		__free_page(page);
 	}
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (balloon_stats.hotplug_start_paddr)
+		balloon_stats.hotplug_size += rc << PAGE_SHIFT;
+#endif
+
 	balloon_stats.current_pages += rc;
 
  out:
@@ -331,6 +424,12 @@ static void balloon_process(struct work_struct *work)
 	int need_sleep = 0;
 	long credit;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	int nid, ret;
+	struct memory_block *mem;
+	unsigned long pfn, pfn_limit;
+#endif
+
 	mutex_lock(&balloon_mutex);
 
 	do {
@@ -349,10 +448,93 @@ static void balloon_process(struct work_struct *work)
 	/* Schedule more work if there is some still to be done. */
 	if (current_target() != balloon_stats.current_pages)
 		mod_timer(&balloon_timer, jiffies + HZ);
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	else if (balloon_stats.hotplug_start_paddr) {
+		nid = memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
+
+		ret = xen_add_memory(nid, balloon_stats.hotplug_start_paddr,
+						balloon_stats.hotplug_size);
+
+		if (ret) {
+			printk(KERN_ERR "%s: xen_add_memory: "
+					"Memory hotplug failed: %i\n",
+					__func__, ret);
+			goto error;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		for (; pfn < pfn_limit; ++pfn)
+			if (!PageHighMem(pfn_to_page(pfn)))
+				BUG_ON(HYPERVISOR_update_va_mapping(
+					(unsigned long)__va(pfn << PAGE_SHIFT),
+					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0));
+
+		ret = online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr),
+					balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		if (ret) {
+			printk(KERN_ERR "%s: online_pages: Failed: %i\n",
+					__func__, ret);
+			goto error;
+		}
+
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		for (; pfn < pfn_limit; pfn += PAGES_PER_SECTION) {
+			mem = find_memory_block(__pfn_to_section(pfn));
+			BUG_ON(!mem);
+			BUG_ON(!present_section_nr(mem->phys_index));
+			mutex_lock(&mem->state_mutex);
+			mem->state = MEM_ONLINE;
+			mutex_unlock(&mem->state_mutex);
+		}
+
+		goto out;
+
+error:
+		balloon_stats.current_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+		balloon_stats.target_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+
+out:
+		balloon_stats.hotplug_start_paddr = 0;
+		balloon_stats.hotplug_size = 0;
+	}
+#endif
 
 	mutex_unlock(&balloon_mutex);
 }
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+
+/* Resets the Xen limit, sets new target, and kicks off processing. */
+static void balloon_set_new_target(unsigned long target)
+{
+	mutex_lock(&balloon_mutex);
+	balloon_stats.target_pages = target;
+	mutex_unlock(&balloon_mutex);
+
+	schedule_work(&balloon_worker);
+}
+
+void balloon_update_stats(long nr_pages)
+{
+	mutex_lock(&balloon_mutex);
+
+	balloon_stats.current_pages += nr_pages;
+	balloon_stats.target_pages += nr_pages;
+
+	xenbus_printf(XBT_NIL, "memory", "target", "%llu",
+			(unsigned long long)balloon_stats.target_pages << (PAGE_SHIFT - 10));
+
+	mutex_unlock(&balloon_mutex);
+}
+EXPORT_SYMBOL_GPL(balloon_update_stats);
+
+#else
+
 /* Resets the Xen limit, sets new target, and kicks off processing. */
 static void balloon_set_new_target(unsigned long target)
 {
@@ -361,6 +543,8 @@ static void balloon_set_new_target(unsigned long target)
 	schedule_work(&balloon_worker);
 }
 
+#endif
+
 static struct xenbus_watch target_watch =
 {
 	.node = "memory/target"
@@ -416,6 +600,12 @@ static int __init balloon_init(void)
 	balloon_stats.balloon_high  = 0;
 	balloon_stats.driver_pages  = 0UL;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	balloon_stats.boot_max_pfn = max_pfn;
+	balloon_stats.hotplug_start_paddr = 0;
+	balloon_stats.hotplug_size = 0;
+#endif
+
 	init_timer(&balloon_timer);
 	balloon_timer.data = 0;
 	balloon_timer.function = balloon_alarm;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 35b07b7..04e67b8 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -211,4 +211,12 @@ extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
+extern int xen_add_memory(int nid, u64 start, u64 size);
+#endif
+
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+extern int xen_memory_probe(u64 phys_addr);
+#endif
+
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
new file mode 100644
index 0000000..84b17b7
--- /dev/null
+++ b/include/xen/balloon.h
@@ -0,0 +1,6 @@
+#ifndef _XEN_BALLOON_H
+#define _XEN_BALLOON_H
+
+extern void balloon_update_stats(long nr_pages);
+
+#endif	/* _XEN_BALLOON_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 9c61158..b04f3a8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -144,6 +144,15 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config XEN_MEMORY_HOTPLUG
+	bool "Allow for memory hot-add in Xen guests"
+	depends on EXPERIMENTAL && ARCH_MEMORY_PROBE && XEN
+	default n
+	help
+	  Memory hotplug allows expanding memory available for the system
+	  above limit declared at system startup. It is very useful on critical
+	  systems which require long run without rebooting.
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index be211a5..1c73703 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -32,6 +32,14 @@
 
 #include <asm/tlbflush.h>
 
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+#include <asm/xen/hypercall.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/memory.h>
+#include <xen/features.h>
+#include <xen/page.h>
+#endif
+
 #include "internal.h"
 
 /* add this memory to iomem resource */
@@ -542,6 +550,138 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
+#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
+/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+int __ref xen_add_memory(int nid, u64 start, u64 size)
+{
+	pg_data_t *pgdat = NULL;
+	int new_pgdat = 0, ret;
+
+	lock_system_sleep();
+
+	if (!node_online(nid)) {
+		pgdat = hotadd_new_pgdat(nid, start);
+		ret = -ENOMEM;
+		if (!pgdat)
+			goto out;
+		new_pgdat = 1;
+	}
+
+	/* call arch's memory hotadd */
+	ret = arch_add_memory(nid, start, size);
+
+	if (ret < 0)
+		goto error;
+
+	/* we online node here. we can't roll back from here. */
+	node_set_online(nid);
+
+	if (new_pgdat) {
+		ret = register_one_node(nid);
+		/*
+		 * If sysfs file of new node can't create, cpu on the node
+		 * can't be hot-added. There is no rollback way now.
+		 * So, check by BUG_ON() to catch it reluctantly..
+		 */
+		BUG_ON(ret);
+	}
+
+	goto out;
+
+error:
+	/* rollback pgdat allocation */
+	if (new_pgdat)
+		rollback_node_hotadd(nid, pgdat);
+
+out:
+	unlock_system_sleep();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xen_add_memory);
+#endif
+
+#ifdef CONFIG_XEN_MEMORY_HOTPLUG
+int xen_memory_probe(u64 phys_addr)
+{
+	int nr_pages, ret;
+	struct resource *r;
+	struct xen_memory_reservation reservation = {
+		.address_bits = 0,
+		.extent_order = 0,
+		.domid = DOMID_SELF,
+		.nr_extents = PAGES_PER_SECTION
+	};
+	unsigned long *frame_list, i, pfn;
+
+	r = register_memory_resource(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+
+	if (!r)
+		return -EEXIST;
+
+	frame_list = vmalloc(PAGES_PER_SECTION * sizeof(unsigned long));
+
+	if (!frame_list) {
+		printk(KERN_ERR "%s: vmalloc: Out of memory\n", __func__);
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	set_xen_guest_handle(reservation.extent_start, frame_list);
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
+		frame_list[i] = pfn;
+
+	ret = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+
+	if (ret < PAGES_PER_SECTION) {
+		if (ret > 0) {
+			printk(KERN_ERR "%s: PHYSMAP is not fully "
+					"populated: %i/%lu\n", __func__,
+					ret, PAGES_PER_SECTION);
+			reservation.nr_extents = nr_pages = ret;
+			ret = HYPERVISOR_memory_op(XENMEM_decrease_reservation, &reservation);
+			BUG_ON(ret != nr_pages);
+			ret = -ENOMEM;
+		} else {
+			ret = (ret < 0) ? ret : -ENOMEM;
+			printk(KERN_ERR "%s: Can't populate PHYSMAP: %i\n", __func__, ret);
+		}
+		goto error;
+	}
+
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn) {
+		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
+			phys_to_machine_mapping_valid(pfn));
+		set_phys_to_machine(pfn, frame_list[i]);
+	}
+
+	ret = xen_add_memory(memory_add_physaddr_to_nid(phys_addr), phys_addr,
+				PAGES_PER_SECTION << PAGE_SHIFT);
+
+	if (ret) {
+		printk(KERN_ERR "%s: xen_add_memory: Memory hotplug "
+				"failed: %i\n", __func__, ret);
+		goto out;
+	}
+
+	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
+		if (!PageHighMem(pfn_to_page(pfn)))
+			BUG_ON(HYPERVISOR_update_va_mapping(
+				(unsigned long)__va(pfn << PAGE_SHIFT),
+				mfn_pte(frame_list[i], PAGE_KERNEL), 0));
+
+	goto out;
+
+error:
+	release_memory_resource(r);
+
+out:
+	vfree(frame_list);
+
+	return (ret < 0) ? ret : 0;
+}
+EXPORT_SYMBOL_GPL(xen_memory_probe);
+#endif
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
