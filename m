Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9E196B025E
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:12:18 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q83so157009iod.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:12:18 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b67si20058291ite.13.2016.07.25.23.12.17
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 23:12:17 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v10 1/7] x86, memhp, numa: Online memory-less nodes at boot time.
Date: Tue, 26 Jul 2016 14:10:23 +0800
Message-ID: <1469513429-25464-2-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1469513429-25464-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1469513429-25464-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

For now, x86 does not support memory-less node. A node without memory
will not be onlined, and the cpus on it will be mapped to the other
online nodes with memory in init_cpu_to_node(). The reason of doing this
is to ensure each cpu has mapped to a node with memory, so that it will
be able to allocate local memory for that cpu.

But we don't have to do it in this way.

In this series of patches, we are going to construct cpu <-> node mapping
for all possible cpus at boot time, which is a persistent mapping. It means
that the cpu will be mapped to the node which it belongs to, and will never
be changed. If a node has only cpus but no memory, the cpus on it will be
mapped to a memory-less node. And the memory-less node should be onlined.

This patch allocate pgdats for all memory-less nodes and online them at
boot time. Then build zonelists for these nodes. As a result, when cpus
on these memory-less nodes try to allocate memory from local node, it
will automatically fall back to the proper zones in the zonelists.

Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 arch/x86/mm/numa.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 9c086c5..2a87a28 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -723,22 +723,19 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static __init int find_near_online_node(int node)
+static void __init init_memory_less_node(int nid)
 {
-	int n, val;
-	int min_val = INT_MAX;
-	int best_node = -1;
+	unsigned long zones_size[MAX_NR_ZONES] = {0};
+	unsigned long zholes_size[MAX_NR_ZONES] = {0};
 
-	for_each_online_node(n) {
-		val = node_distance(node, n);
+	/* Allocate and initialize node data. Memory-less node is now online.*/
+	alloc_node_data(nid);
+	free_area_init_node(nid, zones_size, 0, zholes_size);
 
-		if (val < min_val) {
-			min_val = val;
-			best_node = n;
-		}
-	}
-
-	return best_node;
+	/*
+	 * All zonelists will be built later in start_kernel() after per cpu
+	 * areas are initialized.
+	 */
 }
 
 /*
@@ -767,8 +764,10 @@ void __init init_cpu_to_node(void)
 
 		if (node == NUMA_NO_NODE)
 			continue;
+
 		if (!node_online(node))
-			node = find_near_online_node(node);
+			init_memory_less_node(node);
+
 		numa_set_node(cpu, node);
 	}
 }
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
