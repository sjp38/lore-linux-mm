Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id F1CC46B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:24:02 -0400 (EDT)
Received: by mail-io0-f180.google.com with SMTP id e3so56650223ioa.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:24:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n1si18275515igp.22.2016.03.30.01.24.01
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:24:02 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:25:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 07/11] mm/slab: racy access/modify the slab color
Message-ID: <20160330082557.GF1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-8-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1603282004280.31323@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603282004280.31323@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 28, 2016 at 08:05:41PM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2016, js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Slab color isn't needed to be changed strictly. Because locking
> > for changing slab color could cause more lock contention so this patch
> > implements racy access/modify the slab color. This is a preparation step
> > to implement lockless allocation path when there is no free objects in
> > the kmem_cache.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 
> The rest of the description does not relate to this patch and does not
> actually reflect the improvement of applying this patch. Remove the rest?

No, below improvement is for this individual patch.

Thanks.

> 
> 
> > Below is the result of concurrent allocation/free in slab allocation
> > benchmark made by Christoph a long time ago. I make the output simpler.
> > The number shows cycle count during alloc/free respectively so less
> > is better.
> >
> > * Before
> > Kmalloc N*alloc N*free(32): Average=365/806
> > Kmalloc N*alloc N*free(64): Average=452/690
> > Kmalloc N*alloc N*free(128): Average=736/886
> > Kmalloc N*alloc N*free(256): Average=1167/985
> > Kmalloc N*alloc N*free(512): Average=2088/1125
> > Kmalloc N*alloc N*free(1024): Average=4115/1184
> > Kmalloc N*alloc N*free(2048): Average=8451/1748
> > Kmalloc N*alloc N*free(4096): Average=16024/2048
> >
> > * After
> > Kmalloc N*alloc N*free(32): Average=355/750
> > Kmalloc N*alloc N*free(64): Average=452/812
> > Kmalloc N*alloc N*free(128): Average=559/1070
> > Kmalloc N*alloc N*free(256): Average=1176/980
> > Kmalloc N*alloc N*free(512): Average=1939/1189
> > Kmalloc N*alloc N*free(1024): Average=3521/1278
> > Kmalloc N*alloc N*free(2048): Average=7152/1838
> > Kmalloc N*alloc N*free(4096): Average=13438/2013
> >
> > It shows that contention is reduced for object size >= 1024
> > and performance increases by roughly 15%.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/slab.c | 26 +++++++++++++-------------
> >  1 file changed, 13 insertions(+), 13 deletions(-)
> >
> > diff --git a/mm/slab.c b/mm/slab.c
> > index df11757..52fc5e3 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -2536,20 +2536,7 @@ static int cache_grow(struct kmem_cache *cachep,
> >  	}
> >  	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
> >
> > -	/* Take the node list lock to change the colour_next on this node */
> >  	check_irq_off();
> > -	n = get_node(cachep, nodeid);
> > -	spin_lock(&n->list_lock);
> > -
> > -	/* Get colour for the slab, and cal the next value. */
> > -	offset = n->colour_next;
> > -	n->colour_next++;
> > -	if (n->colour_next >= cachep->colour)
> > -		n->colour_next = 0;
> > -	spin_unlock(&n->list_lock);
> > -
> > -	offset *= cachep->colour_off;
> > -
> >  	if (gfpflags_allow_blocking(local_flags))
> >  		local_irq_enable();
> >
> > @@ -2570,6 +2557,19 @@ static int cache_grow(struct kmem_cache *cachep,
> >  	if (!page)
> >  		goto failed;
> >
> > +	n = get_node(cachep, nodeid);
> > +
> > +	/* Get colour for the slab, and cal the next value. */
> > +	n->colour_next++;
> > +	if (n->colour_next >= cachep->colour)
> > +		n->colour_next = 0;
> > +
> > +	offset = n->colour_next;
> > +	if (offset >= cachep->colour)
> > +		offset = 0;
> > +
> > +	offset *= cachep->colour_off;
> > +
> >  	/* Get slab management. */
> >  	freelist = alloc_slabmgmt(cachep, page, offset,
> >  			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
