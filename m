Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C3CA26B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:03:14 -0500 (EST)
Date: Fri, 18 Dec 2009 17:02:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 27 of 28] memcg compound
Message-ID: <20091218160217.GO29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <4b489bf530048a5712a9.1261076430@v2.random>
 <20091218102701.7fa7124d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091218102701.7fa7124d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 10:27:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1288,15 +1288,20 @@ static atomic_t memcg_drain_count;
> >   * cgroup which is not current target, returns false. This stock will be
> >   * refilled.
> >   */
> > -static bool consume_stock(struct mem_cgroup *mem)
> > +static bool consume_stock(struct mem_cgroup *mem, int *page_size)
> >  {
> >  	struct memcg_stock_pcp *stock;
> >  	bool ret = true;
> >  
> >  	stock = &get_cpu_var(memcg_stock);
> > -	if (mem == stock->cached && stock->charge)
> > -		stock->charge -= PAGE_SIZE;
> > -	else /* need to call res_counter_charge */
> > +	if (mem == stock->cached && stock->charge) {
> > +		if (*page_size > stock->charge) {
> > +			*page_size -= stock->charge;
> > +			stock->charge = 0;
> > +			ret = false;
> > +		} else
> > +			stock->charge -= *page_size;
> > +	} else /* need to call res_counter_charge */
> >  		ret = false;
> 
> I feel we should we skip this per-cpu caching method because counter overflow
> rate is the key for this workaround.
> Then,
> 	if (size == PAGESIZE)
> 		consume_stock()
> seems better to me.

Ok, I did it the way I did it, to be sure to never underestimate the
still available reserved space. Wasting 128k per cgroup seems no big
deal to me, so I can skip it. Clearly performace-wise including the
per-cpu reservation was worthless on 2M pages (reservation is 128k...)
it was only to keep accounting as strict as it should be because the
other code there really went all way down to csize = page_size in case
of failure and tried again. But then it didn't send IPI to other cpus
to release those. So basically you should also remove that "retry"
event which looks pretty worthless with other cpu queues not drained
before retrying and hugepages bypassing the cache entirely. Assume the
cache is an error of 128k*nr_cpus.

> >  	put_cpu_var(memcg_stock);
> >  	return ret;
> > @@ -1401,13 +1406,13 @@ static int __cpuinit memcg_stock_cpu_cal
> >   * oom-killer can be invoked.
> >   */
> >  static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > -			gfp_t gfp_mask, struct mem_cgroup **memcg,
> > -			bool oom, struct page *page)
> > +				   gfp_t gfp_mask, struct mem_cgroup **memcg,
> > +				   bool oom, struct page *page, int page_size)
> >  {
> >  	struct mem_cgroup *mem, *mem_over_limit;
> >  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> >  	struct res_counter *fail_res;
> > -	int csize = CHARGE_SIZE;
> > +	int csize = max(page_size, (int) CHARGE_SIZE);
> >  
> we need max() ?

Not sure I understand the question. max(2M, 128k) looks ok.

> I think should skip this.
> And skip this.

as per above, ok.

> Ah..Hmm...this will be much complicated after Nishimura's "task move" method
> is merged. But ok, for this patch itself.

So I hope is that my patch goes in first so I don't have to make the
much more complicated fix ahahaa ;). Just kidding... Well it's up to
you how you want to handle this.

> Thank you! Seems simpler than expected!

You're welcome. Thanks for the review. So how we want to go from here,
you will incorporate those changes yourself so I only have to maintain
the huge_memory.c part that depends on the above? The above is
transparent hugepage agnostic. For the time being I guess I am forced
to also keep it in my patchset otherwise kernel would fail if somebody
uses mem cgroup, but the ideal is to keep this patch in sync and I
drop it as soon as it goes in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
