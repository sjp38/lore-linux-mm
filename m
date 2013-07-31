Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E3AB26B0036
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:32:10 -0400 (EDT)
Message-Id: <0000014035c972b2-8652a15f-f38d-4c39-aa97-a92d6868498a-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:32:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 2/3] vmstat: create fold_diff
References: <20130731173202.150701040@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org

Both functions that update global counters use the same mechanism.

Create a function that contains the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-07-26 10:37:11.004503227 -0500
+++ linux/mm/vmstat.c	2013-07-26 10:37:11.000503146 -0500
@@ -414,6 +414,15 @@ void dec_zone_page_state(struct page *pa
 EXPORT_SYMBOL(dec_zone_page_state);
 #endif
 
+static inline void fold_diff(int *diff)
+{
+	int i;
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (diff[i])
+			atomic_long_add(diff[i], &vm_stat[i]);
+}
+
 /*
  * Update the zone counters for the current cpu.
  *
@@ -483,10 +492,7 @@ static void refresh_cpu_vm_stats(int cpu
 			drain_zone_pages(zone, &p->pcp);
 #endif
 	}
-
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (global_diff[i])
-			atomic_long_add(global_diff[i], &vm_stat[i]);
+	fold_diff(global_diff);
 }
 
 /*
@@ -516,9 +522,7 @@ void cpu_vm_stats_fold(int cpu)
 			}
 	}
 
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (global_diff[i])
-			atomic_long_add(global_diff[i], &vm_stat[i]);
+	fold_diff(global_diff);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
