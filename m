Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5719B600298
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 12:15:30 -0400 (EDT)
Date: Wed, 4 Aug 2010 11:15:29 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 03/23] slub: Use a constant for a unspecified node.
In-Reply-To: <alpine.DEB.2.00.1008032029380.23490@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008040946200.11084@router.home>
References: <20100804024514.139976032@linux.com> <20100804024525.562559967@linux.com> <alpine.DEB.2.00.1008032029380.23490@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, David Rientjes wrote:

> >  static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
> >  {
> >  	struct page *page;
> > -	int searchnode = (node == -1) ? numa_node_id() : node;
> > +	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> >
> >  	page = get_partial_node(get_node(s, searchnode));
> >  	if (page || (flags & __GFP_THISNODE) || node != -1)
>
> This has a merge conflict with 2.6.35 since it has this:
>
> 	page = get_partial_node(get_node(s, searchnode));
> 	if (page || (flags & __GFP_THISNODE))
> 		return page;
>
> 	return get_any_partial(s, flags);
>
> so what happened to the dropped check for returning get_any_partial() when
> node != -1?  I added the check for benchmarking.

Strange no merge conflict here. Are you sure you use upstream?

GFP_THISNODE does not matter too much. If page == NULL then we failed
to allocate a page on a specific node and have to either give up (and then
extend the slab) or take a page from another node.

We always have give up to go to the page allocator if GFP_THIS_NODE was
set. The modification to additionally also go to the page allocator if
a node was just set even without GFP_THISNODE. So checking for
GFP_THISNODE does not make sense anymore.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
