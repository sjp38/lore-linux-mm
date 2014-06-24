Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3545E6B0074
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 04:25:41 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so6098288lbi.10
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 01:25:40 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b2si19012615lae.133.2014.06.24.01.25.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 01:25:38 -0700 (PDT)
Date: Tue, 24 Jun 2014 12:25:26 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 7/8] slub: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140624082526.GD18121@esperanza>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <d4608a7a00080a51740d747703af5462f1255176.1402602126.git.vdavydov@parallels.com>
 <20140624075011.GD4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140624075011.GD4836@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 04:50:11PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 13, 2014 at 12:38:21AM +0400, Vladimir Davydov wrote:
> > @@ -3409,6 +3417,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
> >  		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
> >  	unsigned long flags;
> >  
> > +	if (memcg_cache_dead(s))
> > +		s->min_partial = 0;
> > +
> >  	if (!slabs_by_inuse) {
> >  		/*
> >  		 * Do not fail shrinking empty slabs if allocation of the
> 
> I think that you should move down n->nr_partial test after holding the
> lock in __kmem_cache_shrink(). Access to n->nr_partial without node lock
> is racy and you can see wrong value. It results in skipping to free empty
> slab so your destroying logic could fail.

You're right! Will fix this.

And there seems to be the same problem in SLAB, where we check
node->slabs_free list emptiness w/o holding node->list_lock (see
drain_freelist) while it can be modified concurrently by free_block.
This will be fixed automatically after we make __kmem_cache_shrink unset
node->free_limit (which must be done under the lock) though.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
