Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C80E16B0283
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:35 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:34 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4312438C8065
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:33 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301XvX319418
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:33 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301V9u013623
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:01:32 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 18/31] drivers/base/node: add unregister_mem_block_under_nodes()
Date: Thu,  2 May 2013 17:00:50 -0700
Message-Id: <1367539263-19999-19-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Provides similar functionality to
unregister_mem_block_section_under_nodes() (which was previously named
identically to the newly added funtion), but operates on all memory
sections included in the memory block, not just the specified one.
---
 drivers/base/node.c  | 53 +++++++++++++++++++++++++++++++++++++++-------------
 include/linux/node.h |  6 ++++++
 2 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index d3f981e..2861ef6 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -424,6 +424,24 @@ int register_mem_block_under_node(struct memory_block *mem_blk, int nid)
 	return 0;
 }
 
+static void unregister_mem_block_pfn_under_nodes(struct memory_block *mem_blk,
+		unsigned long pfn, nodemask_t *unlinked_nodes)
+{
+	int nid;
+
+	nid = get_nid_for_pfn(pfn);
+	if (nid < 0)
+		return;
+	if (!node_online(nid))
+		return;
+	if (node_test_and_set(nid, *unlinked_nodes))
+		return;
+	sysfs_remove_link(&node_devices[nid]->dev.kobj,
+			kobject_name(&mem_blk->dev.kobj));
+	sysfs_remove_link(&mem_blk->dev.kobj,
+			kobject_name(&node_devices[nid]->dev.kobj));
+}
+
 /*
  * unregister memory block under all nodes that a particular section it
  * contains spans spans
@@ -444,20 +462,29 @@ int unregister_mem_block_section_under_nodes(struct memory_block *mem_blk,
 
 	sect_start_pfn = section_nr_to_pfn(sec_num);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
-	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
-		int nid;
+	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++)
+		unregister_mem_block_pfn_under_nodes(mem_blk, pfn,
+				unlinked_nodes);
+	NODEMASK_FREE(unlinked_nodes);
+	return 0;
+}
 
-		nid = get_nid_for_pfn(pfn);
-		if (nid < 0)
-			continue;
-		if (!node_online(nid))
-			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
-			continue;
-		sysfs_remove_link(&node_devices[nid]->dev.kobj,
-			 kobject_name(&mem_blk->dev.kobj));
-		sysfs_remove_link(&mem_blk->dev.kobj,
-			 kobject_name(&node_devices[nid]->dev.kobj));
+int unregister_mem_block_under_nodes(struct memory_block *mem_blk)
+{
+	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
+	unsigned long pfn, sect_start_pfn, sect_end_pfn, sec_num;
+
+	if (!unlinked_nodes)
+		return -ENOMEM;
+	nodes_clear(*unlinked_nodes);
+
+	for (sec_num = mem_blk->start_section_nr;
+			sec_num < mem_blk->end_section_nr; sec_num++) {
+		sect_start_pfn = section_nr_to_pfn(sec_num);
+		sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+		for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++)
+			unregister_mem_block_pfn_under_nodes(mem_blk, pfn,
+					unlinked_nodes);
 	}
 	NODEMASK_FREE(unlinked_nodes);
 	return 0;
diff --git a/include/linux/node.h b/include/linux/node.h
index f438c45..04b464e 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -41,6 +41,7 @@ extern int register_mem_block_under_node(struct memory_block *mem_blk,
 extern int unregister_mem_block_section_under_nodes(
 					struct memory_block *mem_blk,
 					unsigned long sec_nr);
+extern int unregister_mem_block_under_nodes(struct memory_block *mem_blk);
 
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
@@ -75,6 +76,11 @@ static inline int unregister_mem_block_section_under_nodes(
 	return 0;
 }
 
+static inline int unregister_mem_block_under_nodes(struct memory_block *mem_blk)
+{
+	return 0;
+}
+
 static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
 						node_registration_func_t unreg)
 {
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
