Date: Sat, 12 Nov 2005 14:31:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [Patch:RFC] New zone ZONE_EASY_RECLAIM[0/5]
In-Reply-To: <437387B5.2000205@austin.ibm.com>
References: <20051110185754.0230.Y-GOTO@jp.fujitsu.com> <437387B5.2000205@austin.ibm.com>
Message-Id: <20051112135956.0663.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>


> > I rewrote patches to create new zone as ZONE_EASY_RECLAIM.
> 
> Just to be clear.  These patches create the new zone, but they don't seem to 
> actually use it to separate out removable memory, or to do memory remove.  I 
> assume those patches will come later?  In any case this is a good start.

Yes.

Following patch is just to test the new zone on my ia64 box.
In this case, all nodes which doesn't have ZONE_DMA will be
ZONE_EASY_RECLAIM.
But, this should be more considered. At least, it should
check hotplug flag in SRAT table on ia64 (and x86-64?). 
Of course, the way of new zone has a issue of tuning among zones.
"Which area should be ZONE_EASY_RECLAIM" should be specified at boottime.
I'll try it next time.

Thanks.

Index: new_zone/arch/ia64/mm/discontig.c
===================================================================
--- new_zone.orig/arch/ia64/mm/discontig.c	2005-10-28 12:00:11.000000000 +0900
+++ new_zone/arch/ia64/mm/discontig.c	2005-11-07 20:10:25.000000000 +0900
@@ -663,9 +663,9 @@ void __init paging_init(void)
 
 		if (mem_data[node].min_pfn >= max_dma) {
 			/* All of this node's memory is above ZONE_DMA */
-			zones_size[ZONE_NORMAL] = mem_data[node].max_pfn -
+			zones_size[ZONE_EASY_RECLAIM] = mem_data[node].max_pfn -
 				mem_data[node].min_pfn;
-			zholes_size[ZONE_NORMAL] = mem_data[node].max_pfn -
+			zholes_size[ZONE_EASY_RECLAIM] = mem_data[node].max_pfn -
 				mem_data[node].min_pfn -
 				mem_data[node].num_physpages;
 		} else if (mem_data[node].max_pfn < max_dma) {


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
