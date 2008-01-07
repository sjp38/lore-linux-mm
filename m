Date: Mon, 7 Jan 2008 12:04:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
In-Reply-To: <Pine.LNX.4.64.0801031258400.30856@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801071203070.24592@schroedinger.engr.sgi.com>
References: <20071217045904.GB31386@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com>
 <20071217120720.e078194b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com>
 <20071221044508.GA11996@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com>
 <20071228101109.GB5083@linux.vnet.ibm.com> <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801021346580.3778@schroedinger.engr.sgi.com>
 <20080103035942.GB26166@linux.vnet.ibm.com> <20080103041606.GC26166@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0801031258400.30856@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is the cleaned version of the patch. Dhaval is testing it.


quicklists: Only consider memory that can be used with GFP_KERNEL

Quicklists calculates the size of the quicklists based on the number
of free pages. This must be the number of free pages that can be
allocated with GFP_KERNEL. node_page_state() includes the pages in
ZONE_HIGHMEM and ZONE_MOVABLE which may lead the quicklists to
become too large causing OOM.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/quicklist.c
===================================================================
--- linux-2.6.orig/mm/quicklist.c	2008-01-07 10:38:13.000000000 -0800
+++ linux-2.6/mm/quicklist.c	2008-01-07 10:38:44.000000000 -0800
@@ -26,9 +26,17 @@ DEFINE_PER_CPU(struct quicklist, quickli
 static unsigned long max_pages(unsigned long min_pages)
 {
 	unsigned long node_free_pages, max;
+	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
+
+	node_free_pages =
+#ifdef CONFIG_ZONE_DMA
+		zone_page_state(&zones[ZONE_DMA], NR_FREE_PAGES) +
+#endif
+#ifdef CONFIG_ZONE_DMA32
+		zone_page_state(&zones[ZONE_DMA32], NR_FREE_PAGES) +
+#endif
+		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
 
-	node_free_pages = node_page_state(numa_node_id(),
-			NR_FREE_PAGES);
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
 	return max(max, min_pages);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
