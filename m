Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E79A96B009C
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:39:29 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L784Ew005718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 16:08:04 +0900
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L77TlF010635
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 16:07:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3151E45DE51
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 16:07:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 04D0E45DE4F
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 16:07:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E46431DB803C
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 16:07:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 99E221DB805E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 16:07:28 +0900 (JST)
Date: Fri, 21 Aug 2009 16:05:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm] memcg: show swap usage in stat file
Message-Id: <20090821160542.542a490b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090821152549.038e6953.nishimura@mxp.nes.nec.co.jp>
References: <20090821152549.038e6953.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Aug 2009 15:25:49 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> We now count MEM_CGROUP_STAT_SWAPOUT, so we can show swap usage.
> It would be useful for users to show swap usage in memory.stat file,
> because they don't need calculate memsw.usage - res.usage to know swap usage.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Indeed.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Thanks,
-Kame


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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
