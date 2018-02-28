Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A53606B000E
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:03:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y8so1416480itb.4
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:03:28 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h33si392440iod.168.2018.02.27.19.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:03:27 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 5/6] mm/memory_hotplug: don't read nid from struct page during hotplug
Date: Tue, 27 Feb 2018 22:03:07 -0500
Message-Id: <20180228030308.1116-6-pasha.tatashin@oracle.com>
In-Reply-To: <20180228030308.1116-1-pasha.tatashin@oracle.com>
References: <20180228030308.1116-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

register_mem_sect_under_node is careful to check the node id of each
pfn in the memblock range to handle configurations with interleaving
nodes. This is not really needed for the memory hotplug because hotadded
ranges are bound to a single NUMA node. We simply cannot handle
interleaving NUMA nodes in the same memblock currently and there are no
signs that anybody would want anything like that in future. That would
require much more refactoring.

This is a preparatory patch for later patches.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/base/memory.c  |  4 ++--
 drivers/base/node.c    | 22 +++++++++++++++-------
 include/linux/memory.h |  2 +-
 include/linux/node.h   |  4 ++--
 mm/memory_hotplug.c    |  2 +-
 5 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index deb3f029b451..79fcd2bae96b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -712,7 +712,7 @@ static int add_memory_block(int base_section_nr)
  * need an interface for the VM to add new memory regions,
  * but without onlining it.
  */
-int register_new_memory(int nid, struct mem_section *section)
+int hotplug_memory_register(int nid, struct mem_section *section)
 {
 	int ret = 0;
 	struct memory_block *mem;
@@ -731,7 +731,7 @@ int register_new_memory(int nid, struct mem_section *section)
 	}
 
 	if (mem->section_count == sections_per_block)
-		ret = register_mem_sect_under_node(mem, nid);
+		ret = register_mem_sect_under_node(mem, nid, false);
 out:
 	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
diff --git a/drivers/base/node.c b/drivers/base/node.c
index ee090ab9171c..d7cfc8d8a5c5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -397,7 +397,8 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 }
 
 /* register memory section under specified node if it spans that node */
-int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
+int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
+				 bool check_nid)
 {
 	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -423,11 +424,18 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 			continue;
 		}
 
-		page_nid = get_nid_for_pfn(pfn);
-		if (page_nid < 0)
-			continue;
-		if (page_nid != nid)
-			continue;
+		/*
+		 * We need to check if page belongs to nid only for the boot
+		 * case, during hotplug we know that all pages in the memory
+		 * block belong to the same node.
+		 */
+		if (check_nid) {
+			page_nid = get_nid_for_pfn(pfn);
+			if (page_nid < 0)
+				continue;
+			if (page_nid != nid)
+				continue;
+		}
 		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 					&mem_blk->dev.kobj,
 					kobject_name(&mem_blk->dev.kobj));
@@ -502,7 +510,7 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
 
 		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
 
-		ret = register_mem_sect_under_node(mem_blk, nid);
+		ret = register_mem_sect_under_node(mem_blk, nid, true);
 		if (!err)
 			err = ret;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index f71e732c77b2..9f8cd856ca1e 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -109,7 +109,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
-extern int register_new_memory(int, struct mem_section *);
+int hotplug_memory_register(int nid, struct mem_section *section);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int unregister_memory_section(struct mem_section *);
 #endif
diff --git a/include/linux/node.h b/include/linux/node.h
index 4ece0fee0ffc..41f171861dcc 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -67,7 +67,7 @@ extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
-						int nid);
+						int nid, bool check_nid);
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
@@ -97,7 +97,7 @@ static inline int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 	return 0;
 }
 static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
-							int nid)
+							int nid, bool check_nid)
 {
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 565048f496f7..477e183a4ac7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -279,7 +279,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (!want_memblock)
 		return 0;
 
-	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
+	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
 }
 
 /*
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
