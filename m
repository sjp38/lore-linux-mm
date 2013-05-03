Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B36926B0280
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:33 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:33 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 202FAC90048
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:29 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301T2C314940
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:29 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Skc012175
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:28 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 16/31] drivers/base/node,memory: rename function to match interface
Date: Thu,  2 May 2013 17:00:48 -0700
Message-Id: <1367539263-19999-17-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Rename register_mem_sect_under_node() to register_mem_block_under_node() and rename unregister_mem_sect_under_nodes() to unregister_mem_block_under_nodes() to reflect that both of these functions are given memory_blocks instead of mem_sections
---
 drivers/base/memory.c |  4 ++--
 drivers/base/node.c   | 10 +++++-----
 include/linux/node.h  |  8 ++++----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 5247698..b6e3f26 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -619,7 +619,7 @@ static int add_memory_section(int nid, struct mem_section *section,
 	if (!ret) {
 		if (context == HOTPLUG &&
 		    mem->section_count == sections_per_block)
-			ret = register_mem_sect_under_node(mem, nid);
+			ret = register_mem_block_under_node(mem, nid);
 	}
 
 	mutex_unlock(&mem_sysfs_mutex);
@@ -653,7 +653,7 @@ static int remove_memory_block(unsigned long node_id,
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
-	unregister_mem_sect_under_nodes(mem, __section_nr(section));
+	unregister_mem_block_under_nodes(mem, __section_nr(section));
 
 	mem->section_count--;
 	if (mem->section_count == 0) {
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 7616a77c..ad45b59 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -388,8 +388,8 @@ static int get_nid_for_pfn(unsigned long pfn)
 	return pfn_to_nid(pfn);
 }
 
-/* register memory section under specified node if it spans that node */
-int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
+/* register memory block under specified node if it spans that node */
+int register_mem_block_under_node(struct memory_block *mem_blk, int nid)
 {
 	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -424,8 +424,8 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 	return 0;
 }
 
-/* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+/* unregister memory block under all nodes that it spans */
+int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
 				    unsigned long phys_index)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
@@ -485,7 +485,7 @@ static int link_mem_sections(int nid)
 
 		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
 
-		ret = register_mem_sect_under_node(mem_blk, nid);
+		ret = register_mem_block_under_node(mem_blk, nid);
 		if (!err)
 			err = ret;
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 2115ad5..e20a203 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -36,9 +36,9 @@ extern int register_one_node(int nid);
 extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
-extern int register_mem_sect_under_node(struct memory_block *mem_blk,
+extern int register_mem_block_under_node(struct memory_block *mem_blk,
 						int nid);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+extern int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
 #ifdef CONFIG_HUGETLBFS
@@ -62,12 +62,12 @@ static inline int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
 	return 0;
 }
-static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
+static inline int register_mem_block_under_node(struct memory_block *mem_blk,
 							int nid)
 {
 	return 0;
 }
-static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+static inline int unregister_mem_block_under_nodes(struct memory_block *mem_blk,
 						  unsigned long phys_index)
 {
 	return 0;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
