Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id EFE9482F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 22:41:34 -0400 (EDT)
Received: by iofz202 with SMTP id z202so242006492iof.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:41:34 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id gb7si3364092igd.41.2015.10.27.19.41.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Oct 2015 19:41:34 -0700 (PDT)
Message-Id: <20151028024131.512101613@linux.com>
Date: Tue, 27 Oct 2015 21:41:15 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [patch 1/3] vmstat: Make pageset processing optional in refresh_cpu_vm_stats
References: <20151028024114.370693277@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=vmstat_do_pageset_parameter
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Add a parameter to refresh_cpu_vm_stats() to make pageset expiration
optional. Flushing the pagesets is performed by the page allocator
and thus processing of pagesets may not be wanted when just intending
to fold the differentials.

Signed-of-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -460,7 +460,7 @@ static int fold_diff(int *diff)
  *
  * The function returns the number of global counters updated.
  */
-static int refresh_cpu_vm_stats(void)
+static int refresh_cpu_vm_stats(bool do_pagesets)
 {
 	struct zone *zone;
 	int i;
@@ -484,33 +484,35 @@ static int refresh_cpu_vm_stats(void)
 #endif
 			}
 		}
-		cond_resched();
 #ifdef CONFIG_NUMA
-		/*
-		 * Deal with draining the remote pageset of this
-		 * processor
-		 *
-		 * Check if there are pages remaining in this pageset
-		 * if not then there is nothing to expire.
-		 */
-		if (!__this_cpu_read(p->expire) ||
+		if (do_pagesets) {
+			cond_resched();
+			/*
+			 * Deal with draining the remote pageset of this
+			 * processor
+			 *
+			 * Check if there are pages remaining in this pageset
+			 * if not then there is nothing to expire.
+			 */
+			if (!__this_cpu_read(p->expire) ||
 			       !__this_cpu_read(p->pcp.count))
-			continue;
+				continue;
 
-		/*
-		 * We never drain zones local to this processor.
-		 */
-		if (zone_to_nid(zone) == numa_node_id()) {
-			__this_cpu_write(p->expire, 0);
-			continue;
-		}
+			/*
+			 * We never drain zones local to this processor.
+			 */
+			if (zone_to_nid(zone) == numa_node_id()) {
+				__this_cpu_write(p->expire, 0);
+				continue;
+			}
 
-		if (__this_cpu_dec_return(p->expire))
-			continue;
+			if (__this_cpu_dec_return(p->expire))
+				continue;
 
-		if (__this_cpu_read(p->pcp.count)) {
-			drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
-			changes++;
+			if (__this_cpu_read(p->pcp.count)) {
+				drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
+				changes++;
+			}
 		}
 #endif
 	}
@@ -1363,7 +1365,7 @@ static cpumask_var_t cpu_stat_off;
 
 static void vmstat_update(struct work_struct *w)
 {
-	if (refresh_cpu_vm_stats()) {
+	if (refresh_cpu_vm_stats(true)) {
 		/*
 		 * Counters were updated so we expect more updates
 		 * to occur in the future. Keep on running the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
