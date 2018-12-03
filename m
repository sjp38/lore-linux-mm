Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23AA56B6BB1
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:08 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so15365478qte.1
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si6223263qvm.133.2018.12.03.15.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:06 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 07/14] mm/hms: register main memory with heterogenenous memory system
Date: Mon,  3 Dec 2018 18:35:02 -0500
Message-Id: <20181203233509.20671-8-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

Register main memory as target under HMS scheme. Memory is registered
per node (one target device per node). We also create a default link
to connect main memory and CPU that are in the same node. For details
see Documentation/vm/hms.rst.

This is done to allow application to use one API for regular memory or
device memory.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Philip Yang <Philip.Yang@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Paul Blinzer <Paul.Blinzer@amd.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: Vivek Kini <vkini@nvidia.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/base/node.c  | 65 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/node.h |  6 ++++
 2 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..05621ba3cf13 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -323,6 +323,11 @@ static int register_node(struct node *node, int num)
 	if (error)
 		put_device(&node->dev);
 	else {
+		hms_link_register(&node->link, &node->dev, 0);
+		hms_target_register(&node->target, &node->dev,
+				    num, NULL, 0, 0);
+		hms_link_target(node->link, node->target);
+
 		hugetlb_register_node(node);
 
 		compaction_register_node(node);
@@ -339,6 +344,9 @@ static int register_node(struct node *node, int num)
  */
 void unregister_node(struct node *node)
 {
+	hms_target_unregister(&node->target);
+	hms_link_unregister(&node->link);
+
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 
 	device_unregister(&node->dev);
@@ -415,6 +423,9 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	sect_end_pfn += PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
+#if defined(CONFIG_HMS)
+		unsigned long size = PAGE_SIZE;
+#endif
 		int page_nid;
 
 		/*
@@ -445,9 +456,35 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 		if (ret)
 			return ret;
 
-		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
+		ret = sysfs_create_link_nowarn(&mem_blk->dev.kobj,
 				&node_devices[nid]->dev.kobj,
 				kobject_name(&node_devices[nid]->dev.kobj));
+		if (ret)
+			return ret;
+
+#if defined(CONFIG_HMS)
+		/*
+		 * Right now here i do not see any easier way to get the size
+		 * in bytes of valid memory that is added to this node.
+		 */
+		for (++pfn; pfn <= sect_end_pfn; pfn++) {
+			if (!pfn_present(pfn)) {
+				pfn = round_down(pfn + PAGES_PER_SECTION,
+						PAGES_PER_SECTION) - 1;
+				continue;
+			}
+			page_nid = get_nid_for_pfn(pfn);
+			if (page_nid < 0)
+				continue;
+			if (page_nid != nid)
+				continue;
+			size += PAGE_SIZE;
+		}
+
+		hms_target_add_memory(node_devices[nid]->target, size);
+#endif
+
+		return 0;
 	}
 	/* mem section does not span the specified node */
 	return 0;
@@ -471,6 +508,10 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
+#if defined(CONFIG_HMS)
+		unsigned long size = 0;
+		int page_nid;
+#endif
 		int nid;
 
 		nid = get_nid_for_pfn(pfn);
@@ -484,6 +525,28 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
 			 kobject_name(&node_devices[nid]->dev.kobj));
+
+#if defined(CONFIG_HMS)
+		/*
+		 * Right now here i do not see any easier way to get the size
+		 * in bytes of valid memory that is added to this node.
+		 */
+		for (; pfn <= sect_end_pfn; pfn++) {
+			if (!pfn_present(pfn)) {
+				pfn = round_down(pfn + PAGES_PER_SECTION,
+						PAGES_PER_SECTION) - 1;
+				continue;
+			}
+			page_nid = get_nid_for_pfn(pfn);
+			if (page_nid < 0)
+				continue;
+			if (page_nid != nid)
+				break;
+			size += PAGE_SIZE;
+		}
+
+		hms_target_remove_memory(node_devices[nid]->target, size);
+#endif
 	}
 	NODEMASK_FREE(unlinked_nodes);
 	return 0;
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..297b01d3c1ed 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -15,6 +15,7 @@
 #ifndef _LINUX_NODE_H_
 #define _LINUX_NODE_H_
 
+#include <linux/hms.h>
 #include <linux/device.h>
 #include <linux/cpumask.h>
 #include <linux/workqueue.h>
@@ -22,6 +23,11 @@
 struct node {
 	struct device	dev;
 
+#if defined(CONFIG_HMS)
+	struct hms_target *target;
+	struct hms_link *link;
+#endif
+
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
-- 
2.17.2
