Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 965BF6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 09:59:26 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hr17so6475472lab.6
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 06:59:25 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e6si12794537lam.9.2014.02.04.06.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 06:59:24 -0800 (PST)
Message-ID: <52F1004B.90307@parallels.com>
Date: Tue, 4 Feb 2014 18:59:23 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
References: <cover.1391356789.git.vdavydov@parallels.com> <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com> <20140204145210.GH4890@dhcp22.suse.cz>
In-Reply-To: <20140204145210.GH4890@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/04/2014 06:52 PM, Michal Hocko wrote:
> On Sun 02-02-14 20:33:48, Vladimir Davydov wrote:
>> Suppose we are creating memcg cache A that could be merged with cache B
>> of the same memcg. Since any memcg cache has the same parameters as its
>> parent cache, parent caches PA and PB of memcg caches A and B must be
>> mergeable too. That means PA was merged with PB on creation or vice
>> versa, i.e. PA = PB. From that it follows that A = B, and we couldn't
>> even try to create cache B, because it already exists - a contradiction.
> I cannot tell I understand the above but I am totally not sure about the
> statement bellow.
>
>> So let's remove unused code responsible for merging memcg caches.
> How come the code was unused? find_mergeable called cache_match_memcg...

Oh, sorry for misleading comment. I mean the code handling merging of
per-memcg caches is useless, AFAIU: if we find an alias for a per-memcg
cache on kmem_cache_create_memcg(), the parent of the found alias must
be the same as the parent_cache passed to kmem_cache_create_memcg(), but
if it were so, we would never proceed to the memcg cache creation,
because the cache we want to create already exists.

Thanks.

>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> ---
>>  mm/slab.h        |   21 ++++-----------------
>>  mm/slab_common.c |    8 +++++---
>>  mm/slub.c        |   19 +++++++++----------
>>  3 files changed, 18 insertions(+), 30 deletions(-)
>>
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 8184a7cde272..3045316b7c9d 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -55,12 +55,12 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
>>  struct mem_cgroup;
>>  #ifdef CONFIG_SLUB
>>  struct kmem_cache *
>> -__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
>> -		   size_t align, unsigned long flags, void (*ctor)(void *));
>> +__kmem_cache_alias(const char *name, size_t size, size_t align,
>> +		   unsigned long flags, void (*ctor)(void *));
>>  #else
>>  static inline struct kmem_cache *
>> -__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
>> -		   size_t align, unsigned long flags, void (*ctor)(void *))
>> +__kmem_cache_alias(const char *name, size_t size, size_t align,
>> +		   unsigned long flags, void (*ctor)(void *))
>>  { return NULL; }
>>  #endif
>>  
>> @@ -119,13 +119,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
>>  	return !s->memcg_params || s->memcg_params->is_root_cache;
>>  }
>>  
>> -static inline bool cache_match_memcg(struct kmem_cache *cachep,
>> -				     struct mem_cgroup *memcg)
>> -{
>> -	return (is_root_cache(cachep) && !memcg) ||
>> -				(cachep->memcg_params->memcg == memcg);
>> -}
>> -
>>  static inline void memcg_bind_pages(struct kmem_cache *s, int order)
>>  {
>>  	if (!is_root_cache(s))
>> @@ -204,12 +197,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
>>  	return true;
>>  }
>>  
>> -static inline bool cache_match_memcg(struct kmem_cache *cachep,
>> -				     struct mem_cgroup *memcg)
>> -{
>> -	return true;
>> -}
>> -
>>  static inline void memcg_bind_pages(struct kmem_cache *s, int order)
>>  {
>>  }
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 152d9b118b7a..a75834bb966d 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -200,9 +200,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>>  	 */
>>  	flags &= CACHE_CREATE_MASK;
>>  
>> -	s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
>> -	if (s)
>> -		goto out_unlock;
>> +	if (!memcg) {
>> +		s = __kmem_cache_alias(name, size, align, flags, ctor);
>> +		if (s)
>> +			goto out_unlock;
>> +	}
>>  
>>  	err = -ENOMEM;
>>  	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 2b1a6970e46f..962abfdfde06 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3686,9 +3686,8 @@ static int slab_unmergeable(struct kmem_cache *s)
>>  	return 0;
>>  }
>>  
>> -static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
>> -		size_t align, unsigned long flags, const char *name,
>> -		void (*ctor)(void *))
>> +static struct kmem_cache *find_mergeable(size_t size, size_t align,
>> +		unsigned long flags, const char *name, void (*ctor)(void *))
>>  {
>>  	struct kmem_cache *s;
>>  
>> @@ -3707,11 +3706,14 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
>>  		if (slab_unmergeable(s))
>>  			continue;
>>  
>> +		if (!is_root_cache(s))
>> +			continue;
>> +
>>  		if (size > s->size)
>>  			continue;
>>  
>>  		if ((flags & SLUB_MERGE_SAME) != (s->flags & SLUB_MERGE_SAME))
>> -				continue;
>> +			continue;
>>  		/*
>>  		 * Check if alignment is compatible.
>>  		 * Courtesy of Adrian Drzewiecki
>> @@ -3722,21 +3724,18 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
>>  		if (s->size - size >= sizeof(void *))
>>  			continue;
>>  
>> -		if (!cache_match_memcg(s, memcg))
>> -			continue;
>> -
>>  		return s;
>>  	}
>>  	return NULL;
>>  }
>>  
>>  struct kmem_cache *
>> -__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
>> -		   size_t align, unsigned long flags, void (*ctor)(void *))
>> +__kmem_cache_alias(const char *name, size_t size, size_t align,
>> +		   unsigned long flags, void (*ctor)(void *))
>>  {
>>  	struct kmem_cache *s;
>>  
>> -	s = find_mergeable(memcg, size, align, flags, name, ctor);
>> +	s = find_mergeable(size, align, flags, name, ctor);
>>  	if (s) {
>>  		s->refcount++;
>>  		/*
>> -- 
>> 1.7.10.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
