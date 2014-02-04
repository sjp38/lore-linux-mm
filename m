Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id E6E016B0037
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:05:23 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w62so4401525wes.29
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:05:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si12428699wjq.66.2014.02.04.08.05.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:05:22 -0800 (PST)
Date: Tue, 4 Feb 2014 17:05:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 1/6] memcg: do not replicate
 try_get_mem_cgroup_from_mm in __mem_cgroup_try_charge
Message-ID: <20140204160521.GM4890@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-2-git-send-email-mhocko@suse.cz>
 <20140204155508.GM6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204155508.GM6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 10:55:08, Johannes Weiner wrote:
> On Tue, Feb 04, 2014 at 02:28:55PM +0100, Michal Hocko wrote:
> > Johannes Weiner has pointed out that __mem_cgroup_try_charge duplicates
> > try_get_mem_cgroup_from_mm for charges which came without a memcg. The
> > only reason seems to be a tiny optimization when css_tryget is not
> > called if the charge can be consumed from the stock. Nevertheless
> > css_tryget is very cheap since it has been reworked to use per-cpu
> > counting so this optimization doesn't give us anything these days.
> > 
> > So let's drop the code duplication so that the code is more readable.
> > While we are at it also remove a very confusing comment in
> > try_get_mem_cgroup_from_mm.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c | 49 ++++++++-----------------------------------------
> >  1 file changed, 8 insertions(+), 41 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 53385cd4e6f0..042e4ff36c05 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1081,11 +1081,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> >  
> >  	if (!mm)
> >  		return NULL;
> 
> While you're at it, this check also seems unnecessary.

Yes, it will be removed in a later patch. I wanted to have it in a
separate patch for a better bisectability just in case I have really
missed mm-might-by-NULL case.

> > -	/*
> > -	 * Because we have no locks, mm->owner's may be being moved to other
> > -	 * cgroup. We use css_tryget() here even if this looks
> > -	 * pessimistic (rather than adding locks here).
> > -	 */
> > +
> >  	rcu_read_lock();
> >  	do {
> >  		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > @@ -2759,45 +2755,15 @@ again:
> >  			goto done;
> >  		css_get(&memcg->css);
> >  	} else {
> > -		struct task_struct *p;
> > -
> > -		rcu_read_lock();
> > -		p = rcu_dereference(mm->owner);
> > -		/*
> > -		 * Because we don't have task_lock(), "p" can exit.
> > -		 * In that case, "memcg" can point to root or p can be NULL with
> > -		 * race with swapoff. Then, we have small risk of mis-accouning.
> > -		 * But such kind of mis-account by race always happens because
> > -		 * we don't have cgroup_mutex(). It's overkill and we allo that
> > -		 * small race, here.
> > -		 * (*) swapoff at el will charge against mm-struct not against
> > -		 * task-struct. So, mm->owner can be NULL.
> > -		 */
> > -		memcg = mem_cgroup_from_task(p);
> > -		if (!memcg)
> > +		memcg = try_get_mem_cgroup_from_mm(mm);
> > +		if (!memcg) {
> >  			memcg = root_mem_cgroup;
> > -		if (mem_cgroup_is_root(memcg)) {
> > -			rcu_read_unlock();
> > -			goto done;
> > -		}
> > -		if (consume_stock(memcg, nr_pages)) {
> > -			/*
> > -			 * It seems dagerous to access memcg without css_get().
> > -			 * But considering how consume_stok works, it's not
> > -			 * necessary. If consume_stock success, some charges
> > -			 * from this memcg are cached on this cpu. So, we
> > -			 * don't need to call css_get()/css_tryget() before
> > -			 * calling consume_stock().
> > -			 */
> > -			rcu_read_unlock();
> >  			goto done;
> >  		}
> > -		/* after here, we may be blocked. we need to get refcnt */
> > -		if (!css_tryget(&memcg->css)) {
> > -			rcu_read_unlock();
> > -			goto again;
> > -		}
> > -		rcu_read_unlock();
> > +		if (mem_cgroup_is_root(memcg))
> > +			goto done_put;
> > +		if (consume_stock(memcg, nr_pages))
> > +			goto done_put;
> 
> These two are actually the same in the if (*ptr) branch.

True, I just wanted to have the patch minimalistic and do just a single
thing here. Duplicity will vanish in the next patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
