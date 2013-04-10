Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 57CED6B0073
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:25:33 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 12:25:32 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 180853E4006A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:25:17 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIPM9K136562
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:25:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIO93O009364
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:24:09 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 06/11] mm/page_alloc: when handling percpu_pagelist_fraction, don't unneedly recalulate high
Date: Wed, 10 Apr 2013 11:23:34 -0700
Message-Id: <1365618219-17154-7-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Simply moves calculation of the new 'high' value outside the
for_each_possible_cpu() loop, as it does not depend on the cpu.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c54a08..3447a4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5509,7 +5509,6 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
  * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
  * can have before it gets flushed back to buddy allocator.
  */
-
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -5523,12 +5522,11 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 
 	mutex_lock(&pcp_batch_high_lock);
 	for_each_populated_zone(zone) {
-		for_each_possible_cpu(cpu) {
-			unsigned long  high;
-			high = zone->managed_pages / percpu_pagelist_fraction;
+		unsigned long  high;
+		high = zone->managed_pages / percpu_pagelist_fraction;
+		for_each_possible_cpu(cpu)
 			setup_pagelist_highmark(
-				per_cpu_ptr(zone->pageset, cpu), high);
-		}
+					per_cpu_ptr(zone->pageset, cpu), high);
 	}
 	mutex_unlock(&pcp_batch_high_lock);
 	return 0;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
