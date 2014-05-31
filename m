Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 532216B0035
	for <linux-mm@kvack.org>; Sat, 31 May 2014 07:05:10 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so1582268lbg.32
        for <linux-mm@kvack.org>; Sat, 31 May 2014 04:05:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id u3si9134370laj.103.2014.05.31.04.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 May 2014 04:05:08 -0700 (PDT)
Date: Sat, 31 May 2014 15:04:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs
 immediately
Message-ID: <20140531110456.GC25076@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300955120.11943@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405300955120.11943@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 30, 2014 at 09:57:10AM -0500, Christoph Lameter wrote:
> On Fri, 30 May 2014, Vladimir Davydov wrote:
> 
> > (3) is a bit more difficult, because slabs are added to per-cpu partial
> > lists lock-less. Fortunately, we only have to handle the __slab_free
> > case, because, as there shouldn't be any allocation requests dispatched
> > to a dead memcg cache, get_partial_node() should never be called. In
> > __slab_free we use cmpxchg to modify kmem_cache_cpu->partial (see
> > put_cpu_partial) so that setting ->partial to a special value, which
> > will make put_cpu_partial bail out, will do the trick.
> >
> > Note, this shouldn't affect performance, because keeping empty slabs on
> > per node lists as well as using per cpu partials are only worthwhile if
> > the cache is used for allocations, which isn't the case for dead caches.
> 
> This all sounds pretty good to me but we still have some pretty extensive
> modifications that I would rather avoid.
> 
> In put_cpu_partial you can simply check that the memcg is dead right? This
> would avoid all the other modifications I would think and will not require
> a special value for the per cpu partial pointer.

That would be racy. The check if memcg is dead and the write to per cpu
partial ptr wouldn't proceed as one atomic operation. If we set the dead
flag from another thread between these two operations, put_cpu_partial
will add a slab to a per cpu partial list *after* the cache was zapped.

But aren't modifications this patch introduces that extensive?

In fact, it just adds the check if ->partial == CPU_SLAB_PARTIAL_DEAD in
a couple of places, namely put_cpu_partial and unfreeze_partials, where
it looks pretty natural, IMO. Other hunks of this patch just (1) move
some code w/o modifying it to a separate function, (2) add BUG_ON's to
alloc paths (get_partial_node and __slab_alloc), where we should never
see this value, and (3) add checks to sysfs/debug paths.
[ Now I guess I had to split this patch to make it more readable ]

(1) and (2) doesn't make the code slower or more difficult to
understand, IMO. (3) is a bit cumbersome, but we can make it neater by
introducing a special function for them that will return the partial
slab if it wasn't zapped, something like this:

static struct page *cpu_slab_partial(struct kmem_cache *s, int cpu)
{
	struct page = per_cpu_ptr(s->cpu_slab, cpu)->partial;l

	if (page == CPU_SLAB_PARTIAL_DEAD)
		page = NULL;
	return page;
}

Thus we would only have to check for this special value only in three
places in the code, namely put_cpu_partial, unfreeze_partials, and
cpu_slab_partial.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
