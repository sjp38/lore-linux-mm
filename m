Date: Wed, 2 Jan 2008 13:54:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
In-Reply-To: <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801021346580.3778@schroedinger.engr.sgi.com>
References: <20071214150533.aa30efd4.akpm@linux-foundation.org>
 <20071215035200.GA22082@linux.vnet.ibm.com> <20071214220030.325f82b8.akpm@linux-foundation.org>
 <20071215104434.GA26325@linux.vnet.ibm.com> <20071217045904.GB31386@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com>
 <20071217120720.e078194b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com>
 <20071221044508.GA11996@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com>
 <20071228101109.GB5083@linux.vnet.ibm.com> <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just traced it again on my system: It is okay for the number of pages on 
the quicklist to reach the high count that we see (although the 16 bit 
limits are weird. You have around 4GB of memory in the system?). Up to 
1/16th of free memory of a node can be allocated for quicklists (this 
allows the effective shutting down and restarting of large amounts of 
processes)

The problem may be that this is run on a HIGHMEM system and the 
calculation of allowable pages on the quicklists does not take into 
account that highmem pages are not usable for quicklists (not sure about 
ZONE_MOVABLE on i386. Maybe we need to take that into account as well?)

Here is a patch that removes the HIGHMEM portion from the calculation. 
Does this change anything:

Index: linux-2.6/mm/quicklist.c
===================================================================
--- linux-2.6.orig/mm/quicklist.c	2008-01-02 13:41:10.000000000 -0800
+++ linux-2.6/mm/quicklist.c	2008-01-02 13:44:15.000000000 -0800
@@ -29,6 +29,12 @@ static unsigned long max_pages(unsigned 
 
 	node_free_pages = node_page_state(numa_node_id(),
 			NR_FREE_PAGES);
+#ifdef CONFIG_HIGHMEM
+	/* Take HIGHMEM pages out of consideration */
+	node_free_pages -= zone_page_state(&NODE_DATA(numa_node_id())->node_zones[ZONE_HIGHMEM],
+				NR_FREE_PAGES);
+#endif
+
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
 	return max(max, min_pages);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
