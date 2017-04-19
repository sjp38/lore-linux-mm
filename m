Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E35DD2806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:53:07 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k14so9614335pga.5
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:07 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id h130si1620566pgc.266.2017.04.19.00.53.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:53:06 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id a188so2579437pfa.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:06 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC 1/4] mm: create N_COHERENT_MEMORY
Date: Wed, 19 Apr 2017 17:52:39 +1000
Message-Id: <20170419075242.29929-2-bsingharora@gmail.com>
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com, Balbir Singh <bsingharora@gmail.com>

The idea and definition of coherent memory was defined in
RFC's and patchsets. In particular https://lwn.net/Articles/704403/
has the details. This patch has a summary of the intentions
and implementation. The earlier patches were implemented
and designed by Anshuman Khandual.

A coherent memory device is a NUMA node, yes its non-uniform
memory access and also non-uniform memory attributes :) New hardware
has the capability to allow for coherency between device memory
and CPU memory. This memory is visible as a part of system memory
but its attributes are different. The debate is on how we expose
this memory, so that the programming model is simple. HMM provides
a similar approach, but due to lack of hardware cannot make it
as simple as exposing the memory as a NUMA node.

In this patch we create N_COHERENT_MEMORY, which is different
from N_MEMORY. A node hotplugged as coherent memory will have
this state set. The expectation then is that this memory gets
onlined like regular nodes. Memory allocation from such nodes
occurs only when the the node is contained explicitly in the
mask.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 Documentation/memory-hotplug.txt | 13 +++++++++++++
 drivers/base/memory.c            |  3 +++
 drivers/base/node.c              |  2 ++
 include/linux/memory_hotplug.h   |  1 +
 include/linux/nodemask.h         |  1 +
 mm/memory_hotplug.c              |  5 ++++-
 6 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 670f3de..26736d8 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -298,6 +298,19 @@ available memory will be increased.
 Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
 This may be changed in future.
 
+% echo online_coherent > /sys/devices/system/memory/memoryXXX/state
+
+After this memory is onlined, same as "echo online" above, except that the node
+is marked as N_COHERENT_MEMORY and it is not a part of N_MEMORY. Effectively
+it means that this node is not a part of any node zonelist, except itself.
+Ideally N_COHERENT_MEMORY nodes have no cpus on them.
+
+A user space program can use numactl with -a to allocate on this node with
+an explicity node specification. From the kernel, one may use __GFP_THISNODE
+with the node specified and alloc_pages_node() to allocate.
+
+NOTE: This node will not show up in mems_allowed and will not work with
+cpusets in general.
 
 
 ------------------------
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cc4f1d0..9a96c6e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -323,6 +323,8 @@ store_mem_state(struct device *dev,
 		online_type = MMOP_ONLINE_KERNEL;
 	else if (sysfs_streq(buf, "online_movable"))
 		online_type = MMOP_ONLINE_MOVABLE;
+	else if (sysfs_streq(buf, "online_coherent"))
+		online_type = MMOP_ONLINE_COHERENT;
 	else if (sysfs_streq(buf, "online"))
 		online_type = MMOP_ONLINE_KEEP;
 	else if (sysfs_streq(buf, "offline"))
@@ -345,6 +347,7 @@ store_mem_state(struct device *dev,
 	case MMOP_ONLINE_KERNEL:
 	case MMOP_ONLINE_MOVABLE:
 	case MMOP_ONLINE_KEEP:
+	case MMOP_ONLINE_COHERENT:
 		mem->online_type = online_type;
 		ret = device_online(&mem->dev);
 		break;
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..6bfdfd6 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -660,6 +660,7 @@ static struct node_attr node_state_attr[] = {
 #ifdef CONFIG_MOVABLE_NODE
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 #endif
+	[N_COHERENT_MEMORY] = _NODE_ATTR(has_coherent_memory, N_COHERENT_MEMORY),
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
 };
 
@@ -673,6 +674,7 @@ static struct attribute *node_state_attrs[] = {
 #ifdef CONFIG_MOVABLE_NODE
 	&node_state_attr[N_MEMORY].attr.attr,
 #endif
+	&node_state_attr[N_COHERENT_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
 	NULL
 };
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 134a2f6..aa927aa 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -33,6 +33,7 @@ enum {
 	MMOP_ONLINE_KEEP,
 	MMOP_ONLINE_KERNEL,
 	MMOP_ONLINE_MOVABLE,
+	MMOP_ONLINE_COHERENT,
 };
 
 /*
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44..037e34a 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -393,6 +393,7 @@ enum node_states {
 	N_MEMORY = N_HIGH_MEMORY,
 #endif
 	N_CPU,		/* The node has one or more cpus */
+	N_COHERENT_MEMORY,	/* The node has cache coherent device memory */
 	NR_NODE_STATES
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b63d7d1..ebeb3af 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1149,7 +1149,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	if (onlined_pages) {
-		node_states_set_node(nid, &arg);
+		if (online_type == MMOP_ONLINE_COHERENT)
+			node_set_state(nid, N_COHERENT_MEMORY);
+		else
+			node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, NULL);
 		else
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
