Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4658F6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 09:12:50 -0400 (EDT)
Date: Tue, 26 Jul 2011 15:12:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix behavior of mem_cgroup_resize_limit()
Message-ID: <20110726131244.GB17958@tiehlicka.suse.cz>
References: <20110722111703.241caf72.nishimura@mxp.nes.nec.co.jp>
 <20110725134740.GD9445@tiehlicka.suse.cz>
 <20110726143538.88f767a3.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110726143538.88f767a3.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>

On Tue 26-07-11 14:35:38, Daisuke Nishimura wrote:
> On Mon, 25 Jul 2011 15:47:40 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 22-07-11 11:17:03, Daisuke Nishimura wrote:
> > > commit:22a668d7 introduced "memsw_is_minimum" flag, which becomes true when
> > > mem_limit == memsw_limit. The flag is checked at the beginning of reclaim,
> > > and "noswap" is set if the flag is true, because using swap is meaningless
> > > in this case.
> > > 
> > > This works well in most cases, but when we try to shrink mem_limit, which
> > > is the same as memsw_limit now, we might fail to shrink mem_limit because
> > > swap doesn't used.
> > > 
> > > This patch fixes this behavior by:
> > > - check MEM_CGROUP_RECLAIM_SHRINK at the begining of reclaim
> > > - If it is set, don't set "noswap" flag even if memsw_is_minimum is true.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  mm/memcontrol.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index ce0d617..cf6bae8 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1649,7 +1649,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > >  	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> > >  
> > >  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
> > > -	if (!check_soft && root_mem->memsw_is_minimum)
> > > +	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
> > 
> > It took me a while until I understood how we can end up having both
> > flags unset - because I saw them as complementary before. But this is
> > the mem_cgroup_do_charge path that is affected.
> > 
> > Btw. shouldn't we push that check into the loop. We could catch also
> > memsw changes done (e.g. increased memsw limit in order to cope with the
> > current workload) while we were reclaiming from a subgroup.
> > 
> hmm, we shouldn't enable swap if the caller set MEM_CGROUP_RECLAIM_SOFT.
> So, something like this ? I think it must be another patch anyway.

Yes, the separate patch is reasonable. I have mentioned it just because
I was looking at the code. Sorry for not preparing it myself.

> 
> ---
> @@ -1640,7 +1640,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_m
>         struct mem_cgroup *victim;
>         int ret, total = 0;
>         int loop = 0;
> -       bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> +       bool noswap;
>         bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>         bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
>         unsigned long excess;
> @@ -1648,11 +1648,15 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root
> 
>         excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> 
> -       /* If memsw_is_minimum==1, swap-out is of-no-use. */
> -       if (!check_soft && !shrink && root_mem->memsw_is_minimum)
> -               noswap = true;
> -
>         while (1) {
> +               if (reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP)
> +                       noswap = true;
> +               /* If memsw_is_minimum==1, swap-out is of-no-use. */
> +               else if (!check_soft && !shrink && root_mem->memsw_is_minimum)
> +                       noswap = true;
> +               else
> +                       noswap = false;
> +
>                 victim = mem_cgroup_select_victim(root_mem);
>                 if (victim == root_mem) {
>                         loop++;

Little hairy but I I do not have a better idea (making the first two
condition one doesn't improve readability too much IMO). So here is my
Acked-by: Michal Hocko <mhocko@suse.cz>

for the change if that matters.

I would add a description like this:
"
memcg: Recheck noswap conditions during reclaim hierarchy reclaim

Currently we are are checking whether it makes sense to swap before we
start the reclaim loop. This, however, doesn't handle a case when admin
tries to cope with the memory pressure by increasing the memsw.limit so
we can start swapping.

Let's be more dynamic and set noswap flag everytime we are about to
reclaim from a group.
"

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
