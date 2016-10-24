Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D880B6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so114728385pfa.5
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d88si13503125pfb.142.2016.10.23.21.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:20 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4StQK146905
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:19 -0400
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26941gd055-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:19 -0400
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:16 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id ED69CE0040
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:03 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4WDX232833710
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:13 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WBs5020522
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:12 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 1/8] mm: Define coherent device memory node
Date: Mon, 24 Oct 2016 10:01:50 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

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
NUMA node. At the same time pglist_data structure (which is node's memory
representation) of this NUMA node must also be differentiated indicating
that it's coherent device memory not regular system RAM.

After achieving the integration with core memory subsystem through a marked
pglist_data structure, coherent device memory might still need some special
consideration inside the kernel. There can be a variety of coherent memory
nodes with different expectations from the core kernel memory. But right
now only one kind of special treatment is considered which requires certain
isolation.

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
For now, will look into isolation seeking coherent device memory node not
the other ones.

This adds a new 'bool coherent' element in pglist_data structure which can
identify any coherent device node. Instead this can be a u64 which can then
hold an array of properties bits for various types of coherent devices in
future.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 29 +++++++++++++++++++++++++++++
 mm/Kconfig             | 13 +++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..821dffb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -722,8 +722,37 @@ typedef struct pglist_data {
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
+
+#ifdef CONFIG_COHERENT_DEVICE
+	/*
+	 * Coherent device memory node
+	 *
+	 * Devices containing coherent memory is represented as a
+	 * special coherent memory NUMA node, should be identified
+	 * differently compared to normal memory nodes. Though it
+	 * shares lot of common properties with system memory, it
+	 * also has some differentiating factors as well.
+	 *
+	 * XXX: Though this is a bool which identifies the isolation
+	 * requiring coherent device memory node right now, it can be
+	 * extended as a bit mask to represent different properties
+	 * for future coherent device memory nodes.
+	 */
+	bool			coherent_device;
+#endif
 } pg_data_t;
 
+#ifdef CONFIG_COHERENT_DEVICE
+#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
+#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
+#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
+#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
+#else
+#define set_cdm_isolation(nid) ()
+#define clr_cdm_isolation(nid) ()
+#define isolated_cdm_node(nid) (0)
+#endif
+
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
 #define node_spanned_pages(nid)	(NODE_DATA(nid)->node_spanned_pages)
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
diff --git a/mm/Kconfig b/mm/Kconfig
index be0ee11..cb50468 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -704,6 +704,19 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
+config COHERENT_DEVICE
+	bool "Coherent device memory support"
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on PPC64
+	default y
+	help
+	  Coherent device memory node support enables the system to hotplug
+	  a device with coherent memory as a normal system memory node. FPGA,
+	  network, GPU cards etc might contain coherent memory.
+
+	  If not sure, then say N.
+
 config FRAME_VECTOR
 	bool
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
