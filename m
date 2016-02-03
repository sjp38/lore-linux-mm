Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6E858828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 06:31:09 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so12448381pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:31:09 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id p70si8809664pfj.241.2016.02.03.03.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 03:31:08 -0800 (PST)
Subject: Re: [PATCHv3] mm/slab: fix race with dereferencing NULL ptr in
 alloc_calls_show
References: <1454485933-762-1-git-send-email-dsafonov@virtuozzo.com>
 <20160203094420.GH21016@esperanza>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <56B1E4F3.5050806@virtuozzo.com>
Date: Wed, 3 Feb 2016 14:30:59 +0300
MIME-Version: 1.0
In-Reply-To: <20160203094420.GH21016@esperanza>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com

On 02/03/2016 12:44 PM, Vladimir Davydov wrote:
> On Wed, Feb 03, 2016 at 10:52:13AM +0300, Dmitry Safonov wrote:
> ...
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index b50aef0..2bfc0b1 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -451,6 +451,8 @@ EXPORT_SYMBOL(kmem_cache_create);
>>   static int shutdown_cache(struct kmem_cache *s,
>>   		struct list_head *release, bool *need_rcu_barrier)
>>   {
>> +	sysfs_slab_remove(s);
>> +
> shutdown_cache is called with slab_mutex held. slab_attr_store may take
> the mutex. So placing sysfs_slab_remove here introduces a potential
> deadlock.
>
>>   	if (__kmem_cache_shutdown(s) != 0)
>>   		return -EBUSY;
>>   
>> @@ -468,13 +470,8 @@ static void release_caches(struct list_head *release, bool need_rcu_barrier)
>>   	if (need_rcu_barrier)
>>   		rcu_barrier();
>>   
>> -	list_for_each_entry_safe(s, s2, release, list) {
>> -#ifdef SLAB_SUPPORTS_SYSFS
>> -		sysfs_slab_remove(s);
>> -#else
>> +	list_for_each_entry_safe(s, s2, release, list)
>>   		slab_kmem_cache_release(s);
>> -#endif
>> -	}
>>   }
>>   
>>   #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>> @@ -614,6 +611,7 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
>>   	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>>   		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
>>   			continue;
>> +
> Please remove this hunk.
>
>>   		/*
>>   		 * The cgroup is about to be freed and therefore has no charges
>>   		 * left. Hence, all its caches must be empty by now.
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 2e1355a..b6a68b7 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -5296,11 +5296,6 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
>>   #endif
>>   }
>>   
>> -static void kmem_cache_release(struct kobject *k)
>> -{
>> -	slab_kmem_cache_release(to_slab(k));
>> -}
>> -
>>   static const struct sysfs_ops slab_sysfs_ops = {
>>   	.show = slab_attr_show,
>>   	.store = slab_attr_store,
>> @@ -5308,7 +5303,6 @@ static const struct sysfs_ops slab_sysfs_ops = {
>>   
>>   static struct kobj_type slab_ktype = {
>>   	.sysfs_ops = &slab_sysfs_ops,
>> -	.release = kmem_cache_release,
> I surmise this will resurrect the bug that was fixed by 41a212859a4dd
> ("slub: use sysfs'es release mechanism for kmem_cache").
So, I move __kmem_cache_shutdown into slab_kmem_cache_release,
release list will still be collected under slab_mutex.
Seems like no other way to do this.
Will resend mended version.
>
> Thanks,
> Vladimir


-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
