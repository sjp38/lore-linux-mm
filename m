Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E51A48D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 11:33:05 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576257Ab1BCQad (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 3 Feb 2011 17:30:33 +0100
Date: Thu, 3 Feb 2011 17:30:33 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Features and fixes:
  - new version of memory hotplug patch which supports
    among others memory allocation policies during errors
    (try until success or stop at first error),
  - this version of patch was tested with tmem
    (selfballooning and frontswap) and works
    very well with it,
  - some other minor fixes.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/Kconfig   |   10 ++
 drivers/xen/balloon.c |  231 ++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 230 insertions(+), 11 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 07bec09..8f880aa 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -9,6 +9,16 @@ config XEN_BALLOON
 	  the system to expand the domain's memory allocation, or alternatively
 	  return unneeded memory to the system.
 
+config XEN_BALLOON_MEMORY_HOTPLUG
+	bool "Memory hotplug support for Xen balloon driver"
+	default n
+	depends on XEN_BALLOON && MEMORY_HOTPLUG
+	help
+	  Memory hotplug support for Xen balloon driver allows expanding memory
+	  available for the system above limit declared at system startup.
+	  It is very useful on critical systems which require long
+	  run without rebooting.
+
 config XEN_SCRUB_PAGES
 	bool "Scrub pages before returning them to system"
 	depends on XEN_BALLOON
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index b1e199c..e43e928 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -6,6 +6,12 @@
  * Copyright (c) 2003, B Dragovic
  * Copyright (c) 2003-2004, M Williamson, K Fraser
  * Copyright (c) 2005 Dan M. Smith, IBM Corporation
+ * Copyright (c) 2010 Daniel Kiper
+ *
+ * Memory hotplug support was written by Daniel Kiper. Work on
+ * it was sponsored by Google under Google Summer of Code 2010
+ * program. Jeremy Fitzhardinge from Xen.org was the mentor for
+ * this project.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -44,6 +50,7 @@
 #include <linux/list.h>
 #include <linux/sysdev.h>
 #include <linux/gfp.h>
+#include <linux/memory.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -80,6 +87,9 @@ enum bp_state {
 	BP_HUNGRY
 };
 
+#define MH_POLICY_TRY_UNTIL_SUCCESS	0
+#define MH_POLICY_STOP_AT_FIRST_ERROR	1
+
 struct balloon_stats {
 	/* We aim for 'current allocation' == 'target allocation'. */
 	unsigned long current_pages;
@@ -89,6 +99,10 @@ struct balloon_stats {
 	unsigned long balloon_high;
 	unsigned long schedule_delay;
 	unsigned long max_schedule_delay;
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	unsigned long boot_max_pfn;
+	unsigned long mh_policy;
+#endif
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -206,18 +220,199 @@ static void update_schedule_delay(enum bp_state state)
 	balloon_stats.schedule_delay = new_schedule_delay;
 }
 
-static unsigned long current_target(void)
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static struct resource *allocate_memory_resource(unsigned long nr_pages)
+{
+	resource_size_t r_min, r_size;
+	struct resource *r;
+
+	/*
+	 * Look for first unused memory region starting at page
+	 * boundary. Skip last memory section created at boot time
+	 * because it may contains unused memory pages with PG_reserved
+	 * bit not set (online_pages() require PG_reserved bit set).
+	 */
+
+	r = kzalloc(sizeof(struct resource), GFP_KERNEL);
+
+	if (!r)
+		return NULL;
+
+	r->name = "System RAM";
+	r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
+	r_size = nr_pages << PAGE_SHIFT;
+
+	if (allocate_resource(&iomem_resource, r, r_size, r_min,
+					ULONG_MAX, PAGE_SIZE, NULL, NULL) < 0) {
+		kfree(r);
+		return NULL;
+	}
+
+	return r;
+}
+
+static struct resource *adjust_memory_resource(struct resource *r, unsigned long nr_pages)
+{
+	int rc;
+
+	if (r->end + 1 - (nr_pages << PAGE_SHIFT) == r->start) {
+		rc = release_resource(r);
+		BUG_ON(rc < 0);
+		kfree(r);
+		return NULL;
+	}
+
+	rc = adjust_resource(r, r->start, r->end + 1 - r->start -
+				(nr_pages << PAGE_SHIFT));
+
+	BUG_ON(rc < 0);
+
+	return r;
+}
+
+static int allocate_additional_memory(struct resource *r, unsigned long nr_pages)
+{
+	int rc;
+	struct xen_memory_reservation reservation = {
+		.address_bits = 0,
+		.extent_order = 0,
+		.domid        = DOMID_SELF
+	};
+	unsigned long flags, i, pfn, pfn_start;
+
+	if (!nr_pages)
+		return 0;
+
+	pfn_start = PFN_UP(r->end) - nr_pages;
+
+	if (nr_pages > ARRAY_SIZE(frame_list))
+		nr_pages = ARRAY_SIZE(frame_list);
+
+	for (i = 0, pfn = pfn_start; i < nr_pages; ++i, ++pfn)
+		frame_list[i] = pfn;
+
+	set_xen_guest_handle(reservation.extent_start, frame_list);
+	reservation.nr_extents = nr_pages;
+
+	spin_lock_irqsave(&xen_reservation_lock, flags);
+
+	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+
+	if (rc <= 0)
+		return (rc < 0) ? rc : -ENOMEM;
+
+	for (i = 0, pfn = pfn_start; i < rc; ++i, ++pfn) {
+		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
+		       phys_to_machine_mapping_valid(pfn));
+		set_phys_to_machine(pfn, frame_list[i]);
+	}
+
+	spin_unlock_irqrestore(&xen_reservation_lock, flags);
+
+	return rc;
+}
+
+static void hotplug_allocated_memory(struct resource *r)
 {
-	unsigned long target = balloon_stats.target_pages;
+	int nid, rc;
+	resource_size_t r_size;
+	struct memory_block *mem;
+	unsigned long pfn;
+
+	r_size = r->end + 1 - r->start;
+	nid = memory_add_physaddr_to_nid(r->start);
+
+	rc = add_registered_memory(nid, r->start, r_size);
+
+	if (rc) {
+		pr_err("%s: add_registered_memory: Memory hotplug failed: %i\n",
+			__func__, rc);
+		balloon_stats.target_pages = balloon_stats.current_pages;
+		return;
+	}
+
+	if (xen_pv_domain())
+		for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); ++pfn)
+			if (!PageHighMem(pfn_to_page(pfn))) {
+				rc = HYPERVISOR_update_va_mapping(
+					(unsigned long)__va(pfn << PAGE_SHIFT),
+					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0);
+				BUG_ON(rc);
+			}
 
-	target = min(target,
-		     balloon_stats.current_pages +
-		     balloon_stats.balloon_low +
-		     balloon_stats.balloon_high);
+	rc = online_pages(PFN_DOWN(r->start), r_size >> PAGE_SHIFT);
 
-	return target;
+	if (rc) {
+		pr_err("%s: online_pages: Failed: %i\n", __func__, rc);
+		balloon_stats.target_pages = balloon_stats.current_pages;
+		return;
+	}
+
+	for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); pfn += PAGES_PER_SECTION) {
+		mem = find_memory_block(__pfn_to_section(pfn));
+		BUG_ON(!mem);
+		BUG_ON(!present_section_nr(mem->phys_index));
+		mutex_lock(&mem->state_mutex);
+		mem->state = MEM_ONLINE;
+		mutex_unlock(&mem->state_mutex);
+	}
+
+	balloon_stats.current_pages += r_size >> PAGE_SHIFT;
 }
 
+static enum bp_state request_additional_memory(long credit)
+{
+	int rc;
+	static struct resource *r;
+	static unsigned long pages_left;
+
+	if ((credit <= 0 || balloon_stats.balloon_low ||
+				balloon_stats.balloon_high) && !r)
+		return BP_DONE;
+
+	if (!r) {
+		r = allocate_memory_resource(credit);
+
+		if (!r)
+			return BP_ERROR;
+
+		pages_left = credit;
+	}
+
+	rc = allocate_additional_memory(r, pages_left);
+
+	if (rc < 0) {
+		if (balloon_stats.mh_policy == MH_POLICY_TRY_UNTIL_SUCCESS)
+			return BP_ERROR;
+
+		r = adjust_memory_resource(r, pages_left);
+
+		if (!r)
+			return BP_ERROR;
+	} else {
+		pages_left -= rc;
+
+		if (pages_left)
+			return BP_HUNGRY;
+	}
+
+	hotplug_allocated_memory(r);
+
+	r = NULL;
+
+	return BP_DONE;
+}
+#else
+static enum bp_state request_additional_memory(long credit)
+{
+	if (balloon_stats.balloon_low && balloon_stats.balloon_high &&
+			balloon_stats.target_pages > balloon_stats.current_pages)
+		balloon_stats.target_pages = balloon_stats.current_pages;
+	return BP_DONE;
+}
+#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
+
 static enum bp_state increase_reservation(unsigned long nr_pages)
 {
 	enum bp_state state = BP_DONE;
@@ -352,15 +547,17 @@ static enum bp_state decrease_reservation(unsigned long nr_pages)
  */
 static void balloon_process(struct work_struct *work)
 {
-	enum bp_state rc, state = BP_DONE;
+	enum bp_state rc, state;
 	long credit;
 
 	mutex_lock(&balloon_mutex);
 
 	do {
-		credit = current_target() - balloon_stats.current_pages;
+		credit = balloon_stats.target_pages - balloon_stats.current_pages;
 
-		if (credit > 0) {
+		state = request_additional_memory(credit);
+
+		if (credit > 0 && state == BP_DONE) {
 			rc = increase_reservation(credit);
 			state = (rc == BP_ERROR) ? BP_ERROR : state;
 		}
@@ -450,6 +647,11 @@ static int __init balloon_init(void)
 	balloon_stats.schedule_delay = 1;
 	balloon_stats.max_schedule_delay = 32;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	balloon_stats.boot_max_pfn = max_pfn;
+	balloon_stats.mh_policy = MH_POLICY_STOP_AT_FIRST_ERROR;
+#endif
+
 	register_balloon(&balloon_sysdev);
 
 	/*
@@ -506,6 +708,10 @@ BALLOON_SHOW(high_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_high));
 static SYSDEV_ULONG_ATTR(schedule_delay, 0644, balloon_stats.schedule_delay);
 static SYSDEV_ULONG_ATTR(max_schedule_delay, 0644, balloon_stats.max_schedule_delay);
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static SYSDEV_ULONG_ATTR(memory_hotplug_policy, 0644, balloon_stats.mh_policy);
+#endif
+
 static ssize_t show_target_kb(struct sys_device *dev, struct sysdev_attribute *attr,
 			      char *buf)
 {
@@ -568,7 +774,10 @@ static struct sysdev_attribute *balloon_attrs[] = {
 	&attr_target_kb,
 	&attr_target,
 	&attr_schedule_delay.attr,
-	&attr_max_schedule_delay.attr
+	&attr_max_schedule_delay.attr,
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	&attr_memory_hotplug_policy.attr
+#endif
 };
 
 static struct attribute *balloon_info_attrs[] = {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
