Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 00F7A6B011B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:27 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 16:34:26 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E547538C801C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:23 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r35KYNF6305192
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 16:34:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r35KYN0k000816
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 16:34:23 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu() to set percpu pageset fields.
Date: Fri,  5 Apr 2013 13:33:50 -0700
Message-Id: <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

In free_hot_cold_page(), we rely on pcp->batch remaining stable.
Updating it without being on the cpu owning the percpu pageset
potentially destroys this stability.

Change for_each_cpu() to on_each_cpu() to fix.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48f2faa..507db31 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5475,30 +5475,31 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+static void _zone_set_pageset_highmark(void *data)
+{
+	struct zone *zone = data;
+	unsigned long  high;
+	high = zone->managed_pages / percpu_pagelist_fraction;
+	setup_pagelist_highmark(
+			per_cpu_ptr(zone->pageset, smp_processor_id()), high);
+}
+
 /*
  * percpu_pagelist_fraction - changes the pcp->high for each zone on each
  * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
  * can have before it gets flushed back to buddy allocator.
  */
-
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
-	unsigned int cpu;
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (!write || (ret < 0))
 		return ret;
-	for_each_populated_zone(zone) {
-		for_each_possible_cpu(cpu) {
-			unsigned long  high;
-			high = zone->managed_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(
-				per_cpu_ptr(zone->pageset, cpu), high);
-		}
-	}
+	for_each_populated_zone(zone)
+		on_each_cpu(_zone_set_pageset_highmark, zone, true);
 	return 0;
 }
 
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
