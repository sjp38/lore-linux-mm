Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CD2296B0089
	for <linux-mm@kvack.org>; Tue, 28 May 2013 22:47:14 -0400 (EDT)
Message-ID: <51A56C60.9030306@parallels.com>
Date: Wed, 29 May 2013 08:18:00 +0530
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
References: <1368535118-27369-1-git-send-email-avagin@openvz.org> <20130528155326.0a8b66a7711746e827d5fdea@linux-foundation.org>
In-Reply-To: <20130528155326.0a8b66a7711746e827d5fdea@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 05/29/2013 04:23 AM, Andrew Morton wrote:
> On Tue, 14 May 2013 16:38:38 +0400 Andrey Vagin <avagin@openvz.org> wrote:
> 
>> struct memcg_cache_params has a union. Different parts of this union are
>> used for root and non-root caches. A part with destroying work is used only
>> for non-root caches.
> 
> That union is a bit dangerous.  Perhaps it would be better to do
> something like
> 
> --- a/include/linux/slab.h~a
> +++ a/include/linux/slab.h
> @@ -337,15 +337,17 @@ static __always_inline int kmalloc_size(
>  struct memcg_cache_params {
>  	bool is_root_cache;
>  	union {
> -		struct kmem_cache *memcg_caches[0];
> -		struct {
> +		struct memcg_root_cache {
> +			struct kmem_cache *caches[0];
> +		} memcg_root_cache;
> +		struct memcg_child_cache {
>  			struct mem_cgroup *memcg;
>  			struct list_head list;
>  			struct kmem_cache *root_cache;
>  			bool dead;
>  			atomic_t nr_pages;
>  			struct work_struct destroy;
> -		};
> +		} memcg_child_cache;
>  	};
>  };
> 
> And then adopt the convention of selecting either memcg_root_cache or
> memcg_child_cache at the highest level then passing the more strongly
> typed pointer to callees.
> 

Since it is already creating problems, yes, I agree.

I will try to cook up something soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
