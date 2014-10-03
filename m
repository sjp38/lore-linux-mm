Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0CC6B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 11:36:35 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2637923pdi.5
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 08:36:35 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hv6si7617603pbc.0.2014.10.03.08.36.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 08:36:33 -0700 (PDT)
Date: Fri, 3 Oct 2014 19:36:23 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141003153623.GA1162@esperanza>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140926103104.GE29445@esperanza>
 <20141002120748.GA1359@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141002120748.GA1359@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 02, 2014 at 08:07:48AM -0400, Johannes Weiner wrote:
> On Fri, Sep 26, 2014 at 02:31:05PM +0400, Vladimir Davydov wrote:
> > > @@ -1490,12 +1495,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
> > >   */
> > >  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> > >  {
> > > -	unsigned long long margin;
> > > +	unsigned long margin = 0;
> > > +	unsigned long count;
> > > +	unsigned long limit;
> > >  
> > > -	margin = res_counter_margin(&memcg->res);
> > > -	if (do_swap_account)
> > > -		margin = min(margin, res_counter_margin(&memcg->memsw));
> > > -	return margin >> PAGE_SHIFT;
> > > +	count = page_counter_read(&memcg->memory);
> > > +	limit = ACCESS_ONCE(memcg->memory.limit);
> > > +	if (count < limit)
> > 
> > Nit: IMO this looks unwieldier and less readable than
> > res_counter_margin. And two lines below we repeat this.
> 
> Let's add page_counter_margin() once we have a second user ;-) I
> really want to keep this API concise.

This ACCESS_ONCE looks scary to me. I'd keep it in a getter inside the
page_counter core, where the limit is modified. However, since
page_counter_limit() is properly documented now, I don't insist.

[...]
> > > +/**
> > > + * page_counter_try_charge - try to hierarchically charge pages
> > > + * @counter: counter
> > > + * @nr_pages: number of pages to charge
> > > + * @fail: points first counter to hit its limit, if any
> > > + *
> > > + * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> > > + * its ancestors has hit its limit.
> > > + */
> > > +int page_counter_try_charge(struct page_counter *counter,
> > > +			    unsigned long nr_pages,
> > > +			    struct page_counter **fail)
> > > +{
> > > +	struct page_counter *c;
> > > +
> > > +	for (c = counter; c; c = c->parent) {
> > > +		long new;
> > > +		/*
> > > +		 * Charge speculatively to avoid an expensive CAS.  If
> > > +		 * a bigger charge fails, it might falsely lock out a
> > > +		 * racing smaller charge and send it into reclaim
> > > +		 * eraly, but the error is limited to the difference
> > 
> > Nit: s/eraly/early
> 
> Corrected, thanks.
> 
> > > +		 * between the two sizes, which is less than 2M/4M in
> > > +		 * case of a THP locking out a regular page charge.
> > > +		 */
> > > +		new = atomic_long_add_return(nr_pages, &c->count);
> > > +		if (new > c->limit) {
> > > +			atomic_long_sub(nr_pages, &c->count);
> > > +			/*
> > > +			 * This is racy, but the failcnt is only a
> > > +			 * ballpark metric anyway.
> > > +			 */
> > 
> > I still don't think that the failcnt is completely useless. As I
> > mentioned previously, it can be used to check whether the workload is
> > behaving badly due to memcg limits or for some other reason. And I don't
> > see why it couldn't be atomic. This isn't a show stopper though.
> 
> I'm not saying it's useless, just that this level of accuracy should
> be sufficient.  Wouldn't you agree?  Making it atomic wouldn't be a
> problem, either, of course, it's just that it adds more code and
> wrapper indirections for little benefit.

True, but the fact that an attempt to reset failcnt may silently fail
gives me a shiver. OTOH, if the reset functionality is going to be
obsoleted in cgroup-v2, it might not be an issue.

> > > +			c->failcnt++;
> > > +			*fail = c;
> > > +			goto failed;
> > > +		}
> > > +		/*
> > > +		 * This is racy, but with the per-cpu caches on top
> > > +		 * it's just a ballpark metric anyway; and with lazy
> > > +		 * cache reclaim, the majority of workloads peg the
> > > +		 * watermark to the group limit soon after launch.
> > 
> > Not for kmem, I think.
> 
> Ah, good point.  Regardless, the level of accuracy should be
> sufficient here as well, so I'm going to update the comment, ok?

I think so.

> > > +/**
> > > + * page_counter_limit - limit the number of pages allowed
> > > + * @counter: counter
> > > + * @limit: limit to set
> > > + *
> > > + * Returns 0 on success, -EBUSY if the current number of pages on the
> > > + * counter already exceeds the specified limit.
> > > + *
> > > + * The caller must serialize invocations on the same counter.
> > > + */
> > > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > > +{
> > > +	for (;;) {
> > > +		unsigned long old;
> > > +		long count;
> > > +
> > > +		count = atomic_long_read(&counter->count);
> > > +
> > > +		old = xchg(&counter->limit, limit);
> > 
> > Why do you use xchg here?
> > 
> > > +
> > > +		if (atomic_long_read(&counter->count) != count) {
> > > +			counter->limit = old;
> > > +			continue;
> > > +		}
> > > +
> > > +		if (count > limit) {
> > > +			counter->limit = old;
> > > +			return -EBUSY;
> > > +		}
> > 
> > I have a suspicion that this can race with page_counter_try_charge.
> > Look, access to c->limit is not marked as volatile in try_charge so the
> > compiler is allowed to issue read only once, in the very beginning of
> > the try_charge function. Then try_charge may succeed after the limit was
> > actually updated to a smaller value.
> > 
> > Strictly speaking, using ACCESS_ONCE in try_charge wouldn't be enough
> > AFAIU. There must be memory barriers here and there.
> 
> The barriers are implied in change-return atomics, which is why there
> is an xchg.  But it's clear that this needs to be documented.  This?:

With the comments it looks correct to me, but I wonder if we can always
rely on implicit memory barriers issued by atomic ops. Are there any
archs where it doesn't hold?

> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index 4f2321d5293e..a4b220fe8ebc 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -75,6 +75,12 @@ int page_counter_try_charge(struct page_counter *counter,
>  		 * early, but the error is limited to the difference
>  		 * between the two sizes, which is less than 2M/4M in
>  		 * case of a THP locking out a regular page charge.
> +		 *
> +		 * The atomic_long_add_return() implies a full memory
> +		 * barrier between incrementing the count and reading
> +		 * the limit.  When racing with page_counter_limit(),
> +		 * we either see the new limit or the setter sees the
> +		 * counter has changed and retries.
>  		 */
>  		new = atomic_long_add_return(nr_pages, &c->count);
>  		if (new > c->limit) {
> @@ -145,7 +151,15 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
>  		long count;
>  
>  		count = atomic_long_read(&counter->count);
> -
> +		/*
> +		 * The xchg implies two full memory barriers before
> +		 * and after, so the read-swap-read is ordered and
> +		 * ensures coherency with page_counter_try_charge():
> +		 * that function modifies the count before checking
> +		 * the limit, so if it sees the old limit, we see the
> +		 * modified counter and retry.  This guarantees we
> +		 * never successfully set a limit below the counter.
> +		 */
>  		old = xchg(&counter->limit, limit);
>  
>  		if (atomic_long_read(&counter->count) != count) {
> 
[...]

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
