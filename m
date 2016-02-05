Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 64C804403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 09:48:05 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so35258123pac.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 06:48:05 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b70si24407810pfj.56.2016.02.05.06.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 06:48:04 -0800 (PST)
Subject: Re: [PATCHv4] mm: slab: shutdown caches only after releasing sysfs
 file
References: <1454603988-24856-1-git-send-email-dsafonov@virtuozzo.com>
 <20160205132232.GD29522@esperanza>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <56B4B61B.9020305@virtuozzo.com>
Date: Fri, 5 Feb 2016 17:47:55 +0300
MIME-Version: 1.0
In-Reply-To: <20160205132232.GD29522@esperanza>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com

On 02/05/2016 04:22 PM, Vladimir Davydov wrote:
> On Thu, Feb 04, 2016 at 07:39:48PM +0300, Dmitry Safonov wrote:
> ...
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index b7e57927..a6bf41a 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -103,9 +103,10 @@ struct kmem_cache {
>>   
>>   #ifdef CONFIG_SYSFS
>>   #define SLAB_SUPPORTS_SYSFS
>> -void sysfs_slab_remove(struct kmem_cache *);
>> +int sysfs_slab_remove(struct kmem_cache *);
>> +void sysfs_slab_remove_cancel(struct kmem_cache *s);
>>   #else
>> -static inline void sysfs_slab_remove(struct kmem_cache *s)
>> +void sysfs_slab_remove_cancel(struct kmem_cache *s)
>>   {
>>   }
>>   #endif
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 834ad24..ec87600 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -141,7 +141,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>>   
>>   int __kmem_cache_shutdown(struct kmem_cache *);
>>   int __kmem_cache_shrink(struct kmem_cache *, bool);
>> -void slab_kmem_cache_release(struct kmem_cache *);
>> +int slab_kmem_cache_release(struct kmem_cache *);
>>   
>>   struct seq_file;
>>   struct file;
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index b50aef0..3ad3d22 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -448,33 +448,58 @@ out_unlock:
>>   }
>>   EXPORT_SYMBOL(kmem_cache_create);
>>   
>> -static int shutdown_cache(struct kmem_cache *s,
>> +static void prepare_caches_release(struct kmem_cache *s,
>>   		struct list_head *release, bool *need_rcu_barrier)
>>   {
>> -	if (__kmem_cache_shutdown(s) != 0)
>> -		return -EBUSY;
>> -
>>   	if (s->flags & SLAB_DESTROY_BY_RCU)
>>   		*need_rcu_barrier = true;
>>   
>>   	list_move(&s->list, release);
>> -	return 0;
>>   }
>>   
>> -static void release_caches(struct list_head *release, bool need_rcu_barrier)
>> +#ifdef SLAB_SUPPORTS_SYSFS
>> +#define release_one_cache sysfs_slab_remove
>> +#else
>> +#define release_one_cache slab_kmem_cache_release
>> +#endif
>> +
>> +static int release_caches_type(struct list_head *release, bool children)
>>   {
>>   	struct kmem_cache *s, *s2;
>> +	int ret = 0;
>>   
>> +	list_for_each_entry_safe(s, s2, release, list) {
>> +		if (is_root_cache(s) == children)
>> +			continue;
>> +
>> +		ret += release_one_cache(s);
>> +	}
>> +	return ret;
>> +}
>> +
>> +static void release_caches(struct list_head *release, bool need_rcu_barrier)
>> +{
>>   	if (need_rcu_barrier)
>>   		rcu_barrier();
> You must issue an rcu barrier before freeing kmem_cache structure, not
> before issuing __kmem_cache_shutdown. Otherwise a slab freed by
> __kmem_cache_shutdown might hit use-after-free bug.
Yeah, I wrongly interpreted fast reuse of deleted object.
>
>>   
>> -	list_for_each_entry_safe(s, s2, release, list) {
>> -#ifdef SLAB_SUPPORTS_SYSFS
>> -		sysfs_slab_remove(s);
>> -#else
>> -		slab_kmem_cache_release(s);
>> -#endif
>> -	}
>> +	/* remove children in the first place, remove root on success */
>> +	if (!release_caches_type(release, true))
>> +		release_caches_type(release, false);
>> +}
>> +
>> +static void release_cache_cancel(struct kmem_cache *s)
>> +{
>> +	sysfs_slab_remove_cancel(s);
>> +
>> +	get_online_cpus();
>> +	get_online_mems();
> What's point taking these locks when you just want to add a cache to the
> slab_list?
>
> Besides, if cpu/mem hotplug happens *between* prepare_cache_release and
> release_cache_cancel we'll get a cache on the list with not all per
> node/cpu structures allocated.
Oh, I see, you right.
>
>> +	mutex_lock(&slab_mutex);
>> +
>> +	list_move(&s->list, &slab_caches);
>> +
>> +	mutex_unlock(&slab_mutex);
>> +	put_online_mems();
>> +	put_online_cpus();
>>   }
>>   
>>   #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>> @@ -589,16 +614,14 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>>   	put_online_cpus();
>>   }
>>   
>> -static int __shutdown_memcg_cache(struct kmem_cache *s,
>> +static void prepare_memcg_empty_caches(struct kmem_cache *s,
>>   		struct list_head *release, bool *need_rcu_barrier)
>>   {
>>   	BUG_ON(is_root_cache(s));
>>   
>> -	if (shutdown_cache(s, release, need_rcu_barrier))
>> -		return -EBUSY;
>> +	prepare_caches_release(s, release, need_rcu_barrier);
>>   
>> -	list_del(&s->memcg_params.list);
>> -	return 0;
>> +	list_del_init(&s->memcg_params.list);
> AFAICS if kmem_cache_destroy fails, you don't add per-memcg cache back
> to the list. Not good.
>
>>   }
>>   
>>   void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
>> @@ -614,11 +637,12 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
>>   	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>>   		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
>>   			continue;
>> +
>>   		/*
>>   		 * The cgroup is about to be freed and therefore has no charges
>>   		 * left. Hence, all its caches must be empty by now.
>>   		 */
>> -		BUG_ON(__shutdown_memcg_cache(s, &release, &need_rcu_barrier));
> It was a nice little check if everything works fine on memcg side. And
> you wiped it out. Sad.
It's still there but in form of WARN()
>
>> +		prepare_memcg_empty_caches(s, &release, &need_rcu_barrier);
>>   	}
>>   	mutex_unlock(&slab_mutex);
>>   
>> @@ -628,81 +652,53 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
>>   	release_caches(&release, need_rcu_barrier);
>>   }
>>   
>> -static int shutdown_memcg_caches(struct kmem_cache *s,
>> +static void prepare_memcg_filled_caches(struct kmem_cache *s,
>>   		struct list_head *release, bool *need_rcu_barrier)
>>   {
>>   	struct memcg_cache_array *arr;
>>   	struct kmem_cache *c, *c2;
>> -	LIST_HEAD(busy);
>> -	int i;
>>   
>>   	BUG_ON(!is_root_cache(s));
>>   
>> -	/*
>> -	 * First, shutdown active caches, i.e. caches that belong to online
>> -	 * memory cgroups.
>> -	 */
>>   	arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
>>   					lockdep_is_held(&slab_mutex));
> And now what's that for?
>
>> -	for_each_memcg_cache_index(i) {
>> -		c = arr->entries[i];
>> -		if (!c)
>> -			continue;
>> -		if (__shutdown_memcg_cache(c, release, need_rcu_barrier))
>> -			/*
>> -			 * The cache still has objects. Move it to a temporary
>> -			 * list so as not to try to destroy it for a second
>> -			 * time while iterating over inactive caches below.
>> -			 */
>> -			list_move(&c->memcg_params.list, &busy);
>> -		else
>> -			/*
>> -			 * The cache is empty and will be destroyed soon. Clear
>> -			 * the pointer to it in the memcg_caches array so that
>> -			 * it will never be accessed even if the root cache
>> -			 * stays alive.
>> -			 */
>> -			arr->entries[i] = NULL;
> So you don't clean arr->entries on global cache destruction. If we fail
> to destroy a cache, this will result in use-after-free when the global
> cache gets reused.
Yes, should have clean
>
>> -	}
>>   
>> -	/*
>> -	 * Second, shutdown all caches left from memory cgroups that are now
>> -	 * offline.
>> -	 */
>> +	/* move children caches to release list */
>>   	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
>>   				 memcg_params.list)
>> -		__shutdown_memcg_cache(c, release, need_rcu_barrier);
>> -
>> -	list_splice(&busy, &s->memcg_params.list);
>> +		prepare_caches_release(c, release, need_rcu_barrier);
>>   
>> -	/*
>> -	 * A cache being destroyed must be empty. In particular, this means
>> -	 * that all per memcg caches attached to it must be empty too.
>> -	 */
>> -	if (!list_empty(&s->memcg_params.list))
>> -		return -EBUSY;
>> -	return 0;
>> +	/* root cache to the same place */
>> +	prepare_caches_release(s, release, need_rcu_barrier);
>>   }
>> +
>>   #else
>> -static inline int shutdown_memcg_caches(struct kmem_cache *s,
>> -		struct list_head *release, bool *need_rcu_barrier)
>> -{
>> -	return 0;
>> -}
>> +#define prepare_memcg_filled_caches prepare_caches_release
>>   #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>>   
>> -void slab_kmem_cache_release(struct kmem_cache *s)
>> +int slab_kmem_cache_release(struct kmem_cache *s)
>>   {
>> +	if (__kmem_cache_shutdown(s)) {
>> +		WARN(1, "release slub cache %s failed: it still has objects\n",
>> +			s->name);
>> +		release_cache_cancel(s);
>> +		return 1;
>> +	}
>> +
>> +#ifdef CONFIG_MEMCG
>> +	list_del(&s->memcg_params.list);
>> +#endif
>> +
>>   	destroy_memcg_params(s);
>>   	kfree_const(s->name);
>>   	kmem_cache_free(kmem_cache, s);
>> +	return 0;
>>   }
>>   
>>   void kmem_cache_destroy(struct kmem_cache *s)
>>   {
>>   	LIST_HEAD(release);
>>   	bool need_rcu_barrier = false;
>> -	int err;
>>   
>>   	if (unlikely(!s))
>>   		return;
>> @@ -716,15 +712,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
>>   	if (s->refcount)
>>   		goto out_unlock;
>>   
>> -	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
>> -	if (!err)
>> -		err = shutdown_cache(s, &release, &need_rcu_barrier);
>> +	prepare_memcg_filled_caches(s, &release, &need_rcu_barrier);
>>   
>> -	if (err) {
>> -		pr_err("kmem_cache_destroy %s: "
>> -		       "Slab cache still has objects\n", s->name);
>> -		dump_stack();
>> -	}
>>   out_unlock:
>>   	mutex_unlock(&slab_mutex);
>>   
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 2e1355a..373aa6d 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -5429,14 +5429,14 @@ out_del_kobj:
>>   	goto out;
>>   }
>>   
>> -void sysfs_slab_remove(struct kmem_cache *s)
>> +int sysfs_slab_remove(struct kmem_cache *s)
>>   {
>>   	if (slab_state < FULL)
>>   		/*
>>   		 * Sysfs has not been setup yet so no need to remove the
>>   		 * cache from sysfs.
>>   		 */
>> -		return;
>> +		return 0;
>>   
>>   #ifdef CONFIG_MEMCG
>>   	kset_unregister(s->memcg_kset);
>> @@ -5444,6 +5444,24 @@ void sysfs_slab_remove(struct kmem_cache *s)
>>   	kobject_uevent(&s->kobj, KOBJ_REMOVE);
>>   	kobject_del(&s->kobj);
>>   	kobject_put(&s->kobj);
>> +	return 0;
>> +}
>> +
>> +void sysfs_slab_remove_cancel(struct kmem_cache *s)
>> +{
>> +	int ret;
>> +
>> +	if (slab_state < FULL)
>> +		return;
>> +
>> +	/* tricky */
> What purpose is this comment supposed to serve for?
>
>> +	kobject_get(&s->kobj);
>> +	ret = kobject_add(&s->kobj, NULL, "%s", s->name);
> ret is not used.
>
>> +	kobject_uevent(&s->kobj, KOBJ_ADD);
>> +
>> +#ifdef CONFIG_MEMCG
>> +	s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
>> +#endif
> For per-memcg cache we must not create memcg_kset.
>
> And what if any of these functions fail? I don't think that silently
> ignoring failures is good.
I thought, it's fine after WARN try to revert everything as far as you can.
Without checking was reverting successful.
>
> Anyway, I really don't like how this patch approaches the problem. AFAIU
> we only want to postpone kmem_cache_node free until sysfs file is
> destroyed. Can't we just move the code freeing kmem_cache_node to a
> separate function which will be called from sysfs release instead of
> messing things up?
Yeah, I'll redo that way.
Thanks for a review.
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
