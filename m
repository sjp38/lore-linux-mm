Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A94466B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 09:49:19 -0400 (EDT)
Date: Mon, 30 Jul 2012 15:49:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + memcg-oom-provide-more-info-while-memcg-oom-happening.patch
 added to -mm tree
Message-ID: <20120730134914.GE12680@tiehlicka.suse.cz>
References: <20120724203305.66D831E0049@wpzn4.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120724203305.66D831E0049@wpzn4.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, handai.szj@taobao.com, gthelen@google.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi and sorry for the late reply.

On Tue 24-07-12 13:33:03, Andrew Morton wrote:
> 
> The patch titled
>      Subject: memcg, oom: provide more info while memcg oom happening
> has been added to the -mm tree.  Its filename is
>      memcg-oom-provide-more-info-while-memcg-oom-happening.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Sha Zhengju <handai.szj@taobao.com>
> Subject: memcg, oom: provide more info while memcg oom happening
> 
> When an memcg oom is happening the current memcg related dump information
> is limited for debugging.  Provide more detailed memcg page statistics
> together with the total one while hierarchy is enabled.

I do agree that we need to print something more useful for memcg-oom
(who cares about the global state when the problem is per-memcg) but
this doesn't seem to be the best way to address it because it just adds
more to the OOM output and it doesn't prevent the global state being
printed out.
Please note that memcg oom can happen much more often than the global
oom so we should print only the important information.
Some more questions/notes below.

In short, I think the patch should be dropped.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 63 insertions(+), 8 deletions(-)
> 
> diff -puN mm/memcontrol.c~memcg-oom-provide-more-info-while-memcg-oom-happening mm/memcontrol.c
> --- a/mm/memcontrol.c~memcg-oom-provide-more-info-while-memcg-oom-happening
> +++ a/mm/memcontrol.c
> @@ -113,6 +113,14 @@ static const char * const mem_cgroup_eve
>  	"pgmajfault",
>  };
>  
> +static const char * const mem_cgroup_lru_names[] = {
> +	"inactive_anon",
> +	"active_anon",
> +	"inactive_file",
> +	"active_file",
> +	"unevictable",
> +};
> +
>  /*
>   * Per memcg event counter is incremented at every pagein/pageout. With THP,
>   * it will be incremated by the number of pages. This counter is used for
> @@ -1372,6 +1380,59 @@ static void move_unlock_mem_cgroup(struc
>  	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>  }
>  
> +#define K(x) ((x) << (PAGE_SHIFT-10))
> +static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
> +{
> +	int i;
> +	struct mem_cgroup *mi;

We tend to call this iter in the context you are using it. The
declaration can be moved to the appropriate for loop as well.

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

Does it really make sense to print this separately? Which additional
information does this give to you?
OOM acts on a hierarchy in general (with a single tree node if
use_hierarchy==0) so showing the root statistics doesn't sound like very
much useful to me.

> +
> +	/* Dump the total statistics if hierarchy is enabled. */
> +	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> +		long long val = 0;
> +
> +		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +			continue;
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_read_stat(mi, i);
> +		printk(KERN_CONT "total_%s:%lldKB ", mem_cgroup_stat_names[i], K(val));
> +	}
> +
> +	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
> +		unsigned long long val = 0;
> +
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_read_events(mi, i);
> +		printk(KERN_CONT "total_%s:%llu ", mem_cgroup_events_names[i], val);
> +	}
> +
> +	for (i = 0; i < NR_LRU_LISTS; i++) {
> +		unsigned long long val = 0;
> +
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
> +		printk(KERN_CONT "total_%s:%lluKB ", mem_cgroup_lru_names[i], K(val));
> +	}
> +
> +	printk(KERN_CONT "\n");
> +
> +}
> +
>  /**
>   * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
>   * @memcg: The memory cgroup that went over limit
> @@ -1436,6 +1497,8 @@ done:
>  		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
>  		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
>  		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> +
> +	mem_cgroup_print_oom_stat(memcg);
>  }
>  
>  /*
> @@ -4129,14 +4192,6 @@ static int memcg_numa_stat_show(struct c
>  }
>  #endif /* CONFIG_NUMA */
>  
> -static const char * const mem_cgroup_lru_names[] = {
> -	"inactive_anon",
> -	"active_anon",
> -	"inactive_file",
> -	"active_file",
> -	"unevictable",
> -};
> -
>  static inline void mem_cgroup_lru_names_not_uptodate(void)
>  {
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> _
> Subject: Subject: memcg, oom: provide more info while memcg oom happening
> 
> Patches currently in -mm which might be from handai.szj@taobao.com are
> 
> mm-oom-introduce-helper-function-to-process-threads-during-scan.patch
> mm-memcg-introduce-own-oom-handler-to-iterate-only-over-its-own-threads.patch
> memcg-oom-provide-more-info-while-memcg-oom-happening.patch
> memcg-oom-clarify-some-oom-dump-messages.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
