Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85A246B0255
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:29:45 -0400 (EDT)
Received: by iofh134 with SMTP id h134so47340118iof.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 21:29:45 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id qa17si13486131pab.131.2015.09.09.21.29.42
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 21:29:44 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 1/7] x86, numa: Move definition of find_near_online_node() forward.
Date: Thu, 10 Sep 2015 12:27:43 +0800
Message-ID: <1441859269-25831-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Will call this function earlier in next coming patches.
So simply move its definition forward. And also, add comments for it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c | 47 +++++++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 4053bb5..fea387a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -78,6 +78,35 @@ EXPORT_SYMBOL(node_to_cpumask_map);
 DEFINE_EARLY_PER_CPU(int, x86_cpu_to_node_map, NUMA_NO_NODE);
 EXPORT_EARLY_PER_CPU_SYMBOL(x86_cpu_to_node_map);
 
+/**
+ * find_near_online_node - Find the best near online node of a node.
+ * @node: NUMA node ID of the current node.
+ *
+ * Find the best near online node of @node, based on node_distance[] array.
+ * The best near online node is the backup node for memory allocation on
+ * one node.
+ *
+ * RETURNS:
+ * The best near online node ID on success, -1 on failure.
+ */
+static __init int find_near_online_node(int node)
+{
+	int n, val;
+	int min_val = INT_MAX;
+	int near_node = -1;
+
+	for_each_online_node(n) {
+		val = node_distance(node, n);
+
+		if (val < min_val) {
+			min_val = val;
+			near_node = n;
+		}
+	}
+
+	return near_node;
+}
+
 void numa_set_node(int cpu, int node)
 {
 	int *cpu_to_node_map = early_per_cpu_ptr(x86_cpu_to_node_map);
@@ -702,24 +731,6 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static __init int find_near_online_node(int node)
-{
-	int n, val;
-	int min_val = INT_MAX;
-	int best_node = -1;
-
-	for_each_online_node(n) {
-		val = node_distance(node, n);
-
-		if (val < min_val) {
-			min_val = val;
-			best_node = n;
-		}
-	}
-
-	return best_node;
-}
-
 /*
  * Setup early cpu_to_node.
  *
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
