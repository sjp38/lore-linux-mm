Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF2E76B027C
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 07:08:00 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id b14so10931855wmb.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 04:08:00 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id b133si71096966wmd.90.2015.12.29.04.07.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Dec 2015 04:07:59 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 29 Dec 2015 12:07:59 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5FC721B08069
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:08:35 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tBTC7v6Y4718620
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:07:57 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tBTC7vmw028226
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 05:07:57 -0700
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] mm/vmstat: fix overflow in mod_zone_page_state()
Date: Tue, 29 Dec 2015 13:07:54 +0100
Message-Id: <1451390874-29639-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Heiko Carstens <heiko.carstens@de.ibm.com>

mod_zone_page_state() takes a "delta" integer argument. delta contains
the number of pages that should be added or subtracted from a struct
zone's vm_stat field.

If a zone is larger than 8TB this will cause overflows. E.g. for a
zone with a size slightly larger than 8TB the line

	mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);

in mm/page_alloc.c:free_area_init_core() will result in a negative
result for the NR_ALLOC_BATCH entry within the zone's vm_stat, since
8TB contain 0x8xxxxxxx pages which will be sign extended to a negative
value.

Fix this by changing the delta argument to long type.

This could fix an early boot problem seen on s390, where we have a 9TB
system with only one node. ZONE_DMA contains 2GB and ZONE_NORMAL the
rest. The system is trying to allocate a GFP_DMA page but ZONE_DMA is
completely empty, so it tries to reclaim pages in an endless loop.

This was seen on a heavily patched 3.10 kernel. One possible
explaination seem to be the overflows caused by mod_zone_page_state().
Unfortunately I did not have the chance to verify that this patch
actually fixes the problem, since I don't have access to the system
right now. However the overflow problem does exist anyway.

Given the description that a system with slightly less than 8TB does
work, this seems to be a candidate for the observed problem.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 include/linux/vmstat.h |  6 +++---
 mm/vmstat.c            | 10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 5dbc8b0ee567..3e5d9075960f 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -176,11 +176,11 @@ extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
 
 #ifdef CONFIG_SMP
-void __mod_zone_page_state(struct zone *, enum zone_stat_item item, int);
+void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
 void __dec_zone_page_state(struct page *, enum zone_stat_item);
 
-void mod_zone_page_state(struct zone *, enum zone_stat_item, int);
+void mod_zone_page_state(struct zone *, enum zone_stat_item, long);
 void inc_zone_page_state(struct page *, enum zone_stat_item);
 void dec_zone_page_state(struct page *, enum zone_stat_item);
 
@@ -205,7 +205,7 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
  * The functions directly modify the zone and global counters.
  */
 static inline void __mod_zone_page_state(struct zone *zone,
-			enum zone_stat_item item, int delta)
+			enum zone_stat_item item, long delta)
 {
 	zone_page_state_add(delta, zone, item);
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0d5712b0206c..4ebc17d948cb 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -219,7 +219,7 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
  * particular counter cannot be updated from interrupt context.
  */
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
-				int delta)
+			   long delta)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -318,8 +318,8 @@ EXPORT_SYMBOL(__dec_zone_page_state);
  *     1       Overstepping half of threshold
  *     -1      Overstepping minus half of threshold
 */
-static inline void mod_state(struct zone *zone,
-       enum zone_stat_item item, int delta, int overstep_mode)
+static inline void mod_state(struct zone *zone, enum zone_stat_item item,
+			     long delta, int overstep_mode)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -357,7 +357,7 @@ static inline void mod_state(struct zone *zone,
 }
 
 void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
-					int delta)
+			 long delta)
 {
 	mod_state(zone, item, delta, 0);
 }
@@ -384,7 +384,7 @@ EXPORT_SYMBOL(dec_zone_page_state);
  * Use interrupt disable to serialize counter updates
  */
 void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
-					int delta)
+			 long delta)
 {
 	unsigned long flags;
 
-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
