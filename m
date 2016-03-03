Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 14EB36B0258
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 20:44:39 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id m184so12229072iof.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:44:39 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id rt3si8917330igb.53.2016.03.02.17.44.37
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 17:44:38 -0800 (PST)
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Subject: [RESEND PATCH v5 1/5] x86, memhp, numa: Online memory-less nodes at boot time.
Date: Thu, 3 Mar 2016 09:42:03 +0800
Message-ID: <1456969327-20011-2-git-send-email-zhugh.fnst@cn.fujitsu.com>
In-Reply-To: <1456969327-20011-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
References: <1456969327-20011-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

For now, x86 does not support memory-less node. A node without memory
will not be onlined, and the cpus on it will be mapped to the other
online nodes with memory in init_cpu_to_node(). The reason of doing this
is to ensure each cpu has mapped to a node with memory, so that it will
be able to allocate local memory for that cpu.

But we don't have to do it in this way.

In this series of patches, we are going to construct cpu <-> node mapping
for all possible cpus at boot time, which is a 1-1 mapping. It means the
cpu will be mapped to the node it belongs to, and will never be changed.
If a node has only cpus but no memory, the cpus on it will be mapped to
a memory-less node. And the memory-less node should be onlined.

This patch allocate pgdats for all memory-less nodes and online them at
boot time. Then build zonelists for these nodes. As a result, when cpus
on these memory-less nodes try to allocate memory from local node, it
will automatically fall back to the proper zones in the zonelists.

Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
---
 arch/x86/mm/numa.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index d04f809..baf3d72 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -704,22 +704,19 @@ void __init x86_numa_init(void)
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
@@ -748,8 +745,10 @@ void __init init_cpu_to_node(void)
 
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
1.9.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
