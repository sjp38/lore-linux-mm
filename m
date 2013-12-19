Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEB96B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:47:42 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id mc6so339664lab.26
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:47:42 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y9si1322241laa.175.2013.12.19.01.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:47:40 -0800 (PST)
Message-ID: <52B2C0B5.9010602@parallels.com>
Date: Thu, 19 Dec 2013 13:47:33 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] memcg, slab: RCU protect memcg_params for root caches
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com> <be8f2fede0fbc45496c06f7bc6cc2272b9b81cc4.1387372122.git.vdavydov@parallels.com> <20131219092836.GH9331@dhcp22.suse.cz> <52B2BE2A.2080509@parallels.com> <20131219094333.GB10855@dhcp22.suse.cz>
In-Reply-To: <20131219094333.GB10855@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 12/19/2013 01:43 PM, Michal Hocko wrote:
> On Thu 19-12-13 13:36:42, Vladimir Davydov wrote:
>> On 12/19/2013 01:28 PM, Michal Hocko wrote:
>>> On Wed 18-12-13 17:16:57, Vladimir Davydov wrote:
> [...]
>>>> diff --git a/mm/slab.h b/mm/slab.h
>>>> index 1d8b53f..53b81a9 100644
>>>> --- a/mm/slab.h
>>>> +++ b/mm/slab.h
>>>> @@ -164,10 +164,16 @@ static inline struct kmem_cache *
>>>>  cache_from_memcg_idx(struct kmem_cache *s, int idx)
>>>>  {
>>>>  	struct kmem_cache *cachep;
>>>> +	struct memcg_cache_params *params;
>>>>  
>>>>  	if (!s->memcg_params)
>>>>  		return NULL;
>>>> -	cachep = s->memcg_params->memcg_caches[idx];
>>>> +
>>>> +	rcu_read_lock();
>>>> +	params = rcu_dereference(s->memcg_params);
>>>> +	cachep = params->memcg_caches[idx];
>>>> +	rcu_read_unlock();
>>>> +
>>> Consumer has to be covered by the same rcu section otherwise
>>> memcg_params might be freed right after rcu unlock here.
>> No. We protect only accesses to kmem_cache::memcg_params, which can
>> potentially be relocated for root caches.
> Hmm, ok. So memcg_params might change (a new memcg is accounted) but
> pointers at idx will be same, right?

Yes, that's a classical Read-Copy-Update :-)

>
>> But as soon as we get the
>> pointer to a kmem_cache from this array, we can freely dereference it,
>> because the cache cannot be freed when we use it. This is, because we
>> access a kmem_cache either under the slab_mutex or
>> memcg->slab_caches_mutex, or when we allocate/free from it. While doing
>> the latter, the cache can't go away, it would be a bug. IMO.
> That expects that cache_from_memcg_idx is always called with slab_mutex
> or slab_caches_mutex held, right? Please document it.

Yeah, you're right, this longs for a documentation. I'm going to check
this code a bit more and try to write a good comment about it (although
I'm rather poor at writing comments :-( )

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
