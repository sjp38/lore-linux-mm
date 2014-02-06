Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 336426B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 19:33:33 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id p9so2109052lbv.34
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 16:33:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id vr3si925891lbb.106.2014.02.06.09.12.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 09:13:27 -0800 (PST)
Message-ID: <52F3C293.3060400@parallels.com>
Date: Thu, 6 Feb 2014 21:12:51 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] memcg, slab: separate memcg vs root cache creation
 paths
References: <cover.1391441746.git.vdavydov@parallels.com> <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com> <20140204160336.GL4890@dhcp22.suse.cz> <52F13D3C.801@parallels.com> <20140206164135.GK20269@dhcp22.suse.cz>
In-Reply-To: <20140206164135.GK20269@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/06/2014 08:41 PM, Michal Hocko wrote:
> On Tue 04-02-14 23:19:24, Vladimir Davydov wrote:
>> On 02/04/2014 08:03 PM, Michal Hocko wrote:
>>> On Mon 03-02-14 19:54:38, Vladimir Davydov wrote:
>>>> Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
>>>> memcg-only and except-for-memcg calls. To clean this up, let's create a
>>>> separate function handling memcg caches creation. Although this will
>>>> result in the two functions having several hunks of practically the same
>>>> code, I guess this is the case when readability fully covers the cost of
>>>> code duplication.
>>> I don't know. The code is apparently cleaner because calling a function
>>> with NULL memcg just to go via several if (memcg) branches is ugly as
>>> hell. But having a duplicated function like this calls for a problem
>>> later.
>>>
>>> Would it be possible to split kmem_cache_create into memcg independant
>>> part and do the rest in a single memcg branch?
>> May be, something like the patch attached?
>>
>>>  
>>>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>>>> ---
>>>>  include/linux/memcontrol.h |   14 ++---
>>>>  include/linux/slab.h       |    9 ++-
>>>>  mm/memcontrol.c            |   16 ++----
>>>>  mm/slab_common.c           |  130 ++++++++++++++++++++++++++------------------
>>>>  4 files changed, 90 insertions(+), 79 deletions(-)
>>>>
>>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>>> index 84e4801fc36c..de79a9617e09 100644
>>>> --- a/include/linux/memcontrol.h
>>>> +++ b/include/linux/memcontrol.h
>>>> @@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
>>>>  
>>>>  char *memcg_create_cache_name(struct mem_cgroup *memcg,
>>>>  			      struct kmem_cache *root_cache);
>>>> -int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
>>>> -			     struct kmem_cache *root_cache);
>>>> +int memcg_alloc_cache_params(struct kmem_cache *s,
>>>> +		struct mem_cgroup *memcg, struct kmem_cache *root_cache);
>>> Why is the parameters ordering changed? It really doesn't help
>>> review the patch.
>> Oh, this is because seeing something like
>>
>> memcg_alloc_cache_params(NULL, s, NULL);
>>
>> hurts my brain :-) I prefer to have NULLs in the end.
> the function still allocates parameters for the given memcg and cache
> and needs a reference to root cache so the ordering kind of makes sense
> to me.

All right, I'll leave it as is then - anyway, in this patch this hunk is
absent.

>  
>>> Also what does `s' stand for and can we use a more
>>> descriptive name, please?
>> Yes, we can call it `cachep', but it would be too long :-/
>>
>> `s' is the common name for a kmem_cache throughout mm/sl[au]b.c so I
>> guess it fits here. However, this function certainly needs a comment - I
>> guess I'll do it along with swapping the function parameters in a
>> separate patch.
> Yes, it seems that self explaining `s' is spread all over the place.
>
>> From 55f0916c794ad25a8bf45566f6d333bea956e0d4 Mon Sep 17 00:00:00 2001
>> From: Vladimir Davydov <vdavydov@parallels.com>
>> Date: Mon, 3 Feb 2014 19:18:22 +0400
>> Subject: [PATCH] memcg, slab: separate memcg vs root cache creation paths
>>
>> Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
>> memcg-only and except-for-memcg calls. To clean this up, let's create a
>> separate function handling memcg caches creation. Although this will
>> result in the two functions having several hunks of practically the same
>> code, I guess this is the case when readability fully covers the cost of
>> code duplication.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> This looks better. The naming could still be little bit better because
> do_kmem_cache_create suggests that no memcg is involved but it at least
> reduced all the code duplication and nasty if(memcg) parts.
>
> Few minor comments bellow
>
>> ---
>>  include/linux/slab.h |    9 ++-
>>  mm/memcontrol.c      |   12 +---
>>  mm/slab_common.c     |  174 +++++++++++++++++++++++++++-----------------------
>>  3 files changed, 101 insertions(+), 94 deletions(-)
>>
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index 9260abdd67df..e8c95d0bb879 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -113,11 +113,10 @@ void __init kmem_cache_init(void);
>>  int slab_is_available(void);
>>  
>>  struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
>> -			unsigned long,
>> -			void (*)(void *));
>> -struct kmem_cache *
>> -kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
>> -			unsigned long, void (*)(void *), struct kmem_cache *);
>> +				     unsigned long, void (*)(void *));
> It is quite confusing when you mix formatting changes with other ones.

Oh, just could not pass this by. I guess I'll do it in a separate patch
then.

>
> [...]
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 11857abf7057..6bee919ece80 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
> [...]
>> +int kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *cachep)
>>  {
>> -	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
>> +	struct kmem_cache *s;
>> +	int err;
>> +
>> +	get_online_cpus();
>> +	mutex_lock(&slab_mutex);
>> +
>> +	/*
>> +	 * Since per-memcg caches are created asynchronously on first
>> +	 * allocation (see memcg_kmem_get_cache()), several threads can try to
>> +	 * create the same cache, but only one of them may succeed.
>> +	 */
>> +	err = -EEXIST;
> Does it make any sense to report the error here? If we are racing then at
> least on part wins and the work is done.

Yeah, you're perfectly right. It's better to return 0 here.

> We should probably warn about errors which prevent from accounting but
> I do not think there is much more we can do so returning an error code
> from this function seems pointless. memcg_create_cache_work_func ignores
> the return value anyway.

I do not think warnings are appropriate here, because it is not actually
an error if we are short on memory and can't do proper memcg accounting
due to this. Perhaps, we'd better add fail counters for memcg cache
creations and/or accounting to the root cache instead of memcg's one.
That would be useful for debugging. I'm not sure though.

Thanks.

>
>> +	if (cache_from_memcg_idx(cachep, memcg_cache_id(memcg)))
>> +		goto out_unlock;
>> +
>> +	s = do_kmem_cache_create(memcg_create_cache_name(memcg, cachep),
>> +			cachep->object_size, cachep->size, cachep->align,
>> +			cachep->flags & ~SLAB_PANIC, cachep->ctor,
>> +			memcg, cachep);
>> +	err = IS_ERR(s) ? PTR_ERR(s) : 0;
>> +	if (!err)
>> +		s->allocflags |= __GFP_KMEMCG;
>> +
>> +out_unlock:
>> +	mutex_unlock(&slab_mutex);
>> +	put_online_cpus();
>> +	return err;
>>  }
>> -EXPORT_SYMBOL(kmem_cache_create);
>> +#endif /* CONFIG_MEMCG_KMEM */
>>  
>>  void kmem_cache_destroy(struct kmem_cache *s)
>>  {
>> -- 
>> 1.7.10.4
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
