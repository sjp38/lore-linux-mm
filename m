Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EE4A76B008A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 04:18:04 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so864774pab.41
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 01:18:04 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qp3si5323130pac.147.2014.11.06.01.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 01:18:03 -0800 (PST)
Date: Thu, 6 Nov 2014 12:17:49 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 8/8] slab: recharge slab pages to the allocating
 memory cgroup
Message-ID: <20141106091749.GB4839@esperanza>
References: <cover.1415046910.git.vdavydov@parallels.com>
 <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1411051242410.28485@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1411051242410.28485@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christoph,

On Wed, Nov 05, 2014 at 12:43:31PM -0600, Christoph Lameter wrote:
> On Mon, 3 Nov 2014, Vladimir Davydov wrote:
> 
> > +static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
> > +
> >  static __always_inline void *
> >  slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
> >  		   unsigned long caller)
> > @@ -3185,6 +3187,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
> >  		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
> >  		if (unlikely(flags & __GFP_ZERO))
> >  			memset(ptr, 0, cachep->object_size);
> > +		if (unlikely(memcg_kmem_recharge_slab(ptr, flags))) {
> > +			slab_free(cachep, ptr);
> > +			ptr = NULL;
> > +		}
> >  	}
> >
> >  	return ptr;
> > @@ -3250,6 +3256,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
> >  		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
> >  		if (unlikely(flags & __GFP_ZERO))
> >  			memset(objp, 0, cachep->object_size);
> > +		if (unlikely(memcg_kmem_recharge_slab(objp, flags))) {
> > +			slab_free(cachep, objp);
> > +			objp = NULL;
> > +		}
> >  	}
> >
> 
> Please do not add code to the hotpaths if its avoidable. Can you charge
> the full slab only when allocated please?

I call memcg_kmem_recharge_slab only on alloc path. Free path isn't
touched. The overhead added is one function call. The function only
reads and compares two pointers under RCU most of time. This is
comparable to the overhead introduced by memcg_kmem_get_cache, which is
called in slab_alloc/slab_alloc_node earlier.

Anyways, if you think this is unacceptable, I don't mind dropping the
whole patch set and thinking more on how to fix this per-memcg caches
trickery. What do you think?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
