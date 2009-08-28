Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DFE906B00A6
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 06:09:17 -0400 (EDT)
Date: Fri, 28 Aug 2009 11:09:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
Message-ID: <20090828100919.GC5054@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192902.10317.94512.sendpatchset@localhost.localdomain> <20090825101906.GB4427@csn.ul.ie> <1251233369.16229.1.camel@useless.americas.hpqcorp.net> <20090826101122.GD10955@csn.ul.ie> <1251309843.4409.48.camel@useless.americas.hpqcorp.net> <20090827102338.GC21183@csn.ul.ie> <1251391930.4374.89.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251391930.4374.89.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 27, 2009 at 12:52:10PM -0400, Lee Schermerhorn wrote:
> <snip>
> 
> > > @@ -1253,7 +1255,21 @@ static unsigned long set_max_huge_pages(
> > >  	if (h->order >= MAX_ORDER)
> > >  		return h->max_huge_pages;
> > >  
> > > -	nodes_allowed = huge_mpol_nodes_allowed();
> > > +	if (nid == NO_NODEID_SPECIFIED)
> > > +		nodes_allowed = huge_mpol_nodes_allowed();
> > > +	else {
> > > +		/*
> > > +		 * incoming 'count' is for node 'nid' only, so
> > > +		 * adjust count to global, but restrict alloc/free
> > > +		 * to the specified node.
> > > +		 */
> > > +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> > > +		nodes_allowed = alloc_nodemask_of_node(nid);
> > 
> > alloc_nodemask_of_node() isn't defined anywhere.
> 
> 
> Well, that's because the patch that defines it is in a message that I
> meant to send before this one.  I see it's in my Drafts folder.  I'll
> attach that patch below.  I'm rebasing against the 0827 mmotm, and I'll
> resend the rebased series.  However, I wanted to get your opinion of the
> nodemask patch below.
> 

It looks very reasonable to my eye. The caller must know that kfree() is
used to free it instead of free_nodemask_of_node() but it's not worth
getting into a twist over.

> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
