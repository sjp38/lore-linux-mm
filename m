Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6B7AD6B00F5
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 06:54:32 -0400 (EDT)
Message-ID: <4F5C8414.5090800@parallels.com>
Date: Sun, 11 Mar 2012 14:53:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/13] slab: Add kmem_cache_gfp_flags() helper function.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-7-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-7-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
> This function returns the gfp flags that are always applied to
> allocations of a kmem_cache.
>
> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
> ---
>   include/linux/slab_def.h |    6 ++++++
>   include/linux/slob_def.h |    6 ++++++
>   include/linux/slub_def.h |    6 ++++++
>   3 files changed, 18 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index fbd1117..25f9a6a 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -159,6 +159,12 @@ found:
>   	return __kmalloc(size, flags);
>   }
>
> +static inline gfp_t
> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
> +{
> +	return cachep->gfpflags;
> +}
> +
>   #ifdef CONFIG_NUMA
>   extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
>   extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
> index 0ec00b3..3fa527d 100644
> --- a/include/linux/slob_def.h
> +++ b/include/linux/slob_def.h
> @@ -34,4 +34,10 @@ static __always_inline void *__kmalloc(size_t size, gfp_t flags)
>   	return kmalloc(size, flags);
>   }
>
> +static inline gfp_t
> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
> +{
> +	return 0;
> +}
> +
>   #endif /* __LINUX_SLOB_DEF_H */
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index a32bcfd..5911d81 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -313,4 +313,10 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>   }
>   #endif
>
> +static inline gfp_t
> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
> +{
> +	return cachep->allocflags;
> +}
> +

Why is this needed? Can't the caller just call 
mem_cgroup_get_kmem_cache(cachep, flags | cachep->allocflags) ?

>   #endif /* _LINUX_SLUB_DEF_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
