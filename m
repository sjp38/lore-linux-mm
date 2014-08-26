Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 085146B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 22:26:38 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so22623550pab.29
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:26:38 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gi1si1877987pac.168.2014.08.25.19.26.36
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 19:26:38 -0700 (PDT)
Date: Tue, 26 Aug 2014 11:26:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] mm/slab: support slab merge
Message-ID: <20140826022649.GC1035@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1408608675-20420-3-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1408251028420.27302@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408251028420.27302@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 25, 2014 at 10:29:19AM -0500, Christoph Lameter wrote:
> On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> 
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 09b060e..a1cc1c9 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -2052,6 +2052,26 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
> >  	return 0;
> >  }
> >
> > +unsigned long kmem_cache_flags(unsigned long object_size,
> > +	unsigned long flags, const char *name,
> > +	void (*ctor)(void *))
> > +{
> > +	return flags;
> > +}
> > +
> > +struct kmem_cache *
> > +__kmem_cache_alias(const char *name, size_t size, size_t align,
> > +		   unsigned long flags, void (*ctor)(void *))
> > +{
> > +	struct kmem_cache *cachep;
> > +
> > +	cachep = find_mergeable(size, align, flags, name, ctor);
> > +	if (cachep)
> > +		cachep->refcount++;
> > +
> > +	return cachep;
> > +}
> > +
> 
> These could be commonized as well. Make refcount a common field and then
> the same function can be used for both caches.

refcount is already common field. These can't be commonized, because
SLUB need some other SLUB specific processing related to debug flags
and object size change.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
