Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 231B96B0039
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:54 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so37175pdj.21
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:53 -0700 (PDT)
Subject: [RFC][PATCH 8/8] mm: pcp: create setup_boot_pageset()
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:50 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203550.AF0B233E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

pageset_setup_from_batch_size() has one remaining call path:

__build_all_zonelists()
	-> setup_pageset()
		-> pageset_setup_from_batch_size()

And that one path is specialized.  It is meant to essentially
turn off the per-cpu-pagelists.  It's also questionably buggy.
It sets up a ->batch=1, but ->high=0, when called with batch=0
which is contrary to the comments in there that say:

	->batch must never be higher then ->high.

This patch creates a new function, setup_boot_pageset().  This
just (more) directly sets ->high=1 and ->batch=1.  It is
functionally equiavlent to the existing (->high=0 and ->batch=1)
code since high is really only used like this:

	pcp->count++;
        if (pcp->count >= pcp->high) {
                free_pcppages_bulk(zone, batch, pcp);
                pcp->count -= batch;
        }

Looking at that if() above, if pcp->count=1, then

	if (pcp->count >= 1)
and
	if (pcp->count >= 0)

are equivalent, so it does not matter whether we set ->high=0
or ->high=1.  I just find it much more intuitive to have
->high=1 since ->high=0 _looks_ invalid at first.

Also note that this ends up net removing code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/page_alloc.c |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff -puN mm/page_alloc.c~setup_pageset-specialize mm/page_alloc.c
--- linux.git/mm/page_alloc.c~setup_pageset-specialize	2013-10-15 09:57:07.869700754 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:07.874700976 -0700
@@ -3703,7 +3703,7 @@ static void build_zonelist_cache(pg_data
  * not check if the processor is online before following the pageset pointer.
  * Other parts of the kernel may not check if the zone is available.
  */
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
+static void setup_boot_pageset(struct per_cpu_pageset *p);
 static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
 static void setup_zone_pageset(struct zone *zone);
 
@@ -3750,7 +3750,7 @@ static int __build_all_zonelists(void *d
 	 * (a chicken-egg dilemma).
 	 */
 	for_each_possible_cpu(cpu) {
-		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
+		setup_boot_pageset(&per_cpu(boot_pageset, cpu));
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 		/*
@@ -4125,20 +4125,6 @@ static void pageset_update(struct per_cp
 	pcp->batch = batch;
 }
 
-/*
- * Set the batch size for hot per_cpu_pagelist, and derive
- * the high water mark from the batch size.
- */
-static void pageset_setup_from_batch_size(struct per_cpu_pageset *p,
-					unsigned long batch)
-{
-	unsigned long high;
-	high = pcp_high_to_batch_ratio * batch;
-	if (!batch)
-		batch = 1;
-	pageset_update(&p->pcp, high, batch);
-}
-
 static void pageset_init(struct per_cpu_pageset *p)
 {
 	struct per_cpu_pages *pcp;
@@ -4152,10 +4138,17 @@ static void pageset_init(struct per_cpu_
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
 
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+/*
+ * Turn off per-cpu-pages until we have a the
+ * full percpu allocator up.
+ */
+static void setup_boot_pageset(struct per_cpu_pageset *p)
 {
+	unsigned long batch = 1;
+	unsigned long high = 1;
+
 	pageset_init(p);
-	pageset_setup_from_batch_size(p, batch);
+	pageset_update(&p->pcp, high, batch);
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
