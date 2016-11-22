Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 760F76B0266
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:03 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so9984244wmw.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id fd10si25815254wjc.122.2016.11.22.06.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:02 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEIu4u042154
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:00 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vku8btdw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:00 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:19:56 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B58832BB0059
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:54 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEJs4H50790652
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:54 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEJsOZ015263
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:54 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 1/4] mm: Define coherent device memory node
Date: Tue, 22 Nov 2016 19:49:37 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

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
some other special treatment after being part of core memory representation.
For now, will look into isolation seeking coherent device memory node not
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
---
 Documentation/ABI/stable/sysfs-devices-node |  7 +++++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 +++++++
 drivers/base/node.c                         |  6 ++++++
 include/linux/node.h                        |  6 ++++++
 include/linux/nodemask.h                    |  3 +++
 mm/Kconfig                                  |  5 +++++
 mm/memory_hotplug.c                         | 10 ++++++++++
 8 files changed, 45 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 5b2d0f0..6f039a4 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -29,6 +29,13 @@ Description:
 		Nodes that have regular or high memory.
 		Depends on CONFIG_HIGHMEM.
 
+What:		/sys/devices/system/node/is_coherent_device
+Date:		November 2016
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		Lists the nodemask of nodes that have coherent device memory.
+		Depends on CONFIG_COHERENT_DEVICE.
+
 What:		/sys/devices/system/node/nodeX
 Date:		October 2002
 Contact:	Linux Memory Management list <linux-mm@kvack.org>
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 65fba4c..81bf679 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -162,6 +162,7 @@ config PPC
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_KERNEL_GZIP
+	select COHERENT_DEVICE if PPC64 && CPUSETS
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index a51c188..31efc27 100644
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
@@ -661,6 +661,9 @@ static ssize_t show_node_state(struct device *dev,
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 #endif
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+#ifdef CONFIG_COHERENT_DEVICE
+	[N_COHERENT_DEVICE] = _NODE_ATTR(is_coherent_device, N_COHERENT_DEVICE),
+#endif
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -674,6 +677,9 @@ static ssize_t show_node_state(struct device *dev,
 	&node_state_attr[N_MEMORY].attr.attr,
 #endif
 	&node_state_attr[N_CPU].attr.attr,
+#ifdef CONFIG_COHERENT_DEVICE
+	&node_state_attr[N_COHERENT_DEVICE].attr.attr,
+#endif
 	NULL
 };
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 2115ad5..fc319de 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -81,4 +81,10 @@ static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
 
 #define to_node(device) container_of(device, struct node, dev)
 
+#ifdef CONFIG_COHERENT_DEVICE
+extern int arch_check_node_cdm(int nid);
+#else
+static inline int arch_check_node_cdm(int nid) {return 0;}
+#endif
+
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
index 86e3e0e..546dc69 100644
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
index cad4b91..269af7c 100644
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
 
@@ -1844,6 +1849,11 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
