Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id D839C6B0069
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:49:08 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so6024917lbv.14
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:49:08 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e2si18966812lab.49.2014.06.24.00.49.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 00:49:07 -0700 (PDT)
Date: Tue, 24 Jun 2014 11:48:53 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140624074853.GB18121@esperanza>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
 <20140624073840.GC4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140624073840.GC4836@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 04:38:41PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 13, 2014 at 12:38:22AM +0400, Vladimir Davydov wrote:
> > @@ -3462,6 +3474,17 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
> >  
> >  	kmemcheck_slab_free(cachep, objp, cachep->object_size);
> >  
> > +#ifdef CONFIG_MEMCG_KMEM
> > +	if (unlikely(!ac)) {
> > +		int nodeid = page_to_nid(virt_to_page(objp));
> > +
> > +		spin_lock(&cachep->node[nodeid]->list_lock);
> > +		free_block(cachep, &objp, 1, nodeid);
> > +		spin_unlock(&cachep->node[nodeid]->list_lock);
> > +		return;
> > +	}
> > +#endif
> > +
> 
> And, please document intention of this code. :)

Sure.

> And, you said that this way of implementation would be slow because
> there could be many object in dead caches and this implementation
> needs node spin_lock on each object freeing. Is it no problem now?

It may be :(

> If you have any performance data about this implementation and
> alternative one, could you share it?

I haven't (shame on me!). I'll do some testing today and send you the
results.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
