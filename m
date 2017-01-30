Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D96D6B0253
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:24 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so58565916wjd.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:37:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r126si11684472wmb.109.2017.01.29.19.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:37:22 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YP10106706
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:21 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289c9uhars-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:21 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:18 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DFD3D2BB0057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:14 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3b6tO30605528
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:14 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3agTC019633
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:36:42 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 01/12] mm: Define coherent device memory (CDM) node
Date: Mon, 30 Jan 2017 09:05:42 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-2-khandual@linux.vnet.ibm.com>
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
the device onbaord coherent memory must be represented as a memory only
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
 Documentation/ABI/stable/sysfs-devices-node |  7 +++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 +++++
 drivers/base/node.c                         |  6 ++++
 include/linux/node.h                        | 49 +++++++++++++++++++++++++++++
 include/linux/nodemask.h                    |  3 ++
 mm/Kconfig                                  |  5 +++
 mm/memory_hotplug.c                         | 10 ++++++
 8 files changed, 88 insertions(+)

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
index a8ee573..8273e6e 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -165,6 +165,7 @@ config PPC
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_KERNEL_GZIP
 	select HAVE_CC_STACKPROTECTOR
+	select COHERENT_DEVICE if PPC64 && CPUSETS
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index b1099cb..9c73fbe 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -41,6 +41,13 @@
 #include <asm/setup.h>
 #include <asm/vdso.h>
 
+#ifdef CONFIG_COHERENT_DEVICE
+int arch_check_node_cdm(int nid)
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
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 2115ad5..e284206 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -81,4 +81,53 @@ static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
 
 #define to_node(device) container_of(device, struct node, dev)
 
+
+#ifdef CONFIG_COHERENT_DEVICE
+extern int arch_check_node_cdm(int nid);
+
+static inline nodemask_t ram_nodemask(void)
+{
+	nodemask_t ram_nodes;
+
+	nodes_clear(ram_nodes);
+	nodes_andnot(ram_nodes, node_states[N_MEMORY],
+				node_states[N_COHERENT_DEVICE]);
+	return ram_nodes;
+}
+
+static inline bool is_cdm_node(int node)
+{
+	return node_isset(node, node_states[N_COHERENT_DEVICE]);
+}
+
+static inline bool nodemask_has_cdm(nodemask_t mask)
+{
+	int node, i;
+
+	node = first_node(mask);
+	for (i = 0; i < nodes_weight(mask); i++) {
+		if (is_cdm_node(node))
+			return true;
+		node = next_node(node, mask);
+	}
+	return false;
+}
+#else
+static inline int arch_check_node_cdm(int nid) { return 0; }
+
+static inline nodemask_t ram_nodemask(void)
+{
+	return node_states[N_MEMORY];
+}
+
+static inline bool is_cdm_node(int node)
+{
+	return false;
+}
+
+static inline bool nodemask_has_cdm(nodemask_t mask)
+{
+	return false;
+}
+#endif /* CONFIG_COHERENT_DEVICE */
 #endif /* _LINUX_NODE_H_ */
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44..6e66cfd 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -393,6 +393,9 @@ enum node_states {
 	N_MEMORY = N_HIGH_MEMORY,
 #endif
 	N_CPU,		/* The node has one or more cpus */
+#ifdef CONFIG_COHERENT_DEVICE
+	N_COHERENT_DEVICE,
+#endif
 	NR_NODE_STATES
 };
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb..5b7d1e7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -143,6 +143,11 @@ config HAVE_GENERIC_RCU_GUP
 config ARCH_DISCARD_MEMBLOCK
 	bool
 
+config COHERENT_DEVICE
+	bool
+	depends on CPUSETS
+	default n
+
 config NO_BOOTMEM
 	bool
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca2723d..b63010a2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1030,6 +1030,11 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
+#ifdef CONFIG_COHERENT_DEVICE
+	if (arch_check_node_cdm(node))
+		node_set_state(node, N_COHERENT_DEVICE);
+#endif
+
 	node_set_state(node, N_MEMORY);
 }
 
@@ -1830,6 +1835,11 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 	if ((N_MEMORY != N_HIGH_MEMORY) &&
 	    (arg->status_change_nid >= 0))
 		node_clear_state(node, N_MEMORY);
+
+#ifdef CONFIG_COHERENT_DEVICE
+	if (arch_check_node_cdm(node))
+		node_clear_state(node, N_COHERENT_DEVICE);
+#endif
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
