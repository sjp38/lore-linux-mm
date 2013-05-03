Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 04D8F6B0284
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:35 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:35 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 644EAC9001A
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:32 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301WDE40173760
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301WXw026209
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:32 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 19/31] mm: memory,memlayout: add refresh_memory_blocks() for Dynamic NUMA.
Date: Thu,  2 May 2013 17:00:51 -0700
Message-Id: <1367539263-19999-20-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Properly update the sysfs info when memory blocks move between nodes
due to a Dynamic NUMA reconfiguration.
---
 drivers/base/memory.c  | 39 +++++++++++++++++++++++++++++++++++++++
 include/linux/memory.h |  5 +++++
 mm/memlayout.c         |  3 +++
 3 files changed, 47 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 90e387c..db1b034 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -15,6 +15,7 @@
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/kobject.h>
+#include <linux/memlayout.h>
 #include <linux/memory.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm.h>
@@ -700,6 +701,44 @@ bool is_memblock_offlined(struct memory_block *mem)
 	return mem->state == MEM_OFFLINE;
 }
 
+#if defined(CONFIG_DYNAMIC_NUMA)
+int refresh_memory_blocks(struct memlayout *ml)
+{
+	struct subsys_dev_iter iter;
+	struct device *dev;
+	/* XXX: 4th arg is (struct device_type *), can we spec one? */
+	mutex_lock(&mem_sysfs_mutex);
+	subsys_dev_iter_init(&iter, &memory_subsys, NULL, NULL);
+
+	while ((dev = subsys_dev_iter_next(&iter))) {
+		struct memory_block *mem_blk = container_of(dev, struct memory_block, dev);
+		unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+		unsigned long end_pfn   = section_nr_to_pfn(mem_blk->end_section_nr + 1);
+		struct rangemap_entry *rme = memlayout_pfn_to_rme_higher(ml, start_pfn);
+		unsigned long pfn = start_pfn;
+
+		if (!rme || !rme_bounds_pfn(rme, pfn)) {
+			pr_warn("memory block %s {sec %lx-%lx}, {pfn %05lx-%05lx} is not bounded by the memlayout %pK\n",
+					dev_name(dev),
+					mem_blk->start_section_nr, mem_blk->end_section_nr,
+					start_pfn, end_pfn, ml);
+			continue;
+		}
+
+		unregister_mem_block_under_nodes(mem_blk);
+
+		for (; pfn < end_pfn && rme; rme = rme_next(rme)) {
+			register_mem_block_under_node(mem_blk, rme->nid);
+			pfn = rme->pfn_end + 1;
+		}
+	}
+
+	subsys_dev_iter_exit(&iter);
+	mutex_unlock(&mem_sysfs_mutex);
+	return 0;
+}
+#endif
+
 /*
  * Initialize the sysfs support for memory devices...
  */
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 85c31a8..8f1dc43 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -143,6 +143,11 @@ enum mem_add_context { BOOT, HOTPLUG };
 #define unregister_hotmemory_notifier(nb)  ({ (void)(nb); })
 #endif
 
+#ifdef CONFIG_DYNAMIC_NUMA
+struct memlayout;
+extern int refresh_memory_blocks(struct memlayout *ml);
+#endif
+
 /*
  * 'struct memory_accessor' is a generic interface to provide
  * in-kernel access to persistent memory such as i2c or SPI EEPROMs
diff --git a/mm/memlayout.c b/mm/memlayout.c
index 0a1a602..8b9ba9a 100644
--- a/mm/memlayout.c
+++ b/mm/memlayout.c
@@ -9,6 +9,7 @@
 #include <linux/dnuma.h>
 #include <linux/export.h>
 #include <linux/memblock.h>
+#include <linux/memory.h>
 #include <linux/printk.h>
 #include <linux/rbtree.h>
 #include <linux/rcupdate.h>
@@ -300,6 +301,8 @@ void memlayout_commit(struct memlayout *ml)
 	drain_all_pages();
 	/* All new page allocations now match the memlayout */
 
+	refresh_memory_blocks(ml);
+
 	mutex_unlock(&memlayout_lock);
 }
 
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
