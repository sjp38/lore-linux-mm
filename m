Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 207D46B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 16:23:29 -0500 (EST)
Date: Wed, 8 Feb 2012 21:23:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120208212323.GM5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <1328568978-17553-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1202071025050.30652@router.home>
 <20120208144506.GI5938@suse.de>
 <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de>
 <alpine.DEB.2.00.1202081338210.32060@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202081338210.32060@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Feb 08, 2012 at 01:49:05PM -0600, Christoph Lameter wrote:
> On Wed, 8 Feb 2012, Mel Gorman wrote:
> 
> > Ok, I looked into what is necessary to replace these with checking a page
> > flag and the cost shifts quite a bit and ends up being more expensive.
> 
> That is only true if you go the slab route.

Well, yes but both slab and slub have to be supported. I see no reason
why I would choose to make this a slab-only or slub-only feature. Slob is
not supported because it's not expected that a platform using slob is also
going to use network-based swap.

> Slab suffers from not having
> the page struct pointer readily available. The changes are likely already
> impacting slab performance without the virt_to_page patch.
> 

The performance impact only comes into play when swap is on a network
device and pfmemalloc reserves are in use. The rest of the time the check
on ac avoids all the cost and there is a micro-optimisation later to avoid
calling a function (patch 12).

> > In slub, it's sufficient to check kmem_cache_cpu to know whether the
> > objects in the list are pfmemalloc or not.
> 
> We try to minimize the size of kmem_cache_cpu. The page pointer is readily
> available. We just removed the node field from kmem_cache_cpu because it
> was less expensive to get the node number from the struct page field.
> 
> The same is certainly true for a PFMEMALLOC flag.
> 

Ok, are you asking that I use the page flag for slub and leave kmem_cache_cpu
alone in the slub case? I can certainly check it out if that's what you
are asking for.

> > Yeah, you're right on the button there. I did my checking assuming that
> > PG_active+PG_slab were safe to use. The following is an untested patch that
> > I probably got details wrong in but it illustrates where virt_to_page()
> > starts cropping up.
> 
> Yes you need to come up with a way to not use virt_to_page otherwise slab
> performance is significantly impacted.

I did come up with a way: the necessary information is in ac and slabp
on slab :/ . There are not exactly many ways that the information can
be recorded.

> On NUMA we are already doing a page struct lookup on free in slab.
> If you would save the page struct pointer
> there and reuse it then you would not have an issue at least on free.
> 

That information is only available on NUMA and only when there is more than
one node. Having cache_free_alien return the page for passing to ac_put_obj()
would also be ugly. The biggest downfall by far is that single-node machines
incur the cost of virt_to_page() where they did not have to before. This
is not a solution and it is not better than the current simply check on
a struct field.

> You still would need to determine which "struct slab" pointer is in use
> which will also require similar lookups in varous places.
> 
> Transfer of the pfmemalloc flags (guess you must have a pfmemalloc
> field in struct slab then) in slab is best be done when allocating and
> freeing a slab page from the page allocator.
> 

The page->pfmemalloc is already been transferred to the slab in
cache_grow.

> I think its rather trivial to add the support you want in a non intrusive
> way to slub. Slab would require some more thought and discussion.
> 

I'm slightly confused by this sentence. Support for slub is already in the
patch and as you say, it's fairly straight-forward. Supporting a page flag
and leaving kmem_cache_cpu alone may also be easier as kmem_cache_cpu->page
can be used instead of a kmem_cache_cpu->pfmemalloc field.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
