Date: Wed, 1 Jun 2005 11:59:50 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Periodically drain non local pagesets
In-Reply-To: <1117651618.13600.16.camel@localhost>
Message-ID: <Pine.LNX.4.62.0506011155270.9664@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
 <1117651618.13600.16.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jun 2005, Dave Hansen wrote:

> Also, are you sure that you need the local_irq_en/disable()?  

drain_pages() does the same. We would run into trouble if an 
interrupt would use the page allocator.

Fix for the zone comparison:

Index: linux-2.6.12-rc5/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5.orig/mm/page_alloc.c	2005-06-01 10:41:25.000000000 -0700
+++ linux-2.6.12-rc5/mm/page_alloc.c	2005-06-01 11:57:55.000000000 -0700
@@ -528,7 +528,7 @@ void drain_remote_pages(void)
 		struct per_cpu_pageset *pset;
 
 		/* Do not drain local pagesets */
-		if (zone == zone_table[numa_node_id()])
+		if (zone->zone_pgdat->node_id == numa_node_id())
 			continue;
 
 		pset = zone->pageset[smp_processor_id()];
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
