Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5C02gnP019686
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:02:42 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C07A8X212806
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:07:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C07Aww026354
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:07:10 -0600
Date: Mon, 11 Jun 2007 17:07:05 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612000705.GH14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [16:45:30 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Eep, except that we don't initialize node_populated_mask unless we're
> > NUMA. Also, do you think it's worth adding the comment in mmzone.h that
> > now now NUMA policies depend on present_pages?
> 
> No need to initialize if we do not use it. You may to #ifdef it out
> by moving the definition. Please sent a diff against the earlier patch 
> since Andrew already merged it.

We will be using it (it == node_populated_mask) later in my sysfs patch
and in the fix hugepage allocation patch.

Sorry, sent the updated patch before I got Andrew's mail.

> present_pages just indicates that there is memory on the node. So I am not 
> sure that this will help.

Ok.

> > +
> > +	/*
> > +	 * record populated zones for use when INTERLEAVE'ing or using
> > +	 * GFP_THISNODE
> > +	 */
> 
> There may be other purposes as well. No need to enumerate those here.

Ok.

Applies on top of add-populated_map-to-account-for-memoryless-nodes.patch.

populated_map needs to be consistent in both the NUMA and !NUMA cases to
fix hugepage allocation with empty nodes. Assume the one node in the
!NUMA case is populated.

Remove a comment that would only increase the maintenance burden.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 456f2f6..825d2df 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2303,10 +2303,6 @@ static void build_zonelists(pg_data_t *pgdat)
 		build_zonelists_in_zone_order(pgdat, j);
 	}
 
-	/*
-	 * record populated zones for use when INTERLEAVE'ing or using
-	 * GFP_THISNODE
-	 */
 	if (pgdat->node_present_pages)
 		node_set_populated(local_node);
 }
@@ -2370,6 +2366,8 @@ static void build_zonelists(pg_data_t *pgdat)
 
 		zonelist->zones[j] = NULL;
 	}
+
+	node_set_populated(local_node);
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
