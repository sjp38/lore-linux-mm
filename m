Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63FD78D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:44:49 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KGda94005635
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:39:36 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KGiVQJ141870
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:44:31 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KGiUMW002388
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:44:30 -0700
Message-ID: <4D38666D.7010509@austin.ibm.com>
Date: Thu, 20 Jan 2011 10:44:29 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/4] Update phys_index to [start|end]_section_nr
References: <4D386498.9080201@austin.ibm.com>
In-Reply-To: <4D386498.9080201@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

Update the 'phys_index' property of a the memory_block struct to be
called start_section_nr, and add a end_section_nr property.  The
data tracked here is the same but the updated naming is more in line
with what is stored here, namely the first and last section number
that the memory block spans.

The names presented to userspace remain the same, phys_index for
start_section_nr and end_phys_index for end_section_nr, to avoid breaking
anything in userspace.

This also updates the node sysfs code to be aware of the new capability for
a memory block to contain multiple memory sections and be aware of the memory
block structure name changes (start_section_nr).  This requires an additional
parameter to unregister_mem_sect_under_nodes so that we know which memory
section of the memory block to unregister.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
Reviewed-by: Robin Holt <holt@sgi.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 drivers/base/memory.c  |   41 +++++++++++++++++++++++++++++++----------
 drivers/base/node.c    |   12 ++++++++----
 include/linux/memory.h |    3 ++-
 include/linux/node.h   |    6 ++++--
 4 files changed, 45 insertions(+), 17 deletions(-)

Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2011-01-20 08:20:54.000000000 -0600
+++ linux-2.6/drivers/base/memory.c	2011-01-20 08:20:56.000000000 -0600
@@ -97,7 +97,7 @@ int register_memory(struct memory_block
 	int error;
 
 	memory->sysdev.cls = &memory_sysdev_class;
-	memory->sysdev.id = memory->phys_index / sections_per_block;
+	memory->sysdev.id = memory->start_section_nr / sections_per_block;
 
 	error = sysdev_register(&memory->sysdev);
 	return error;
@@ -138,12 +138,26 @@ static unsigned long get_memory_block_si
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
@@ -158,7 +172,7 @@ static ssize_t show_mem_removable(struct
 		container_of(dev, struct memory_block, sysdev);
 
 	for (i = 0; i < sections_per_block; i++) {
-		pfn = section_nr_to_pfn(mem->phys_index + i);
+		pfn = section_nr_to_pfn(mem->start_section_nr + i);
 		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
 	}
 
@@ -275,14 +289,15 @@ static int memory_block_change_state(str
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
@@ -330,7 +345,8 @@ static ssize_t show_phys_device(struct s
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
-static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
+static SYSDEV_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
+static SYSDEV_ATTR(end_phys_index, 0444, show_mem_end_phys_index, NULL);
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
 static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
@@ -522,17 +538,21 @@ static int init_memory_block(struct memo
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
@@ -575,11 +595,12 @@ int remove_memory_block(unsigned long no
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
+	unregister_mem_sect_under_nodes(mem, __section_nr(section));
 
 	mem->section_count--;
 	if (mem->section_count == 0) {
-		unregister_mem_sect_under_nodes(mem);
 		mem_remove_simple_file(mem, phys_index);
+		mem_remove_simple_file(mem, end_phys_index);
 		mem_remove_simple_file(mem, state);
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
Index: linux-2.6/drivers/base/node.c
===================================================================
--- linux-2.6.orig/drivers/base/node.c	2011-01-20 08:20:03.000000000 -0600
+++ linux-2.6/drivers/base/node.c	2011-01-20 08:20:56.000000000 -0600
@@ -375,8 +375,10 @@ int register_mem_sect_under_node(struct
 		return -EFAULT;
 	if (!node_online(nid))
 		return 0;
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
+	sect_end_pfn += PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int page_nid;
 
@@ -400,7 +402,8 @@ int register_mem_sect_under_node(struct
 }
 
 /* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
+int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+				    unsigned long phys_index)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -412,7 +415,8 @@ int unregister_mem_sect_under_nodes(stru
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
+
+	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
Index: linux-2.6/include/linux/memory.h
===================================================================
--- linux-2.6.orig/include/linux/memory.h	2011-01-20 08:18:22.000000000 -0600
+++ linux-2.6/include/linux/memory.h	2011-01-20 08:20:56.000000000 -0600
@@ -21,7 +21,8 @@
 #include <linux/mutex.h>
 
 struct memory_block {
-	unsigned long phys_index;
+	unsigned long start_section_nr;
+	unsigned long end_section_nr;
 	unsigned long state;
 	int section_count;
 
Index: linux-2.6/include/linux/node.h
===================================================================
--- linux-2.6.orig/include/linux/node.h	2011-01-20 08:18:22.000000000 -0600
+++ linux-2.6/include/linux/node.h	2011-01-20 08:20:56.000000000 -0600
@@ -39,7 +39,8 @@ extern int register_cpu_under_node(unsig
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						int nid);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
+extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+					   unsigned long phys_index);
 
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
@@ -67,7 +68,8 @@ static inline int register_mem_sect_unde
 {
 	return 0;
 }
-static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
+static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+						  unsigned long phys_index)
 {
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
