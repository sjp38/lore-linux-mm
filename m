Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 23C186B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:36:40 -0400 (EDT)
Date: Tue, 9 Apr 2013 09:36:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: defer page_cgroup initialization
Message-ID: <20130409133630.GR1953@cmpxchg.org>
References: <1365499511-10923-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365499511-10923-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Apr 09, 2013 at 01:25:11PM +0400, Glauber Costa wrote:
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
>  include/linux/page_cgroup.h | 13 +++++++------
>  init/main.c                 |  1 -
>  mm/memcontrol.c             |  2 ++
>  mm/page_cgroup.c            | 19 ++++++++-----------
>  4 files changed, 17 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 777a524..bfb43f0 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -33,11 +33,16 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
>  static inline void __init page_cgroup_init_flatmem(void)
>  {
>  }
> -extern void __init page_cgroup_init(void);
> +extern bool page_cgroup_init(void);
>  #else
>  void __init page_cgroup_init_flatmem(void);
> -static inline void __init page_cgroup_init(void)
> +/*
> + * If we reach here, we would have already initialized flatmem mappings.
> + * So just always succeed
> + */
> +static inline bool page_cgroup_init(void)
>  {
> +	return 0;

Could you please make it either int (*)(void) OR return true for
success? :-)

> @@ -78,7 +78,8 @@ void __init page_cgroup_init_flatmem(void)
>  	}
>  	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
>  	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
> -	" don't want memory cgroups\n");
> +	" don't want memory cgroups. Alternatively, use SPARSEMEM mappings"
> +	" to defer initialization until actual use.");

Isn't that promising a bit much as long as "actual use" means "until
we create the root_mem_cgroup during boot time"?

> @@ -299,17 +300,13 @@ void __init page_cgroup_init(void)
>  			if (pfn_to_nid(pfn) != nid)
>  				continue;
>  			if (init_section_page_cgroup(pfn, nid))
> -				goto oom;
> +				return 1;
>  		}
>  	}
> +#ifdef CONFIG_MEMORY_HOTPLUG
>  	hotplug_memory_notifier(page_cgroup_callback, 0);
> -	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
> -			 "don't want memory cgroups\n");
> -	return;
> -oom:
> -	printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> -	panic("Out of memory");
> +#endif
> +	return 0;

Ok, so this message will be replaced with BUG() in cgroup.c, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
