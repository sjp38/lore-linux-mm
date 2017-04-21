Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9426B03A2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:06:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p80so133799481iop.16
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:40 -0700 (PDT)
Received: from mail-io0-f196.google.com (mail-io0-f196.google.com. [209.85.223.196])
        by mx.google.com with ESMTPS id h201si1917501ita.116.2017.04.21.05.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:06:39 -0700 (PDT)
Received: by mail-io0-f196.google.com with SMTP id h41so29678527ioi.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/13] mm, memory_hotplug: split up register_one_node
Date: Fri, 21 Apr 2017 14:05:08 +0200
Message-Id: <20170421120512.23960-6-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Memory hotplug (add_memory_resource) has to reinitialize node
infrastructure if the node is offline (one which went through the
complete add_memory(); remove_memory() cycle). That involves node
registration to the kobj infrastructure (register_node), the proper
association with cpus (register_cpu_under_node) and finally creation of
node<->memblock symlinks (link_mem_sections).

The last part requires to know node_start_pfn and node_spanned_pages
which we currently have but a leter patch will postpone this
initialization to the onlining phase which happens later. In fact we do
not need to rely on the early pgdat initialization even now because the
currently hot added pfn range is currently known.

Split register_one_node into core which does all the common work for
the boot time NUMA initialization and the hotplug (__register_one_node).
register_one_node keeps the full initialization while hotplug calls
__register_one_node and manually calls link_mem_sections for the proper
range.

This shouldn't introduce any functional change.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/node.c  | 51 ++++++++++++++++++++-------------------------------
 include/linux/node.h | 35 ++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c  | 17 ++++++++++++++++-
 3 files changed, 70 insertions(+), 33 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 06294d69779b..dff5b53f7905 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -461,10 +461,9 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	return 0;
 }
 
-static int link_mem_sections(int nid)
+int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
 {
-	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
-	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	unsigned long end_pfn = start_pfn + nr_pages;
 	unsigned long pfn;
 	struct memory_block *mem_blk = NULL;
 	int err = 0;
@@ -552,10 +551,7 @@ static int node_memory_callback(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 #endif	/* CONFIG_HUGETLBFS */
-#else	/* !CONFIG_MEMORY_HOTPLUG_SPARSE */
-
-static int link_mem_sections(int nid) { return 0; }
-#endif	/* CONFIG_MEMORY_HOTPLUG_SPARSE */
+#endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 #if !defined(CONFIG_MEMORY_HOTPLUG_SPARSE) || \
     !defined(CONFIG_HUGETLBFS)
@@ -569,39 +565,32 @@ static void init_node_hugetlb_work(int nid) { }
 
 #endif
 
-int register_one_node(int nid)
+int __register_one_node(int nid)
 {
-	int error = 0;
+	int p_node = parent_node(nid);
+	struct node *parent = NULL;
+	int error;
 	int cpu;
 
-	if (node_online(nid)) {
-		int p_node = parent_node(nid);
-		struct node *parent = NULL;
-
-		if (p_node != nid)
-			parent = node_devices[p_node];
-
-		node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
-		if (!node_devices[nid])
-			return -ENOMEM;
-
-		error = register_node(node_devices[nid], nid, parent);
+	if (p_node != nid)
+		parent = node_devices[p_node];
 
-		/* link cpu under this node */
-		for_each_present_cpu(cpu) {
-			if (cpu_to_node(cpu) == nid)
-				register_cpu_under_node(cpu, nid);
-		}
+	node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
+	if (!node_devices[nid])
+		return -ENOMEM;
 
-		/* link memory sections under this node */
-		error = link_mem_sections(nid);
+	error = register_node(node_devices[nid], nid, parent);
 
-		/* initialize work queue for memory hot plug */
-		init_node_hugetlb_work(nid);
+	/* link cpu under this node */
+	for_each_present_cpu(cpu) {
+		if (cpu_to_node(cpu) == nid)
+			register_cpu_under_node(cpu, nid);
 	}
 
-	return error;
+	/* initialize work queue for memory hot plug */
+	init_node_hugetlb_work(nid);
 
+	return error;
 }
 
 void unregister_one_node(int nid)
diff --git a/include/linux/node.h b/include/linux/node.h
index 2115ad5d6f19..d1751beb462c 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -30,9 +30,38 @@ struct memory_block;
 extern struct node *node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
+extern int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages);
+#else
+static inline int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
+{
+	return 0;
+}
+#endif
+
 extern void unregister_node(struct node *node);
 #ifdef CONFIG_NUMA
-extern int register_one_node(int nid);
+/* Core of the node registration - only memory hotplug should use this */
+extern int __register_one_node(int nid);
+
+/* Registers an online node */
+static inline int register_one_node(int nid)
+{
+	int error = 0;
+
+	if (node_online(nid)) {
+		struct pglist_data *pgdat = NODE_DATA(nid);
+
+		error = __register_one_node(nid);
+		if (error)
+			return error;
+		/* link memory sections under this node */
+		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages);
+	}
+
+	return error;
+}
+
 extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
@@ -46,6 +75,10 @@ extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
 					 node_registration_func_t unregister);
 #endif
 #else
+static inline int __register_one_node(int nid)
+{
+	return 0;
+}
 static inline int register_one_node(int nid)
 {
 	return 0;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c0147d3024eb..caa58338d121 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1388,7 +1388,22 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	node_set_online(nid);
 
 	if (new_node) {
-		ret = register_one_node(nid);
+		unsigned long start_pfn = start >> PAGE_SHIFT;
+		unsigned long nr_pages = size >> PAGE_SHIFT;
+
+		ret = __register_one_node(nid);
+		if (ret)
+			goto register_fail;
+
+		/*
+		 * link memory sections under this node. This is already
+		 * done when creatig memory section in register_new_memory
+		 * but that depends to have the node registered so offline
+		 * nodes have to go through register_node.
+		 * TODO clean up this mess.
+		 */
+		ret = link_mem_sections(nid, start_pfn, nr_pages);
+register_fail:
 		/*
 		 * If sysfs file of new node can't create, cpu on the node
 		 * can't be hot-added. There is no rollback way now.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
