Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 92EF86B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 03:40:37 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o757eejt021412
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 00:40:42 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by kpbe19.cbf.corp.google.com with ESMTP id o757ecc3021479
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 00:40:39 -0700
Received: by pxi7 with SMTP id 7so2432369pxi.28
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 00:40:38 -0700 (PDT)
Date: Thu, 5 Aug 2010 00:40:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 03/23] slub: Use a constant for a unspecified node.
In-Reply-To: <alpine.DEB.2.00.1008040946200.11084@router.home>
Message-ID: <alpine.DEB.2.00.1008050036520.29020@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <20100804024525.562559967@linux.com> <alpine.DEB.2.00.1008032029380.23490@chino.kir.corp.google.com> <alpine.DEB.2.00.1008040946200.11084@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 2010, Christoph Lameter wrote:

> > >  static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
> > >  {
> > >  	struct page *page;
> > > -	int searchnode = (node == -1) ? numa_node_id() : node;
> > > +	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> > >
> > >  	page = get_partial_node(get_node(s, searchnode));
> > >  	if (page || (flags & __GFP_THISNODE) || node != -1)
> >
> > This has a merge conflict with 2.6.35 since it has this:
> >
> > 	page = get_partial_node(get_node(s, searchnode));
> > 	if (page || (flags & __GFP_THISNODE))
> > 		return page;
> >
> > 	return get_any_partial(s, flags);
> >
> > so what happened to the dropped check for returning get_any_partial() when
> > node != -1?  I added the check for benchmarking.
> 
> Strange no merge conflict here. Are you sure you use upstream?
> 

Yes, 2.6.35 does not have the node != -1 check and Linus hasn't pulled 
slub/fixes from Pekka's tree yet.  Even when he does, "slub numa: Fix rare 
allocation from unexpected node" removes the __GFP_THISNODE check before 
adding node != -1, so this definitely doesn't apply to anybody else's 
tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
