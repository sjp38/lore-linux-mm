Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 512106B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 04:31:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 847D13EE0C1
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 17:31:29 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F9EE45DE56
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 17:31:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D01645DE52
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 17:31:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 246231DB8038
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 17:31:29 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E761DB803A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 17:31:28 +0900 (JST)
Message-ID: <4FF3FED6.9010700@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 17:29:10 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] memcg: print more detailed info while memcg oom happening
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881609-5935-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340881609-5935-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 20:06), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> While memcg oom happening, the dump info is limited, so add this
> to provide memcg page stat.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Could you split this into a different series ?
seems good to me in general but...one concern is hierarchy handling.

IIUC, the passed 'memcg' is the root of hierarchy which gets OOM.
So, the LRU info, which is local to the root memcg, may not contain any good
information. I think you should visit all memcg under the tree.

Thanks,
-Kame

> ---
>   mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++++++--------
>   1 files changed, 34 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8493119..3ed41e9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -101,6 +101,14 @@ static const char * const mem_cgroup_events_names[] = {
>   	"pgmajfault",
>   };
>   
> +static const char * const mem_cgroup_lru_names[] = {
> +	"inactive_anon",
> +	"active_anon",
> +	"inactive_file",
> +	"active_file",
> +	"unevictable",
> +};
> +
>   /*
>    * Per memcg event counter is incremented at every pagein/pageout. With THP,
>    * it will be incremated by the number of pages. This counter is used for
> @@ -1358,6 +1366,30 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>   	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>   }
>   
> +#define K(x) ((x) << (PAGE_SHIFT-10))
> +static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
> +{
> +	int i;
> +
> +	printk(KERN_INFO "Memory cgroup stat:\n");
> +	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> +		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +			continue;
> +		printk(KERN_CONT "%s:%ldKB ", mem_cgroup_stat_names[i],
> +			   K(mem_cgroup_read_stat(memcg, i)));
> +	}
> +
> +	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
> +		printk(KERN_CONT "%s:%lu ", mem_cgroup_events_names[i],
> +			   mem_cgroup_read_events(memcg, i));
> +
> +	for (i = 0; i < NR_LRU_LISTS; i++)
> +		printk(KERN_CONT "%s:%luKB ", mem_cgroup_lru_names[i],
> +			   K(mem_cgroup_nr_lru_pages(memcg, BIT(i))));
> +	printk(KERN_CONT "\n");
> +
> +}
> +
>   /**
>    * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
>    * @memcg: The memory cgroup that went over limit
> @@ -1422,6 +1454,8 @@ done:
>   		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
>   		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
>   		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> +
> +	mem_cgroup_print_oom_stat(memcg);
>   }
>   
>   /*
> @@ -4043,14 +4077,6 @@ static int mem_control_numa_stat_show(struct cgroup *cont, struct cftype *cft,
>   }
>   #endif /* CONFIG_NUMA */
>   
> -static const char * const mem_cgroup_lru_names[] = {
> -	"inactive_anon",
> -	"active_anon",
> -	"inactive_file",
> -	"active_file",
> -	"unevictable",
> -};
> -
>   static inline void mem_cgroup_lru_names_not_uptodate(void)
>   {
>   	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
