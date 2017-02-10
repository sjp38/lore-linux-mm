Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3B76B0388
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:47 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y196so45187323ity.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:07:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 14si1480578iol.242.2017.02.10.02.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 02:07:46 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1AA43ZG044033
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:45 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28h75ga8qq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:45 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 10 Feb 2017 20:07:42 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 55E633578057
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:40 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1AA7W6a23199824
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:40 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1AA776q002112
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:08 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2 1/3] mm: Define coherent device memory (CDM) node
Date: Fri, 10 Feb 2017 15:36:38 +0530
In-Reply-To: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170210100640.26927-2-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

There are certain devices like specialized accelerator, GPU cards, network
cards, FPGA cards etc which might contain onboard memory which is coherent
along with the existing system RAM while being accessed either from the CPU
or from the device. They share some similar properties with that of normal
system RAM but at the same time can also be different with respect to
system RAM.

User applications might be interested in using this kind of coherent device
memory explicitly or implicitly along side the system RAM utilizing all
possible core memory functions like anon mapping (LRU), file mapping (LRU),
page cache (LRU), driver managed (non LRU), HW poisoning, NUMA migrations
etc. To achieve this kind of tight integration with core memory subsystem,
the device onboard coherent memory must be represented as a memory only
NUMA node. At the same time arch must export some kind of a function to
identify of this node as a coherent device memory not any other regular
cpu less memory only NUMA node.

After achieving the integration with core memory subsystem coherent device
memory might still need some special consideration inside the kernel. There
can be a variety of coherent memory nodes with different expectations from
the core kernel memory. But right now only one kind of special treatment is
considered which requires certain isolation.

Now consider the case of a coherent device memory node type which requires
isolation. This kind of coherent memory is onboard an external device
attached to the system through a link where there is always a chance of a
link failure taking down the entire memory node with it. More over the
memory might also have higher chance of ECC failure as compared to the
system RAM. Hence allocation into this kind of coherent memory node should
be regulated. Kernel allocations must not come here. Normal user space
allocations too should not come here implicitly (without user application
knowing about it). This summarizes isolation requirement of certain kind of
coherent device memory node as an example. There can be different kinds of
isolation requirement also.

Some coherent memory devices might not require isolation altogether after
all. Then there might be other coherent memory devices which might require
some other special treatment after being part of core memory representation
. For now, will look into isolation seeking coherent device memory node not
the other ones.

To implement the integration as well as isolation, the coherent memory node
must be present in N_MEMORY and a new N_COHERENT_DEVICE node mask inside
the node_states[] array. During memory hotplug operations, the new nodemask
N_COHERENT_DEVICE is updated along with N_MEMORY for these coherent device
memory nodes. This also creates the following new sysfs based interface to
list down all the coherent memory nodes of the system.

	/sys/devices/system/node/is_coherent_node

Architectures must export function arch_check_node_cdm() which identifies
any coherent device memory node in case they enable CONFIG_COHERENT_DEVICE.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  7 ++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 ++++
 drivers/base/node.c                         |  6 +++
 include/linux/nodemask.h                    | 58 ++++++++++++++++++++++++++++-
 mm/Kconfig                                  |  4 ++
 mm/memory_hotplug.c                         |  3 ++
 mm/page_alloc.c                             |  8 +++-
 8 files changed, 91 insertions(+), 3 deletions(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 5b2d0f0..fa2f105 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -29,6 +29,13 @@ Description:
 		Nodes that have regular or high memory.
 		Depends on CONFIG_HIGHMEM.
 
+What:		/sys/devices/system/node/is_coherent_device
+Date:		January 2017
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		Lists the nodemask of nodes that have coherent device memory.
+		Depends on CONFIG_COHERENT_DEVICE.
+
 What:		/sys/devices/system/node/nodeX
 Date:		October 2002
 Contact:	Linux Memory Management list <linux-mm@kvack.org>
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 281f4f1..1cff239 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -164,6 +164,7 @@ config PPC
 	select ARCH_HAS_SCALED_CPUTIME if VIRT_CPU_ACCOUNTING_NATIVE
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_KERNEL_GZIP
+	select COHERENT_DEVICE if PPC_BOOK3S_64 && NEED_MULTIPLE_NODES
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index b1099cb..14f0b98 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -41,6 +41,13 @@
 #include <asm/setup.h>
 #include <asm/vdso.h>
 
+#ifdef CONFIG_COHERENT_DEVICE
+inline int arch_check_node_cdm(int nid)
+{
+	return 0;
+}
+#endif
+
 static int numa_enabled = 1;
 
 static char *cmdline __initdata;
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..5b5dd89 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -661,6 +661,9 @@ static struct node_attr node_state_attr[] = {
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 #endif
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+#ifdef CONFIG_COHERENT_DEVICE
+	[N_COHERENT_DEVICE] = _NODE_ATTR(is_coherent_device, N_COHERENT_DEVICE),
+#endif
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -674,6 +677,9 @@ static struct attribute *node_state_attrs[] = {
 	&node_state_attr[N_MEMORY].attr.attr,
 #endif
 	&node_state_attr[N_CPU].attr.attr,
+#ifdef CONFIG_COHERENT_DEVICE
+	&node_state_attr[N_COHERENT_DEVICE].attr.attr,
+#endif
 	NULL
 };
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44..175c2d6 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -388,11 +388,14 @@ enum node_states {
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
 #ifdef CONFIG_MOVABLE_NODE
-	N_MEMORY,		/* The node has memory(regular, high, movable) */
+	N_MEMORY,	/* The node has memory(regular, high, movable, cdm) */
 #else
 	N_MEMORY = N_HIGH_MEMORY,
 #endif
 	N_CPU,		/* The node has one or more cpus */
+#ifdef CONFIG_COHERENT_DEVICE
+	N_COHERENT_DEVICE,	/* The node has CDM memory */
+#endif
 	NR_NODE_STATES
 };
 
@@ -496,6 +499,59 @@ static inline int node_random(const nodemask_t *mask)
 }
 #endif
 
+#ifdef CONFIG_COHERENT_DEVICE
+extern int arch_check_node_cdm(int nid);
+
+static inline nodemask_t system_mem_nodemask(void)
+{
+	nodemask_t system_mem;
+
+	nodes_clear(system_mem);
+	nodes_andnot(system_mem, node_states[N_MEMORY],
+			node_states[N_COHERENT_DEVICE]);
+	return system_mem;
+}
+
+static inline bool is_cdm_node(int node)
+{
+	return node_isset(node, node_states[N_COHERENT_DEVICE]);
+}
+
+static inline void node_set_state_cdm(int node)
+{
+	if (arch_check_node_cdm(node))
+		node_set_state(node, N_COHERENT_DEVICE);
+}
+
+static inline void node_clear_state_cdm(int node)
+{
+	if (arch_check_node_cdm(node))
+		node_clear_state(node, N_COHERENT_DEVICE);
+}
+
+#else
+
+static inline int arch_check_node_cdm(int nid) { return 0; }
+
+static inline nodemask_t system_mem_nodemask(void)
+{
+	return node_states[N_MEMORY];
+}
+
+static inline bool is_cdm_node(int node)
+{
+	return false;
+}
+
+static inline void node_set_state_cdm(int node)
+{
+}
+
+static inline void node_clear_state_cdm(int node)
+{
+}
+#endif	/* CONFIG_COHERENT_DEVICE */
+
 #define node_online_map 	node_states[N_ONLINE]
 #define node_possible_map 	node_states[N_POSSIBLE]
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb..6263a65 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -143,6 +143,10 @@ config HAVE_GENERIC_RCU_GUP
 config ARCH_DISCARD_MEMBLOCK
 	bool
 
+config COHERENT_DEVICE
+	bool
+	default n
+
 config NO_BOOTMEM
 	bool
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b8c11e0..6bce093 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1030,6 +1030,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
+	node_set_state_cdm(node);
 	node_set_state(node, N_MEMORY);
 }
 
@@ -1843,6 +1844,8 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 	if ((N_MEMORY != N_HIGH_MEMORY) &&
 	    (arg->status_change_nid >= 0))
 		node_clear_state(node, N_MEMORY);
+
+	node_clear_state_cdm(node);
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..84d61bb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6080,8 +6080,10 @@ static unsigned long __init early_calculate_totalpages(void)
 		unsigned long pages = end_pfn - start_pfn;
 
 		totalpages += pages;
-		if (pages)
+		if (pages) {
+			node_set_state_cdm(nid);
 			node_set_state(nid, N_MEMORY);
+		}
 	}
 	return totalpages;
 }
@@ -6392,8 +6394,10 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 				find_min_pfn_for_node(nid), NULL);
 
 		/* Any memory on that node */
-		if (pgdat->node_present_pages)
+		if (pgdat->node_present_pages) {
+			node_set_state_cdm(nid);
 			node_set_state(nid, N_MEMORY);
+		}
 		check_for_memory(pgdat, nid);
 	}
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
