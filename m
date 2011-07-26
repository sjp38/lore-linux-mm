Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1D16B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 01:37:13 -0400 (EDT)
Date: Tue, 26 Jul 2011 14:35:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix behavior of mem_cgroup_resize_limit()
Message-Id: <20110726143538.88f767a3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110725134740.GD9445@tiehlicka.suse.cz>
References: <20110722111703.241caf72.nishimura@mxp.nes.nec.co.jp>
	<20110725134740.GD9445@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Mon, 25 Jul 2011 15:47:40 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 22-07-11 11:17:03, Daisuke Nishimura wrote:
> > commit:22a668d7 introduced "memsw_is_minimum" flag, which becomes true when
> > mem_limit == memsw_limit. The flag is checked at the beginning of reclaim,
> > and "noswap" is set if the flag is true, because using swap is meaningless
> > in this case.
> > 
> > This works well in most cases, but when we try to shrink mem_limit, which
> > is the same as memsw_limit now, we might fail to shrink mem_limit because
> > swap doesn't used.
> > 
> > This patch fixes this behavior by:
> > - check MEM_CGROUP_RECLAIM_SHRINK at the begining of reclaim
> > - If it is set, don't set "noswap" flag even if memsw_is_minimum is true.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ce0d617..cf6bae8 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1649,7 +1649,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> >  
> >  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
> > -	if (!check_soft && root_mem->memsw_is_minimum)
> > +	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
> 
> It took me a while until I understood how we can end up having both
> flags unset - because I saw them as complementary before. But this is
> the mem_cgroup_do_charge path that is affected.
> 
> Btw. shouldn't we push that check into the loop. We could catch also
> memsw changes done (e.g. increased memsw limit in order to cope with the
> current workload) while we were reclaiming from a subgroup.
> 
hmm, we shouldn't enable swap if the caller set MEM_CGROUP_RECLAIM_SOFT.
So, something like this ? I think it must be another patch anyway.

---
@@ -1640,7 +1640,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_m
        struct mem_cgroup *victim;
        int ret, total = 0;
        int loop = 0;
-       bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
+       bool noswap;
        bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
        bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
        unsigned long excess;
@@ -1648,11 +1648,15 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root

        excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;

-       /* If memsw_is_minimum==1, swap-out is of-no-use. */
-       if (!check_soft && !shrink && root_mem->memsw_is_minimum)
-               noswap = true;
-
        while (1) {
+               if (reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP)
+                       noswap = true;
+               /* If memsw_is_minimum==1, swap-out is of-no-use. */
+               else if (!check_soft && !shrink && root_mem->memsw_is_minimum)
+                       noswap = true;
+               else
+                       noswap = false;
+
                victim = mem_cgroup_select_victim(root_mem);
                if (victim == root_mem) {
                        loop++;
---

> Anyway looks good.
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thank you for your review!

Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
