Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C18AE6B0285
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 14:15:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so234478949pfb.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:15:19 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id ot5si8856253pac.256.2016.09.23.11.15.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 11:15:19 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/1] mm/percpu.c: simplify grouping cpu logic in
 pcpu_build_alloc_info()
Message-ID: <5dcf5870-67ad-97e4-518b-645d60b0a520@zoho.com>
Date: Sat, 24 Sep 2016 02:15:09 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

simplify grouping cpu logic in pcpu_build_alloc_info() to improve
readability and performance, it discards the goto statement too

for every possible cpu, decide whether it can share group id of any
lower index CPU, use the group id if so, otherwise a new group id
is allocated to it

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/percpu.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 9903830aaebb..fcaaac977954 100644
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
