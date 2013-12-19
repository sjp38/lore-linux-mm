Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id DAFFB6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:43:34 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so341476eek.8
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:43:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si3518585eeo.107.2013.12.19.01.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:43:34 -0800 (PST)
Date: Thu, 19 Dec 2013 10:43:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/6] memcg, slab: RCU protect memcg_params for root caches
Message-ID: <20131219094333.GB10855@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <be8f2fede0fbc45496c06f7bc6cc2272b9b81cc4.1387372122.git.vdavydov@parallels.com>
 <20131219092836.GH9331@dhcp22.suse.cz>
 <52B2BE2A.2080509@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B2BE2A.2080509@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 19-12-13 13:36:42, Vladimir Davydov wrote:
> On 12/19/2013 01:28 PM, Michal Hocko wrote:
> > On Wed 18-12-13 17:16:57, Vladimir Davydov wrote:
[...]
> >> diff --git a/mm/slab.h b/mm/slab.h
> >> index 1d8b53f..53b81a9 100644
> >> --- a/mm/slab.h
> >> +++ b/mm/slab.h
> >> @@ -164,10 +164,16 @@ static inline struct kmem_cache *
> >>  cache_from_memcg_idx(struct kmem_cache *s, int idx)
> >>  {
> >>  	struct kmem_cache *cachep;
> >> +	struct memcg_cache_params *params;
> >>  
> >>  	if (!s->memcg_params)
> >>  		return NULL;
> >> -	cachep = s->memcg_params->memcg_caches[idx];
> >> +
> >> +	rcu_read_lock();
> >> +	params = rcu_dereference(s->memcg_params);
> >> +	cachep = params->memcg_caches[idx];
> >> +	rcu_read_unlock();
> >> +
> > Consumer has to be covered by the same rcu section otherwise
> > memcg_params might be freed right after rcu unlock here.
> 
> No. We protect only accesses to kmem_cache::memcg_params, which can
> potentially be relocated for root caches.

Hmm, ok. So memcg_params might change (a new memcg is accounted) but
pointers at idx will be same, right?

> But as soon as we get the
> pointer to a kmem_cache from this array, we can freely dereference it,
> because the cache cannot be freed when we use it. This is, because we
> access a kmem_cache either under the slab_mutex or
> memcg->slab_caches_mutex, or when we allocate/free from it. While doing
> the latter, the cache can't go away, it would be a bug. IMO.

That expects that cache_from_memcg_idx is always called with slab_mutex
or slab_caches_mutex held, right? Please document it.

> 
> Thanks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
