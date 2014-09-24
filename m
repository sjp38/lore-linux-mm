Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 50DC56B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:02:25 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id et14so8226241pad.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:02:25 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ro17si4018008pab.106.2014.09.24.01.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 01:02:24 -0700 (PDT)
Date: Wed, 24 Sep 2014 12:02:08 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140924080208.GN18526@esperanza>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
 <20140922185736.GB6630@cmpxchg.org>
 <20140923110634.GH18526@esperanza>
 <20140923132801.GA14302@cmpxchg.org>
 <20140923152150.GL18526@esperanza>
 <20140923170525.GA28460@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140923170525.GA28460@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 23, 2014 at 01:05:25PM -0400, Johannes Weiner wrote:
> On Tue, Sep 23, 2014 at 07:21:50PM +0400, Vladimir Davydov wrote:
> > On Tue, Sep 23, 2014 at 09:28:01AM -0400, Johannes Weiner wrote:
> > > On Tue, Sep 23, 2014 at 03:06:34PM +0400, Vladimir Davydov wrote:
[...]
> > > > Anyway, I still don't think it's a good idea to keep all the definitions
> > > > in the same file. memcontrol.c is already huge. Adding more code to it
> > > > is not desirable, especially if it can naturally live in a separate
> > > > file. And since the page_counter is independent of the memcg core and
> > > > *looks* generic, I believe we should keep it separately.
> > > 
> > > It's less code than what I just deleted, and half of it seems
> > > redundant when integrated into memcg.  This code would benefit a lot
> > > from being part of memcg, and memcg could reduce its public API.
> > 
> > I think I understand. You are afraid that other users of the
> > page_counter will show up one day, and you won't be able to modify its
> > API freely. That's reasonable. But we can solve it while still keeping
> > page_counter separately. For example, put the header to mm/ and state
> > clearly that it's for memcontrol.c and nobody is allowed to use it w/o a
> > special permission.
> > 
> > My point is that it's easier to maintain the code divided in logical
> > parts. And page_counter seems to be such a logical part.
> 
> It's not about freely changing it, it's that there is no user outside
> of memory controlling proper, and there is none in sight.
> 
> What makes memcontrol.c hard to deal with is that different things are
> interspersed.  The page_counter is in its own little section in there,
> and the compiler can optimize and inline the important fastpaths.

I'm afraid we may end up like kernel/sched, which had been staying as a
bunch of .c files included one into another for a long time until it was
finally split properly into logical parts.

> > Coming to think about placing page_counter.h to mm/, another question
> > springs into my mind. Why do you force kmem.tcp code to use the
> > page_counter instead of the res_counter? Nobody seems to use it and it
> > should pass away sooner or later. May be it's worth leaving kmem.tcp
> > using res_counter? I think we could isolate kmem.tcp under a separate
> > config option depending on the RES_COUNTER, and mark them both as
> > deprecated somehow.
> 
> What we usually do is keep changing deprecated or unused code with
> minimal/compile-only testing.  Eventually somebody will notice that
> something major broke while doing this but that noone has complained
> in months or even years, at which point we remove it.
> 
> I'm curious why you reach the conclusion that we should string *more*
> code along for unused interfaces, rather than less?

This would reduce the patch footprint. The code left (res_counters)
would be disabled by default anyway so it wouldn't result in the binary
growth. And it wouldn't really affect the code base, because it lives
peacefully in a separate file. OTOH this would allow you to make
page_counter private to memcontrol.c sooner, w/o waiting until kmem.tcp
is gone.

> > > > > > > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > > > > > > +			struct page_counter **fail);
> > > > > > > +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> > > > > > > +int page_counter_limit(struct page_counter *counter, unsigned long limit);
> > > > > > 
> > > > > > Hmm, why not page_counter_set_limit?
> > > > > 
> > > > > Limit is used as a verb here, "to limit".  Getters and setters are
> > > > > usually wrappers around unusual/complex data structure access,
> > > > 
> > > > Not necessarily. Look at percpu_counter_read e.g. It's a one-line
> > > > getter, which we could easily live w/o, but still it's there.
> > > 
> > > It abstracts an unusual and error-prone access to a counter value,
> > > i.e. reading an unsigned quantity out of a signed variable.
> > 
> > Wait, percpu_counter_read retval has type s64 and it returns
> > percpu_counter->count, which is also s64. So it's a 100% equivalent of
> > plain reading of percpu_counter->count.
> 
> My bad, I read page_counter instead of percpu_counter.  Nonetheless, I
> did add page_counter_read().
> 
> > > > > but this function does a lot more, so I'm not fond of _set_limit().
> > > > 
> > > > Nevertheless, everything it does can be perfectly described in one
> > > > sentence "it tries to set the new value of the limit", so it does
> > > > function as a setter. And if there's a setter, there must be a getter
> > > > IMO.
> > > 
> > > That's oversimplifying things.  Setting a limit requires enforcing a
> > > whole bunch of rules and synchronization, whereas reading a limit is
> > > accessing an unsigned long.
> > 
> > Let's look at percpu_counter once again (excuse me for sticking to it,
> > but it seems to be a good example): percpu_counter_set requires
> > enforcing a whole bunch of rules and synchronization, whereas reading
> > percpu_counter value is accessing an s64. Nevertheless, they're
> > *semantically* a getter and a setter. The same is fair for the
> > page_counter IMO.
> > 
> > I don't want to enforce you to introduce the getter, it's not that
> > important to me. Just reasoning.
> 
> You can always find such comparisons, but the only thing that counts
> is the engineering merit, which I don't see for the page limit.
> 
> percpu_counter_read() is more obvious, because it's an API that is
> expected to be widely used, and the "counter" is actually a complex
> data structure.  That accessor might choose to do postprocessing like
> underflow or percpu-variance correction at some point, and then it can
> change callers all over the tree in a single place.
> 
> None of this really applies to the page counter limit, however.

OK, you convinced me.

> > > > > > >  		break;
> > > > > > >  	case RES_FAILCNT:
> > > > > > > -		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> > > > > > > +		counter->limited = 0;
> > > > > > 
> > > > > > page_counter_reset_failcnt?
> > > > > 
> > > > > That would be more obscure than counter->failcnt = 0, I think.
> > > > 
> > > > There's one thing that bothers me about this patch. Before, all the
> > > > functions operating on res_counter were mutually smp-safe, now they
> > > > aren't. E.g. if the failcnt reset races with the falcnt increment from
> > > > page_counter_try_charge, the reset might be skipped. You only use the
> > > > atomic type for the counter, but my guess is that failcnt and watermark
> > > > should be atomic too, at least if we're not going to get rid of them
> > > > soon. Otherwise, it should be clearly stated that failcnt and watermark
> > > > are racy.
> > > 
> > > It's fair enough that the raciness should be documented, but both
> > > counters are such roundabout metrics to begin with that it really
> > > doesn't matter.  What's the difference between a failcnt of 590 and
> > > 600 in practical terms?  And what does it matter if the counter
> > > watermark is off by a few pages when there are per-cpu caches on top
> > > of the counters, and the majority of workloads peg the watermark to
> > > the limit during startup anyway?
> > 
> > Suppose failcnt=42000. The user resets it and gets 42001 instead of 0.
> > That's a huge difference.
> 
> I guess that's true, but I still have a really hard time caring.  Who
> resets this in the middle of ongoing execution?  Who resets this at
> all instead of just comparing before/after snapshots, like with all
> other mm stats?  And is anybody even using these pointless metrics?

Don't know about the watermark, but the failcnt can be really useful
while investigating why your container started to behave badly. Also,
they might be used for testing that memcg limits work properly. Not sure
if anybody would need to reset it though.

> I'm inclined to just put stop_machine() into the reset functions...

I don't see why making it atomic could be worse. Anyway, I think this
means we need a getter and reset functions for them, because they ain't
as trivial as the limit.

> > > > > > > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > > > > > > +{
> > > > > > > +	for (;;) {
> > > > > > > +		unsigned long count;
> > > > > > > +		unsigned long old;
> > > > > > > +
> > > > > > > +		count = atomic_long_read(&counter->count);
> > > > > > > +
> > > > > > > +		old = xchg(&counter->limit, limit);
> > > > > > > +
> > > > > > > +		if (atomic_long_read(&counter->count) != count) {
> > > > > > > +			counter->limit = old;
> > > > > > 
> > > > > > I wonder what can happen if two threads execute this function
> > > > > > concurrently... or may be it's not supposed to be smp-safe?
> > > > > 
> > > > > memcg already holds the set_limit_mutex here.  I updated the tcp and
> > > > > hugetlb controllers accordingly to take limit locks as well.
> > > > 
> > > > I would prefer page_counter to handle it internally, because we won't
> > > > need the set_limit_mutex once memsw is converted to plain swap
> > > > accounting.
> > > >
> > > > Besides, memcg_update_kmem_limit doesn't take it. Any chance to
> > > > achieve that w/o spinlocks, using only atomic variables?
> > > 
> > > We still need it to serialize concurrent access to the memory limit,
> > > and I updated the patch to have kmem take it as well.  It's such a
> > > cold path that using a lockless scheme and worrying about coherency
> > > between updates is not worth it, I think.
> > 
> > OK, it's not that important actually. Please state explicitly in the
> > comment to the function definition that it needs external
> > synchronization then.
> 
> Yeah, I documented everything now.

Thank you.

> How about the following update?  Don't be thrown by the
> page_counter_cancel(), I went back to it until we find something more
> suitable.  But as long as it's documented and has only 1.5 callsites,
> it shouldn't matter all that much TBH.

A couple of minor comments inline.

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ec2210965686..70839678d805 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -65,18 +65,32 @@
>  
>  #include <trace/events/vmscan.h>
>  
> -int page_counter_sub(struct page_counter *counter, unsigned long nr_pages)
> +/**
> + * page_counter_cancel - take pages out of the local counter
> + * @counter: counter
> + * @nr_pages: number of pages to cancel
> + *
> + * Returns whether there are remaining pages in the counter.
> + */
> +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
>  {
>  	long new;
>  
>  	new = atomic_long_sub_return(nr_pages, &counter->count);
>  
> -	if (WARN_ON(unlikely(new < 0)))
> -		atomic_long_set(&counter->count, 0);
> +	if (WARN_ON_ONCE(unlikely(new < 0)))

WARN_ON is unlikely by itself, no need to include yet another one
inside.

> +		atomic_long_add(nr_pages, &counter->count);
>  
>  	return new > 0;
>  }
>  
> +/**
> + * page_counter_charge - hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + *
> + * NOTE: This may exceed the configured counter limits.
> + */
>  void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
>  {
>  	struct page_counter *c;
> @@ -91,6 +105,15 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
>  	}
>  }
>  
> +/**
> + * page_counter_try_charge - try to hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + * @fail: points first counter to hit its limit, if any
> + *
> + * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> + * its ancestors has hit its limit.
> + */
>  int page_counter_try_charge(struct page_counter *counter,
>  			    unsigned long nr_pages,
>  			    struct page_counter **fail)
> @@ -98,37 +121,44 @@ int page_counter_try_charge(struct page_counter *counter,
>  	struct page_counter *c;
>  
>  	for (c = counter; c; c = c->parent) {
> -		for (;;) {
> -			long count;
> -			long new;
> -
> -			count = atomic_long_read(&c->count);
> -
> -			new = count + nr_pages;
> -			if (new > c->limit) {
> -				c->failcnt++;
> -				*fail = c;
> -				goto failed;
> -			}
> -
> -			if (atomic_long_cmpxchg(&c->count, count, new) != count)
> -				continue;
> -
> -			if (new > c->watermark)
> -				c->watermark = new;
> +		long new;
>  
> -			break;
> +		new = atomic_long_add_return(nr_pages, &c->count);
> +		if (new > c->limit) {

I'd also added a comment explaining that this is racy too, and may
result in false-positives, but that this isn't critical for our use
case, as you pointed out in your previous e-mail. Just to forestall
further questions.

> +			atomic_long_sub(nr_pages, &c->count);
> +			/*
> +			 * This is racy, but the failcnt is only a
> +			 * ballpark metric anyway.
> +			 */
> +			c->failcnt++;
> +			*fail = c;
> +			goto failed;
>  		}
> +		/*
> +		 * This is racy, but with the per-cpu caches on top
> +		 * this is a ballpark metric as well, and with lazy
> +		 * cache reclaim, the majority of workloads peg the
> +		 * watermark to the group limit soon after launch.
> +		 */
> +		if (new > c->watermark)
> +			c->watermark = new;
>  	}
>  	return 0;
>  
>  failed:
>  	for (c = counter; c != *fail; c = c->parent)
> -		page_counter_sub(c, nr_pages);
> +		page_counter_cancel(c, nr_pages);
>  
>  	return -ENOMEM;
>  }
[...]

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
