Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id B915F6B004D
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:43:15 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id s7so6005479lbd.18
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:43:14 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yi2si37648560lbb.41.2014.06.24.00.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 00:43:13 -0700 (PDT)
Date: Tue, 24 Jun 2014 11:42:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140624074258.GA18121@esperanza>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
 <20140624072554.GB4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140624072554.GB4836@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Jun 24, 2014 at 04:25:54PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 13, 2014 at 12:38:22AM +0400, Vladimir Davydov wrote:
> > @@ -3368,7 +3379,8 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
> >  
> >  		/* fixup slab chains */
> >  		if (page->active == 0) {
> > -			if (n->free_objects > n->free_limit) {
> > +			if (n->free_objects > n->free_limit ||
> > +			    memcg_cache_dead(cachep)) {
> 
> I'd like to set 0 to free_limit in __kmem_cache_shrink()
> rather than memcg_cache_dead() test here, because memcg_cache_dead()
> is more expensive than it. Is there any problem in this way?

We'd have to be careful on cpu hotplug then, because it may update the
free_limit. Not a big problem though. Will fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
