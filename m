Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 677636B0283
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:36 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:35 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6DF8D38C8056
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:29 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301TjR285386
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301T1g013496
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:01:29 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 17/31] drivers/base/node: rename unregister_mem_blk_under_nodes() to be more acurate
Date: Thu,  2 May 2013 17:00:49 -0700
Message-Id: <1367539263-19999-18-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

unregister_mem_block_under_nodes() only unregisters a single section in
the mem block under all nodes, not the entire mem block. Rename it to
unregister_mem_block_section_under_nodes(). Also rename the phys_index
param to indicate that it is a section number.
---
 drivers/base/memory.c |  2 +-
 drivers/base/node.c   | 11 +++++++----
 include/linux/node.h  | 10 ++++++----
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index b6e3f26..90e387c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -653,7 +653,7 @@ static int remove_memory_block(unsigned long node_id,
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
-	unregister_mem_block_under_nodes(mem, __section_nr(section));
+	unregister_mem_block_section_under_nodes(mem, __section_nr(section));
 
 	mem->section_count--;
 	if (mem->section_count == 0) {
diff --git a/drivers/base/node.c b/drivers/base/node.c
index ad45b59..d3f981e 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -424,9 +424,12 @@ int register_mem_block_under_node(struct memory_block *mem_blk, int nid)
 	return 0;
 }
 
-/* unregister memory block under all nodes that it spans */
-int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
-				    unsigned long phys_index)
+/*
+ * unregister memory block under all nodes that a particular section it
+ * contains spans spans
+ */
+int unregister_mem_block_section_under_nodes(struct memory_block *mem_blk,
+				    unsigned long sec_num)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -439,7 +442,7 @@ int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
 
-	sect_start_pfn = section_nr_to_pfn(phys_index);
+	sect_start_pfn = section_nr_to_pfn(sec_num);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
diff --git a/include/linux/node.h b/include/linux/node.h
index e20a203..f438c45 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -38,8 +38,9 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_block_under_node(struct memory_block *mem_blk,
 						int nid);
-extern int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
-					   unsigned long phys_index);
+extern int unregister_mem_block_section_under_nodes(
+					struct memory_block *mem_blk,
+					unsigned long sec_nr);
 
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
@@ -67,8 +68,9 @@ static inline int register_mem_block_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
-						  unsigned long phys_index)
+static inline int unregister_mem_block_section_under_nodes(
+						struct memory_block *mem_blk,
+						unsigned long sec_nr)
 {
 	return 0;
 }
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
