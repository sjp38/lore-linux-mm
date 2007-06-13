Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5DN4eG1006411
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:04:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DN98Wx242296
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:09:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DN97go026204
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:09:08 -0600
Date: Wed, 13 Jun 2007 16:09:06 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070613230906.GV3798@us.ibm.com>
References: <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost> <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com> <1181677473.5592.149.camel@localhost> <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com> <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost> <20070613175802.GP3798@us.ibm.com> <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [15:50:41 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > I think your code above makes sense -- I'd still leave in the earlier
> > check, though.
> > 
> > So it probably should be:
> > 
> > 	pgdat = NODE_DATA(nid);
> > 	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> > 
> > 	if (unlikely((gfp_mask & __GFP_THISNODE) &&
> > 		(!node_memory(nid) ||
> > 		 zonelist->zones[0]->zone_pgdat != pgdat)))
> > 		 return NULL;
> > 
> > That way, if the node has no memory whatsoever, we don't bother checking
> > the pgdat of the relevant zone?
> 
> Checking the pgdat is already done in __alloc_pages. No need to repeat
> it here.

Except that check is broken in the same way it is for memoryless nodes,
right?

from get_page_from_freelist():

                if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
                        zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))

Which asks if for this zone, is the first node the same as each node we look at
for THISNODE requests. But if the first node for the zone is a
*different* node, we still satisfy the request, but go off-node?

Just trying to see if that maybe is the problem here?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
