Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CF6336B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:16:25 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1B99E3EE0AE
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:16:24 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 00C6D45DEBB
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:16:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB92145DEB6
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:16:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CAEF51DB803C
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:16:23 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78CC21DB8038
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:16:23 +0900 (JST)
Message-ID: <51643EB8.1020109@jp.fujitsu.com>
Date: Wed, 10 Apr 2013 01:15:52 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: defer page_cgroup initialization
References: <1365499511-10923-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1365499511-10923-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/09 18:25), Glauber Costa wrote:
> We have now reached the point in which there is no real need to allocate
> page_cgroup upon system boot. We can defer it to the first memcg
> initialization, and if it fails, we treat it like any other memcg memory
> failures (like for instance, if the mem_cgroup structure itself failed).
> In the future, we may want to defer this to the first non-root cgroup
> initialization, but we are not there yet. With that, page_cgroup can be
> more silent in its initialization.
> 
> Unfortunately, doing that for flatmem models would lead to significant
> vmalloc-area waste. Since big-memory 32-bit machines are quite common,
> this would be reality for most of them. This means that we will leave
> FLATMEM alone, and fix only the SPARSEMEM case. We modify the message
> slightly so that in future reports we know precisely if this message is
> from a flatmem kernel or a older kernel initializing page_cgroup early.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   include/linux/page_cgroup.h | 13 +++++++------
>   init/main.c                 |  1 -
>   mm/memcontrol.c             |  2 ++
>   mm/page_cgroup.c            | 19 ++++++++-----------
>   4 files changed, 17 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 777a524..bfb43f0 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -33,11 +33,16 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
>   static inline void __init page_cgroup_init_flatmem(void)
>   {
>   }
> -extern void __init page_cgroup_init(void);
> +extern bool page_cgroup_init(void);
>   #else
>   void __init page_cgroup_init_flatmem(void);
> -static inline void __init page_cgroup_init(void)
> +/*
> + * If we reach here, we would have already initialized flatmem mappings.
> + * So just always succeed
> + */
> +static inline bool page_cgroup_init(void)
>   {
> +	return 0;
>   }
>   #endif
>   
> @@ -94,10 +99,6 @@ static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
>   	return NULL;
>   }
>   
> -static inline void page_cgroup_init(void)
> -{
> -}
> -
>   static inline void __init page_cgroup_init_flatmem(void)
>   {
>   }
> diff --git a/init/main.c b/init/main.c
> index cee4b5c..49aa019 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -592,7 +592,6 @@ asmlinkage void __init start_kernel(void)
>   		initrd_start = 0;
>   	}
>   #endif
> -	page_cgroup_init();
>   	debug_objects_mem_init();
>   	kmemleak_init();
>   	setup_per_cpu_pageset();

This is good.


> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f608546..59a5b1f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6357,6 +6357,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>   		res_counter_init(&memcg->res, NULL);
>   		res_counter_init(&memcg->memsw, NULL);
>   		res_counter_init(&memcg->kmem, NULL);
> +		if (page_cgroup_init())
> +			goto free_out;
>   	}
>   
>   	memcg->last_scanned_node = MAX_NUMNODES;
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6d757e3..679de38 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -78,7 +78,8 @@ void __init page_cgroup_init_flatmem(void)
>   	}
>   	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
>   	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
> -	" don't want memory cgroups\n");
> +	" don't want memory cgroups. Alternatively, use SPARSEMEM mappings"
> +	" to defer initialization until actual use.");

I'm sorry that I think you don't defer initialization until actual use...yet.
page_cgroup() will allocated at initialization even if memory cgroup is not
mounted at all. Right ?

>   	return;
>   fail:
>   	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
> @@ -266,13 +267,13 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
>   
>   #endif
>   
> -void __init page_cgroup_init(void)
> +bool page_cgroup_init(void)
>   {
>   	unsigned long pfn;
>   	int nid;
>   
>   	if (mem_cgroup_disabled())
> -		return;
> +		return 0;
>   
>   	for_each_node_state(nid, N_MEMORY) {
>   		unsigned long start_pfn, end_pfn;
> @@ -299,17 +300,13 @@ void __init page_cgroup_init(void)
>   			if (pfn_to_nid(pfn) != nid)
>   				continue;
>   			if (init_section_page_cgroup(pfn, nid))
> -				goto oom;
> +				return 1;
>   		}
>   	}
> +#ifdef CONFIG_MEMORY_HOTPLUG
>   	hotplug_memory_notifier(page_cgroup_callback, 0);
> -	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
> -			 "don't want memory cgroups\n");
> -	return;
> -oom:
> -	printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> -	panic("Out of memory");
> +#endif
> +	return 0;

IIUC, hotplug_memory_notifier() is NOP if CONFIG_MEMORY_HOTPLUG is set.
So, you don't need to add #ifdef

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
