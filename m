Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4694A6B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 19:45:48 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id hr13so2141433lab.1
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 16:45:47 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l9si770356lbd.134.2014.02.06.07.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 07:39:39 -0800 (PST)
Message-ID: <52F3AC9A.7050600@parallels.com>
Date: Thu, 6 Feb 2014 19:39:06 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
References: <cover.1391356789.git.vdavydov@parallels.com> <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com> <20140204145210.GH4890@dhcp22.suse.cz> <52F1004B.90307@parallels.com> <20140204151145.GI4890@dhcp22.suse.cz> <52F106D7.3060802@parallels.com> <20140206140707.GF20269@dhcp22.suse.cz> <52F39916.2040603@parallels.com> <20140206152944.GG20269@dhcp22.suse.cz>
In-Reply-To: <20140206152944.GG20269@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/06/2014 07:29 PM, Michal Hocko wrote:
> On Thu 06-02-14 18:15:50, Vladimir Davydov wrote:
>> On 02/06/2014 06:07 PM, Michal Hocko wrote:
>>> On Tue 04-02-14 19:27:19, Vladimir Davydov wrote:
>>> [...]
>>>> What does this patch change? Actually, it introduces no functional
>>>> changes - it only remove the code trying to find an alias for a memcg
>>>> cache, because it will fail anyway. So this is rather a cleanup.
>>> But this also means that two different memcgs might share the same cache
>>> and so the pages for that cache, no?
>> No, because in this patch I explicitly forbid to merge memcg caches by
>> this hunk:
>>
>> @@ -200,9 +200,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg,
>> const char *name, size_t size,
>>       */
>>      flags &= CACHE_CREATE_MASK;
>>  
>> -    s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
>> -    if (s)
>> -        goto out_unlock;
>> +    if (!memcg) {
>> +        s = __kmem_cache_alias(name, size, align, flags, ctor);
>> +        if (s)
>> +            goto out_unlock;
>> +    }
> Ohh, that was the missing part. Thanks and sorry I have missed it.

Never mind.

> Maybe it is worth mentioning in the changelog?

Hmm, changelog? This hunk was there from the very beginning :-/

Anyway, I'm going to expand this patch's comment, because it's too short
and difficult to understand.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
