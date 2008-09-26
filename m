Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q9rDfS007641
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 15:23:13 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q9rDLK1368142
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 15:23:13 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8Q9rD4Q023708
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:53:13 +1000
Message-ID: <48DCB107.1020307@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 15:23:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 6/12] memcg optimize percpu stat
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151823.62bf6bd6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925151823.62bf6bd6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Some obvious optimization to memcg.
> 
> I found mem_cgroup_charge_statistics() is a little big (in object) and
> does unnecessary address calclation.
> This patch is for optimization to reduce the size of this function.
> 
> And res_counter_charge() is 'likely' to success.
> 
> Changelog v3->v4:
>  - merged with an other leaf patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
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
> @@ -237,18 +236,21 @@ static void mem_cgroup_charge_statistics
>  {
>  	int val = (charge)? 1 : -1;
>  	struct mem_cgroup_stat *stat = &mem->stat;
> +	struct mem_cgroup_stat_cpu *cpustat;
> 
>  	VM_BUG_ON(!irqs_disabled());
> +
> +	cpustat = &stat->cpustat[smp_processor_id()];
>  	if (PageCgroupCache(pc))
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
> @@ -609,7 +611,7 @@ static int mem_cgroup_charge_common(stru
>  		css_get(&memcg->css);
>  	}
> 
> -	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
> +	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto out;
> 
> 

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
