Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E78C26B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 07:47:08 -0400 (EDT)
Date: Thu, 21 Jul 2011 13:47:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110721114704.GC27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
 <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jul 2011 09:58:24 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > percpu_charge_mutex protects from multiple simultaneous per-cpu charge
> > caches draining because we might end up having too many work items.
> > At least this was the case until 26fe6168 (memcg: fix percpu cached
> > charge draining frequency) when we introduced a more targeted draining
> > for async mode.
> > Now that also sync draining is targeted we can safely remove mutex
> > because we will not send more work than the current number of CPUs.
> > FLUSHING_CACHED_CHARGE protects from sending the same work multiple
> > times and stock->nr_pages == 0 protects from pointless sending a work
> > if there is obviously nothing to be done. This is of course racy but we
> > can live with it as the race window is really small (we would have to
> > see FLUSHING_CACHED_CHARGE cleared while nr_pages would be still
> > non-zero).
> > The only remaining place where we can race is synchronous mode when we
> > rely on FLUSHING_CACHED_CHARGE test which might have been set by other
> > drainer on the same group but we should wait in that case as well.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> A concern.
> 
> > ---
> >  mm/memcontrol.c |   12 ++----------
> >  1 files changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8180cd9..9d49a12 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2065,7 +2065,6 @@ struct memcg_stock_pcp {
> >  #define FLUSHING_CACHED_CHARGE	(0)
> >  };
> >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> > -static DEFINE_MUTEX(percpu_charge_mutex);
> >  
> >  /*
> >   * Try to consume stocked charge on this cpu. If success, one page is consumed
> > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > +		if (root_mem == stock->cached &&
> > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> >  			flush_work(&stock->work);
> 
> Doesn't this new check handle hierarchy ?
> css_is_ancestor() will be required if you do this check.

Yes you are right. Will fix it. I will add a helper for the check.

> BTW, this change should be in other patch, I think.

I have put the change here intentionally because previously we were
protected by the lock so we couldn't race with somebody else so the
check was not necessary.

> 
> Thanks,
> -Kame

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
