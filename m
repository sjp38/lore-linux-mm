Date: Wed, 13 Jun 2007 13:13:19 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613041319.GA15328@linux-sh.org>
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au> <20070613033306.GA15169@linux-sh.org> <466F66E3.8020200@yahoo.com.au> <466F67A4.9080104@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466F67A4.9080104@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 01:42:28PM +1000, Nick Piggin wrote:
> Nick Piggin wrote:
> >Paul Mundt wrote:
> 
> >>That's why I tossed in the node id matching in slob_alloc() for the
> >>partial free page lookup. At the moment the logic obviously won't scale,
> >>since we end up scanning the entire freelist looking for a page that
> >>matches the node specifier. If we don't find one, we could rescan and
> >>just grab a block from another node, but at the moment it just continues
> >>on and tries to fetch a new page for the specified node.
> >
> >
> >Oh, I didn't notice that. OK, sorry that would work.
> 
> OTOH, there are lots of places that don't specify the node explicitly,
> but most of them prefer the allocation to come from the current node...
> and that case isn't handled very well is it?
> 
Well, we could throw in a numa_node_id() for kmem_cache_alloc() and
__kmalloc(), that would actually simplify slob_new_page(), since we can
just use alloc_pages_node() directly in the NUMA case without special
casing the node id.

This also has the side-effect of working well on UP with asymmetric nodes
(assuming a larger node 0), since numa_node_id() will leave us with a
node 0 preference in places where the node id isn't explicitly given.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
