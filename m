Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
	 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
	 <20070611221036.GA14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 10:19:00 -0400
Message-Id: <1181657940.5592.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-11 at 15:42 -0700, Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Already done in the original patch (node_populated() returns (node == 0)
> > if MAX_NUMODES <= 1), I think.
> 
> Ah good.
> 
> > @@ -2299,6 +2303,18 @@ static void build_zonelists(pg_data_t *pgdat)
> >  		/* calculate node order -- i.e., DMA last! */
> >  		build_zonelists_in_zone_order(pgdat, j);
> >  	}
> > +
> > +	/*
> > +	 * record nodes whose first fallback zone is "on-node" as
> > +	 * populated
> > +	 */
> > +	z = pgdat->node_zonelists->zones[0];
> > +
> > +	VM_BUG_ON(!z);
> > +	if (z->zone_pgdat == pgdat)
> > +		node_set_populated(local_node);
> > +	else
> > +		node_not_populated(local_node);
> >  }
> >  
> >  /* Construct the zonelist performance cache - see further mmzone.h */
> > 
> 
> Could be much simpler:
> 
> if (pgdat->node_present_pages)
> 	node_set_populated(local_node);

As a minimum, we need to exclude a node with only zone DMA memory for
this to work on our platforms.  For that, I think the current code is
the simplest because we still need to check if the first zone is
"on-node" and !DMA.

And, I think we need both cases--set and reset populated map bit--to
handle memory/node hotplug.  So something like:

	if (z->zone_pgdat == pgdat && !is_zone_dma(z))
		node_set_populated(local_node);
	else
		node_not_populated(local_node);

Need to define 'is_zone-dma()' to test the zone or unconditionally
return false depending on whether ZONE_DMA is configured.


I will repost Nish's repost to "fix" this.

Lee
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
