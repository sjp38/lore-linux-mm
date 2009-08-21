Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5175B6B0095
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:33:37 -0400 (EDT)
Received: from rcpt-expgw.biglobe.ne.jp
	by rcpt-mqugw.biglobe.ne.jp (kbkr/4512300408) with ESMTP id n7LAeaji001320
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 19:40:36 +0900
Date: Fri, 21 Aug 2009 19:39:58 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH -mmotm] memcg: show swap usage in stat file
Message-Id: <20090821193958.05a771de.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090821093548.GD29572@balbir.in.ibm.com>
References: <20090821152549.038e6953.nishimura@mxp.nes.nec.co.jp>
	<20090821093548.GD29572@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Aug 2009 15:05:48 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-08-21 15:25:49]:
> 
> > We now count MEM_CGROUP_STAT_SWAPOUT, so we can show swap usage.
> > It would be useful for users to show swap usage in memory.stat file,
> > because they don't need calculate memsw.usage - res.usage to know swap usage.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   17 ++++++++++++++---
> >  1 files changed, 14 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8b06c05..ae80de0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2663,6 +2663,7 @@ enum {
> >  	MCS_MAPPED_FILE,
> >  	MCS_PGPGIN,
> >  	MCS_PGPGOUT,
> > +	MCS_SWAP,
> >  	MCS_INACTIVE_ANON,
> >  	MCS_ACTIVE_ANON,
> >  	MCS_INACTIVE_FILE,
> > @@ -2684,6 +2685,7 @@ struct {
> >  	{"mapped_file", "total_mapped_file"},
> >  	{"pgpgin", "total_pgpgin"},
> >  	{"pgpgout", "total_pgpgout"},
> > +	{"swap", "total_swap"},
> >  	{"inactive_anon", "total_inactive_anon"},
> >  	{"active_anon", "total_active_anon"},
> >  	{"inactive_file", "total_inactive_file"},
> > @@ -2708,6 +2710,10 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  	s->stat[MCS_PGPGIN] += val;
> >  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
> >  	s->stat[MCS_PGPGOUT] += val;
> > +	if (do_swap_account) {
> > +		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
> > +		s->stat[MCS_SWAP] += val;
> > +	}
> > 
> >  	/* per zone stat */
> >  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> > @@ -2739,8 +2745,11 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
> >  	memset(&mystat, 0, sizeof(mystat));
> >  	mem_cgroup_get_local_stat(mem_cont, &mystat);
> > 
> > -	for (i = 0; i < NR_MCS_STAT; i++)
> > +	for (i = 0; i < NR_MCS_STAT; i++) {
> > +		if (i == MCS_SWAP && !do_swap_account)
> > +			continue;
> 
> May be worth encapsulating in a function like memcg_show_swapout
> 
I tried it first, but I think it would be overkill a bit
and writing in open-coded would be more simple and making it
clear what we are doing.
So, I went this direction.

> >  		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
> > +	}
> > 
> >  	/* Hierarchical information */
> >  	{
> > @@ -2753,9 +2762,11 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
> > 
> >  	memset(&mystat, 0, sizeof(mystat));
> >  	mem_cgroup_get_total_stat(mem_cont, &mystat);
> > -	for (i = 0; i < NR_MCS_STAT; i++)
> > +	for (i = 0; i < NR_MCS_STAT; i++) {
> > +		if (i == MCS_SWAP && !do_swap_account)
> > +			continue;
> >  		cb->fill(cb, memcg_stat_strings[i].total_name, mystat.stat[i]);
> > -
> > +	}
> > 
> >  #ifdef CONFIG_DEBUG_VM
> >  	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
> 
> Overall, looks good
> 
> 
> Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>  
Thank you.


Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
