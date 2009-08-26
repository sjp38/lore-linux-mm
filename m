Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F29F6B0144
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:16:14 -0400 (EDT)
Date: Wed, 26 Aug 2009 10:58:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] hugetlb:  add nodemask arg to huge page alloc,
	free and surplus adjust fcns
Message-ID: <20090826095835.GB10955@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192637.10317.31039.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0908250112510.23660@chino.kir.corp.google.com> <1251233374.16229.2.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251233374.16229.2.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 04:49:34PM -0400, Lee Schermerhorn wrote:
> > > <SNIP>
> > > +static int hstate_next_node_to_alloc(struct hstate *h,
> > > +					nodemask_t *nodes_allowed)
> > >  {
> > >  	int nid, next_nid;
> > >  
> > > -	nid = h->next_nid_to_alloc;
> > > -	next_nid = next_node_allowed(nid);
> > > +	if (!nodes_allowed)
> > > +		nodes_allowed = &node_online_map;
> > > +
> > > +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> > > +
> > > +	next_nid = next_node_allowed(nid, nodes_allowed);
> > >  	h->next_nid_to_alloc = next_nid;
> > > +
> > >  	return nid;
> > >  }
> > 
> > Don't need next_nid.
> 
> Well, the pre-existing comment block indicated that the use of the
> apparently spurious next_nid variable is necessary to close a race.  Not
> sure whether that comment still applies with this rework.  What do you
> think?  
> 

The original intention was not to return h->next_nid_to_alloc because
there is a race window where it's MAX_NUMNODES.

nid is a stack-local variable here, it should not become MAX_NUMNODES by
accident because this_node_allowed() and next_node_allowed() are both taking
care not to return MAX_NUMNODES so it's safe as a return value. Even in the
presense of races with the code structure you currently have. I think it's
safe to have

nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);

return nid;

because at worse in the presense of races, h->next_nid_to_alloc gets
assigned to the same value twice, but never MAX_NUMNODES.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
