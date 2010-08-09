Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC746B02C9
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:41:44 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o79IQWNP006914
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 14:26:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o79IfUne1790198
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 14:41:30 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o79IfUP8003370
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 15:41:30 -0300
Message-ID: <4C604BD7.8020202@austin.ibm.com>
Date: Mon, 09 Aug 2010 13:41:27 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 6/8] v5  Update the node sysfs code
References: <4C60407C.2080608@austin.ibm.com>
In-Reply-To: <4C60407C.2080608@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>
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

Index: linux-2.6/drivers/base/node.c
===================================================================
--- linux-2.6.orig/drivers/base/node.c	2010-08-09 07:36:50.000000000 -0500
+++ linux-2.6/drivers/base/node.c	2010-08-09 07:53:30.000000000 -0500
@@ -346,8 +346,10 @@ int register_mem_sect_under_node(struct
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
 
@@ -371,7 +373,8 @@ int register_mem_sect_under_node(struct
 }
 
 /* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
+int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+				    unsigned long phys_index)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -383,7 +386,8 @@ int unregister_mem_sect_under_nodes(stru
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
+
+	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2010-08-09 07:50:28.000000000 -0500
+++ linux-2.6/drivers/base/memory.c	2010-08-09 07:53:30.000000000 -0500
@@ -555,9 +555,9 @@ int remove_memory_block(unsigned long no
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
+	unregister_mem_sect_under_nodes(mem, __section_nr(section));
 
 	if (atomic_dec_and_test(&mem->section_count)) {
-		unregister_mem_sect_under_nodes(mem);
 		mem_remove_simple_file(mem, phys_index);
 		mem_remove_simple_file(mem, end_phys_index);
 		mem_remove_simple_file(mem, state);
Index: linux-2.6/include/linux/node.h
===================================================================
--- linux-2.6.orig/include/linux/node.h	2010-08-09 07:36:50.000000000 -0500
+++ linux-2.6/include/linux/node.h	2010-08-09 07:53:30.000000000 -0500
@@ -44,7 +44,8 @@ extern int register_cpu_under_node(unsig
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						int nid);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
+extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+					   unsigned long phys_index);
 
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
@@ -72,7 +73,8 @@ static inline int register_mem_sect_unde
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
