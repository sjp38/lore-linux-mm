Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A72FB6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:50:28 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so918390pab.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:50:28 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id uk9si4170293pac.166.2016.02.02.13.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 13:50:27 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id ho8so944810pac.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:50:27 -0800 (PST)
Date: Tue, 2 Feb 2016 13:50:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCHv2] mm/slab: fix race with dereferencing NULL ptr in
 alloc_calls_show
In-Reply-To: <1454428630-22930-1-git-send-email-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.10.1602021348230.4977@chino.kir.corp.google.com>
References: <1454428630-22930-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Vladimir Davydov <vdavydov@virtuozzo.com>

On Tue, 2 Feb 2016, Dmitry Safonov wrote:

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index b7e57927..43634cd 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -101,16 +101,6 @@ struct kmem_cache {
>  	struct kmem_cache_node *node[MAX_NUMNODES];
>  };
>  
> -#ifdef CONFIG_SYSFS
> -#define SLAB_SUPPORTS_SYSFS
> -void sysfs_slab_remove(struct kmem_cache *);
> -#else
> -static inline void sysfs_slab_remove(struct kmem_cache *s)
> -{
> -}
> -#endif
> -
> -
>  /**
>   * virt_to_obj - returns address of the beginning of object.
>   * @s: object's kmem_cache
> diff --git a/mm/slab.h b/mm/slab.h
> index 834ad24..2983ab2 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -367,6 +367,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>  
>  #endif
>  
> +#if defined(CONFIG_SLUB) && defined(CONFIG_SYSFS)
> +void sysfs_slab_remove(struct kmem_cache *);
> +#else
> +static inline void sysfs_slab_remove(struct kmem_cache *s)
> +{
> +}
> +#endif
> +
>  void *slab_start(struct seq_file *m, loff_t *pos);
>  void *slab_next(struct seq_file *m, void *p, loff_t *pos);
>  void slab_stop(struct seq_file *m, void *p);
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index b50aef0..6725eb3 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -468,13 +468,8 @@ static void release_caches(struct list_head *release, bool need_rcu_barrier)
>  	if (need_rcu_barrier)
>  		rcu_barrier();
>  
> -	list_for_each_entry_safe(s, s2, release, list) {
> -#ifdef SLAB_SUPPORTS_SYSFS
> -		sysfs_slab_remove(s);
> -#else
> +	list_for_each_entry_safe(s, s2, release, list)
>  		slab_kmem_cache_release(s);
> -#endif
> -	}
>  }
>  
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> @@ -614,6 +609,9 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
>  	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>  		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
>  			continue;
> +
> +		sysfs_slab_remove(s);
> +

I would have expected to have seen this added to shutdown_cache() instead.

>  		/*
>  		 * The cgroup is about to be freed and therefore has no charges
>  		 * left. Hence, all its caches must be empty by now.
> diff --git a/mm/slub.c b/mm/slub.c
> index 2e1355a..b6a68b7 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5296,11 +5296,6 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
>  #endif
>  }
>  
> -static void kmem_cache_release(struct kobject *k)
> -{
> -	slab_kmem_cache_release(to_slab(k));
> -}
> -
>  static const struct sysfs_ops slab_sysfs_ops = {
>  	.show = slab_attr_show,
>  	.store = slab_attr_store,
> @@ -5308,7 +5303,6 @@ static const struct sysfs_ops slab_sysfs_ops = {
>  
>  static struct kobj_type slab_ktype = {
>  	.sysfs_ops = &slab_sysfs_ops,
> -	.release = kmem_cache_release,
>  };
>  
>  static int uevent_filter(struct kset *kset, struct kobject *kobj)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
