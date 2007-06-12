Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CHcHHC029587
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:38:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CHaCp6240106
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:38:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CHZON6012585
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:35:24 -0600
Date: Tue, 12 Jun 2007 10:35:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
Message-ID: <20070612173521.GX3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <1181657433.5592.11.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181657433.5592.11.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [10:10:33 -0400], Lee Schermerhorn wrote:
> On Mon, 2007-06-11 at 14:25 -0700, Christoph Lameter wrote:
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > @@ -2161,7 +2164,7 @@ static int node_order[MAX_NUMNODES];
> > >  static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
> > >  {
> > >  	enum zone_type i;
> > > -	int pos, j, node;
> > > +	int pos, j;
> > >  	int zone_type;		/* needs to be signed */
> > >  	struct zone *z;
> > >  	struct zonelist *zonelist;
> > > @@ -2171,7 +2174,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
> > >  		pos = 0;
> > >  		for (zone_type = i; zone_type >= 0; zone_type--) {
> > >  			for (j = 0; j < nr_nodes; j++) {
> > > -				node = node_order[j];
> > > +				int node = node_order[j];
> > >  				z = &NODE_DATA(node)->node_zones[zone_type];
> > >  				if (populated_zone(z)) {
> > >  					zonelist->zones[pos++] = z;
> > 
> > Unrelated modifications.
> > 
> > > @@ -2244,6 +2247,22 @@ static void set_zonelist_order(void)
> > >  		current_zonelist_order = user_zonelist_order;
> > >  }
> > >  
> > > +/*
> > > + * setup_populate_map() - record nodes whose "policy_zone" is "on-node".
> > > + */
> > > +static void setup_populated_map(int nid)
> > > +{
> > > +	pg_data_t *pgdat = NODE_DATA(nid);
> > > +	struct zonelist *zl = pgdat->node_zonelists + policy_zone;
> > > +	struct zone *z = zl->zones[0];
> > > +
> > > +	VM_BUG_ON(!z);
> > > +	if (z->zone_pgdat == pgdat)
> > > +		node_set_populated(nid);
> > > +	else
> > > +		node_not_populated(nid);
> > > +}
> > 
> > 
> > A node is only populated if it has memory in the policy zone? I
> > would say a node is populated if it has any memory in any zone.
> 
> Mea culpa.  Our platforms have a [pseudo-]node with just O(1G) memory
> all in zone DMA.  That node can't look populated for allocating huge
> pages.

Because you don't want to use up any of the DMA pages, right? That seems
*very* platform specific. And it doesn't seem right to make common code
more complicated for one platform. Maybe there isn't a better solution,
but I'd like to mull it over.

> > The above check may fail on x86_64 where only some nodes may have 
> > ZONE_NORMAL. Others only have ZONE_DMA32. Policy zone will be set to 
> > ZONE_NORMAL.
> 
> Yes.  I thought of this after I created the patch.  I've been looking
> for a platform with exactly 4GB per node to test on.  I believe that,
> on our platforms, all of node zero would be in zone DMA32 and all
> other nodes would be > DMA32.  
> 
> Maybe we can just exclude zone DMA from the populated map?

Maybe I don't know enough about NUMA and such, but I'm not sure I
understand how this would make it a populated map anymore?

Maybe we need two maps, really?

One is for nodes that have memory, period (pages_present) ==
populated_map as currently implemented.

Another is for nodes that can satisfy hugepage allocations
(policy_zone?) (a subset of the populated nodes).

That may solve both the memoryless nodes problem and your platform's
problem?

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
