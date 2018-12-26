Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F50F8E000A
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so17734192pfa.18
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.287359389@intel.com>
Date: Wed, 26 Dec 2018 21:14:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 04/21] x86/numa_emulation: pass numa node type to fake nodes
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0021-x86-numa-Fix-fake-numa-in-uniform-case.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

From: Fan Du <fan.du@intel.com>

Signed-off-by: Fan Du <fan.du@intel.com>
---
 arch/x86/mm/numa_emulation.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- linux.orig/arch/x86/mm/numa_emulation.c	2018-12-23 19:21:11.002206144 +0800
+++ linux/arch/x86/mm/numa_emulation.c	2018-12-23 19:21:10.998206236 +0800
@@ -12,6 +12,8 @@
 
 static int emu_nid_to_phys[MAX_NUMNODES];
 static char *emu_cmdline __initdata;
+static nodemask_t emu_numa_nodes_pmem;
+static nodemask_t emu_numa_nodes_dram;
 
 void __init numa_emu_cmdline(char *str)
 {
@@ -311,6 +313,12 @@ static int __init split_nodes_size_inter
 					       min(end, limit) - start);
 			if (ret < 0)
 				return ret;
+
+			/* Update numa node type for fake numa node */
+			if (node_isset(i, emu_numa_nodes_pmem))
+				node_set(nid - 1, numa_nodes_pmem);
+			else
+				node_set(nid - 1, numa_nodes_dram);
 		}
 	}
 	return nid;
@@ -410,6 +418,12 @@ void __init numa_emulation(struct numa_m
 		unsigned long n;
 		int nid = 0;
 
+		emu_numa_nodes_pmem = numa_nodes_pmem;
+		emu_numa_nodes_dram = numa_nodes_dram;
+
+		nodes_clear(numa_nodes_pmem);
+		nodes_clear(numa_nodes_dram);
+
 		n = simple_strtoul(emu_cmdline, &emu_cmdline, 0);
 		ret = -1;
 		for_each_node_mask(i, physnode_mask) {
