Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id BB4186B005A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 08:39:26 -0500 (EST)
Date: Thu, 10 Jan 2013 14:39:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: modify swap accounting function to support THP
Message-ID: <20130110133922.GB19858@dhcp22.suse.cz>
References: <1357818238-11455-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357818238-11455-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, Sha Zhengju <handai.szj@taobao.com>

On Thu 10-01-13 19:43:58, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>

THP are not swapped out because they are split before so this change
doesn't make much sense to me.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  mm/memcontrol.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3817460..674cf21 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -914,10 +914,9 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
>  }
>  
>  static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
> -					 bool charge)
> +					 int nr_pages)
>  {
> -	int val = (charge) ? 1 : -1;
> -	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
> +	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], nr_pages);
>  }
>  
>  static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
> @@ -4107,7 +4106,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>  	 */
>  	memcg_check_events(memcg, page);
>  	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> -		mem_cgroup_swap_statistics(memcg, true);
> +		mem_cgroup_swap_statistics(memcg, nr_pages);
>  		mem_cgroup_get(memcg);
>  	}
>  	/*
> @@ -4238,7 +4237,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  		 */
>  		if (!mem_cgroup_is_root(memcg))
>  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> -		mem_cgroup_swap_statistics(memcg, false);
> +		mem_cgroup_swap_statistics(memcg, -1);
>  		mem_cgroup_put(memcg);
>  	}
>  	rcu_read_unlock();
> @@ -4267,8 +4266,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  	new_id = css_id(&to->css);
>  
>  	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
> -		mem_cgroup_swap_statistics(from, false);
> -		mem_cgroup_swap_statistics(to, true);
> +		mem_cgroup_swap_statistics(from, -1);
> +		mem_cgroup_swap_statistics(to, 1);
>  		/*
>  		 * This function is only called from task migration context now.
>  		 * It postpones res_counter and refcount handling till the end
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
