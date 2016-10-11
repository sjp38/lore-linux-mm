Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C130F6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 08:49:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z82so13344306qkb.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 05:49:25 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id i32si1356617qte.149.2016.10.11.05.49.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 05:49:25 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
Message-ID: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
Date: Tue, 11 Oct 2016 20:48:45 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

pcpu_build_alloc_info() groups CPUs according to relevant proximity
together to allocate memory for each percpu unit based on group.
however, the grouping algorithm consists of three loops and a goto
statement actually, and is inefficient and difficult to understand

the original algorithm is simplified to only consists of two loops
without any goto statement. for the new one, in order to assign a group
number to a target CPU, we check whether it can share a group with any
lower index CPU; the shareable group number is reused if so; otherwise,
a new one is assigned to it.

compared with the original algorithm theoretically and practically, the
new one educes the same grouping results, besides, it is more effective,
simpler and easier to understand.

in order to verify the new algorithm, we enumerate many pairs of type
@pcpu_fc_cpu_distance_fn_t function and the relevant CPU IDs array such
below sample, then apply both algorithms to the same pair and print the
grouping results separately, the new algorithm is okay after checking
whether the result printed from the new one is same with the original.
a sample pair of function and array format is shown as follows:
/* group CPUs by even/odd number */
static int cpu_distance_fn0(int from, int to)
{
	if (from % 2 ^ to % 2)
		return REMOTE_DISTANCE;
	else
		return LOCAL_DISTANCE;
}
/* end with -1 */
int cpu_ids_0[] = {0, 1, 2, 3, 7, 8, 9, 11, 14, 17, 19, 20, 22, 24, -1};

Signed-off-by: zijun_hu <zijun_hu@htc.com>
Tested-by: zijun_hu <zijun_hu@htc.com>
---
 Changes in v2:
  - update commit messages

 mm/percpu.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 255714302394..32e2d8d128c1 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1824,23 +1824,25 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	max_upa = upa;
 
 	/* group cpus according to their proximity */
-	for_each_possible_cpu(cpu) {
-		group = 0;
-	next_group:
+	group = 0;
+	for_each_possible_cpu(cpu)
 		for_each_possible_cpu(tcpu) {
-			if (cpu == tcpu)
-				break;
-			if (group_map[tcpu] == group && cpu_distance_fn &&
-			    (cpu_distance_fn(cpu, tcpu) > LOCAL_DISTANCE ||
-			     cpu_distance_fn(tcpu, cpu) > LOCAL_DISTANCE)) {
+			if (tcpu == cpu) {
+				group_map[cpu] = group;
+				group_cnt[group] = 1;
 				group++;
-				nr_groups = max(nr_groups, group + 1);
-				goto next_group;
+				break;
+			}
+
+			if (!cpu_distance_fn ||
+			    (cpu_distance_fn(cpu, tcpu) == LOCAL_DISTANCE &&
+			     cpu_distance_fn(tcpu, cpu) == LOCAL_DISTANCE)) {
+				group_map[cpu] = group_map[tcpu];
+				group_cnt[group_map[cpu]]++;
+				break;
 			}
 		}
-		group_map[cpu] = group;
-		group_cnt[group]++;
-	}
+	nr_groups = group;
 
 	/*
 	 * Expand unit size until address space usage goes over 75%
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
