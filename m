Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 359E56B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 19:20:41 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 69EB53EE0B5
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:20:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4620745DE50
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:20:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DDD345DE4E
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:20:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 218691DB803E
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:20:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D27821DB803A
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:20:37 +0900 (JST)
Date: Mon, 24 Jan 2011 09:14:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] memcg : fix charge function of THP allocation.
Message-Id: <20110124091441.5dcb937c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121174818.28e1cc83.nishimura@mxp.nes.nec.co.jp>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121174818.28e1cc83.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 17:48:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 21 Jan 2011 15:44:30 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > When THP is used, Hugepage size charge can happen. It's not handled
> > correctly in mem_cgroup_do_charge(). For example, THP can fallback
> > to small page allocation when HUGEPAGE allocation seems difficult
> > or busy, but memory cgroup doesn't understand it and continue to
> > try HUGEPAGE charging. And the worst thing is memory cgroup
> > believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.
> > 
> > By this, khugepaged etc...can goes into inifinite reclaim loop
> > if tasks in memcg are busy.
> > 
> > After this patch 
> >  - Hugepage allocation will fail if 1st trial of page reclaim fails.
> >  - distinguish THP allocaton from Bached allocation. 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   51 +++++++++++++++++++++++++++++++++++----------------
> >  1 file changed, 35 insertions(+), 16 deletions(-)
> > 
> > Index: mmotm-0107/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0107.orig/mm/memcontrol.c
> > +++ mmotm-0107/mm/memcontrol.c
> > @@ -1812,24 +1812,25 @@ enum {
> >  	CHARGE_OK,		/* success */
> >  	CHARGE_RETRY,		/* need to retry but retry is not bad */
> >  	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
> > +	CHARGE_NEED_BREAK,	/* big size allocation failure */
> >  	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
> >  	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
> >  };
> >  
> >  static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
> > -				int csize, bool oom_check)
> > +			int page_size, bool do_reclaim, bool oom_check)
> 
> I'm sorry, I can't understand why we need 'do_reclaim'. See below.
> 
> >  {
> >  	struct mem_cgroup *mem_over_limit;
> >  	struct res_counter *fail_res;
> >  	unsigned long flags = 0;
> >  	int ret;
> >  
> > -	ret = res_counter_charge(&mem->res, csize, &fail_res);
> > +	ret = res_counter_charge(&mem->res, page_size, &fail_res);
> >  
> >  	if (likely(!ret)) {
> >  		if (!do_swap_account)
> >  			return CHARGE_OK;
> > -		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
> > +		ret = res_counter_charge(&mem->memsw, page_size, &fail_res);
> >  		if (likely(!ret))
> >  			return CHARGE_OK;
> >  
> > @@ -1838,14 +1839,14 @@ static int __mem_cgroup_do_charge(struct
> >  	} else
> >  		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> >  
> > -	if (csize > PAGE_SIZE) /* change csize and retry */
> > +	if (!do_reclaim)
> >  		return CHARGE_RETRY;
> >  
> 
> From the very beginning, do we need this "CHARGE_RETRY" ?
> 

Reducing charge_size here in automatic and go back to the start of this function ? 
I think returning here is better.


> >  	if (!(gfp_mask & __GFP_WAIT))
> >  		return CHARGE_WOULDBLOCK;
> >  
> >  	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > -					gfp_mask, flags, csize);
> > +					gfp_mask, flags, page_size);
> >  	/*
> >  	 * try_to_free_mem_cgroup_pages() might not give us a full
> >  	 * picture of reclaim. Some pages are reclaimed and might be
> > @@ -1853,19 +1854,28 @@ static int __mem_cgroup_do_charge(struct
> >  	 * Check the limit again to see if the reclaim reduced the
> >  	 * current usage of the cgroup before giving up
> >  	 */
> > -	if (ret || mem_cgroup_check_under_limit(mem_over_limit, csize))
> > +	if (ret || mem_cgroup_check_under_limit(mem_over_limit, page_size))
> >  		return CHARGE_RETRY;
> >  
> >  	/*
> > +	 * When page_size > PAGE_SIZE, THP calls this function and it's
> > +	 * ok to tell 'there are not enough pages for hugepage'. THP will
> > +	 * fallback into PAGE_SIZE allocation. If we do reclaim eagerly,
> > +	 * page splitting will occur and it seems much worse.
> > +	 */
> > +	if (page_size > PAGE_SIZE)
> > +		return CHARGE_NEED_BREAK;
> > +
> > +	/*
> >  	 * At task move, charge accounts can be doubly counted. So, it's
> >  	 * better to wait until the end of task_move if something is going on.
> >  	 */
> >  	if (mem_cgroup_wait_acct_move(mem_over_limit))
> >  		return CHARGE_RETRY;
> > -
> >  	/* If we don't need to call oom-killer at el, return immediately */
> >  	if (!oom_check)
> >  		return CHARGE_NOMEM;
> > +
> >  	/* check OOM */
> >  	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
> >  		return CHARGE_OOM_DIE;
> > @@ -1885,7 +1895,7 @@ static int __mem_cgroup_try_charge(struc
> >  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> >  	struct mem_cgroup *mem = NULL;
> >  	int ret;
> > -	int csize = max(CHARGE_SIZE, (unsigned long) page_size);
> > +	bool use_pcp_cache = (page_size == PAGE_SIZE);
> >  
> >  	/*
> >  	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> > @@ -1910,7 +1920,7 @@ again:
> >  		VM_BUG_ON(css_is_removed(&mem->css));
> >  		if (mem_cgroup_is_root(mem))
> >  			goto done;
> > -		if (page_size == PAGE_SIZE && consume_stock(mem))
> > +		if (use_pcp_cache && consume_stock(mem))
> >  			goto done;
> >  		css_get(&mem->css);
> >  	} else {
> > @@ -1933,7 +1943,7 @@ again:
> >  			rcu_read_unlock();
> >  			goto done;
> >  		}
> > -		if (page_size == PAGE_SIZE && consume_stock(mem)) {
> > +		if (use_pcp_cache && consume_stock(mem)) {
> >  			/*
> >  			 * It seems dagerous to access memcg without css_get().
> >  			 * But considering how consume_stok works, it's not
> > @@ -1967,17 +1977,26 @@ again:
> >  			oom_check = true;
> >  			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> >  		}
> > -
> > -		ret = __mem_cgroup_do_charge(mem, gfp_mask, csize, oom_check);
> > +		if (use_pcp_cache)
> > +			ret = __mem_cgroup_do_charge(mem, gfp_mask,
> > +					CHARGE_SIZE, false, oom_check);
> > +		else
> > +			ret = __mem_cgroup_do_charge(mem, gfp_mask,
> > +					page_size, true, oom_check);
> >  
> 
> hmm, this confuses me. I think 'use_pcp_cache' will be used to decide
> whether we should do consume_stock() or not, but why we change charge size
> and reclaim behavior depending on it ? I think this code itself is right,
> but using 'use_pcp_cache' confused me.
> 

Is it problem of function name ? 
'do_batched_charge' or some ?

I'd like to use a 'xxxx_size' variable rather than 2 xxxx_size variable.



> 
> >  		switch (ret) {
> >  		case CHARGE_OK:
> >  			break;
> >  		case CHARGE_RETRY: /* not in OOM situation but retry */
> > -			csize = page_size;
> > +			if (use_pcp_cache)/* need to reclaim pages */
> > +				use_pcp_cache = false;
> >  			css_put(&mem->css);
> >  			mem = NULL;
> >  			goto again;
> > +		case CHARGE_NEED_BREAK: /* page_size > PAGE_SIZE */
> > +			css_put(&mem->css);
> > +			/* returning faiulre doesn't mean OOM for hugepages */
> > +			goto nomem;
> 
> I like this change.
> 
> >  		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
> >  			css_put(&mem->css);
> >  			goto nomem;
> > @@ -1994,9 +2013,9 @@ again:
> >  			goto bypass;
> >  		}
> >  	} while (ret != CHARGE_OK);
> > -
> > -	if (csize > page_size)
> > -		refill_stock(mem, csize - page_size);
> > +	/* This flag is cleared when we fail CHAEGE_SIZE charge. */
> > +	if (use_pcp_cache)
> > +		refill_stock(mem, CHARGE_SIZE - page_size);
> 
> Ditto. can't we keep 'csize' and old code here ?
> 

I remove csize. 2 'size' variable is confusing.


Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
