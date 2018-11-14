Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38A166B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:53:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o17so11668045pgi.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:53:05 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l13-v6si29485562pls.222.2018.11.14.14.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 14:53:03 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 1/7] node: Link memory nodes to their compute nodes
Date: Wed, 14 Nov 2018 15:49:14 -0700
Message-Id: <20181114224921.12123-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Memory-only nodes will often have affinity to a compute node, and
platforms have ways to express that locality relationship.

A node containing CPUs or other DMA devices that can initiate memory
access are referred to as "memory iniators". A "memory target" is a
node that provides at least one phyiscal address range accessible to a
memory initiator.

In preparation for these systems, provide a new kernel API to link
the target memory node to its initiator compute node with symlinks to
each other.

The following example shows the new sysfs hierarchy setup for memory node
'Y' local to commpute node 'X':

  # ls -l /sys/devices/system/node/nodeX/initiator*
  /sys/devices/system/node/nodeX/targetY -> ../nodeY

  # ls -l /sys/devices/system/node/nodeY/target*
  /sys/devices/system/node/nodeY/initiatorX -> ../nodeX

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/node.c  | 32 ++++++++++++++++++++++++++++++++
 include/linux/node.h |  2 ++
 2 files changed, 34 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..a9b7512a9502 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -372,6 +372,38 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 				 kobject_name(&node_devices[nid]->dev.kobj));
 }
 
+int register_memory_node_under_compute_node(unsigned int m, unsigned int p)
+{
+	int ret;
+	char initiator[20], target[17];
+
+	if (!node_online(p) || !node_online(m))
+		return -ENODEV;
+	if (m == p)
+		return 0;
+
+	snprintf(initiator, sizeof(initiator), "initiator%d", p);
+	snprintf(target, sizeof(target), "target%d", m);
+
+	ret = sysfs_create_link(&node_devices[p]->dev.kobj,
+				&node_devices[m]->dev.kobj,
+				target);
+	if (ret)
+		return ret;
+
+	ret = sysfs_create_link(&node_devices[m]->dev.kobj,
+				&node_devices[p]->dev.kobj,
+				initiator);
+	if (ret)
+		goto err;
+
+	return 0;
+ err:
+	sysfs_remove_link(&node_devices[p]->dev.kobj,
+			  kobject_name(&node_devices[m]->dev.kobj));
+	return ret;
+}
+
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
 	struct device *obj;
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..1fd734a3fb3f 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -75,6 +75,8 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
+extern int register_memory_node_under_compute_node(unsigned int m, unsigned int p);
+
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
 					 node_registration_func_t unregister);
-- 
2.14.4
