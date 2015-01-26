Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4F03D6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:02:01 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id g10so12883568pdj.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:02:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xq8si13056776pab.11.2015.01.26.09.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 09:02:00 -0800 (PST)
Date: Mon, 26 Jan 2015 20:01:47 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 1/3] slub: don't fail kmem_cache_shrink if slab
 placement optimization fails
Message-ID: <20150126170147.GB28978@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501260944550.15849@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501260944550.15849@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christoph,

On Mon, Jan 26, 2015 at 09:48:00AM -0600, Christoph Lameter wrote:
> On Mon, 26 Jan 2015, Vladimir Davydov wrote:
> 
> > SLUB's kmem_cache_shrink not only removes empty slabs from the cache,
> > but also sorts slabs by the number of objects in-use to cope with
> > fragmentation. To achieve that, it tries to allocate a temporary array.
> > If it fails, it will abort the whole procedure.
> 
> I do not think its worth optimizing this. If we cannot allocate even a
> small object then the system is in an extremely bad state anyways.

Hmm, I've just checked my /proc/slabinfo and seen that I have 512
objects per slab at max, so that the temporary array will be 2 pages at
max. So you're right - this kmalloc will never fail on my system, simply
because we never fail GFP_KERNEL allocations of order < 3. However,
theoretically we can have as much as MAX_OBJS_PER_PAGE=32767 objects per
slab, which would result in a huge allocation.

Anyways, I think that silently relying on the fact that the allocator
never fails small allocations is kind of unreliable. What if this
behavior will change one day? So I'd prefer to either make
kmem_cache_shrink fall back to using a variable on stack in case of the
kmalloc failure, like this patch does, or place an explicit BUG_ON after
it. The latter looks dangerous to me, because, as I mentioned above, I'm
not sure that we always have less than 2048 objects per slab.

> 
> > @@ -3400,7 +3407,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
> >  		 * list_lock. page->inuse here is the upper limit.
> >  		 */
> >  		list_for_each_entry_safe(page, t, &n->partial, lru) {
> > -			list_move(&page->lru, slabs_by_inuse + page->inuse);
> > +			if (page->inuse < objects)
> > +				list_move(&page->lru,
> > +					  slabs_by_inuse + page->inuse);
> >  			if (!page->inuse)
> >  				n->nr_partial--;
> >  		}
> 
> The condition is always true. A page that has page->inuse == objects
> would not be on the partial list.
> 

This is in case we failed to allocate the slabs_by_inuse array. We only
have a list for empty slabs then (on stack).

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
