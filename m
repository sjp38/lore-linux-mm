Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8016B008A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:33:30 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7LFX32C008678
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 21:03:03 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7L9Zoqc2437316
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 15:08:40 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7L9ZoZn029324
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 19:35:50 +1000
Date: Fri, 21 Aug 2009 15:05:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm] memcg: show swap usage in stat file
Message-ID: <20090821093548.GD29572@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090821152549.038e6953.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090821152549.038e6953.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-08-21 15:25:49]:

> We now count MEM_CGROUP_STAT_SWAPOUT, so we can show swap usage.
> It would be useful for users to show swap usage in memory.stat file,
> because they don't need calculate memsw.usage - res.usage to know swap usage.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   17 ++++++++++++++---
>  1 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8b06c05..ae80de0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2663,6 +2663,7 @@ enum {
>  	MCS_MAPPED_FILE,
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
> +	MCS_SWAP,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -2684,6 +2685,7 @@ struct {
>  	{"mapped_file", "total_mapped_file"},
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
> +	{"swap", "total_swap"},
>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -2708,6 +2710,10 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
>  	s->stat[MCS_PGPGIN] += val;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
>  	s->stat[MCS_PGPGOUT] += val;
> +	if (do_swap_account) {
> +		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
> +		s->stat[MCS_SWAP] += val;
> +	}
> 
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> @@ -2739,8 +2745,11 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  	memset(&mystat, 0, sizeof(mystat));
>  	mem_cgroup_get_local_stat(mem_cont, &mystat);
> 
> -	for (i = 0; i < NR_MCS_STAT; i++)
> +	for (i = 0; i < NR_MCS_STAT; i++) {
> +		if (i == MCS_SWAP && !do_swap_account)
> +			continue;

May be worth encapsulating in a function like memcg_show_swapout

>  		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
> +	}
> 
>  	/* Hierarchical information */
>  	{
> @@ -2753,9 +2762,11 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
> 
>  	memset(&mystat, 0, sizeof(mystat));
>  	mem_cgroup_get_total_stat(mem_cont, &mystat);
> -	for (i = 0; i < NR_MCS_STAT; i++)
> +	for (i = 0; i < NR_MCS_STAT; i++) {
> +		if (i == MCS_SWAP && !do_swap_account)
> +			continue;
>  		cb->fill(cb, memcg_stat_strings[i].total_name, mystat.stat[i]);
> -
> +	}
> 
>  #ifdef CONFIG_DEBUG_VM
>  	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));

Overall, looks good


Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
