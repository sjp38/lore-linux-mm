Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CCD8E6B02B5
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 07:12:09 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1546062Ab0HFLLr (ORCPT <rfc822;linux-mm@kvack.org>);
	Fri, 6 Aug 2010 13:11:47 +0200
Date: Fri, 6 Aug 2010 13:11:47 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - second fully working version - once again
Message-ID: <20100806111147.GA31683@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: jeremy@goop.org, konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

Hi,

I am sending this e-mail once again because it probably
has been lost in abyss of Xen-devel/LKLM list.

Here is the second version of memory hotplug support
for Xen guests patch. This one cleanly applies to
git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git
repository, xen/memory-hotplug head.

Changes:
  - /sys/devices/system/memory/probe interface has been removed;
    /sys/devices/system/xen_memory/xen_memory0/{target,target_kb}
    are much better (I forgot about them),
  - most of the code have been moved to drivers/xen/balloon.c,
  - this changes forced me to export hotadd_new_pgdat and
    rollback_node_hotadd function from mm/memory_hotplug.c;
    could it be accepted by mm/memory_hotplug.c maintainers ???
  - PV on HVM mode is supported now; it was tested on
    git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git
    repository, 2.6.34-pvhvm head,
  - most of Jeremy suggestions have been applied.

On Wed, Jul 28, 2010 at 11:36:29AM +0400, Vasiliy G Tolstov wrote:
[...]
> Work's fine with opensuse 11.3 (dom0 and domU)

Thx.

On Thu, Jul 29, 2010 at 12:39:52PM -0700, Jeremy Fitzhardinge wrote:
>  On 07/26/2010 05:41 PM, Daniel Kiper wrote:
> >Hi,
> >
> >Currently there is fully working version.
> >It has been tested on Xen Ver. 4.0.0 in PV
> >guest i386/x86_64 with Linux kernel Ver. 2.6.32.16
> >and Ver. 2.6.34.1. This patch cleanly applys
> >to Ver. 2.6.34.1
>
> Thanks.  I've pushed this into xen.git as xen/memory-hotplug so people
> can play with it more easily (but I haven't merged it into any of the
> other branches yet).

Thx.

> >+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> >+static inline unsigned long current_target(void)
> >+{
> >+	return balloon_stats.target_pages;
>
> Why does this need its own version?

Because original version return values not bigger
then initial memory allocation which does not allow
memory hotplug to function.

> >+int __ref xen_add_memory(int nid, u64 start, u64 size)
> >+{
> >+	pg_data_t *pgdat = NULL;
> >+	int new_pgdat = 0, ret;
> >+
> >+	lock_system_sleep();
> >+
> >+	if (!node_online(nid)) {
> >+		pgdat = hotadd_new_pgdat(nid, start);
> >+		ret = -ENOMEM;
> >+		if (!pgdat)
> >+			goto out;
> >+		new_pgdat = 1;
> >+	}
> >+
> >+	/* call arch's memory hotadd */
> >+	ret = arch_add_memory(nid, start, size);
> >+
> >+	if (ret<  0)
> >+		goto error;
> >+
> >+	/* we online node here. we can't roll back from here. */
> >+	node_set_online(nid);
> >+
> >+	if (new_pgdat) {
> >+		ret = register_one_node(nid);
> >+		/*
> >+		 * If sysfs file of new node can't create, cpu on the node
> >+		 * can't be hot-added. There is no rollback way now.
> >+		 * So, check by BUG_ON() to catch it reluctantly..
> >+		 */
> >+		BUG_ON(ret);
> >+	}
>
> This doesn't seem to be doing anything particularly xen-specific.

In general it could be generic however I do not know
it will be useful for others. If this function would
be accepted by mm/memory_hotplug.c maintainers we could
move it there. I removed from original add_memory funtion
resource allocation (and deallocation after error), which
must be done before XENMEM_populate_physmap in Xen. xen_add_memory
is called after physmap is fully populated.

If you have a questions please drop me a line.

Daniel

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/Kconfig               |    2 +-
 drivers/base/memory.c          |   23 ---
 drivers/xen/Kconfig            |    2 +-
 drivers/xen/balloon.c          |  416 ++++++++++++++++++++++------------------
 include/linux/memory_hotplug.h |   10 +-
 include/xen/balloon.h          |    6 -
 mm/Kconfig                     |    9 -
 mm/memory_hotplug.c            |  146 +--------------
 8 files changed, 240 insertions(+), 374 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 38434da..beb1aa7 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	depends on ARCH_SPARSEMEM_ENABLE
 
 config ARCH_MEMORY_PROBE
-	def_bool y
+	def_bool X86_64 && !XEN
 	depends on MEMORY_HOTPLUG
 
 config ILLEGAL_POINTER_VALUE
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 709457b..933442f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -27,14 +27,6 @@
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-#include <xen/xen.h>
-#endif
-
-#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
-#include <xen/balloon.h>
-#endif
-
 #define MEMORY_CLASS_NAME	"memory"
 
 static struct sysdev_class memory_sysdev_class = {
@@ -223,10 +215,6 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 		case MEM_ONLINE:
 			start_pfn = page_to_pfn(first_page);
 			ret = online_pages(start_pfn, PAGES_PER_SECTION);
-#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
-			if (xen_domain() && !ret)
-				balloon_update_stats(PAGES_PER_SECTION);
-#endif
 			break;
 		case MEM_OFFLINE:
 			mem->state = MEM_GOING_OFFLINE;
@@ -237,10 +225,6 @@ memory_block_action(struct memory_block *mem, unsigned long action)
 				mem->state = old_state;
 				break;
 			}
-#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
-			if (xen_domain())
-				balloon_update_stats(-PAGES_PER_SECTION);
-#endif
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
@@ -357,13 +341,6 @@ memory_probe_store(struct class *class, struct class_attribute *attr,
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-	if (xen_domain()) {
-		ret = xen_memory_probe(phys_addr);
-		return ret ? ret : count;
-	}
-#endif
-
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 9713048..4f35eaf 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -11,8 +11,8 @@ config XEN_BALLOON
 
 config XEN_BALLOON_MEMORY_HOTPLUG
 	bool "Xen memory balloon driver with memory hotplug support"
-	depends on EXPERIMENTAL && XEN_BALLOON && MEMORY_HOTPLUG
 	default n
+	depends on XEN_BALLOON && MEMORY_HOTPLUG
 	help
 	  Xen memory balloon driver with memory hotplug support allows expanding
 	  memory available for the system above limit declared at system startup.
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index f80bba0..31edc26 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -45,6 +45,8 @@
 #include <linux/list.h>
 #include <linux/sysdev.h>
 #include <linux/gfp.h>
+#include <linux/memory.h>
+#include <linux/suspend.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -62,10 +64,6 @@
 #include <xen/features.h>
 #include <xen/page.h>
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-#include <linux/memory.h>
-#endif
-
 #define PAGES2KB(_p) ((_p)<<(PAGE_SHIFT-10))
 
 #define BALLOON_CLASS_NAME "xen_memory"
@@ -199,6 +197,196 @@ static inline unsigned long current_target(void)
 {
 	return balloon_stats.target_pages;
 }
+
+static inline u64 is_memory_resource_reserved(void)
+{
+	return balloon_stats.hotplug_start_paddr;
+}
+
+/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+static int __ref xen_add_memory(int nid, u64 start, u64 size)
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
+
+static int allocate_additional_memory(unsigned long nr_pages)
+{
+	long rc;
+	resource_size_t r_min, r_size;
+	struct resource *r;
+	struct xen_memory_reservation reservation = {
+		.address_bits = 0,
+		.extent_order = 0,
+		.domid        = DOMID_SELF
+	};
+	unsigned long flags, i, pfn;
+
+	if (nr_pages > ARRAY_SIZE(frame_list))
+		nr_pages = ARRAY_SIZE(frame_list);
+
+	spin_lock_irqsave(&balloon_lock, flags);
+
+	if (!is_memory_resource_reserved()) {
+
+		/*
+		 * Look for first unused memory region starting at page
+		 * boundary. Skip last memory section created at boot time
+		 * becuase it may contains unused memory pages with PG_reserved
+		 * bit not set (online_pages require PG_reserved bit set).
+		 */
+
+		r = kzalloc(sizeof(struct resource), GFP_KERNEL);
+
+		if (!r) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		r->name = "System RAM";
+		r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
+		r_size = (balloon_stats.target_pages - balloon_stats.current_pages) << PAGE_SHIFT;
+
+		rc = allocate_resource(&iomem_resource, r, r_size, r_min,
+					ULONG_MAX, PAGE_SIZE, NULL, NULL);
+
+		if (rc < 0) {
+			kfree(r);
+			goto out;
+		}
+
+		balloon_stats.hotplug_start_paddr = r->start;
+	}
+
+	pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr + balloon_stats.hotplug_size);
+
+	for (i = 0; i < nr_pages; ++i, ++pfn)
+		frame_list[i] = pfn;
+
+	set_xen_guest_handle(reservation.extent_start, frame_list);
+	reservation.nr_extents = nr_pages;
+
+	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+
+	if (rc < 0)
+		goto out;
+
+	pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr + balloon_stats.hotplug_size);
+
+	for (i = 0; i < rc; ++i, ++pfn) {
+		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
+		       phys_to_machine_mapping_valid(pfn));
+		set_phys_to_machine(pfn, frame_list[i]);
+	}
+
+	balloon_stats.hotplug_size += rc << PAGE_SHIFT;
+	balloon_stats.current_pages += rc;
+
+out:
+	spin_unlock_irqrestore(&balloon_lock, flags);
+
+	return rc < 0 ? rc : rc != nr_pages;
+}
+
+static void hotplug_allocated_memory(void)
+{
+	int nid, ret;
+	struct memory_block *mem;
+	unsigned long pfn, pfn_limit;
+
+	nid = memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
+
+	ret = xen_add_memory(nid, balloon_stats.hotplug_start_paddr,
+						balloon_stats.hotplug_size);
+
+	if (ret) {
+		pr_err("%s: xen_add_memory: Memory hotplug failed: %i\n",
+			__func__, ret);
+		goto error;
+	}
+
+	if (xen_pv_domain()) {
+		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+		for (; pfn < pfn_limit; ++pfn)
+			if (!PageHighMem(pfn_to_page(pfn)))
+				BUG_ON(HYPERVISOR_update_va_mapping(
+					(unsigned long)__va(pfn << PAGE_SHIFT),
+					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0));
+	}
+
+	ret = online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr),
+				balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+	if (ret) {
+		pr_err("%s: online_pages: Failed: %i\n", __func__, ret);
+		goto error;
+	}
+
+	pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
+	pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
+
+	for (; pfn < pfn_limit; pfn += PAGES_PER_SECTION) {
+		mem = find_memory_block(__pfn_to_section(pfn));
+		BUG_ON(!mem);
+		BUG_ON(!present_section_nr(mem->phys_index));
+		mutex_lock(&mem->state_mutex);
+		mem->state = MEM_ONLINE;
+		mutex_unlock(&mem->state_mutex);
+	}
+
+	goto out;
+
+error:
+	balloon_stats.current_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+	balloon_stats.target_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
+
+out:
+	balloon_stats.hotplug_start_paddr = 0;
+	balloon_stats.hotplug_size = 0;
+}
 #else
 static unsigned long current_target(void)
 {
@@ -211,12 +399,26 @@ static unsigned long current_target(void)
 
 	return target;
 }
+
+static inline u64 is_memory_resource_reserved(void)
+{
+	return 0;
+}
+
+static inline int allocate_additional_memory(unsigned long nr_pages)
+{
+	return 0;
+}
+
+static inline void hotplug_allocated_memory(void)
+{
+}
 #endif
 
 static int increase_reservation(unsigned long nr_pages)
 {
-	unsigned long  uninitialized_var(pfn), i, flags;
-	struct page    *uninitialized_var(page);
+	unsigned long  pfn, i, flags;
+	struct page   *page;
 	long           rc;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
@@ -224,63 +426,11 @@ static int increase_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	resource_size_t r_min, r_size;
-	struct resource *r;
-#endif
-
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
 	spin_lock_irqsave(&balloon_lock, flags);
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
-		if (!balloon_stats.hotplug_start_paddr) {
-
-			/*
-			 * Look for first unused memory region starting
-			 * at page boundary. Skip last memory section created
-			 * at boot time becuase it may contains unused memory
-			 * pages with PG_reserved bit not set (online_pages
-			 * require PG_reserved bit set).
-			 */
-
-			r = kzalloc(sizeof(struct resource), GFP_KERNEL);
-
-			if (!r) {
-				rc = -ENOMEM;
-				goto out;
-			}
-
-			r->name = "System RAM";
-			r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-			r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
-			r_size = (balloon_stats.target_pages - balloon_stats.current_pages) << PAGE_SHIFT;
-
-			rc = allocate_resource(&iomem_resource, r,
-						r_size, r_min, ULONG_MAX,
-						PAGE_SIZE, NULL, NULL);
-
-			if (rc < 0) {
-				kfree(r);
-				goto out;
-			}
-
-			balloon_stats.hotplug_start_paddr = r->start;
-		}
-
-		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr +
-					balloon_stats.hotplug_size);
-
-		for (i = 0; i < nr_pages; ++i, ++pfn)
-			frame_list[i] = pfn;
-
-		pfn -= nr_pages + 1;
-		goto populate_physmap;
-	}
-#endif
-
 	page = balloon_first_page();
 	for (i = 0; i < nr_pages; i++) {
 		BUG_ON(page == NULL);
@@ -288,9 +438,6 @@ static int increase_reservation(unsigned long nr_pages)
 		page = balloon_next_page(page);
 	}
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-populate_physmap:
-#endif
 	set_xen_guest_handle(reservation.extent_start, frame_list);
 	reservation.nr_extents = nr_pages;
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
@@ -298,33 +445,17 @@ populate_physmap:
 		goto out;
 
 	for (i = 0; i < rc; i++) {
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-		if (balloon_stats.hotplug_start_paddr) {
-			++pfn;
-			goto set_p2m;
-		}
-#endif
-
 		page = balloon_retrieve();
 		BUG_ON(page == NULL);
 
 		pfn = page_to_pfn(page);
-
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-set_p2m:
-#endif
 		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
 		       phys_to_machine_mapping_valid(pfn));
 
 		set_phys_to_machine(pfn, frame_list[i]);
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-		if (balloon_stats.hotplug_start_paddr)
-			continue;
-#endif
-
 		/* Link back into the page tables if not highmem. */
-		if (!PageHighMem(page)) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
@@ -339,11 +470,6 @@ set_p2m:
 		__free_page(page);
 	}
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	if (balloon_stats.hotplug_start_paddr)
-		balloon_stats.hotplug_size += rc << PAGE_SHIFT;
-#endif
-
 	balloon_stats.current_pages += rc;
 
  out:
@@ -379,7 +505,7 @@ static int decrease_reservation(unsigned long nr_pages)
 
 		scrub_page(page);
 
-		if (!PageHighMem(page)) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
 				__pte_ma(0), 0);
@@ -424,18 +550,18 @@ static void balloon_process(struct work_struct *work)
 	int need_sleep = 0;
 	long credit;
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	int nid, ret;
-	struct memory_block *mem;
-	unsigned long pfn, pfn_limit;
-#endif
-
 	mutex_lock(&balloon_mutex);
 
 	do {
 		credit = current_target() - balloon_stats.current_pages;
-		if (credit > 0)
-			need_sleep = (increase_reservation(credit) != 0);
+
+		if (credit > 0) {
+			if (balloon_stats.balloon_low || balloon_stats.balloon_high)
+				need_sleep = (increase_reservation(credit) != 0);
+			else
+				need_sleep = (allocate_additional_memory(credit) != 0);
+		}
+
 		if (credit < 0)
 			need_sleep = (decrease_reservation(-credit) != 0);
 
@@ -448,93 +574,12 @@ static void balloon_process(struct work_struct *work)
 	/* Schedule more work if there is some still to be done. */
 	if (current_target() != balloon_stats.current_pages)
 		mod_timer(&balloon_timer, jiffies + HZ);
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	else if (balloon_stats.hotplug_start_paddr) {
-		nid = memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
-
-		ret = xen_add_memory(nid, balloon_stats.hotplug_start_paddr,
-						balloon_stats.hotplug_size);
-
-		if (ret) {
-			printk(KERN_ERR "%s: xen_add_memory: "
-					"Memory hotplug failed: %i\n",
-					__func__, ret);
-			goto error;
-		}
-
-		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
-		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
-
-		for (; pfn < pfn_limit; ++pfn)
-			if (!PageHighMem(pfn_to_page(pfn)))
-				BUG_ON(HYPERVISOR_update_va_mapping(
-					(unsigned long)__va(pfn << PAGE_SHIFT),
-					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0));
-
-		ret = online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr),
-					balloon_stats.hotplug_size >> PAGE_SHIFT);
-
-		if (ret) {
-			printk(KERN_ERR "%s: online_pages: Failed: %i\n",
-					__func__, ret);
-			goto error;
-		}
-
-		pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr);
-		pfn_limit = pfn + (balloon_stats.hotplug_size >> PAGE_SHIFT);
-
-		for (; pfn < pfn_limit; pfn += PAGES_PER_SECTION) {
-			mem = find_memory_block(__pfn_to_section(pfn));
-			BUG_ON(!mem);
-			BUG_ON(!present_section_nr(mem->phys_index));
-			mutex_lock(&mem->state_mutex);
-			mem->state = MEM_ONLINE;
-			mutex_unlock(&mem->state_mutex);
-		}
-
-		goto out;
-
-error:
-		balloon_stats.current_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
-		balloon_stats.target_pages -= balloon_stats.hotplug_size >> PAGE_SHIFT;
-
-out:
-		balloon_stats.hotplug_start_paddr = 0;
-		balloon_stats.hotplug_size = 0;
-	}
-#endif
+	else if (is_memory_resource_reserved())
+		hotplug_allocated_memory();
 
 	mutex_unlock(&balloon_mutex);
 }
 
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-
-/* Resets the Xen limit, sets new target, and kicks off processing. */
-static void balloon_set_new_target(unsigned long target)
-{
-	mutex_lock(&balloon_mutex);
-	balloon_stats.target_pages = target;
-	mutex_unlock(&balloon_mutex);
-
-	schedule_work(&balloon_worker);
-}
-
-void balloon_update_stats(long nr_pages)
-{
-	mutex_lock(&balloon_mutex);
-
-	balloon_stats.current_pages += nr_pages;
-	balloon_stats.target_pages += nr_pages;
-
-	xenbus_printf(XBT_NIL, "memory", "target", "%llu",
-			(unsigned long long)balloon_stats.target_pages << (PAGE_SHIFT - 10));
-
-	mutex_unlock(&balloon_mutex);
-}
-EXPORT_SYMBOL_GPL(balloon_update_stats);
-
-#else
-
 /* Resets the Xen limit, sets new target, and kicks off processing. */
 static void balloon_set_new_target(unsigned long target)
 {
@@ -543,8 +588,6 @@ static void balloon_set_new_target(unsigned long target)
 	schedule_work(&balloon_worker);
 }
 
-#endif
-
 static struct xenbus_watch target_watch =
 {
 	.node = "memory/target"
@@ -589,12 +632,16 @@ static int __init balloon_init(void)
 	unsigned long pfn;
 	struct page *page;
 
-	if (!xen_pv_domain())
+	if (!xen_domain())
 		return -ENODEV;
 
 	pr_info("xen_balloon: Initialising balloon driver.\n");
 
-	balloon_stats.current_pages = min(xen_start_info->nr_pages, max_pfn);
+	if (xen_pv_domain())
+		balloon_stats.current_pages = min(xen_start_info->nr_pages, max_pfn);
+	else
+		balloon_stats.current_pages = max_pfn;
+
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
@@ -613,11 +660,12 @@ static int __init balloon_init(void)
 	register_balloon(&balloon_sysdev);
 
 	/* Initialise the balloon with excess memory space. */
-	for (pfn = xen_start_info->nr_pages; pfn < max_pfn; pfn++) {
-		page = pfn_to_page(pfn);
-		if (!PageReserved(page))
-			balloon_append(page);
-	}
+	if (xen_pv_domain())
+		for (pfn = xen_start_info->nr_pages; pfn < max_pfn; pfn++) {
+			page = pfn_to_page(pfn);
+			if (!PageReserved(page))
+				balloon_append(page);
+		}
 
 	target_watch.callback = watch_target;
 	xenstore_notifier.notifier_call = balloon_init_watcher;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 04e67b8..6652eae 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -202,6 +202,8 @@ static inline int is_mem_section_removable(unsigned long pfn,
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+extern pg_data_t *hotadd_new_pgdat(int nid, u64 start);
+extern void rollback_node_hotadd(int nid, pg_data_t *pgdat);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
@@ -211,12 +213,4 @@ extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
-#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
-extern int xen_add_memory(int nid, u64 start, u64 size);
-#endif
-
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-extern int xen_memory_probe(u64 phys_addr);
-#endif
-
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
deleted file mode 100644
index 84b17b7..0000000
--- a/include/xen/balloon.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _XEN_BALLOON_H
-#define _XEN_BALLOON_H
-
-extern void balloon_update_stats(long nr_pages);
-
-#endif	/* _XEN_BALLOON_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index b04f3a8..9c61158 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -144,15 +144,6 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
-config XEN_MEMORY_HOTPLUG
-	bool "Allow for memory hot-add in Xen guests"
-	depends on EXPERIMENTAL && ARCH_MEMORY_PROBE && XEN
-	default n
-	help
-	  Memory hotplug allows expanding memory available for the system
-	  above limit declared at system startup. It is very useful on critical
-	  systems which require long run without rebooting.
-
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1c73703..143e03c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -32,14 +32,6 @@
 
 #include <asm/tlbflush.h>
 
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-#include <asm/xen/hypercall.h>
-#include <xen/interface/xen.h>
-#include <xen/interface/memory.h>
-#include <xen/features.h>
-#include <xen/page.h>
-#endif
-
 #include "internal.h"
 
 /* add this memory to iomem resource */
@@ -461,7 +453,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
+pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
 	struct pglist_data *pgdat;
 	unsigned long zones_size[MAX_NR_ZONES] = {0};
@@ -481,13 +473,15 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 	return pgdat;
 }
+EXPORT_SYMBOL_GPL(hotadd_new_pgdat);
 
-static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
+void rollback_node_hotadd(int nid, pg_data_t *pgdat)
 {
 	arch_refresh_nodedata(nid, NULL);
 	arch_free_nodedata(pgdat);
 	return;
 }
+EXPORT_SYMBOL_GPL(rollback_node_hotadd);
 
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
@@ -550,138 +544,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
-#if defined(CONFIG_XEN_MEMORY_HOTPLUG) || defined(CONFIG_XEN_BALLOON_MEMORY_HOTPLUG)
-/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref xen_add_memory(int nid, u64 start, u64 size)
-{
-	pg_data_t *pgdat = NULL;
-	int new_pgdat = 0, ret;
-
-	lock_system_sleep();
-
-	if (!node_online(nid)) {
-		pgdat = hotadd_new_pgdat(nid, start);
-		ret = -ENOMEM;
-		if (!pgdat)
-			goto out;
-		new_pgdat = 1;
-	}
-
-	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size);
-
-	if (ret < 0)
-		goto error;
-
-	/* we online node here. we can't roll back from here. */
-	node_set_online(nid);
-
-	if (new_pgdat) {
-		ret = register_one_node(nid);
-		/*
-		 * If sysfs file of new node can't create, cpu on the node
-		 * can't be hot-added. There is no rollback way now.
-		 * So, check by BUG_ON() to catch it reluctantly..
-		 */
-		BUG_ON(ret);
-	}
-
-	goto out;
-
-error:
-	/* rollback pgdat allocation */
-	if (new_pgdat)
-		rollback_node_hotadd(nid, pgdat);
-
-out:
-	unlock_system_sleep();
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xen_add_memory);
-#endif
-
-#ifdef CONFIG_XEN_MEMORY_HOTPLUG
-int xen_memory_probe(u64 phys_addr)
-{
-	int nr_pages, ret;
-	struct resource *r;
-	struct xen_memory_reservation reservation = {
-		.address_bits = 0,
-		.extent_order = 0,
-		.domid = DOMID_SELF,
-		.nr_extents = PAGES_PER_SECTION
-	};
-	unsigned long *frame_list, i, pfn;
-
-	r = register_memory_resource(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
-
-	if (!r)
-		return -EEXIST;
-
-	frame_list = vmalloc(PAGES_PER_SECTION * sizeof(unsigned long));
-
-	if (!frame_list) {
-		printk(KERN_ERR "%s: vmalloc: Out of memory\n", __func__);
-		ret = -ENOMEM;
-		goto error;
-	}
-
-	set_xen_guest_handle(reservation.extent_start, frame_list);
-	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
-		frame_list[i] = pfn;
-
-	ret = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
-
-	if (ret < PAGES_PER_SECTION) {
-		if (ret > 0) {
-			printk(KERN_ERR "%s: PHYSMAP is not fully "
-					"populated: %i/%lu\n", __func__,
-					ret, PAGES_PER_SECTION);
-			reservation.nr_extents = nr_pages = ret;
-			ret = HYPERVISOR_memory_op(XENMEM_decrease_reservation, &reservation);
-			BUG_ON(ret != nr_pages);
-			ret = -ENOMEM;
-		} else {
-			ret = (ret < 0) ? ret : -ENOMEM;
-			printk(KERN_ERR "%s: Can't populate PHYSMAP: %i\n", __func__, ret);
-		}
-		goto error;
-	}
-
-	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn) {
-		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
-			phys_to_machine_mapping_valid(pfn));
-		set_phys_to_machine(pfn, frame_list[i]);
-	}
-
-	ret = xen_add_memory(memory_add_physaddr_to_nid(phys_addr), phys_addr,
-				PAGES_PER_SECTION << PAGE_SHIFT);
-
-	if (ret) {
-		printk(KERN_ERR "%s: xen_add_memory: Memory hotplug "
-				"failed: %i\n", __func__, ret);
-		goto out;
-	}
-
-	for (i = 0, pfn = PFN_DOWN(phys_addr); i < PAGES_PER_SECTION; ++i, ++pfn)
-		if (!PageHighMem(pfn_to_page(pfn)))
-			BUG_ON(HYPERVISOR_update_va_mapping(
-				(unsigned long)__va(pfn << PAGE_SHIFT),
-				mfn_pte(frame_list[i], PAGE_KERNEL), 0));
-
-	goto out;
-
-error:
-	release_memory_resource(r);
-
-out:
-	vfree(frame_list);
-
-	return (ret < 0) ? ret : 0;
-}
-EXPORT_SYMBOL_GPL(xen_memory_probe);
-#endif
-
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
