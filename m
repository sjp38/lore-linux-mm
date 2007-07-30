Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from
	MPOL_INTERLEAVE masks
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707301128400.1013@schroedinger.engr.sgi.com>
References: <1185566878.5069.123.camel@localhost>
	 <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1185812028.5492.79.camel@localhost>
	 <Pine.LNX.4.64.0707301128400.1013@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 30 Jul 2007 16:32:26 -0400
Message-Id: <1185827546.5492.84.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Paul Mundt <lethal@linux-sh.org>, Nishanth Aravamudan <nacc@us.ibm.com>, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-30 at 11:29 -0700, Christoph Lameter wrote:
> On Mon, 30 Jul 2007, Lee Schermerhorn wrote:
> 
> > +	return 0;
> > +}
> > +early_param("no_interleave_nodes", setup_no_interleave_nodes);
> > +
> >  /* The value user specified ....changed by config */
> >  static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
> >  /* string for sysctl */
> > @@ -2410,8 +2435,15 @@ static int __build_all_zonelists(void *d
> >  		build_zonelists(pgdat);
> >  		build_zonelist_cache(pgdat);
> >  
> > -		if (pgdat->node_present_pages)
> > +		if (pgdat->node_present_pages) {
> >  			node_set_state(nid, N_MEMORY);
> > +			/*
> > +			 * Only nodes with memory are valid for MPOL_INTERLEAVE,
> > +			 * but maybe not all of them?
> > +			 */
> > +			if (!node_isset(nid, no_interleave_nodes))
> > +				node_set_state(nid, N_INTERLEAVE);
> 
> 			else
> 			 printk ....
> 
> would be better since it will only list the nodes that have memory and are 
> excluded from interleave.

You mean instead of just listing the no_interleave_nodes node list
argument which might contain memoryless nodes? 

I'll fix that up on next respin.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
