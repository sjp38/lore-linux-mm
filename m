Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 871F76B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:33:46 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91IXv8W011281
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 14:33:57 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o91IXgqk461594
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 14:33:42 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91IbS72020149
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:37:28 -0600
Message-ID: <4CA62982.5080900@austin.ibm.com>
Date: Fri, 01 Oct 2010 13:33:38 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 5/9] v3 rename phys_index properties of memory block struct
References: <4CA62700.7010809@austin.ibm.com>
In-Reply-To: <4CA62700.7010809@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Update the 'phys_index' property of a the memory_block struct to be
called start_section_nr, and add a end_section_nr property.  The
data tracked here is the same but the updated naming is more in line
with what is stored here, namely the first and last section number
that the memory block spans.

The names presented to userspace remain the same, phys_index for
start_section_nr and end_phys_index for end_section_nr, to avoid breaking
anything in userspace.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c  |   39 ++++++++++++++++++++++++++++++---------
 include/linux/memory.h |    3 ++-
 2 files changed, 32 insertions(+), 10 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-30 14:46:00.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-30 14:46:09.000000000 -0500
@@ -97,7 +97,7 @@
 	int error;
 
 	memory->sysdev.cls = &memory_sysdev_class;
-	memory->sysdev.id = memory->phys_index / sections_per_block;
+	memory->sysdev.id = memory->start_section_nr / sections_per_block;
 
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
+	phys_index = mem->start_section_nr / sections_per_block;
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
+	phys_index = mem->end_section_nr / sections_per_block;
+	return sprintf(buf, "%08lx\n", phys_index);
 }
 
 /*
@@ -158,7 +172,7 @@
 		container_of(dev, struct memory_block, sysdev);
 
 	for (i = 0; i < sections_per_block; i++) {
-		pfn = section_nr_to_pfn(mem->phys_index + i);
+		pfn = section_nr_to_pfn(mem->start_section_nr + i);
 		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
 	}
 
@@ -275,14 +289,15 @@
 		mem->state = MEM_GOING_OFFLINE;
 
 	for (i = 0; i < sections_per_block; i++) {
-		ret = memory_section_action(mem->phys_index + i, to_state);
+		ret = memory_section_action(mem->start_section_nr + i,
+					    to_state);
 		if (ret)
 			break;
 	}
 
 	if (ret) {
 		for (i = 0; i < sections_per_block; i++)
-			memory_section_action(mem->phys_index + i,
+			memory_section_action(mem->start_section_nr + i,
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
+	mem->start_section_nr =
+			base_memory_block_id(scn_nr) * sections_per_block;
+	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
 	mem->section_count++;
 	mutex_init(&mem->state_mutex);
-	start_pfn = section_nr_to_pfn(mem->phys_index);
+	start_pfn = section_nr_to_pfn(mem->start_section_nr);
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
@@ -572,6 +592,7 @@
 	if (mem->section_count == 0) {
 		unregister_mem_sect_under_nodes(mem);
 		mem_remove_simple_file(mem, phys_index);
+		mem_remove_simple_file(mem, end_phys_index);
 		mem_remove_simple_file(mem, state);
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
Index: linux-next/include/linux/memory.h
===================================================================
--- linux-next.orig/include/linux/memory.h	2010-09-30 14:44:39.000000000 -0500
+++ linux-next/include/linux/memory.h	2010-09-30 14:46:09.000000000 -0500
@@ -21,7 +21,8 @@
 #include <linux/mutex.h>
 
 struct memory_block {
-	unsigned long phys_index;
+	unsigned long start_section_nr;
+	unsigned long end_section_nr;
 	unsigned long state;
 	int section_count;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
