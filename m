Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB446B00F2
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:06:49 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id q8so3744195lbi.40
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 03:06:48 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wy8si41674224lbb.21.2014.06.10.03.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jun 2014 03:06:47 -0700 (PDT)
Date: Tue, 10 Jun 2014 14:06:31 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 3/8] memcg: mark caches that belong to offline
 memcgs as dead
Message-ID: <20140610100629.GB6293@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <9e6537847c22a5050f84bd2bf5633f7c022fb801.1402060096.git.vdavydov@parallels.com>
 <20140610074840.GF19036@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140610074840.GF19036@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 04:48:40PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 06, 2014 at 05:22:40PM +0400, Vladimir Davydov wrote:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 886b5b414958..ed42fd1105a5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3294,6 +3294,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
> >  	mutex_lock(&memcg_slab_mutex);
> >  	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
> >  		cachep = memcg_params_to_cache(params);
> > +		cachep->memcg_params->dead = true;
> 
> I guess that this needs smp_wmb() and memcg_cache_dead() needs
> smp_rmb(), since we could call memcg_cache_dead() without holding any locks.

Good catch! Actually, I thought we always call on_each_cpu, which works
effectively as a full memory barrier, from kmem_cache_shrink, but that's
not always true for SLUB, so we do need the barriers here. Will fix in
the next iteration.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
