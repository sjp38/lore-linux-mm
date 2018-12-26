Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0C08E0006
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so15223477pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.164047705@intel.com>
Date: Wed, 26 Dec 2018 21:14:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 02/21] acpi/numa: memorize NUMA node type from SRAT table
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0002-acpi-Memorize-numa-node-type-from-SRAT-table.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

Mark NUMA node as DRAM or PMEM.

This could happen in boot up state (see the e820 pmem type
override patch), or on fly when bind devdax device with kmem
driver.

It depends on BIOS supplying PMEM NUMA proximity in SRAT table,
that's current production BIOS does.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/numa.h |    2 ++
 arch/x86/mm/numa.c          |    2 ++
 drivers/acpi/numa.c         |    5 +++++
 3 files changed, 9 insertions(+)

--- linux.orig/arch/x86/include/asm/numa.h	2018-12-23 19:20:39.890947888 +0800
+++ linux/arch/x86/include/asm/numa.h	2018-12-23 19:20:39.890947888 +0800
@@ -30,6 +30,8 @@ extern int numa_off;
  */
 extern s16 __apicid_to_node[MAX_LOCAL_APIC];
 extern nodemask_t numa_nodes_parsed __initdata;
+extern nodemask_t numa_nodes_pmem;
+extern nodemask_t numa_nodes_dram;
 
 extern int __init numa_add_memblk(int nodeid, u64 start, u64 end);
 extern void __init numa_set_distance(int from, int to, int distance);
--- linux.orig/arch/x86/mm/numa.c	2018-12-23 19:20:39.890947888 +0800
+++ linux/arch/x86/mm/numa.c	2018-12-23 19:20:39.890947888 +0800
@@ -20,6 +20,8 @@
 
 int numa_off;
 nodemask_t numa_nodes_parsed __initdata;
+nodemask_t numa_nodes_pmem;
+nodemask_t numa_nodes_dram;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
--- linux.orig/drivers/acpi/numa.c	2018-12-23 19:20:39.890947888 +0800
+++ linux/drivers/acpi/numa.c	2018-12-23 19:20:39.890947888 +0800
@@ -297,6 +297,11 @@ acpi_numa_memory_affinity_init(struct ac
 
 	node_set(node, numa_nodes_parsed);
 
+	if (ma->flags & ACPI_SRAT_MEM_NON_VOLATILE)
+		node_set(node, numa_nodes_pmem);
+	else
+		node_set(node, numa_nodes_dram);
+
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
 		node, pxm,
 		(unsigned long long) start, (unsigned long long) end - 1,
