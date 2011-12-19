Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E40806B004F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:30:18 -0500 (EST)
Received: by yhgm50 with SMTP id m50so2931848yhg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:30:18 -0800 (PST)
Message-ID: <4EEF74AC.1060503@gmail.com>
Date: Mon, 19 Dec 2011 12:30:20 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
In-Reply-To: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?B?QXJ2ZSBIag==?= =?UTF-8?B?w7hubmV2w6Vn?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Personally I'd start thinking about the new [lightweight] notification
> stuff, i.e. something without mem_cg's downsides. Though, I'm Cc'ing
> Android folks so maybe they could enlighten us why in-kernel "lowmemory
> manager" might be a better idea. Plus Cc'ing folks that I think might
> be interested in this discussion.
>
> Thanks!
>
> p.s.
>
> I'm inlining the android memory killer code down below, just for the
> reference. It is quite small (and useful... though, currently only for
> Android case).
>
> - - - -
> From: Arve HjA,nnevAJPYg<arve@android.com>
> Subject: Android low memory killer driver
>
> The lowmemorykiller driver lets user-space specify a set of memory thresholds
> where processes with a range of oom_adj values will get killed. Specify the
> minimum oom_adj values in /sys/module/lowmemorykiller/parameters/adj and the
> number of free pages in /sys/module/lowmemorykiller/parameters/minfree. Both
> files take a comma separated list of numbers in ascending order.
>
> For example, write "0,8" to /sys/module/lowmemorykiller/parameters/adj and
> "1024,4096" to /sys/module/lowmemorykiller/parameters/minfree to kill processes
> with a oom_adj value of 8 or higher when the free memory drops below 4096 pages
> and kill processes with a oom_adj value of 0 or higher when the free memory
> drops below 1024 pages.
>
> The driver considers memory used for caches to be free, but if a large
> percentage of the cached memory is locked this can be very inaccurate
> and processes may not get killed until the normal oom killer is triggered.
>
> ---
>   mm/Kconfig           |    7 ++
>   mm/Makefile          |    1 +
>   mm/lowmemorykiller.c |  175 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 183 insertions(+), 0 deletions(-)
>   create mode 100644 mm/lowmemorykiller.c
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 011b110..a2e7959 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -259,6 +259,12 @@ config DEFAULT_MMAP_MIN_ADDR
>   	  This value can be changed after boot using the
>   	  /proc/sys/vm/mmap_min_addr tunable.
>
> +config LOW_MEMORY_KILLER
> +	bool "Low Memory Killer"
> +	help
> +	  The lowmemorykiller driver lets user-space specify a set of memory
> +	  thresholds where processes will get killed.
> +
>   config ARCH_SUPPORTS_MEMORY_FAILURE
>   	bool
>
> diff --git a/mm/Makefile b/mm/Makefile
> index 50ec00e..10fb4ff 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -47,6 +47,7 @@ obj-$(CONFIG_QUICKLIST) += quicklist.o
>   obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>   obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
>   obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
> +obj-$(CONFIG_LOW_MEMORY_KILLER)	+= lowmemorykiller.o
>   obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>   obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>   obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> diff --git a/mm/lowmemorykiller.c b/mm/lowmemorykiller.c
> new file mode 100644
> index 0000000..4e51936
> --- /dev/null
> +++ b/mm/lowmemorykiller.c
> @@ -0,0 +1,175 @@
> +/*
> + * The lowmemorykiller driver lets user-space specify a set of memory thresholds
> + * where processes with a range of oom_adj values will get killed. Specify the
> + * minimum oom_adj values in /sys/module/lowmemorykiller/parameters/adj and the
> + * number of free pages in /sys/module/lowmemorykiller/parameters/minfree. Both
> + * files take a comma separated list of numbers in ascending order.
> + *
> + * For example, write "0,8" to /sys/module/lowmemorykiller/parameters/adj and
> + * "1024,4096" to /sys/module/lowmemorykiller/parameters/minfree to kill processes
> + * with a oom_adj value of 8 or higher when the free memory drops below 4096 pages
> + * and kill processes with a oom_adj value of 0 or higher when the free memory
> + * drops below 1024 pages.
> + *
> + * The driver considers memory used for caches to be free, but if a large
> + * percentage of the cached memory is locked this can be very inaccurate
> + * and processes may not get killed until the normal oom killer is triggered.
> + *
> + * Copyright (C) 2007-2008 Google, Inc.
> + *
> + * This software is licensed under the terms of the GNU General Public
> + * License version 2, as published by the Free Software Foundation, and
> + * may be copied, distributed, and modified under those terms.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + */
> +
> +#include<linux/module.h>
> +#include<linux/kernel.h>
> +#include<linux/mm.h>
> +#include<linux/oom.h>
> +#include<linux/sched.h>
> +#include<linux/notifier.h>
> +
> +static uint32_t lowmem_debug_level = 2;
> +static int lowmem_adj[6] = {
> +	0,
> +	1,
> +	6,
> +	12,
> +};
> +static int lowmem_adj_size = 4;
> +static size_t lowmem_minfree[6] = {
> +	3 * 512,	/* 6MB */
> +	2 * 1024,	/* 8MB */
> +	4 * 1024,	/* 16MB */
> +	16 * 1024,	/* 64MB */
> +};
> +static int lowmem_minfree_size = 4;
> +
> +#define lowmem_print(level, x...)			\
> +	do {						\
> +		if (lowmem_debug_level>= (level))	\
> +			printk(x);			\
> +	} while (0)
> +
> +static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
> +{
> +	struct task_struct *p;
> +	struct task_struct *selected = NULL;
> +	int rem = 0;
> +	int tasksize;
> +	int i;
> +	int min_adj = OOM_ADJUST_MAX + 1;
> +	int selected_tasksize = 0;
> +	int selected_oom_adj;
> +	int array_size = ARRAY_SIZE(lowmem_adj);
> +	int other_free = global_page_state(NR_FREE_PAGES);
> +	int other_file = global_page_state(NR_FILE_PAGES) -
> +						global_page_state(NR_SHMEM);
> +
> +	if (lowmem_adj_size<  array_size)
> +		array_size = lowmem_adj_size;
> +	if (lowmem_minfree_size<  array_size)
> +		array_size = lowmem_minfree_size;
> +	for (i = 0; i<  array_size; i++) {
> +		if (other_free<  lowmem_minfree[i]&&
> +		    other_file<  lowmem_minfree[i]) {
> +			min_adj = lowmem_adj[i];
> +			break;
> +		}
> +	}
> +	if (sc->nr_to_scan>  0)
> +		lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %d\n",
> +			     sc->nr_to_scan, sc->gfp_mask, other_free, other_file,
> +			     min_adj);
> +	rem = global_page_state(NR_ACTIVE_ANON) +
> +		global_page_state(NR_ACTIVE_FILE) +
> +		global_page_state(NR_INACTIVE_ANON) +
> +		global_page_state(NR_INACTIVE_FILE);

Seems incorrect. process killing only free anon pages, but not file cache.


> +	if (sc->nr_to_scan<= 0 || min_adj == OOM_ADJUST_MAX + 1) {
> +		lowmem_print(5, "lowmem_shrink %lu, %x, return %d\n",
> +			     sc->nr_to_scan, sc->gfp_mask, rem);
> +		return rem;
> +	}
> +	selected_oom_adj = min_adj;
> +
> +	read_lock(&tasklist_lock);

Crazy inefficient. mere slab shrinker shouldn't take tasklist_lock. 
Imagine if tasks are much plenty...

Moreover, if system have plenty file cache, any process shouldn't killed 
at all! That's fundamental downside of this patch.


> +	for_each_process(p) {
> +		struct mm_struct *mm;
> +		struct signal_struct *sig;
> +		int oom_adj;
> +
> +		task_lock(p);
> +		mm = p->mm;
> +		sig = p->signal;
> +		if (!mm || !sig) {
> +			task_unlock(p);
> +			continue;
> +		}
> +		oom_adj = sig->oom_adj;
> +		if (oom_adj<  min_adj) {
> +			task_unlock(p);
> +			continue;
> +		}
> +		tasksize = get_mm_rss(mm);
> +		task_unlock(p);
> +		if (tasksize<= 0)
> +			continue;
> +		if (selected) {
> +			if (oom_adj<  selected_oom_adj)
> +				continue;
> +			if (oom_adj == selected_oom_adj&&
> +			    tasksize<= selected_tasksize)
> +				continue;
> +		}
> +		selected = p;
> +		selected_tasksize = tasksize;
> +		selected_oom_adj = oom_adj;
> +		lowmem_print(2, "select %d (%s), adj %d, size %d, to kill\n",
> +			     p->pid, p->comm, oom_adj, tasksize);
> +	}
> +	if (selected) {
> +		lowmem_print(1, "send sigkill to %d (%s), adj %d, size %d\n",
> +			     selected->pid, selected->comm,
> +			     selected_oom_adj, selected_tasksize);
> +		force_sig(SIGKILL, selected);

Scary naive assumption. To send SIGKILL doesn't have a guarantee to kill 
a process immediately if the task is stuck in kernel.


> +		rem -= selected_tasksize;
> +	}
> +	lowmem_print(4, "lowmem_shrink %lu, %x, return %d\n",
> +		     sc->nr_to_scan, sc->gfp_mask, rem);
> +	read_unlock(&tasklist_lock);
> +	return rem;
> +}
> +
> +static struct shrinker lowmem_shrinker = {
> +	.shrink = lowmem_shrink,
> +	.seeks = DEFAULT_SEEKS * 16
> +};
> +
> +static int __init lowmem_init(void)
> +{
> +	register_shrinker(&lowmem_shrinker);
> +	return 0;
> +}
> +
> +static void __exit lowmem_exit(void)
> +{
> +	unregister_shrinker(&lowmem_shrinker);
> +}
> +
> +module_param_named(cost, lowmem_shrinker.seeks, int, S_IRUGO | S_IWUSR);
> +module_param_array_named(adj, lowmem_adj, int,&lowmem_adj_size,
> +			 S_IRUGO | S_IWUSR);
> +module_param_array_named(minfree, lowmem_minfree, uint,&lowmem_minfree_size,
> +			 S_IRUGO | S_IWUSR);
> +module_param_named(debug_level, lowmem_debug_level, uint, S_IRUGO | S_IWUSR);
> +
> +module_init(lowmem_init);
> +module_exit(lowmem_exit);
> +
> +MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
