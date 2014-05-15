Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 15EA66B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 02:34:55 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so434951lbv.35
        for <linux-mm@kvack.org>; Wed, 14 May 2014 23:34:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bd6si1417021lbc.131.2014.05.14.23.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 May 2014 23:34:54 -0700 (PDT)
Date: Thu, 15 May 2014 10:34:42 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg
 caches
Message-ID: <20140515063441.GA32113@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141114040.16512@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405141114040.16512@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 14, 2014 at 11:16:36AM -0500, Christoph Lameter wrote:
> On Tue, 13 May 2014, Vladimir Davydov wrote:
> 
> > Currently full slabs are only kept on per-node lists for debugging, but
> > we need this feature to reparent per memcg caches, so let's enable it
> > for them too.
> 
> That will significantly impact the fastpaths for alloc and free.
> 
> Also a pretty significant change the logic of the fastpaths since they
> were not designed to handle the full lists. In debug mode all operations
> were only performed by the slow paths and only the slow paths so far
> supported tracking full slabs.

That's the minimal price we have to pay for slab re-parenting, because
w/o it we won't be able to look up for all slabs of a particular per
memcg cache. The question is, can it be tolerated or I'd better try some
other way?

> 
> > @@ -2587,6 +2610,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
> >
> >  			} else { /* Needs to be taken off a list */
> >
> > +				if (kmem_cache_has_cpu_partial(s) && !prior)
> > +					new.frozen = 1;
> > +
> >  	                        n = get_node(s, page_to_nid(page));
> 
> Make this code conditional?

No problem, this patch is just a draft. Thanks to static keys, it won't
be difficult to eliminate any overhead if there is no kmem-active
memcgs.

Thanks.

> 
> >  				/*
> >  				 * Speculatively acquire the list_lock.
> > @@ -2606,6 +2632,12 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
> >  		object, new.counters,
> >  		"__slab_free"));
> >
> > +	if (unlikely(n) && new.frozen && !was_frozen) {
> > +		remove_full(s, n, page);
> > +		spin_unlock_irqrestore(&n->list_lock, flags);
> > +		n = NULL;
> > +	}
> > +
> >  	if (likely(!n)) {
> 
> Here too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
