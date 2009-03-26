Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 68B0E6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 01:19:15 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2Q67ivn012196
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Mar 2009 15:07:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C647245DE4F
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:07:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 990E245DE4D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:07:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 80BBE1DB8043
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:07:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1F41DB8040
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:07:41 +0900 (JST)
Date: Thu, 26 Mar 2009 15:06:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326150613.09aacf0d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090326145148.ba722e1e.nishimura@mxp.nes.nec.co.jp>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
	<20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326145148.ba722e1e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 14:51:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Ah, i see. good cacth. 
> > But it seems to be the patch is a bit big and includes duplications.
> > Can't we divide this patch into 2 and reduce modification ?
> > 
> Will do if needed.
> (returning mem_over_limit part and implementing
> add_to_page_cache_store_memcg part, perhaps)
> 
> > mem_cgroup_shrink_usage() should do something proper...
> > My brief thinking is a patch like this, how do you think ?
> > 
> I thought the same direction at first.
> But it's similar to the old implementation before c9b0ed51 conceptually,
> so I chose a new direction.
> 
> I withdraw my patch if you prefer this direction :)
> 
Ah, my basic plan is.
  - BUGFIX should be simple.
  - If clean up is necessary, it should be on other patch.

I have no objections to make memcg cleaner.


> > Maybe renaming this function is appropriate...
> I think so too if we go in this direction.
> 
> Just a few comments below.
> 
Thanks,

> > ==
> > mem_cgroup_shrink_usage() is called by shmem, but its purpose is
> > not different from try_charge().
> > 
> > In current behavior, it ignores upward hierarchy and doesn't update
> > OOM status of memcg. That's bad. We can simply call try_charge()
> > and drop charge later.
> > 
> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   16 ++++++++--------
> >  1 file changed, 8 insertions(+), 8 deletions(-)
> > 
> > Index: test/mm/memcontrol.c
> > ===================================================================
> > --- test.orig/mm/memcontrol.c
> > +++ test/mm/memcontrol.c
> > @@ -1655,16 +1655,16 @@ int mem_cgroup_shrink_usage(struct page 
> >  	if (unlikely(!mem))
> >  		return 0;
> >  
> > -	do {
> > -		progress = mem_cgroup_hierarchical_reclaim(mem,
> > -					gfp_mask, true, false);
> > -		progress += mem_cgroup_check_under_limit(mem);
> > -	} while (!progress && --retry);
> > +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, mem, true);
> >  
> I think we should simply call mem_cgroup_try_charge_swapin() w/o doing try_get.
> 
Hmm, ok. Let me see again.


> > +	if (!ret) {
> > +		css_put(&mem->css); /* refcnt by charge *//
> It should be done after res_counter_uncharge().
> 
yes.

> > +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +		if (do_swap_account)
> > +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +	}
> >  	css_put(&mem->css);
> This put isn't needed if we don't try_get.
> 
In shrink_usage() (not in this patch), we called try_get(), I think.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
