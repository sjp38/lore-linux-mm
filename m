Subject: [PATCH] 2.6.23-rc3-mm1 - update N_HIGH_MEMORY node state for
	memory hotadd
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 27 Aug 2007 11:58:01 -0400
Message-Id: <1188230281.5952.63.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: clameter@sgi.com, jeremy@sgi.com, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

I believe [something like] the following is required for memory hot add,
after moving the setting of N_HIGH_MEMORY node state to
free_area_init_nodes().  However, we could also move that BACK to
__build_all_zonelists() BEFORE calling build_zonelists() and dispense
with this patch.

Thoughts?  [besides the obvious churn, I mean.  :-\]

Lee
=================

PATCH update N_HIGH_MEMORY node state for memory hotadd

Against:  2.6.23-rc3-mm1

Setting N_HIGH_MEMORY node state in free_area_init_nodes()
works for memory present at boot time, but not for hot-added
memory.  Update the N_HIGH_MEMORY node state in online_pages(),
if we've added pages to this node, before rebuilding zonelists.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/memory_hotplug.c |    2 ++
 1 file changed, 2 insertions(+)

Index: Linux/mm/memory_hotplug.c
===================================================================
--- Linux.orig/mm/memory_hotplug.c	2007-08-22 09:20:26.000000000 -0400
+++ Linux/mm/memory_hotplug.c	2007-08-27 10:40:57.000000000 -0400
@@ -211,6 +211,8 @@ int online_pages(unsigned long pfn, unsi
 		online_pages_range);
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
+	if (onlined_pages)
+		node_set_state(zone->node, N_HIGH_MEMORY);
 
 	setup_per_zone_pages_min();
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
