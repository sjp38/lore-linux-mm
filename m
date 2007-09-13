Date: Thu, 13 Sep 2007 11:11:42 +0100
Subject: Re: [PATCH 0/6] Use one zonelist per node instead of multiple zonelists v5 (resend)
Message-ID: <20070913101142.GE22778@skynet.ie>
References: <20070911213006.23507.19569.sendpatchset@skynet.skynet.ie> <1189628853.5004.66.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1189628853.5004.66.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On (12/09/07 16:27), Lee Schermerhorn didst pronounce:
> On Tue, 2007-09-11 at 22:30 +0100, Mel Gorman wrote:
> > (Sorry for the resend, I mucked up the TO: line in the earlier sending)
> > 
> > This is the latest version of one-zonelist and it should be solid enough
> > for wider testing. To briefly summarise, the patchset replaces multiple
> > zonelists-per-node with one zonelist that is filtered based on nodemask and
> > GFP flags. I've dropped the patch that replaces inline functions with macros
> > from the end as it obscures the code for something that may or may not be a
> > performance benefit on older compilers. If we see performance regressions that
> > might have something to do with it, the patch is trivially to bring forward.
> > 
> > Andrew, please merge to -mm for wider testing and consideration for merging
> > to mainline. Minimally, it gets rid of the hack in relation to ZONE_MOVABLE
> > and MPOL_BIND.
> 
> 
> Mel:
> 
> I'm just getting to this after sorting out an issue with the memory
> controller stuff in 23-rc4-mm1.  I'm building all my kernels with the
> memory controller enabled now, as it hits areas that I'm playing in.  I
> wanted to give you a heads up that vmscan.c doesn't build with
> CONTAINER_MEM_CONT configured with your patches.  I won't get to this
> until tomorrow.  Since you're a few hours ahead of me, you might want to
> take a look.  No worries, if you don't get a chance...
> 

Thanks a lot. I took a look and you're right. Does the following patch
fix it for you?

====

Fix a compile bug with one-zonelist and the memory controller.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-onezonelist_v5r21/mm/vmscan.c linux-2.6.23-rc4-mm1-onezonelist_v5r21-fix/mm/vmscan.c
--- linux-2.6.23-rc4-mm1-onezonelist_v5r21/mm/vmscan.c	2007-09-12 10:00:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-onezonelist_v5r21-fix/mm/vmscan.c	2007-09-13 11:09:49.000000000 +0100
@@ -1368,11 +1368,11 @@ unsigned long try_to_free_mem_container_
 		.isolate_pages = mem_container_isolate_pages,
 	};
 	int node;
-	struct zone **zones;
+	struct zonelist *zonelist;
 
 	for_each_online_node(node) {
-		zones = NODE_DATA(node)->node_zonelists[ZONE_USERPAGES].zones;
-		if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
+		zonelist = &NODE_DATA(node)->node_zonelist;
+		if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
 			return 1;
 	}
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
