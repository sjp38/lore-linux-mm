Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 48CEA6B0038
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:23 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:24:22 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 48336C9005E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:09 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIO8Za32899084
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:09 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AINwI9015881
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:23:59 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 02/11] mm/page_alloc: prevent concurrent updaters of pcp ->batch and ->high
Date: Wed, 10 Apr 2013 11:23:30 -0700
Message-Id: <1365618219-17154-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Because we are going to rely upon a careful transision between old and
new ->high and ->batch values using memory barriers and will remove
stop_machine(), we need to prevent multiple updaters from interweaving
their memory writes.

Add a simple mutex to protect both update loops.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5877cf0..d259599 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,9 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+/* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
+static DEFINE_MUTEX(pcp_batch_high_lock);
+
 #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
 DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
@@ -5491,6 +5494,8 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (!write || (ret < 0))
 		return ret;
+
+	mutex_lock(&pcp_batch_high_lock);
 	for_each_populated_zone(zone) {
 		for_each_possible_cpu(cpu) {
 			unsigned long  high;
@@ -5499,6 +5504,7 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 				per_cpu_ptr(zone->pageset, cpu), high);
 		}
 	}
+	mutex_unlock(&pcp_batch_high_lock);
 	return 0;
 }
 
@@ -6012,7 +6018,9 @@ static int __meminit __zone_pcp_update(void *data)
 
 void __meminit zone_pcp_update(struct zone *zone)
 {
+	mutex_lock(&pcp_batch_high_lock);
 	stop_machine(__zone_pcp_update, zone, NULL);
+	mutex_unlock(&pcp_batch_high_lock);
 }
 #endif
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
