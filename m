Date: Tue, 22 Nov 2005 16:10:00 -0800
From: Rohit Seth <rohit.seth@intel.com>
Subject: [PATCH]: Free pages from local pcp lists under tight memory conditions
Message-ID: <20051122161000.A22430@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, torvalds@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew, Linus,

[PATCH]: This patch free pages (pcp->batch from each list at a time) from
local pcp lists when a higher order allocation request is not able to 
get serviced from global free_list.

This should help fix some of the earlier failures seen with order 1 allocations.

I will send separate patches for:

1- Reducing the remote cpus pcp
2- Clean up page_alloc.c for CONFIG_HOTPLUG_CPU to use this code appropiately

Signed-off-by: Rohit Seth <rohit.seth@intel.com>


--- a/mm/page_alloc.c	2005-11-22 07:03:40.000000000 -0800
+++ linux-2.6.15-rc2/mm/page_alloc.c	2005-11-22 07:17:48.000000000 -0800
@@ -827,6 +827,35 @@
 	return page;
 }
 
+static int
+reduce_cpu_pcp(void )
+{
+	struct zone *zone;
+	unsigned long flags;
+	unsigned int cpu = get_cpu();
+	int i, ret=0;
+
+	local_irq_save(flags);
+	for_each_zone(zone) {
+		struct per_cpu_pageset *pset;
+
+		pset = zone_pcp(zone, cpu);
+		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
+			struct per_cpu_pages *pcp;
+
+			pcp = &pset->pcp[i];
+			if (pcp->count == 0)
+				continue;
+			pcp->count -= free_pages_bulk(zone, pcp->batch,
+						&pcp->list, 0);
+			ret++;
+		}
+	}
+	local_irq_restore(flags);
+	put_cpu();
+	return ret;
+}
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -887,6 +916,7 @@
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
+try_again:
 	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
 	if (page)
 		goto got_pg;
@@ -911,8 +941,15 @@
 	}
 
 	/* Atomic allocations - we can't balance anything */
-	if (!wait)
-		goto nopage;
+	if (!wait) {
+		/* Check if there are pages available on pcp lists that can be 
+		 * moved to global page list to satisfy higher order allocations.
+		 */
+		if ((order > 0) && (reduce_cpu_pcp()))
+			goto try_again;
+		else 
+			goto nopage;
+	}
 
 rebalance:
 	cond_resched();
@@ -950,6 +987,14 @@
 		goto restart;
 	}
 
+	if (order > 0) 
+		while (reduce_cpu_pcp()) {
+			if (get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags))
+				goto got_pg;
+		}
+	/* FIXME: Add the support for reducing/draining the remote pcps.
+	 */
+
 	/*
 	 * Don't let big-order allocations loop unless the caller explicitly
 	 * requests that.  Wait for some write requests to complete then retry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
