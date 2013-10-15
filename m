Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2C98C6B0044
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:36:10 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so9344676pde.24
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:36:09 -0700 (PDT)
Subject: [RFC][PATCH 7/8] mm: pcp: move page coloring optimization away from pcp sizing
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:49 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203549.4CBB955A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The percpu pages calculations are a bit convoluted.  Right now,
zone_batchsize() claims to be calculating the ->batch size, but
what actually happens is:

1. Calculate how large we want the entire pcp set to be (->high)
2. Scale that down by the ratio that we want high:batch to be
3. Adjust ->batch for good cache-coloring behavior
4. Re-derive ->high by scaling back up by the (2) ratio

We actually feed the cache-coloring scaling back in to the ->high
value, when it really only *should* apply to the batch value.
That was probably unintentional, and it was one of the things
that led us to mismatching the high:batch ratio that we saw in
the previous patch.

This patch reorganizes the code.  It separates out the ->batch
and ->high calculations so that it's clear when we are
calculating each of them.  It also ensures that we always
calculate ->high _first_, then derive ->batch from it, finally
we adjust ->batch for good cache coloring behavior.

Since we are no longer calculating the batch size by itself, it
is not simple to print it out in zone_pcp_init() during boot.
We, instead, print out the 'high' value.  If anyone really misses
this, they can surely just read /proc/zoneinfo after boot.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/page_alloc.c |   54 ++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff -puN mm/page_alloc.c~rename-zone_batchsize mm/page_alloc.c
--- linux.git/mm/page_alloc.c~rename-zone_batchsize	2013-10-15 09:57:07.597688692 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:07.602688914 -0700
@@ -4061,10 +4061,10 @@ static void __meminit zone_init_free_lis
 
 static int pcp_high_to_batch_ratio = 4;
 
-static int zone_batchsize(struct zone *zone)
+static int calculate_zone_pcp_high(struct zone *zone)
 {
 #ifdef CONFIG_MMU
-	int batch;
+	int high;
 
 	/*
 	 * The per-cpu-pages pools are set to around 1000th of the
@@ -4072,26 +4072,13 @@ static int zone_batchsize(struct zone *z
 	 *
 	 * OK, so we don't know how big the cache is.  So guess.
 	 */
-	batch = zone->managed_pages / 1024;
-	if (batch * PAGE_SIZE > 512 * 1024)
-		batch = (512 * 1024) / PAGE_SIZE;
-	batch /= pcp_high_to_batch_ratio;
-	if (batch < 1)
-		batch = 1;
-
-	/*
-	 * Clamp the batch to a 2^n - 1 value. Having a power
-	 * of 2 value was found to be more likely to have
-	 * suboptimal cache aliasing properties in some cases.
-	 *
-	 * For example if 2 tasks are alternately allocating
-	 * batches of pages, one task can end up with a lot
-	 * of pages of one half of the possible page colors
-	 * and the other with pages of the other colors.
-	 */
-	batch = rounddown_pow_of_two(batch + batch/2) - 1;
+	high = zone->managed_pages / 1024;
+	if (high * PAGE_SIZE > 512 * 1024)
+		high = (512 * 1024) / PAGE_SIZE;
+	if (high < 1)
+		high = 1;
 
-	return batch;
+	return high;
 
 #else
 	/* The deferral and batching of frees should be suppressed under NOMMU
@@ -4181,6 +4168,19 @@ static void pageset_setup_from_high_mark
 	unsigned long batch = max(1UL, high / pcp_high_to_batch_ratio);
 	if ((high / pcp_high_to_batch_ratio) > (PAGE_SHIFT * 8))
 		batch = PAGE_SHIFT * 8;
+	/*
+	 * Clamp the batch to a 2^n - 1 value. Having a power
+	 * of 2 value was found to be more likely to have
+	 * suboptimal cache aliasing properties in some cases.
+	 *
+	 * For example if 2 tasks are alternately allocating
+	 * batches of pages, one task can end up with a lot
+	 * of pages of one half of the possible page colors
+	 * and the other with pages of the other colors.
+	 */
+	batch = rounddown_pow_of_two(batch + batch/2) - 1;
+	if (!batch)
+		batch = 1;
 
 	pageset_update(&p->pcp, high, batch);
 }
@@ -4188,12 +4188,12 @@ static void pageset_setup_from_high_mark
 static void pageset_set_high_and_batch(struct zone *zone,
 		struct per_cpu_pageset *pcp)
 {
+	int high;
 	if (percpu_pagelist_fraction)
-		pageset_setup_from_high_mark(pcp,
-			(zone->managed_pages /
-				percpu_pagelist_fraction));
+		high = (zone->managed_pages / percpu_pagelist_fraction);
 	else
-		pageset_setup_from_batch_size(pcp, zone_batchsize(zone));
+		high = calculate_zone_pcp_high(zone);
+	pageset_setup_from_high_mark(pcp, high);
 }
 
 static void __meminit zone_pageset_init(struct zone *zone, int cpu)
@@ -4277,9 +4277,9 @@ static __meminit void zone_pcp_init(stru
 	zone->pageset = &boot_pageset;
 
 	if (zone->present_pages)
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%u\n",
+		printk(KERN_DEBUG "  %s zone: %lu pages, pcp high:%d\n",
 			zone->name, zone->present_pages,
-					 zone_batchsize(zone));
+					 calculate_zone_pcp_high(zone));
 }
 
 int __meminit init_currently_empty_zone(struct zone *zone,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
