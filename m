Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PFqZcb009335
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:52:35 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PFqV8E083470
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 09:52:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PFqUhk022038
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 09:52:31 -0600
Subject: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 08:55:56 -0700
Message-Id: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Kame & Mel,

Here is the updated patch, which checks all the pages in the section
to cover all archs. Are you okay with this ? 

Thanks,
Badari

Here is the output:

./memory0/mem_type: Multiple
./memory1/mem_type: Multiple
./memory2/mem_type: Movable
./memory3/mem_type: Movable
./memory4/mem_type: Movable
./memory5/mem_type: Movable
./memory6/mem_type: Movable
./memory7/mem_type: Movable
..

Each section of the memory has attributes in /sysfs. This patch adds 
file "mem_type" to show that memory section's migrate type. This is useful
to identify section of the memory for hotplug memory remove.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
 drivers/base/memory.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

Index: linux-2.6.23/drivers/base/memory.c
===================================================================
--- linux-2.6.23.orig/drivers/base/memory.c	2007-10-23 15:19:14.000000000 -0700
+++ linux-2.6.23/drivers/base/memory.c	2007-10-25 10:34:41.000000000 -0700
@@ -105,6 +105,35 @@ static ssize_t show_mem_phys_index(struc
 }
 
 /*
+ * show memory migrate type
+ */
+static ssize_t show_mem_type(struct sys_device *dev, char *buf)
+{
+	struct page *page;
+	int type;
+	int i = pageblock_nr_pages;
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+
+	/*
+	 * Get the type of first page in the block
+	 */
+	page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
+	type = get_pageblock_migratetype(page);
+
+	/*
+	 * Check the migrate type of other pages in this section.
+	 * If the type doesn't match, report it.
+	 */
+	while (i < PAGES_PER_SECTION) {
+		if (type != get_pageblock_migratetype(page + i))
+			return sprintf(buf, "Multiple\n");
+		i += pageblock_nr_pages;
+	}
+	return sprintf(buf, "%s\n", migratetype_names[type]);
+}
+
+/*
  * online, offline, going offline, etc.
  */
 static ssize_t show_mem_state(struct sys_device *dev, char *buf)
@@ -263,6 +292,7 @@ static ssize_t show_phys_device(struct s
 static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
+static SYSDEV_ATTR(mem_type, 0444, show_mem_type, NULL);
 
 #define mem_create_simple_file(mem, attr_name)	\
 	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
@@ -351,6 +381,8 @@ static int add_memory_block(unsigned lon
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
+	if (!ret)
+		ret = mem_create_simple_file(mem, mem_type);
 
 	return ret;
 }
@@ -395,6 +427,7 @@ int remove_memory_block(unsigned long no
 	mem_remove_simple_file(mem, phys_index);
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
+	mem_remove_simple_file(mem, mem_type);
 	unregister_memory(mem, section, NULL);
 
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
