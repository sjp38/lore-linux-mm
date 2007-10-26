Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9QGrPrW009331
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 12:53:25 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9QGrPEQ095482
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:53:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9QGrOJG022983
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:53:25 -0600
Subject: [PATCH] Add "removable" to /sysfs to show memblock removability
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 09:56:51 -0700
Message-Id: <1193417811.9894.42.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here is the latest version with all the concerns/suggestions
addressed. Tested on x86-64 and ppc64 with and without 
CONFIG_HOTPLUG_MEMORY option.

Andrew, Can you include it in -mm ?

Sample output:

./memory/memory0/removable: 0
./memory/memory1/removable: 0
./memory/memory2/removable: 0
./memory/memory3/removable: 0
./memory/memory4/removable: 0
./memory/memory5/removable: 0
./memory/memory6/removable: 0
./memory/memory7/removable: 1
./memory/memory8/removable: 0
./memory/memory9/removable: 0
./memory/memory10/removable: 0
./memory/memory11/removable: 0
./memory/memory12/removable: 0
./memory/memory13/removable: 0
./memory/memory14/removable: 0
./memory/memory15/removable: 0
./memory/memory16/removable: 0
./memory/memory17/removable: 1
./memory/memory18/removable: 1
./memory/memory19/removable: 1
./memory/memory20/removable: 1
./memory/memory21/removable: 1
./memory/memory22/removable: 1

Thanks,
Badari

Each section of the memory has attributes in /sysfs. This patch adds 
file "removable" to show if this memory block is removable. This
helps user-level agents to identify section of the memory for hotplug 
memory remove.

Sections with MOVABLE pageblocks are removable.  And also pageblock 
that is entirely free may be removed regardless of the pageblock type. 
Similarly, a pageblock that starts with a reserved page will not be 
removable no matter what the pageblock type is. Detect these
two situations when reporting whether a section may be removed or not.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

 drivers/base/memory.c          |   19 +++++++++++++
 include/linux/memory_hotplug.h |   12 ++++++++
 mm/memory_hotplug.c            |   57 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+)

Index: linux-2.6.24-rc1/drivers/base/memory.c
===================================================================
--- linux-2.6.24-rc1.orig/drivers/base/memory.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/drivers/base/memory.c	2007-10-26 09:00:24.000000000 -0700
@@ -105,6 +105,21 @@ static ssize_t show_mem_phys_index(struc
 }
 
 /*
+ * show memory migrate type
+ */
+static ssize_t show_mem_removable(struct sys_device *dev, char *buf)
+{
+	unsigned long start_pfn;
+	int ret;
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+
+	start_pfn = section_nr_to_pfn(mem->phys_index);
+	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
+	return sprintf(buf, "%d\n", ret);
+}
+
+/*
  * online, offline, going offline, etc.
  */
 static ssize_t show_mem_state(struct sys_device *dev, char *buf)
@@ -263,6 +278,7 @@ static ssize_t show_phys_device(struct s
 static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
+static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
 
 #define mem_create_simple_file(mem, attr_name)	\
 	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
@@ -351,6 +367,8 @@ static int add_memory_block(unsigned lon
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
+	if (!ret)
+		ret = mem_create_simple_file(mem, removable);
 
 	return ret;
 }
@@ -395,6 +413,7 @@ int remove_memory_block(unsigned long no
 	mem_remove_simple_file(mem, phys_index);
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
+	mem_remove_simple_file(mem, removable);
 	unregister_memory(mem, section, NULL);
 
 	return 0;
Index: linux-2.6.24-rc1/include/linux/memory_hotplug.h
===================================================================
--- linux-2.6.24-rc1.orig/include/linux/memory_hotplug.h	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/include/linux/memory_hotplug.h	2007-10-26 09:00:24.000000000 -0700
@@ -171,6 +171,18 @@ static inline int mhp_notimplemented(con
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+
+extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
+
+#else
+static inline int is_mem_section_removable(unsigned long pfn,
+					unsigned long nr_pages)
+{
+	return 0;
+}
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
Index: linux-2.6.24-rc1/mm/memory_hotplug.c
===================================================================
--- linux-2.6.24-rc1.orig/mm/memory_hotplug.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/mm/memory_hotplug.c	2007-10-26 09:16:59.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/migrate.h>
 #include <linux/page-isolation.h>
+#include "internal.h"
 
 #include <asm/tlbflush.h>
 
@@ -328,6 +329,62 @@ error:
 EXPORT_SYMBOL_GPL(add_memory);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
+/* Returns true if the pageblock contains only free pages */
+static inline int pageblock_free(struct page *page)
+{
+	return PageBuddy(page) && page_order(page) >= pageblock_order;
+}
+
+/* Move to the next pageblock that is in use */
+static inline struct page *next_active_pageblock(struct page *page)
+{
+	/* Moving forward by at least 1 * pageblock_nr_pages */
+	int order = 1;
+
+	/* If the entire pageblock is free, move to the end of free page */
+	if (pageblock_free(page) && page_order(page) > pageblock_order)
+		order += page_order(page) - pageblock_order;
+
+	return page + (order * pageblock_nr_pages);
+}
+
+/*
+ * Find out if this section of the memory is removable.
+ */
+int
+is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
+{
+	int type;
+	struct page *page, *end_page;
+
+	/*
+	 * Check all pageblocks in the section to ensure they are all
+	 * removable.
+	 */
+	page = pfn_to_page(start_pfn);
+	end_page = page + nr_pages;
+
+	for (; page < end_page; page = next_active_pageblock(page)) {
+		type = get_pageblock_migratetype(page);
+
+		/*
+		 * For now, we can remove sections with only MOVABLE pages
+		 * or contain free pages
+		 */
+		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
+			return 0;
+
+		/*
+		 * Check if the first page is reserved, this can happen
+		 * for bootmem reserved pages pageblocks
+		 */
+		if (PageReserved(page))
+			return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Confirm all pages in a range [start, end) is belongs to the same zone.
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
