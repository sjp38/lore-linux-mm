Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 136C26B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:07:32 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so1488054lab.18
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:07:32 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id am6si19302558lbc.24.2014.04.18.09.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 09:07:31 -0700 (PDT)
Message-ID: <53514DBF.3040508@parallels.com>
Date: Fri, 18 Apr 2014 20:07:27 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC -mm v2 2/3] memcg, slab: merge memcg_{bind,release}_pages
 to memcg_{un}charge_slab
References: <cover.1397804745.git.vdavydov@parallels.com> <49f7f2d048e56fac4d29dd5b39f6f76c7bdd6bec.1397804745.git.vdavydov@parallels.com> <20140418134453.GC26283@cmpxchg.org>
In-Reply-To: <20140418134453.GC26283@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/18/2014 05:44 PM, Johannes Weiner wrote:
> On Fri, Apr 18, 2014 at 12:04:48PM +0400, Vladimir Davydov wrote:
>> Currently we have two pairs of kmemcg-related functions that are called
>> on slab alloc/free. The first is memcg_{bind,release}_pages that count
>> the total number of pages allocated on a kmem cache. The second is
>> memcg_{un}charge_slab that {un}charge slab pages to kmemcg resource
>> counter. Let's just merge them to keep the code clean.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> ---
>>   include/linux/memcontrol.h |    4 ++--
>>   mm/memcontrol.c            |   22 ++++++++++++++++++++--
>>   mm/slab.c                  |    2 --
>>   mm/slab.h                  |   25 ++-----------------------
>>   mm/slub.c                  |    2 --
>>   5 files changed, 24 insertions(+), 31 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 087a45314181..d38d190f4cec 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -506,8 +506,8 @@ void memcg_update_array_size(int num_groups);
>>   struct kmem_cache *
>>   __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
>>
>> -int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
>> -void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
>> +int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
>> +void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
>
> I like the patch overall, but why the __prefix and not just
> memcg_charge_slab() and memcg_uncharge_slab()?

Because I have memcg_{un}charge_slab (without underscores) in mm/slab.h.
Those functions are inline so that we only issue a function call if the
memcg_kmem_enabled static key is on and the cache is not a global one.

Actually I'm not sure if we really need such an optimization in slab
allocation/free paths, which are not very hot, but it wouldn't hurt,
would it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
