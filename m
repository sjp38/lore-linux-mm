Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D91C86B0078
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:30:06 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MEA6jP032001
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:10:06 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8METxbd074950
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:29:59 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MEXf9i012562
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 08:33:42 -0600
Message-ID: <4C9A12E5.3000501@austin.ibm.com>
Date: Wed, 22 Sep 2010 09:29:57 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/8] Update memory block struct to have start and end phys
 index
References: <4C9A0F8F.2030409@austin.ibm.com>
In-Reply-To: <4C9A0F8F.2030409@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Update the 'phys_index' properties of a memory block to include a
'start_phys_index' which is the same as the current 'phys_index' property.
The property still appears as 'phys_index' in sysfs but the memory_block
struct name is updated to indicate the start and end values.
This also adds an 'end_phys_index' property to indicate the id of the
last section in th memory block.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c  |   28 ++++++++++++++++++++--------
 include/linux/memory.h |    3 ++-
 2 files changed, 22 insertions(+), 9 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-21 12:32:45.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-21 12:34:04.000000000 -0500
@@ -109,12 +109,20 @@ unregister_memory(struct memory_block *m
  * uses.
  */
 
-static ssize_t show_mem_phys_index(struct sys_device *dev,
+static ssize_t show_mem_start_phys_index(struct sys_device *dev,
 			struct sysdev_attribute *attr, char *buf)
 {
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
-	return sprintf(buf, "%08lx\n", mem->phys_index);
+	return sprintf(buf, "%08lx\n", mem->start_phys_index);
+}
+
+static ssize_t show_mem_end_phys_index(struct sys_device *dev,
+			struct sysdev_attribute *attr, char *buf)
+{
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+	return sprintf(buf, "%08lx\n", mem->end_phys_index);
 }
 
 /*
@@ -128,7 +136,7 @@ static ssize_t show_mem_removable(struct
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
 
-	start_pfn = section_nr_to_pfn(mem->phys_index);
+	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
 	return sprintf(buf, "%d\n", ret);
 }
@@ -191,7 +199,7 @@ memory_block_action(struct memory_block
 	int ret;
 	int old_state = mem->state;
 
-	psection = mem->phys_index;
+	psection = mem->start_phys_index;
 	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
 
 	/*
@@ -264,7 +272,7 @@ store_mem_state(struct sys_device *dev,
 	int ret = -EINVAL;
 
 	mem = container_of(dev, struct memory_block, sysdev);
-	phys_section_nr = mem->phys_index;
+	phys_section_nr = mem->start_phys_index;
 
 	if (!present_section_nr(phys_section_nr))
 		goto out;
@@ -296,7 +304,8 @@ static ssize_t show_phys_device(struct s
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
-static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
+static SYSDEV_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
+static SYSDEV_ATTR(end_phys_index, 0444, show_mem_end_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
 static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
@@ -476,16 +485,18 @@ static int add_memory_block(int nid, str
 	if (!mem)
 		return -ENOMEM;
 
-	mem->phys_index = __section_nr(section);
+	mem->start_phys_index = __section_nr(section);
 	mem->state = state;
 	mutex_init(&mem->state_mutex);
-	start_pfn = section_nr_to_pfn(mem->phys_index);
+	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
 	ret = register_memory(mem, section);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_index);
 	if (!ret)
+		ret = mem_create_simple_file(mem, end_phys_index);
+	if (!ret)
 		ret = mem_create_simple_file(mem, state);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_device);
@@ -507,6 +518,7 @@ int remove_memory_block(unsigned long no
 	mem = find_memory_block(section);
 	unregister_mem_sect_under_nodes(mem);
 	mem_remove_simple_file(mem, phys_index);
+	mem_remove_simple_file(mem, end_phys_index);
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
 	mem_remove_simple_file(mem, removable);
Index: linux-next/include/linux/memory.h
===================================================================
--- linux-next.orig/include/linux/memory.h	2010-09-21 11:59:28.000000000 -0500
+++ linux-next/include/linux/memory.h	2010-09-21 12:34:04.000000000 -0500
@@ -21,7 +21,8 @@
 #include <linux/mutex.h>
 
 struct memory_block {
-	unsigned long phys_index;
+	unsigned long start_phys_index;
+	unsigned long end_phys_index;
 	unsigned long state;
 	/*
 	 * This serializes all state change requests.  It isn't

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
