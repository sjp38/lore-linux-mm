Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 341246B0009
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:59:38 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w125so744437itf.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:59:38 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a22si4867257ioc.260.2018.02.15.08.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 08:59:37 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 5/6] mm/memory_hotplug: don't read nid from struct page during hotplug
Date: Thu, 15 Feb 2018 11:59:19 -0500
Message-Id: <20180215165920.8570-6-pasha.tatashin@oracle.com>
In-Reply-To: <20180215165920.8570-1-pasha.tatashin@oracle.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

During memory hotplugging the probe routine will leave struct pages
uninitialized, the same as it is currently done during boot. Therefore, we
do not want to access the inside of struct pages before
__init_single_page() is called during onlining.

Because during hotplug we know that pages in one memory block belong to
the same numa node, we can skip the checking. We should keep checking for
the boot case.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 drivers/base/memory.c |  2 +-
 drivers/base/node.c   | 22 +++++++++++++++-------
 include/linux/node.h  |  4 ++--
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index deb3f029b451..a14fb0cd424a 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
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
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
