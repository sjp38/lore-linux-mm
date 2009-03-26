Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD4026B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 01:58:25 -0400 (EDT)
Date: Thu, 26 Mar 2009 15:38:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326153803.23689561.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090326152734.365b8689.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
	<20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326145148.ba722e1e.nishimura@mxp.nes.nec.co.jp>
	<20090326150613.09aacf0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326151733.1e36bf43.nishimura@mxp.nes.nec.co.jp>
	<20090326152734.365b8689.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 15:27:34 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 26 Mar 2009 15:17:33 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > > > @@ -1655,16 +1655,16 @@ int mem_cgroup_shrink_usage(struct page 
> > > > >  	if (unlikely(!mem))
> > > > >  		return 0;
> > > > >  
> > > > > -	do {
> > > > > -		progress = mem_cgroup_hierarchical_reclaim(mem,
> > > > > -					gfp_mask, true, false);
> > > > > -		progress += mem_cgroup_check_under_limit(mem);
> > > > > -	} while (!progress && --retry);
> > > > > +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, mem, true);
> > > > >  
> > > > I think we should simply call mem_cgroup_try_charge_swapin() w/o doing try_get.
> > > > 
> > > Hmm, ok. Let me see again.
> > > 
> > > 
> > > > > +	if (!ret) {
> > > > > +		css_put(&mem->css); /* refcnt by charge *//
> > > > It should be done after res_counter_uncharge().
> > > > 
> > > yes.
> > > 
> > > > > +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> > > > > +		if (do_swap_account)
> > > > > +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > > > > +	}
> > > > >  	css_put(&mem->css);
> > > > This put isn't needed if we don't try_get.
> > > > 
> > > In shrink_usage() (not in this patch), we called try_get(), I think.
> > > 
> > I meant that if we changed above part to try_charge_swapin w/o calling try_get
> > in shrink_usage, we don't need this put :)
> > 
> > And I think we can use cancel_charge_swapin at uncharge part.
> > 
> > So, mem_cgroup_shrink_usage would be like this ?
> > 
> > ===
> > int mem_cgroup_shrink_usage(struct page *page,
> >                             struct mm_struct *mm,
> >                             gfp_t gfp_mask)
> > {
> >         struct mem_cgroup *mem = NULL;
> >         int ret;
> > 
> >         ret = mem_cgroup_try_charge_swapin(mm, page, mask, &ptr);
> >         if (!ret && ptr)
> >                 mem_cgroup_cancel_charge_swapin(ptr);
> > 
> >         return ret;
> > }
> 
> Seems very simple. hmm, I'm thinking of following.
> ==
> int mem_cgroup_shmem_charge_fallback(struct page *page, struct mm_struct *mm, gfp_t mask)
> {
> 	return mem_cgroup_cache_charge(mm, page, mask);
> }
> ==
> 
> But I'm afraid that this adds another corner case to account the page not under
> radix-tree. (But this is SwapCache...then...this will work.)
> 
> Could you write a patch in this direction ? (or I'll write by myself.)
> It's obvious that you do better test.
> 
Okey.

I'll make a patch and repost it after doing some tests for review.

BTW, do you have any good idea about the new name of shrink_usage ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
