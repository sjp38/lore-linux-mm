Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OGYKtA018528
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 12:34:20 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OGYJx5046856
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 10:34:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OGYJbN001953
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 10:34:19 -0600
Subject: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 09:37:46 -0700
Message-Id: <1193243866.30836.25.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Each memory block of the memory has attributes exported to /sysfs. 
This patch adds file "mem_type" to show that memory block's migrate type. 
This is useful to identify memory blocks for hotplug memory remove.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
---
 drivers/base/memory.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

Index: linux-2.6.23/drivers/base/memory.c
===================================================================
--- linux-2.6.23.orig/drivers/base/memory.c	2007-10-24 09:09:05.000000000 -0700
+++ linux-2.6.23/drivers/base/memory.c	2007-10-24 09:10:05.000000000 -0700
@@ -105,6 +105,26 @@ static ssize_t show_mem_phys_index(struc
 }
 
 /*
+ * show memory migrate type
+ */
+static ssize_t show_mem_type(struct sys_device *dev, char *buf)
+{
+	struct page *first_page;
+	int type;
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+
+	/*
+	 * Get the type of the firstpage in the memory block.
+	 * For now, assume that entire memory block is of same
+	 * type.
+	 */
+	first_page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
+	type =  get_pageblock_migratetype(first_page);
+	return sprintf(buf, "%s\n", migratetype_names[type]);
+}
+
+/*
  * online, offline, going offline, etc.
  */
 static ssize_t show_mem_state(struct sys_device *dev, char *buf)
@@ -270,6 +290,7 @@ static ssize_t show_phys_device(struct s
 static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
+static SYSDEV_ATTR(mem_type, 0444, show_mem_type, NULL);
 
 #define mem_create_simple_file(mem, attr_name)	\
 	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
@@ -358,6 +379,8 @@ static int add_memory_block(unsigned lon
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
+	if (!ret)
+		ret = mem_create_simple_file(mem, mem_type);
 
 	return ret;
 }
@@ -402,6 +425,7 @@ int remove_memory_block(unsigned long no
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
