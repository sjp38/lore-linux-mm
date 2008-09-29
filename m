Date: Mon, 29 Sep 2008 20:44:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 4/4] memcg: optimze cpustat
Message-Id: <20080929204436.ee3fce0b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080929192430.e93d4f21.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
	<20080929192430.e93d4f21.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 19:24:30 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Some obvious optimization to memcg.
> 
> I found mem_cgroup_charge_statistics() is a little big (in object) and
> does unnecessary address calclation.
> This patch is for optimization to reduce the size of this function.
> 
> And res_counter_charge() is 'likely' to success.
> 
> Changlog: v5->v6
>  - patch series was reordered and needs some adjustment. no changes in logic.
> Changelog v3->v4:
>  - merged with an other leaf patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> 
	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I'll test with all the patches applied tonight.


Thanks,
Daisuke Nishimura.

>  mm/memcontrol.c |   18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
> +++ mmotm-2.6.27-rc7+/mm/memcontrol.c
> @@ -66,11 +66,10 @@ struct mem_cgroup_stat {
>  /*
>   * For accounting under irq disable, no need for increment preempt count.
>   */
> -static void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
> +static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
>  		enum mem_cgroup_stat_index idx, int val)
>  {
> -	int cpu = smp_processor_id();
> -	stat->cpustat[cpu].count[idx] += val;
> +	stat->count[idx] += val;
>  }
>  
>  static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
> @@ -190,18 +189,21 @@ static void mem_cgroup_charge_statistics
>  {
>  	int val = (charge)? 1 : -1;
>  	struct mem_cgroup_stat *stat = &mem->stat;
> +	struct mem_cgroup_stat_cpu *cpustat;
>  
>  	VM_BUG_ON(!irqs_disabled());
> +
> +	cpustat = &stat->cpustat[smp_processor_id()];
>  	if (flags & PAGE_CGROUP_FLAG_CACHE)
> -		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
> +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
>  	else
> -		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
> +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
>  
>  	if (charge)
> -		__mem_cgroup_stat_add_safe(stat,
> +		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
>  	else
> -		__mem_cgroup_stat_add_safe(stat,
> +		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
>  }
>  
> @@ -558,7 +560,7 @@ static int mem_cgroup_charge_common(stru
>  		css_get(&memcg->css);
>  	}
>  
> -	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> +	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto out;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
