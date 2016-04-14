Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97F936B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 21:56:07 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id jl1so115439790obb.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 18:56:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 4si1452198igy.84.2016.04.13.18.56.05
        for <linux-mm@kvack.org>;
        Wed, 13 Apr 2016 18:56:06 -0700 (PDT)
Date: Thu, 14 Apr 2016 10:56:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 01/11] mm/slab: fix the theoretical race by holding
 proper lock
Message-ID: <20160414015640.GB9198@js1304-P5Q-DELUXE>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1460436666-20462-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1604121137470.14315@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1604121137470.14315@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 12, 2016 at 11:38:39AM -0500, Christoph Lameter wrote:
> On Tue, 12 Apr 2016, js1304@gmail.com wrote:
> 
> > @@ -2222,6 +2241,7 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
> >  {
> >  	struct kmem_cache_node *n;
> >  	int node;
> > +	LIST_HEAD(list);
> >
> >  	on_each_cpu(do_drain, cachep, 1);
> >  	check_irq_on();
> > @@ -2229,8 +2249,13 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
> >  		if (n->alien)
> >  			drain_alien_cache(cachep, n->alien);
> >
> > -	for_each_kmem_cache_node(cachep, node, n)
> > -		drain_array(cachep, n, n->shared, 1, node);
> > +	for_each_kmem_cache_node(cachep, node, n) {
> > +		spin_lock_irq(&n->list_lock);
> > +		drain_array_locked(cachep, n->shared, node, true, &list);
> > +		spin_unlock_irq(&n->list_lock);
> > +
> > +		slabs_destroy(cachep, &list);
> 
> Can the slabs_destroy() call be moved outside of the loop? It may be
> faster then?

Yes, it can. But, I'd prefer to call it on each node. It would be
better for cache although it would be marginal.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
