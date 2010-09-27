Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A0C906B004A
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:27:13 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8RJ8AmW026354
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:08:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8RJRBZn402798
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:27:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8RJRA7s029107
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:27:11 -0400
Message-ID: <4CA0F00D.9000702@austin.ibm.com>
Date: Mon, 27 Sep 2010 14:27:09 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 6/8] v2 Update node sysfs code
References: <4CA0EBEB.1030204@austin.ibm.com>
In-Reply-To: <4CA0EBEB.1030204@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Update the node sysfs code to be aware of the new capability for a memory
block to contain multiple memory sections.  This requires an additional
parameter to unregister_mem_sect_under_nodes so that we know which memory
section of the memory block to unregister.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c |    2 +-
 drivers/base/node.c   |   12 ++++++++----
 include/linux/node.h  |    6 ++++--
 3 files changed, 13 insertions(+), 7 deletions(-)

Index: linux-next/drivers/base/node.c
===================================================================
--- linux-next.orig/drivers/base/node.c	2010-09-27 13:49:36.000000000 -0500
+++ linux-next/drivers/base/node.c	2010-09-27 13:50:43.000000000 -0500
@@ -346,8 +346,10 @@
 		return -EFAULT;
 	if (!node_online(nid))
 		return 0;
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
+	sect_end_pfn += PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int page_nid;
 
@@ -371,7 +373,8 @@
 }
 
 /* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
+int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+				    unsigned long phys_index)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -383,7 +386,8 @@
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
+
+	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-27 13:50:38.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-27 13:50:43.000000000 -0500
@@ -587,9 +587,9 @@
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
+	unregister_mem_sect_under_nodes(mem, __section_nr(section));
 
 	if (atomic_dec_and_test(&mem->section_count)) {
-		unregister_mem_sect_under_nodes(mem);
 		mem_remove_simple_file(mem, phys_index);
 		mem_remove_simple_file(mem, end_phys_index);
 		mem_remove_simple_file(mem, state);
Index: linux-next/include/linux/node.h
===================================================================
--- linux-next.orig/include/linux/node.h	2010-09-27 13:49:36.000000000 -0500
+++ linux-next/include/linux/node.h	2010-09-27 13:50:43.000000000 -0500
@@ -44,7 +44,8 @@
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						int nid);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
+extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+					   unsigned long phys_index);
 
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
@@ -72,7 +73,8 @@
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
