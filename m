Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC7E6B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 06:29:42 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id u14so3326528lbd.15
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 03:29:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id t10si4749434lat.87.2014.01.31.03.29.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jan 2014 03:29:40 -0800 (PST)
Message-ID: <52EB8920.5040705@parallels.com>
Date: Fri, 31 Jan 2014 15:29:36 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com> <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org> <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com> <20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org> <alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com> <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org> <alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com> <20140130140902.93d35d866f9ea1c697811f6e@linux-foundation.org> <alpine.DEB.2.02.1401301411590.15271@chino.kir.corp.google.com> <20140130141538.a9e3977b5e7b76bdcf59a15f@linux-foundation.org> <alpine.DEB.2.02.1401301438500.12223@chino.kir.corp.google.com> <52EB487B.6040701@parallels.com> <alpine.DEB.2.02.1401310241080.7183@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401310241080.7183@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/31/2014 02:42 PM, David Rientjes wrote:
> On Fri, 31 Jan 2014, Vladimir Davydov wrote:
>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -637,6 +637,9 @@ int memcg_limited_groups_array_size;
>>>   * better kept as an internal representation in cgroup.c. In any case, the
>>>   * cgrp_id space is not getting any smaller, and we don't have to necessarily
>>>   * increase ours as well if it increases.
>>> + *
>>> + * Updates to MAX_SIZE should update the space for the memcg name in
>>> + * memcg_create_kmem_cache().
>>>   */
>>>  #define MEMCG_CACHES_MIN_SIZE 4
>>>  #define MEMCG_CACHES_MAX_SIZE MEM_CGROUP_ID_MAX
>>> @@ -3400,8 +3403,10 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>>>  static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>>>  						  struct kmem_cache *s)
>>>  {
>>> -	char *name = NULL;
>>>  	struct kmem_cache *new;
>>> +	const char *cgrp_name;
>>> +	char *name = NULL;
>>> +	size_t len;
>>>  
>>>  	BUG_ON(!memcg_can_account_kmem(memcg));
>>>  
>>> @@ -3409,9 +3414,22 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>>>  	if (unlikely(!name))
>>>  		return NULL;
>>>  
>>> +	/*
>>> +	 * Format of a memcg's kmem cache name:
>>> +	 * <cache-name>(<memcg-id>:<cgroup-name>)
>>> +	 */
>>> +	len = strlen(s->name);
>>> +	/* Space for parentheses, colon, terminator */
>>> +	len += 4;
>>> +	/* MEMCG_CACHES_MAX_SIZE is USHRT_MAX */
>>> +	len += 5;
>>> +	BUILD_BUG_ON(MEMCG_CACHES_MAX_SIZE > USHRT_MAX);
>>> +
>> This looks cumbersome, IMO. Let's leave it as is for now. AFAIK,
>> cgroup_name() will be reworked soon so that it won't require RCU-context
>> (https://lkml.org/lkml/2014/1/28/530). Therefore, it will be possible to
>> get rid of this pointless tmp_name allocation by making
>> kmem_cache_create_memcg() take not just name, but printf-like format +
>> vargs.
>>
> You believe it's less cumbersome to do two memory allocations to figure 
> out how much memory you really need to allocate rather than just 
> calculating the necessary size?

Well, I mean not the approach - here everything is right - but how it
looks. This

len += 4
len += 5

looks scary even with comments, IMHO. Note, I do not stand for this
temporary buffer - it was introduced long before I started tweaking this
code. I just want to say that substituting it now with something (OK,
less, but IMHO still) cumbersome is not a good idea provided soon it
will be possible to remove tmp_name while still having the code looking
nice. If you insist, I don't mind, but... why?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
