Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 007756B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 19:16:32 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id n15so1100166dad.29
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:16:32 -0800 (PST)
Message-ID: <512FF35B.2030200@gmail.com>
Date: Fri, 01 Mar 2013 08:16:27 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 2/2] mm: tuning hardcoded reserved memory
References: <20130227210925.GB8429@localhost.localdomain>
In-Reply-To: <20130227210925.GB8429@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/28/2013 05:09 AM, Andrew Shewmaker wrote:
> Add a rootuser_reserve_pages knob to allow admins of large memory
> systems running with overcommit disabled to change the hardcoded
> memory reserve to something other than 3%.
>
> Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
>
> ---
>
> Patch based off of mmotm git tree as of February 27th.
>
> I set rootuser_reserve pages to be a default of 1000, and I suppose
> I should have initialzed similarly to the way min_free_kbytes is,
> scaling it with the size of the box. However, I wanted to get a
> simple version of this patch out for feedback to see if it has any
> chance of acceptance or if I need to take an entirely different
> approach.
>
> Any feedback will be appreciated!
>
>   Documentation/sysctl/vm.txt |  9 +++++++++
>   include/linux/mm.h          |  2 ++
>   kernel/sysctl.c             |  8 ++++++++
>   mm/mmap.c                   | 30 +++++++++++++++++++++++-------
>   4 files changed, 42 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 078701f..3a71de9 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -51,6 +51,7 @@ Currently, these files are in /proc/sys/vm:
>   - page-cluster
>   - panic_on_oom
>   - percpu_pagelist_fraction
> +- rootuser_reserve_pages
>   - stat_interval
>   - swappiness
>   - vfs_cache_pressure
> @@ -628,6 +629,14 @@ the high water marks for each per cpu page list.
>   
>   ==============================================================
>   
> +rootuser_reserve_pages
> +
> +The number of free pages left in the system that should be reserved for users
> +with the capability cap_sys_admin. The default falue is 3% of total system

s/falue/value

> +memory. Changing this takes effect whenever an application requests memory.
> +
> +==============================================================
> +
>   stat_interval
>   
>   The time interval between which vm statistics are updated.  The default
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 66e2f7c..af7b39f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1677,6 +1677,8 @@ int in_gate_area_no_mm(unsigned long addr);
>   
>   int drop_caches_sysctl_handler(struct ctl_table *, int,
>   					void __user *, size_t *, loff_t *);
> +int rootuser_reserve_pages_sysctl_handler(struct ctl_table *, int,
> +					void __user *, size_t *, loff_t *);
>   unsigned long shrink_slab(struct shrink_control *shrink,
>   			  unsigned long nr_pages_scanned,
>   			  unsigned long lru_pages);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c88878d..cd1987e 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -96,6 +96,7 @@
>   /* External variables not in a header file. */
>   extern int sysctl_overcommit_memory;
>   extern int sysctl_overcommit_ratio;
> +extern int sysctl_rootuser_reserve_pages;
>   extern int max_threads;
>   extern int suid_dumpable;
>   #ifdef CONFIG_COREDUMP
> @@ -1413,6 +1414,13 @@ static struct ctl_table vm_table[] = {
>   		.extra2		= &one,
>   	},
>   #endif
> +	{
> +		.procname	= "rootuser_reserve_pages",
> +		.data		= &sysctl_rootuser_reserve_pages,
> +		.maxlen		= sizeof(sysctl_rootuser_reserve_pages),
> +		.mode		= 0644,
> +		.proc_handler	= rootuser_reserve_pages_sysctl_handler,
> +	},
>   	{ }
>   };
>   
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d1e4124..b58af97 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -32,6 +32,7 @@
>   #include <linux/khugepaged.h>
>   #include <linux/uprobes.h>
>   #include <linux/rbtree_augmented.h>
> +#include <linux/sysctl.h>
>   
>   #include <asm/uaccess.h>
>   #include <asm/cacheflush.h>
> @@ -83,6 +84,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
>   int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
>   int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
>   int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
> +int sysctl_rootuser_reserve_pages __read_mostly = 1000;
>   /*
>    * Make sure vm_committed_as in one cacheline and not cacheline shared with
>    * other variables. It can be updated by several CPUs frequently.
> @@ -165,7 +167,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>   		 * Leave the last 3% for root
>   		 */
>   		if (!cap_sys_admin)
> -			free -= free / 32;
> +			free -= sysctl_rootuser_reserve_pages;
>   
>   		if (free > pages)
>   			return 0;
> @@ -179,9 +181,9 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>   	 * Leave the last 3% for root
>   	 */
>   	if (!cap_sys_admin)
> -		allowed -= allowed / 32;
> +		allowed -= sysctl_rootuser_reserve_pages;
>   	allowed += total_swap_pages;
>   
>   	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
>   		return 0;
>   error:
> @@ -3052,3 +3049,22 @@ void __init mmap_init(void)
>   	ret = percpu_counter_init(&vm_committed_as, 0);
>   	VM_BUG_ON(ret);
>   }
> +
> +/*
> + * rootuser_reserve_pages_sysctl_handler - just a wrapper around proc_dointvec_minmax() so
> + *	that we can cap the number of pages to the current number of free pages.
> + */
> +int rootuser_reserve_pages_sysctl_handler(ctl_table *table, int write,
> +	void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	unsigned long free;
> +
> +	proc_dointvec(table, write, buffer, length, ppos);
> +
> +	if (write) {
> +		free = global_page_state(NR_FREE_PAGES);
> +		if (sysctl_rootuser_reserve_pages > free)
> +			sysctl_rootuser_reserve_pages = free;
> +	}
> +	return 0;
> +}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
