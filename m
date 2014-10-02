Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7166B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 08:07:59 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id gb8so2203786lab.31
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 05:07:58 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ao5si6290817lbc.58.2014.10.02.05.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 05:07:57 -0700 (PDT)
Date: Thu, 2 Oct 2014 08:07:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141002120748.GA1359@cmpxchg.org>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140926103104.GE29445@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140926103104.GE29445@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Vladimir,

On Fri, Sep 26, 2014 at 02:31:05PM +0400, Vladimir Davydov wrote:
> > @@ -1490,12 +1495,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
> >   */
> >  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> >  {
> > -	unsigned long long margin;
> > +	unsigned long margin = 0;
> > +	unsigned long count;
> > +	unsigned long limit;
> >  
> > -	margin = res_counter_margin(&memcg->res);
> > -	if (do_swap_account)
> > -		margin = min(margin, res_counter_margin(&memcg->memsw));
> > -	return margin >> PAGE_SHIFT;
> > +	count = page_counter_read(&memcg->memory);
> > +	limit = ACCESS_ONCE(memcg->memory.limit);
> > +	if (count < limit)
> 
> Nit: IMO this looks unwieldier and less readable than
> res_counter_margin. And two lines below we repeat this.

Let's add page_counter_margin() once we have a second user ;-) I
really want to keep this API concise.

> > +		margin = limit - count;
> > +
> > +	if (do_swap_account) {
> > +		count = page_counter_read(&memcg->memsw);
> > +		limit = ACCESS_ONCE(memcg->memsw.limit);
> > +		if (count < limit)
> > +			margin = min(margin, limit - count);
> > +	}
> > +
> > +	return margin;
> >  }
> >  
> >  int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> [...]
> > @@ -1685,30 +1698,19 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
> >  }
> >  
> >  /*
> > - * Return the memory (and swap, if configured) limit for a memcg.
> > + * Return the memory (and swap, if configured) maximum consumption for a memcg.
> 
> Nit: Why did you change the comment? Now it doesn't seem to be relevant.

Yes, it's a left-over from when I wanted to generally move away from
the term limit due to its ambiguity.  But that's another story, so I
reverted this hunk.

> > +/**
> > + * page_counter_try_charge - try to hierarchically charge pages
> > + * @counter: counter
> > + * @nr_pages: number of pages to charge
> > + * @fail: points first counter to hit its limit, if any
> > + *
> > + * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> > + * its ancestors has hit its limit.
> > + */
> > +int page_counter_try_charge(struct page_counter *counter,
> > +			    unsigned long nr_pages,
> > +			    struct page_counter **fail)
> > +{
> > +	struct page_counter *c;
> > +
> > +	for (c = counter; c; c = c->parent) {
> > +		long new;
> > +		/*
> > +		 * Charge speculatively to avoid an expensive CAS.  If
> > +		 * a bigger charge fails, it might falsely lock out a
> > +		 * racing smaller charge and send it into reclaim
> > +		 * eraly, but the error is limited to the difference
> 
> Nit: s/eraly/early

Corrected, thanks.

> > +		 * between the two sizes, which is less than 2M/4M in
> > +		 * case of a THP locking out a regular page charge.
> > +		 */
> > +		new = atomic_long_add_return(nr_pages, &c->count);
> > +		if (new > c->limit) {
> > +			atomic_long_sub(nr_pages, &c->count);
> > +			/*
> > +			 * This is racy, but the failcnt is only a
> > +			 * ballpark metric anyway.
> > +			 */
> 
> I still don't think that the failcnt is completely useless. As I
> mentioned previously, it can be used to check whether the workload is
> behaving badly due to memcg limits or for some other reason. And I don't
> see why it couldn't be atomic. This isn't a show stopper though.

I'm not saying it's useless, just that this level of accuracy should
be sufficient.  Wouldn't you agree?  Making it atomic wouldn't be a
problem, either, of course, it's just that it adds more code and
wrapper indirections for little benefit.

> > +			c->failcnt++;
> > +			*fail = c;
> > +			goto failed;
> > +		}
> > +		/*
> > +		 * This is racy, but with the per-cpu caches on top
> > +		 * it's just a ballpark metric anyway; and with lazy
> > +		 * cache reclaim, the majority of workloads peg the
> > +		 * watermark to the group limit soon after launch.
> 
> Not for kmem, I think.

Ah, good point.  Regardless, the level of accuracy should be
sufficient here as well, so I'm going to update the comment, ok?

> > +/**
> > + * page_counter_limit - limit the number of pages allowed
> > + * @counter: counter
> > + * @limit: limit to set
> > + *
> > + * Returns 0 on success, -EBUSY if the current number of pages on the
> > + * counter already exceeds the specified limit.
> > + *
> > + * The caller must serialize invocations on the same counter.
> > + */
> > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > +{
> > +	for (;;) {
> > +		unsigned long old;
> > +		long count;
> > +
> > +		count = atomic_long_read(&counter->count);
> > +
> > +		old = xchg(&counter->limit, limit);
> 
> Why do you use xchg here?
> 
> > +
> > +		if (atomic_long_read(&counter->count) != count) {
> > +			counter->limit = old;
> > +			continue;
> > +		}
> > +
> > +		if (count > limit) {
> > +			counter->limit = old;
> > +			return -EBUSY;
> > +		}
> 
> I have a suspicion that this can race with page_counter_try_charge.
> Look, access to c->limit is not marked as volatile in try_charge so the
> compiler is allowed to issue read only once, in the very beginning of
> the try_charge function. Then try_charge may succeed after the limit was
> actually updated to a smaller value.
> 
> Strictly speaking, using ACCESS_ONCE in try_charge wouldn't be enough
> AFAIU. There must be memory barriers here and there.

The barriers are implied in change-return atomics, which is why there
is an xchg.  But it's clear that this needs to be documented.  This?:

diff --git a/mm/page_counter.c b/mm/page_counter.c
index 4f2321d5293e..a4b220fe8ebc 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -75,6 +75,12 @@ int page_counter_try_charge(struct page_counter *counter,
 		 * early, but the error is limited to the difference
 		 * between the two sizes, which is less than 2M/4M in
 		 * case of a THP locking out a regular page charge.
+		 *
+		 * The atomic_long_add_return() implies a full memory
+		 * barrier between incrementing the count and reading
+		 * the limit.  When racing with page_counter_limit(),
+		 * we either see the new limit or the setter sees the
+		 * counter has changed and retries.
 		 */
 		new = atomic_long_add_return(nr_pages, &c->count);
 		if (new > c->limit) {
@@ -145,7 +151,15 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
 		long count;
 
 		count = atomic_long_read(&counter->count);
-
+		/*
+		 * The xchg implies two full memory barriers before
+		 * and after, so the read-swap-read is ordered and
+		 * ensures coherency with page_counter_try_charge():
+		 * that function modifies the count before checking
+		 * the limit, so if it sees the old limit, we see the
+		 * modified counter and retry.  This guarantees we
+		 * never successfully set a limit below the counter.
+		 */
 		old = xchg(&counter->limit, limit);
 
 		if (atomic_long_read(&counter->count) != count) {

> > @@ -126,43 +134,36 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
> >  	return ret ?: nbytes;
> >  }
> >  
> > -static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
> > -{
> > -	struct cg_proto *cg_proto;
> > -
> > -	cg_proto = tcp_prot.proto_cgroup(memcg);
> > -	if (!cg_proto)
> > -		return default_val;
> > -
> > -	return res_counter_read_u64(&cg_proto->memory_allocated, type);
> > -}
> > -
> > -static u64 tcp_read_usage(struct mem_cgroup *memcg)
> > -{
> > -	struct cg_proto *cg_proto;
> > -
> > -	cg_proto = tcp_prot.proto_cgroup(memcg);
> > -	if (!cg_proto)
> > -		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
> > -
> > -	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
> > -}
> > -
> >  static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > +	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
> >  	u64 val;
> >  
> >  	switch (cft->private) {
> >  	case RES_LIMIT:
> > -		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
> > +		if (!cg_proto)
> > +			return PAGE_COUNTER_MAX;
> 
> For compatibility it must be ULLONG_MAX.

If the controller is actually enabled, the maximum settable limit is
PAGE_COUNTER_MAX, so it's probably better to be consistent.  I'm going
out on a limb here and say that this won't break any existing users ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
