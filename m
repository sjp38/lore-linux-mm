Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D44E36B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 11:25:44 -0500 (EST)
Date: Thu, 8 Nov 2012 17:25:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3] memcg, oom: provide more precise dump info while
 memcg oom happening
Message-ID: <20121108162539.GP31821@dhcp22.suse.cz>
References: <1352389967-23270-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352389967-23270-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu 08-11-12 23:52:47, Sha Zhengju wrote:
[...]
> (2) After change
> [  269.225628] mal invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> [  269.225633] mal cpuset=/ mems_allowed=0-1
> [  269.225636] Pid: 4616, comm: mal Not tainted 3.6.0+ #25
> [  269.225637] Call Trace:
> [  269.225647]  [<ffffffff8111b9c4>] dump_header+0x84/0xd0
> [  269.225650]  [<ffffffff8111c691>] oom_kill_process+0x331/0x350
> [  269.225710]  .......(call trace)
> [  269.225713]  [<ffffffff81517325>] page_fault+0x25/0x30
> [  269.225716] Task in /1/2 killed as a result of limit of /1
> [  269.225718] memory: usage 511732kB, limit 512000kB, failcnt 5071
> [  269.225720] memory+swap: usage 563200kB, limit 563200kB, failcnt 57
> [  269.225721] kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
> [  269.225722] Memory cgroup stats:cache:8KB rss:511724KB mapped_file:4KB swap:51468KB inactive_anon:265864KB active_anon:245832KB inactive_file:0KB active_file:0KB unevictable:0KB
> [  269.225741] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
> [  269.225757] [ 4554]     0  4554    16626      473      17       25             0 bash
> [  269.225759] [ 4611]     0  4611   103328    90231     208    12260             0 mal
> [  269.225762] [ 4616]     0  4616   103328    32799      88     7562             0 mal
> [  269.225764] Memory cgroup out of memory: Kill process 4611 (mal) score 699 or sacrifice child
> [  269.225766] Killed process 4611 (mal) total-vm:413312kB, anon-rss:360632kB, file-rss:292kB
> 
> This version provides more pointed info for memcg in "Memory cgroup stats" section.

Looks much better!

> 
> Change log:
> v3 <--- v2
> 	1. fix towards hierarchy
> 	2. undo rework dump_tasks
> v2 <--- v1
> 	1. some modification towards hierarchy
> 	2. rework dump_tasks
> 	3. rebased on Michal's mm tree since-3.6
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  mm/memcontrol.c |   41 +++++++++++++++++++++++++++++++----------
>  mm/oom_kill.c   |    6 ++++--
>  2 files changed, 35 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0eab7d5..17317fa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -1501,8 +1509,8 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>  	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>  }
>  
> +#define K(x) ((x) << (PAGE_SHIFT-10))
>  /**
> - * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.

No need to remove this just fix it:
 * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.

>   * @memcg: The memory cgroup that went over limit
>   * @p: Task that is going to be killed
>   *
> @@ -1520,8 +1528,10 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  	 */
>  	static char memcg_name[PATH_MAX];
>  	int ret;
> +	struct mem_cgroup *mi;
> +	unsigned int i;
>  
> -	if (!memcg || !p)
> +	if (!p)
>  		return;
>  
>  	rcu_read_lock();
> @@ -1569,6 +1579,25 @@ done:
>  		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
>  		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
>  		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
> +
> +	printk(KERN_INFO "Memory cgroup stats:");

"Memory cgroup hierarchy stats" is probably a better fit with the
current implementation.

> +	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> +		long long val = 0;
> +		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +			continue;
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_read_stat(mi, i);
> +		printk(KERN_CONT "%s:%lldKB ", mem_cgroup_stat_names[i], K(val));
> +	}
> +
> +	for (i = 0; i < NR_LRU_LISTS; i++) {
> +		unsigned long long val = 0;
> +
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
> +		printk(KERN_CONT "%s:%lluKB ", mem_cgroup_lru_names[i], K(val));
> +	}
> +	printk(KERN_CONT "\n");

This is nice and simple I am just thinking whether it is enough. Say
that you have a deeper hierarchy and the there is a safety limit in the
its root
        A (limit)
       /|\
      B C D
          |\
	  E F

and we trigger an OOM on the A's limit. Now we know that something blew
up but what it was we do not know. Wouldn't it be better to swap the for
and for_each_mem_cgroup_tree loops? Then we would see the whole
hierarchy and can potentially point at the group which doesn't behave.
Memory cgroup stats for A/: ...
Memory cgroup stats for A/B/: ...
Memory cgroup stats for A/C/: ...
Memory cgroup stats for A/D/: ...
Memory cgroup stats for A/D/E/: ...
Memory cgroup stats for A/D/F/: ...

Would it still fit in with your use case?
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
