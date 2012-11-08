Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 9F4A56B005A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 04:07:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9D5983EE0B6
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:07:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 801D045DEBA
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:07:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 685AE45DEC6
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:07:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B18E08002
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:07:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC6F1DB8040
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:07:52 +0900 (JST)
Message-ID: <509B7658.1020807@jp.fujitsu.com>
Date: Thu, 08 Nov 2012 18:07:36 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg, oom: provide more precise dump info while
 memcg oom happening
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com> <1352277696-21724-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1352277696-21724-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/11/07 17:41), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Current, when a memcg oom is happening the oom dump messages is still global
> state and provides few useful info for users. This patch prints more pointed
> memcg page statistics for memcg-oom.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>   mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>   mm/oom_kill.c   |    6 +++-
>   2 files changed, 66 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0eab7d5..2df5e72 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -118,6 +118,14 @@ static const char * const mem_cgroup_events_names[] = {
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

Is this for the same strings with show_free_areas() ?


>   /*
>    * Per memcg event counter is incremented at every pagein/pageout. With THP,
>    * it will be incremated by the number of pages. This counter is used for
> @@ -1501,8 +1509,59 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>   	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>   }
>   
> +#define K(x) ((x) << (PAGE_SHIFT-10))
> +static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *mi;
> +	unsigned int i;
> +
> +	if (!memcg->use_hierarchy && memcg != root_mem_cgroup) {

Why do you need to have this condition check ?

> +		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> +			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +				continue;
> +			printk(KERN_CONT "%s:%ldKB ", mem_cgroup_stat_names[i],
> +				K(mem_cgroup_read_stat(memcg, i)));

Hm, how about using the same style with show_free_areas() ?

> +		}
> +
> +		for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
> +			printk(KERN_CONT "%s:%lu ", mem_cgroup_events_names[i],
> +				mem_cgroup_read_events(memcg, i));
> +

I don't think EVENTS info is useful for oom.

> +		for (i = 0; i < NR_LRU_LISTS; i++)
> +			printk(KERN_CONT "%s:%luKB ", mem_cgroup_lru_names[i],
> +				K(mem_cgroup_nr_lru_pages(memcg, BIT(i))));

How far does your new information has different format than usual oom ?
Could you show a sample and difference in changelog ?

Of course, I prefer both of them has similar format.





> +	} else {
> +
> +		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> +			long long val = 0;
> +
> +			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +				continue;
> +			for_each_mem_cgroup_tree(mi, memcg)
> +				val += mem_cgroup_read_stat(mi, i);
> +			printk(KERN_CONT "%s:%lldKB ", mem_cgroup_stat_names[i], K(val));
> +		}
> +
> +		for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
> +			unsigned long long val = 0;
> +
> +			for_each_mem_cgroup_tree(mi, memcg)
> +				val += mem_cgroup_read_events(mi, i);
> +			printk(KERN_CONT "%s:%llu ",
> +				mem_cgroup_events_names[i], val);
> +		}
> +
> +		for (i = 0; i < NR_LRU_LISTS; i++) {
> +			unsigned long long val = 0;
> +
> +			for_each_mem_cgroup_tree(mi, memcg)
> +				val += mem_cgroup_nr_lru_pages(mi, BIT(i));
> +			printk(KERN_CONT "%s:%lluKB ", mem_cgroup_lru_names[i], K(val));
> +		}
> +	}
> +	printk(KERN_CONT "\n");
> +}




>   /**
> - * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
>    * @memcg: The memory cgroup that went over limit
>    * @p: Task that is going to be killed
>    *
> @@ -1569,6 +1628,8 @@ done:
>   		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
>   		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
>   		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
> +
> +	mem_cgroup_print_oom_stat(memcg);
>   }

please put directly in print_oom_info()



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
