Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CHWn5n003723
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:32:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CHWU2k145416
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:32:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CHWTq6023247
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:32:29 -0600
Date: Tue, 12 Jun 2007 10:32:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
Message-ID: <20070612173226.GW3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <1181657940.5592.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181657940.5592.19.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [10:19:00 -0400], Lee Schermerhorn wrote:
> On Mon, 2007-06-11 at 15:42 -0700, Christoph Lameter wrote:
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > Already done in the original patch (node_populated() returns (node == 0)
> > > if MAX_NUMODES <= 1), I think.
> > 
> > Ah good.
> > 
> > > @@ -2299,6 +2303,18 @@ static void build_zonelists(pg_data_t *pgdat)
> > >  		/* calculate node order -- i.e., DMA last! */
> > >  		build_zonelists_in_zone_order(pgdat, j);
> > >  	}
> > > +
> > > +	/*
> > > +	 * record nodes whose first fallback zone is "on-node" as
> > > +	 * populated
> > > +	 */
> > > +	z = pgdat->node_zonelists->zones[0];
> > > +
> > > +	VM_BUG_ON(!z);
> > > +	if (z->zone_pgdat == pgdat)
> > > +		node_set_populated(local_node);
> > > +	else
> > > +		node_not_populated(local_node);
> > >  }
> > >  
> > >  /* Construct the zonelist performance cache - see further mmzone.h */
> > > 
> > 
> > Could be much simpler:
> > 
> > if (pgdat->node_present_pages)
> > 	node_set_populated(local_node);
> 
> As a minimum, we need to exclude a node with only zone DMA memory for
> this to work on our platforms.  For that, I think the current code is
> the simplest because we still need to check if the first zone is
> "on-node" and !DMA.
> 
> And, I think we need both cases--set and reset populated map bit--to
> handle memory/node hotplug.  So something like:

That's a good point -- build_zonelists() will get called for the
rebuild, but won't remove nodes from the populated_map. Admittedly, only
hot-add is currently supported, right?

> 	if (z->zone_pgdat == pgdat && !is_zone_dma(z))
> 		node_set_populated(local_node);
> 	else
> 		node_not_populated(local_node);

Hrm, but then node_populated == node has non-DMA pages, which is
altogether unintuitive. Again, I think this obfuscates things -- perhaps
the map should be renamed to something closer to what you actually want
it to represent?

> Need to define 'is_zone-dma()' to test the zone or unconditionally
> return false depending on whether ZONE_DMA is configured.

@Andrew: would you be ok dropping the populated_map patches while I hammer
out whether it's what we want with Lee; and decide whether the fix-patch
on top is needed, as well, based on Christoph's feedback?

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
