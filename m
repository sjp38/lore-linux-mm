Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2973682F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:10:54 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id g6so92875820igt.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:10:54 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id c40si42314426ioj.36.2016.02.22.10.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 10:10:53 -0800 (PST)
Message-Id: <20160222181049.844884425@linux.com>
Date: Mon, 22 Feb 2016 12:10:41 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [patch 1/2] vmstat: Optimize refresh_cpu_vmstat()
References: <20160222181040.553533936@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=vmstat_speed_up
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

Create a new function zone_needs_update() that uses a memchr to check
all diffs for being nonzero first.

If we use this function in refresh_cpu_vm_stat() then we can avoid the
this_cpu_xchg() loop over all differentials. This becomes in particular
important as the number of counters keeps on increasing.

This also avoids modifying the cachelines with the differentials
unnecessarily.

Also add some likely()s to ensure that the icache requirements
are low when we do not have any updates to process.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2016-02-22 11:54:02.179095030 -0600
+++ linux/mm/vmstat.c	2016-02-22 11:54:24.338528277 -0600
@@ -444,6 +444,18 @@ static int fold_diff(int *diff)
 	return changes;
 }
 
+bool zone_needs_update(struct per_cpu_pageset *p)
+{
+
+	BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
+	/*
+	 * The fast way of checking if there are any vmstat diffs.
+	 * This works because the diffs are byte sized items.
+	 */
+	return memchr_inv(p->vm_stat_diff, 0,
+			NR_VM_ZONE_STAT_ITEMS) != NULL;
+}
+
 /*
  * Update the zone counters for the current cpu.
  *
@@ -470,18 +482,20 @@ static int refresh_cpu_vm_stats(bool do_
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset __percpu *p = zone->pageset;
 
-		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
-			int v;
+		if (unlikely(zone_needs_update(this_cpu_ptr(p)))) {
+			for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
+				int v;
 
-			v = this_cpu_xchg(p->vm_stat_diff[i], 0);
-			if (v) {
+				v = this_cpu_xchg(p->vm_stat_diff[i], 0);
+				if (v) {
 
-				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+					atomic_long_add(v, &zone->vm_stat[i]);
+					global_diff[i] += v;
 #ifdef CONFIG_NUMA
-				/* 3 seconds idle till flush */
-				__this_cpu_write(p->expire, 3);
+					/* 3 seconds idle till flush */
+					__this_cpu_write(p->expire, 3);
 #endif
+				}
 			}
 		}
 #ifdef CONFIG_NUMA
@@ -494,8 +508,8 @@ static int refresh_cpu_vm_stats(bool do_
 			 * Check if there are pages remaining in this pageset
 			 * if not then there is nothing to expire.
 			 */
-			if (!__this_cpu_read(p->expire) ||
-			       !__this_cpu_read(p->pcp.count))
+			if (likely(!__this_cpu_read(p->expire) ||
+			       !__this_cpu_read(p->pcp.count)))
 				continue;
 
 			/*
@@ -1440,19 +1454,12 @@ static bool need_update(int cpu)
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
 
-		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
-		/*
-		 * The fast way of checking if there are any vmstat diffs.
-		 * This works because the diffs are byte sized items.
-		 */
-		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
+		if (zone_needs_update(p))
 			return true;
-
 	}
 	return false;
 }
 
-
 /*
  * Shepherd worker thread that checks the
  * differentials of processors that have their worker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
