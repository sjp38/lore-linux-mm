Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C97916B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:26:50 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8RJBhaX004108
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:11:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8RJQJ331851626
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:26:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8RJQJxQ025675
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:26:19 -0400
Message-ID: <4CA0EFDA.9020703@austin.ibm.com>
Date: Mon, 27 Sep 2010 14:26:18 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 5/8] v2 Add end_phys_index file
References: <4CA0EBEB.1030204@austin.ibm.com>
In-Reply-To: <4CA0EBEB.1030204@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Update the 'phys_index' properties of a memory block to include a
'start_phys_index' which is the same as the current 'phys_index' property.
The property still appears as 'phys_index' in sysfs but the memory_block
struct name is updated to indicate the start and end values.
This also adds an 'end_phys_index' property to indicate the id of the
last section in th memory block.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c  |   39 ++++++++++++++++++++++++++++++---------
 include/linux/memory.h |    3 ++-
 2 files changed, 32 insertions(+), 10 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-27 13:50:18.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-27 13:50:38.000000000 -0500
@@ -97,7 +97,7 @@
 	int error;
 
 	memory->sysdev.cls = &memory_sysdev_class;
-	memory->sysdev.id = memory->phys_index / sections_per_block;
+	memory->sysdev.id = memory->start_phys_index / sections_per_block;
 
 	error = sysdev_register(&memory->sysdev);
 	return error;
@@ -138,12 +138,26 @@
  * uses.
  */
 
-static ssize_t show_mem_phys_index(struct sys_device *dev,
+static ssize_t show_mem_start_phys_index(struct sys_device *dev,
 			struct sysdev_attribute *attr, char *buf)
 {
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
-	return sprintf(buf, "%08lx\n", mem->phys_index / sections_per_block);
+	unsigned long phys_index;
+
+	phys_index = mem->start_phys_index / sections_per_block;
+	return sprintf(buf, "%08lx\n", phys_index);
+}
+
+static ssize_t show_mem_end_phys_index(struct sys_device *dev,
+			struct sysdev_attribute *attr, char *buf)
+{
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+	unsigned long phys_index;
+
+	phys_index = mem->end_phys_index / sections_per_block;
+	return sprintf(buf, "%08lx\n", phys_index);
 }
 
 /*
@@ -158,7 +172,7 @@
 		container_of(dev, struct memory_block, sysdev);
 
 	for (i = 0; i < sections_per_block; i++) {
-		pfn = section_nr_to_pfn(mem->phys_index + i);
+		pfn = section_nr_to_pfn(mem->start_phys_index + i);
 		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
 	}
 
@@ -275,14 +289,15 @@
 		mem->state = MEM_GOING_OFFLINE;
 
 	for (i = 0; i < sections_per_block; i++) {
-		ret = memory_section_action(mem->phys_index + i, to_state);
+		ret = memory_section_action(mem->start_phys_index + i,
+					    to_state);
 		if (ret)
 			break;
 	}
 
 	if (ret) {
 		for (i = 0; i < sections_per_block; i++)
-			memory_section_action(mem->phys_index + i,
+			memory_section_action(mem->start_phys_index + i,
 					      from_state_req);
 
 		mem->state = from_state_req;
@@ -330,7 +345,8 @@
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
-static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
+static SYSDEV_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
+static SYSDEV_ATTR(end_phys_index, 0444, show_mem_end_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
 static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
@@ -514,17 +530,21 @@
 		return -ENOMEM;
 
 	scn_nr = __section_nr(section);
-	mem->phys_index = base_memory_block_id(scn_nr) * sections_per_block;
+	mem->start_phys_index =
+			base_memory_block_id(scn_nr) * sections_per_block;
+	mem->end_phys_index = mem->start_phys_index + sections_per_block - 1;
 	mem->state = state;
 	atomic_inc(&mem->section_count);
 	mutex_init(&mem->state_mutex);
-	start_pfn = section_nr_to_pfn(mem->phys_index);
+	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
 	ret = register_memory(mem);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_index);
 	if (!ret)
+		ret = mem_create_simple_file(mem, end_phys_index);
+	if (!ret)
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
@@ -571,6 +591,7 @@
 	if (atomic_dec_and_test(&mem->section_count)) {
 		unregister_mem_sect_under_nodes(mem);
 		mem_remove_simple_file(mem, phys_index);
+		mem_remove_simple_file(mem, end_phys_index);
 		mem_remove_simple_file(mem, state);
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
Index: linux-next/include/linux/memory.h
===================================================================
--- linux-next.orig/include/linux/memory.h	2010-09-27 13:49:37.000000000 -0500
+++ linux-next/include/linux/memory.h	2010-09-27 13:50:38.000000000 -0500
@@ -22,7 +22,8 @@
 #include <asm/atomic.h>
 
 struct memory_block {
-	unsigned long phys_index;
+	unsigned long start_phys_index;
+	unsigned long end_phys_index;
 	unsigned long state;
 	atomic_t section_count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
