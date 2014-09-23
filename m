Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 25DBE6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:22:15 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id m1so4670210oag.33
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 08:22:12 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zq1si6819832pac.44.2014.09.23.08.22.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 08:22:10 -0700 (PDT)
Date: Tue, 23 Sep 2014 19:21:50 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140923152150.GL18526@esperanza>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
 <20140922185736.GB6630@cmpxchg.org>
 <20140923110634.GH18526@esperanza>
 <20140923132801.GA14302@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140923132801.GA14302@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 23, 2014 at 09:28:01AM -0400, Johannes Weiner wrote:
> On Tue, Sep 23, 2014 at 03:06:34PM +0400, Vladimir Davydov wrote:
> > On Mon, Sep 22, 2014 at 02:57:36PM -0400, Johannes Weiner wrote:
> > > On Mon, Sep 22, 2014 at 06:41:58PM +0400, Vladimir Davydov wrote:
> > > > On Fri, Sep 19, 2014 at 09:22:08AM -0400, Johannes Weiner wrote:
> > > > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > > > index 19df5d857411..bf8fb1a05597 100644
> > > > > --- a/include/linux/memcontrol.h
> > > > > +++ b/include/linux/memcontrol.h
> > > > > @@ -54,6 +54,38 @@ struct mem_cgroup_reclaim_cookie {
> > > > >  };
> > > > >  
> > > > >  #ifdef CONFIG_MEMCG
> > > > > +
> > > > > +struct page_counter {
> > > > 
> > > > I'd place it in a separate file, say
> > > > 
> > > > 	include/linux/page_counter.h
> > > > 	mm/page_counter.c
> > > > 
> > > > just to keep mm/memcontrol.c clean.
> > > 
> > > The page counters are the very core of the memory controller and, as I
> > > said to Michal, I want to integrate the hugetlb controller into memcg
> > > as well, at which point there won't be any outside users anymore.  So
> > > I think this is the right place for it.
> > 
> > Hmm, there might be memcg users out there that don't want to pay for
> > hugetlb accounting. Or is the overhead supposed to be negligible?
> 
> Yes.  But if it gets in the way, it creates pressure to optimize it.

There always will be an overhead no matter how we optimize it.

I think we should only merge them if it could really help simplify the
code, for instance if they were dependant on each other. Anyway, I'm not
an expert in the hugetlb cgroup, so I can't judge whether it's good or
not. I believe you should raise this topic separately and see if others
agree with you.

> That's the same reason why I've been trying to integrate memcg into
> the rest of the VM for over two years now - aside from resulting in
> much more unified code, it forces us to compete, and it increases our
> testing exposure by several orders of magnitude.
> 
> The only reason we are discussing lockless page counters right now is
> because we got rid of "memcg specialness" and exposed res_counters to
> the rest of the world; and boy did that instantly raise the bar on us.
> 
> > Anyway, I still don't think it's a good idea to keep all the definitions
> > in the same file. memcontrol.c is already huge. Adding more code to it
> > is not desirable, especially if it can naturally live in a separate
> > file. And since the page_counter is independent of the memcg core and
> > *looks* generic, I believe we should keep it separately.
> 
> It's less code than what I just deleted, and half of it seems
> redundant when integrated into memcg.  This code would benefit a lot
> from being part of memcg, and memcg could reduce its public API.

I think I understand. You are afraid that other users of the
page_counter will show up one day, and you won't be able to modify its
API freely. That's reasonable. But we can solve it while still keeping
page_counter separately. For example, put the header to mm/ and state
clearly that it's for memcontrol.c and nobody is allowed to use it w/o a
special permission.

My point is that it's easier to maintain the code divided in logical
parts. And page_counter seems to be such a logical part.

Coming to think about placing page_counter.h to mm/, another question
springs into my mind. Why do you force kmem.tcp code to use the
page_counter instead of the res_counter? Nobody seems to use it and it
should pass away sooner or later. May be it's worth leaving kmem.tcp
using res_counter? I think we could isolate kmem.tcp under a separate
config option depending on the RES_COUNTER, and mark them both as
deprecated somehow.

> There are tangible costs associated with having a separate pile of
> bitrot depend on our public interface.  Over 90% of the recent changes
> to the hugetlb controller were done by Tejun as part of changing the
> cgroup interfaces.  And I went through several WTFs switching that
> code to the new page counter API.  The cost of maintaining a unified
> codebase is negligible in comparison.
> 
> > > > > +	atomic_long_t count;
> > > > > +	unsigned long limit;
> > > > > +	struct page_counter *parent;
> > > > > +
> > > > > +	/* legacy */
> > > > > +	unsigned long watermark;
> > > > > +	unsigned long limited;
> > > > 
> > > > IMHO, failcnt would fit better.
> > > 
> > > I never liked the failcnt name, but also have to admit that "limited"
> > > is crap.  Let's leave it at failcnt for now.
> > > 
> > > > > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
> > > > 
> > > > When I first saw this function, I couldn't realize by looking at its
> > > > name what it's intended to do. I think
> > > > 
> > > > 	page_counter_cancel_local_charge()
> > > > 
> > > > would fit better.
> > > 
> > > It's a fairly unwieldy name.  How about page_counter_sub()?  local_sub()?
> > 
> > The _sub suffix doesn't match _charge/_uncharge. May be
> > page_counter_local_uncharge, or _uncharge_local?
> 
> I always think of a charge as the full hierarchical quantity, but this
> function only clips that one counter and so anything "uncharge" sounds
> terribly wrong to me.  But I can't think of anything great, either.
> 
> Any more ideas? :)

Not yet :(

> > > > > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > > > > +			struct page_counter **fail);
> > > > > +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> > > > > +int page_counter_limit(struct page_counter *counter, unsigned long limit);
> > > > 
> > > > Hmm, why not page_counter_set_limit?
> > > 
> > > Limit is used as a verb here, "to limit".  Getters and setters are
> > > usually wrappers around unusual/complex data structure access,
> > 
> > Not necessarily. Look at percpu_counter_read e.g. It's a one-line
> > getter, which we could easily live w/o, but still it's there.
> 
> It abstracts an unusual and error-prone access to a counter value,
> i.e. reading an unsigned quantity out of a signed variable.

Wait, percpu_counter_read retval has type s64 and it returns
percpu_counter->count, which is also s64. So it's a 100% equivalent of
plain reading of percpu_counter->count.

> > > but this function does a lot more, so I'm not fond of _set_limit().
> > 
> > Nevertheless, everything it does can be perfectly described in one
> > sentence "it tries to set the new value of the limit", so it does
> > function as a setter. And if there's a setter, there must be a getter
> > IMO.
> 
> That's oversimplifying things.  Setting a limit requires enforcing a
> whole bunch of rules and synchronization, whereas reading a limit is
> accessing an unsigned long.

Let's look at percpu_counter once again (excuse me for sticking to it,
but it seems to be a good example): percpu_counter_set requires
enforcing a whole bunch of rules and synchronization, whereas reading
percpu_counter value is accessing an s64. Nevertheless, they're
*semantically* a getter and a setter. The same is fair for the
page_counter IMO.

I don't want to enforce you to introduce the getter, it's not that
important to me. Just reasoning.

> In general I agree that we should strive for symmetry and follow the
> principle of least surprise, but in terms of complexity these two
> operations are very different, and providing a getter on principle
> would not actually improve readability in this case.
> 
> > > > > @@ -1218,34 +1217,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
> > > > >  					      unsigned long amt,
> > > > >  					      int *parent_status)
> > > > >  {
> > > > > -	struct res_counter *fail;
> > > > > -	int ret;
> > > > > +	page_counter_charge(&prot->memory_allocated, amt, NULL);
> > > > >  
> > > > > -	ret = res_counter_charge_nofail(&prot->memory_allocated,
> > > > > -					amt << PAGE_SHIFT, &fail);
> > > > > -	if (ret < 0)
> > > > > +	if (atomic_long_read(&prot->memory_allocated.count) >
> > > > > +	    prot->memory_allocated.limit)
> > > > 
> > > > I don't like your equivalent of res_counter_charge_nofail.
> > > > 
> > > > Passing NULL to page_counter_charge might be useful if one doesn't have
> > > > a back-off strategy, but still want to fail on hitting the limit. With
> > > > your interface the user must pass something to the function then, which
> > > > isn't convenient.
> > > > 
> > > > Besides, it depends on the internal implementation of the page_counter
> > > > struct. I'd encapsulate this.
> > > 
> > > Thinking about this more, I don't like my version either; not because
> > > of how @fail must always be passed, but because of how it changes the
> > > behavior.  I changed the API to
> > > 
> > > void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
> > > int page_counter_try_charge(struct page_counter *counter, unsigned long nr_pages,
> > >                             struct page_counter **fail);
> > 
> > That looks good to me. I would also add something like
> > 
> >   bool page_counter_exceeds_limit(struct page_counter *counter);
> > 
> > to use instead of this
> > 
> > +	if (atomic_long_read(&prot->memory_allocated.count) >
> > +	    prot->memory_allocated.limit)
> 
> I really don't see the point in obscuring a simple '<' behind a
> function call.  What follows this is that somebody adds it for the
> soft limit, and later for any other type of relational comparison.

I think I agree with you at this point.

> > > > >  		break;
> > > > >  	case RES_FAILCNT:
> > > > > -		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> > > > > +		counter->limited = 0;
> > > > 
> > > > page_counter_reset_failcnt?
> > > 
> > > That would be more obscure than counter->failcnt = 0, I think.
> > 
> > There's one thing that bothers me about this patch. Before, all the
> > functions operating on res_counter were mutually smp-safe, now they
> > aren't. E.g. if the failcnt reset races with the falcnt increment from
> > page_counter_try_charge, the reset might be skipped. You only use the
> > atomic type for the counter, but my guess is that failcnt and watermark
> > should be atomic too, at least if we're not going to get rid of them
> > soon. Otherwise, it should be clearly stated that failcnt and watermark
> > are racy.
> 
> It's fair enough that the raciness should be documented, but both
> counters are such roundabout metrics to begin with that it really
> doesn't matter.  What's the difference between a failcnt of 590 and
> 600 in practical terms?  And what does it matter if the counter
> watermark is off by a few pages when there are per-cpu caches on top
> of the counters, and the majority of workloads peg the watermark to
> the limit during startup anyway?

Suppose failcnt=42000. The user resets it and gets 42001 instead of 0.
That's a huge difference.

> > Anyway, that's where the usefulness of res_counter_reset_failcnt
> > reveals. If one decides to make it race-free one day, they won't have to
> > modify code outside the page_counter definition.
> 
> A major problem with cgroups overall was that it was designed for a
> lot of hypotheticals that are irrelevant in practice but incur very
> high costs.  Multiple orthogonal hierarchies is the best example, but
> using locked byte counters that can be used to account all manner of
> resources, with accurate watermarks and limit failures, when all we
> need to count is pages and nobody cares about accurate watermarks and
> limit failures, is another one.
> 
> It's very unlikely that failcnt and watermark will have to me atomic
> ever again, so there is very little hypothetical upside to wrapping a
> '= 0' in a function.  But such indirection comes at a real cost.

Hmm, why? I mean why could making failcnt atomic be problematic? IMO it
wouldn't complicate the code, neither would it affect performance. And
why does page_counter_reset_failcnt() come at a real cost? It's +4 lines
to your patch.

> > > > > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > > > > +{
> > > > > +	for (;;) {
> > > > > +		unsigned long count;
> > > > > +		unsigned long old;
> > > > > +
> > > > > +		count = atomic_long_read(&counter->count);
> > > > > +
> > > > > +		old = xchg(&counter->limit, limit);
> > > > > +
> > > > > +		if (atomic_long_read(&counter->count) != count) {
> > > > > +			counter->limit = old;
> > > > 
> > > > I wonder what can happen if two threads execute this function
> > > > concurrently... or may be it's not supposed to be smp-safe?
> > > 
> > > memcg already holds the set_limit_mutex here.  I updated the tcp and
> > > hugetlb controllers accordingly to take limit locks as well.
> > 
> > I would prefer page_counter to handle it internally, because we won't
> > need the set_limit_mutex once memsw is converted to plain swap
> > accounting.
> >
> > Besides, memcg_update_kmem_limit doesn't take it. Any chance to
> > achieve that w/o spinlocks, using only atomic variables?
> 
> We still need it to serialize concurrent access to the memory limit,
> and I updated the patch to have kmem take it as well.  It's such a
> cold path that using a lockless scheme and worrying about coherency
> between updates is not worth it, I think.

OK, it's not that important actually. Please state explicitly in the
comment to the function definition that it needs external
synchronization then.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
