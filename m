Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PMWSKQ020548
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:32:28 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PMWSd0107600
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:32:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PMWRw9018737
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:32:27 -0600
Subject: [PATCH] Add "removable" to /sysfs to show memblock removability
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 15:35:56 -0700
Message-Id: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Dave & Mel,

Here is the new version of the patch with your suggestion. 
Dave, does this suite your taste ? Mel, Can you handle the 
corner case you mentioned earlier ?

Thanks,
Badari

Each section of the memory has attributes in /sysfs. This patch adds 
file "removable" to show if this memory block is removable. This
helps user-level agents to identify section of the memory for hotplug 
memory remove.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 

 drivers/base/memory.c           |   21 +++++++++++++++++++++
 include/linux/pageblock-flags.h |    2 ++
 mm/page_alloc.c                 |   27 +++++++++++++++++++++++++++
 3 files changed, 50 insertions(+)

Index: linux-2.6.24-rc1/drivers/base/memory.c
===================================================================
--- linux-2.6.24-rc1.orig/drivers/base/memory.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/drivers/base/memory.c	2007-10-25 17:14:32.000000000 -0700
@@ -105,6 +105,23 @@ static ssize_t show_mem_phys_index(struc
 }
 
 /*
+ * show memory migrate type
+ */
+static ssize_t show_mem_removable(struct sys_device *dev, char *buf)
+{
+	unsigned long start_pfn;
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+
+	start_pfn = section_nr_to_pfn(mem->phys_index);
+	if (is_mem_section_removable(start_pfn, PAGES_PER_SECTION))
+		return sprintf(buf, "True\n");
+	else
+		return sprintf(buf, "False\n");
+
+}
+
+/*
  * online, offline, going offline, etc.
  */
 static ssize_t show_mem_state(struct sys_device *dev, char *buf)
@@ -263,6 +280,7 @@ static ssize_t show_phys_device(struct s
 static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
+static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
 
 #define mem_create_simple_file(mem, attr_name)	\
 	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
@@ -351,6 +369,8 @@ static int add_memory_block(unsigned lon
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
+	if (!ret)
+		ret = mem_create_simple_file(mem, removable);
 
 	return ret;
 }
@@ -395,6 +415,7 @@ int remove_memory_block(unsigned long no
 	mem_remove_simple_file(mem, phys_index);
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
+	mem_remove_simple_file(mem, removable);
 	unregister_memory(mem, section, NULL);
 
 	return 0;
Index: linux-2.6.24-rc1/include/linux/pageblock-flags.h
===================================================================
--- linux-2.6.24-rc1.orig/include/linux/pageblock-flags.h	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/include/linux/pageblock-flags.h	2007-10-25 17:14:54.000000000 -0700
@@ -67,6 +67,8 @@ unsigned long get_pageblock_flags_group(
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
 
+int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
+
 #define get_pageblock_flags(page) \
 			get_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
 #define set_pageblock_flags(page) \
Index: linux-2.6.24-rc1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc1.orig/mm/page_alloc.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/mm/page_alloc.c	2007-10-25 17:29:30.000000000 -0700
@@ -4489,6 +4489,33 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+/*
+ * Find out if this section of the memory is removable.
+ */
+int
+is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
+{
+	int type, i = 0;
+	struct page *page;
+
+	/*
+	 * Check all pageblocks in the section to ensure they are all
+	 * removable.
+	 */
+	page = pfn_to_page(start_pfn);
+	while (i < nr_pages) {
+		type = get_pageblock_migratetype(page + i);
+
+		/*
+		 * For now, we can remove sections with only MOVABLE pages.
+		 */
+		if (type != MIGRATE_MOVABLE)
+			return 0;
+		i += pageblock_nr_pages;
+	}
+	return 1;
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
