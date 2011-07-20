Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C7C406B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:43:53 -0400 (EDT)
Date: Wed, 20 Jul 2011 14:43:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
Message-ID: <20110720134342.GK5349@suse.de>
References: <20110720121612.28888.38970.stgit@localhost6>
 <alpine.DEB.2.00.1107201611010.3528@tiger>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107201611010.3528@tiger>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, Jul 20, 2011 at 04:14:51PM +0300, Pekka Enberg wrote:
> On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
> >Order of sizeof(struct kmem_cache) can be bigger than PAGE_ALLOC_COSTLY_ORDER,
> >thus there is a good chance of unsuccessful allocation.
> >With __GFP_REPEAT buddy-allocator will reclaim/compact memory more aggressively.
> >
> >Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> >---
> >mm/slab.c |    2 +-
> >1 files changed, 1 insertions(+), 1 deletions(-)
> >
> >diff --git a/mm/slab.c b/mm/slab.c
> >index d96e223..53bddc8 100644
> >--- a/mm/slab.c
> >+++ b/mm/slab.c
> >@@ -2304,7 +2304,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
> >		gfp = GFP_NOWAIT;
> >
> >	/* Get cache's description obj. */
> >-	cachep = kmem_cache_zalloc(&cache_cache, gfp);
> >+	cachep = kmem_cache_zalloc(&cache_cache, gfp | __GFP_REPEAT);
> >	if (!cachep)
> >		goto oops;
> 
> The changelog isn't that convincing, really. This is
> kmem_cache_create() so I'm surprised we'd ever get NULL here in
> practice. Does this fix some problem you're seeing? If this is
> really an issue, I'd blame the page allocator as GFP_KERNEL should
> just work.
> 

Besides, is allocating from cache_cache really a
PAGE_ALLOC_COSTLY_ORDER allocation? On my laptop at least, it's an
order-2 allocation which is supporting up to 512 CPUs and 512 nodes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
