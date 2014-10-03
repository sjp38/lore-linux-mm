Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C25D46B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 10:50:45 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so2354703wib.11
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 07:50:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd2si9056254wjb.117.2014.10.03.07.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 07:50:44 -0700 (PDT)
Date: Fri, 3 Oct 2014 16:50:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141003145042.GC4816@dhcp22.suse.cz>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140930110622.GB4456@dhcp22.suse.cz>
 <20141002150135.GA1394@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141002150135.GA1394@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 02-10-14 11:01:35, Johannes Weiner wrote:
> Hi Michal,
> 
> On Tue, Sep 30, 2014 at 01:06:22PM +0200, Michal Hocko wrote:
> > On Wed 24-09-14 11:43:08, Johannes Weiner wrote:
> > > Memory is internally accounted in bytes, using spinlock-protected
> > > 64-bit counters, even though the smallest accounting delta is a page.
> > > The counter interface is also convoluted and does too many things.
> > > 
> > > Introduce a new lockless word-sized page counter API, then change all
> > > memory accounting over to it and remove the old one.  The translation
> > > from and to bytes then only happens when interfacing with userspace.
> > > 
> > > Aside from the locking costs, this gets rid of the icky unsigned long
> > > long types in the very heart of memcg, which is great for 32 bit and
> > > also makes the code a lot more readable.
> > 
> > Please describe the usual use pattern of the API. It is much easier to
> > read it here than pulling it out from the source.
> 
> Could you explain what you are looking for?  I can't find any examples
> in git log that I could base this on.

What about something like the following:

page_counter to res_counter compatibility table:
page_counter_try_charge -> res_counter_charge
page_counter_uncharge -> res_counter_uncharge
page_counter_charge -> res_counter_charge_nofail.

page_counter_cancel -> res_counter_uncharge_until except it is less
generic. The res_counter version allowed to uncharge up to a given
parent. This API has never been used in such a generic way. It was in
fact only used as the local uncharge so there is no need for full
compatibility here.

page_counter_limit -> res_counter_set_limit except it expects an
external locking to protect from multiple updaters.

page_counter_memparse -> res_counter_memparse_write_strategy.

[...]
> > > @@ -0,0 +1,49 @@
> > > +#ifndef _LINUX_PAGE_COUNTER_H
> > > +#define _LINUX_PAGE_COUNTER_H
> > > +
> > > +#include <linux/atomic.h>
> > > +
> > > +struct page_counter {
> > > +	atomic_long_t count;
> > > +	unsigned long limit;
> > > +	struct page_counter *parent;
> > > +
> > > +	/* legacy */
> > > +	unsigned long watermark;
> > 
> > The name suggest this is a restriction not a highest usage mark.
> > max_count would be less confusing.
> 
> Interesting, where do you get restriction?  We use the watermark term
> all over the kernel to mean "highest usage"; it's based on this:
> 
> http://en.wikipedia.org/wiki/High_water_mark

You are right. I just managed to confuse myself.

> > > +	unsigned long failcnt;
> > > +};
> > > +
> > > +#if BITS_PER_LONG == 32
> > > +#define PAGE_COUNTER_MAX LONG_MAX
> > > +#else
> > > +#define PAGE_COUNTER_MAX (LONG_MAX / PAGE_SIZE)
> > > +#endif
> > 
> > It is not clear to me why you need a separate definitions here. LONG_MAX
> > seems to be good for both 32b and 64b.
> 
> Because we need space to convert these to 64-bit bytes for the user
> interface.  On 32 bit, we naturally have another 33 to spare above
> LONG_MAX, but on 64 bit we need to reserve the necessary bits.
> 
> (u64)PAGE_COUNTER_MAX * PAGE_SIZE can't overflow.

Right and that's why I was so confused by the definition because
(u64)LONG_MAX * PAGE_SIZE doesn't overflow and all the places which
convert to bytes cast to u64 explicitly. What you did is less error
prone of course. Thanks for the clarification.

> > [...]
> > > diff --git a/mm/page_counter.c b/mm/page_counter.c
> > > new file mode 100644
> > > index 000000000000..51c45921b8d1
> > > --- /dev/null
> > > +++ b/mm/page_counter.c
> > > @@ -0,0 +1,191 @@
> > > +/*
> > > + * Lockless hierarchical page accounting & limiting
> > > + *
> > > + * Copyright (C) 2014 Red Hat, Inc., Johannes Weiner
> > > + */
> > > +#include <linux/page_counter.h>
> > > +#include <linux/atomic.h>
> > > +
> > > +/**
> > > + * page_counter_cancel - take pages out of the local counter
> > > + * @counter: counter
> > > + * @nr_pages: number of pages to cancel
> > > + *
> > > + * Returns whether there are remaining pages in the counter.
> > > + */
> > > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> > > +{
> > > +	long new;
> > > +
> > > +	new = atomic_long_sub_return(nr_pages, &counter->count);
> > > +
> > 
> > This really deserves a comment IMO. Something like the following:
> > 	/*
> > 	 * Charges and uncharges are always ordered properly from memory
> > 	 * ordering point of view. The only case where underflow can happen
> > 	 * is a mismatched uncharge. Report it and fix it up now rather
> > 	 * than blow up later.
> > 	 */
> > > +	if (WARN_ON_ONCE(new < 0))
> > > +		atomic_long_add(nr_pages, &counter->count);
> > 
> > anyway this doesn't look correct because you can have false positives:
> > [counter->count = 1]
> > 	CPU0					CPU1
> > new = atomic_long_sub_return(THP)
> > 					new = atomic_long_sub_return(1)
> > (new < 0)				(new < 0)
> >   atomic_long_add(THP)			  atomic_add(1)
> > 
> > So we will end up with counter->count = 1 rather than 0. I think you
> > need to use a lock in the slow path. Something like
> > 
> > 	if (new < 0) {
> > 		unsigned long flags;
> > 
> > 		/*
> > 		 * Multiple uncharger might race together and we do not
> > 		 * want to let any of them revert the uncharge just
> > 		 * because a faulty uncharge and the fixup are not
> > 		 * atomic.
> > 		 */
> > 		atomic_lond_add(nr_pages, &counter->count);
> > 
> > 		spin_lock_irqsave(&counter->lock, flags);
> > 		new = atomic_long_sub_return(nr_pages, &counter->count);
> > 		if (WARN_ON(new < 0))
> > 			atomic_long_add(nr_pages, &counter->count);
> > 		spin_unlock_irqrestore(&counter->lock, flags);
> > 	}
> 
> What are we trying to accomplish here?  We know the counter value no
> longer reflects reality when it underflows.  Reverting an unrelated
> charge doesn't change that.  I'm just going to leave the warning in
> there with a comment and then remove the fix-up.

I was merely pointing that the fixup would incorrectly revert even a
correct charge and cause more harm than good in the end. The lock in the
slow path was supposed to help to order racing unchargers but as you are
saying this is still buggy. I agree we simply shouldn't do the fixup.

> > > +/**
> > > + * page_counter_charge - hierarchically charge pages
> > > + * @counter: counter
> > > + * @nr_pages: number of pages to charge
> > > + *
> > > + * NOTE: This may exceed the configured counter limits.
> > 
> > The name is rather awkward. It sounds like a standard way to charge the
> > counter. I would rather stick to _nofail suffix and the following
> > addition to the doc.
> > "
> > Can be called only from contexts where the charge failure cannot be
> > handled. This should be rare and used with extreme caution.
> > "
> 
> We extensively use the do()/try_do() pattern for operations that can
> fail conditionally, and it never implies a standard way - it depends
> on the user which one is used more often.  There are more css_tryget()
> than css_get() for example.
> 
> As per your request, this is now a generic hierarchical page counter
> library, and we may very well grow users that don't even use the
> optional limit feature.  For them, page_counter_charge() is the only
> sensible way to add pages.
> 
> Using this function doesn't require any more or less caution than
> using any other function.  The code just has to make sense.

Fair enough.
 
> > > + */
> > > +void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
> > > +{
> > > +	struct page_counter *c;
> > > +
> > > +	for (c = counter; c; c = c->parent) {
> > > +		long new;
> > > +
> > > +		new = atomic_long_add_return(nr_pages, &c->count);
> > > +		/*
> > > +		 * This is racy, but with the per-cpu caches on top
> > > +		 * it's just a ballpark metric anyway; and with lazy
> > > +		 * cache reclaim, the majority of workloads peg the
> > > +		 * watermark to the group limit soon after launch.
> > > +		 */
> > > +		if (new > c->watermark)
> > > +			c->watermark = new;
> > > +	}
> > > +}
> > > +
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
> > > +		 * between the two sizes, which is less than 2M/4M in
> > > +		 * case of a THP locking out a regular page charge.
> > > +		 */
> > 
> > If this ever turns out to be a problem then we can check the size of the
> > overflow and retry if it is > nr_online_cpus or something like that. Not
> > worth bothering now I guess but definitely good to have this documented.
> > I would even like to have it in the changelog for users bisecting an
> > excessive reclaim because it is easier to find that in the changelog
> > than in the code.
> 
> If a failing THP charge races with a bunch of order-0 allocations they
> will enter reclaim less than 2MB before they would have had to enter
> reclaim anyway.  It's like temporarily lowering the limit by lt 2MB.
> 
> So workloads whose workingsets come within one THP of the limit might
> see temporary increases in reclaim activity when a THP happens to be
> the allocation exceeding the limit.  But THP allocations are not
> reliable in the first place, so anything operating within such a range
> is liable to variation anyway and we'd contribute marginally to the
> noise.  Is this worth bothering?

The point is that a single THP can push out many single page charges on a
machine with many CPUs. The race is quite unlikely due to per-cpu
caching, though.
But, as I've said not worth bothering but good to have it documented.

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
> > Ordering doesn't make much sense to me here. Say you really want to set
> > limit < count. You are effectively pushing all concurrent charges to
> > the reclaim even though you would revert your change and return with
> > EBUSY later on.
> >
> > Wouldn't (count > limit) check make more sense right after the first
> > atomic_long_read?
> > Also the second count check should be sufficient to check > count and
> > retry only when the count has increased.
> > Finally continuous flow of charges can keep this loop running for quite
> > some time and trigger lockup detector. cond_resched before continue
> > would handle that. Something like the following:
> > 
> > 	for (;;) {
> > 		unsigned long old;
> > 		long count;
> > 
> > 		count = atomic_long_read(&counter->count);
> > 		if (count > limit)
> > 			return -EBUSY;
> > 
> > 		old = xchg(&counter->limit, limit);
> > 
> > 		/* Recheck for concurrent charges */
> > 		if (atomic_long_read(&counter->count) > count) {
> > 			counter->limit = old;
> > 			cond_resched();
> > 			continue;
> > 		}
> > 
> > 		return 0;
> > 	}
> 
> This is susceptible to spurious -EBUSY during races with speculative
> charges and uncharges.  My code avoids that by retrying until we set
> the limit without any concurrent counter operations first, before
> moving on to implementing policy and rollback.
> 
> Some reclaim activity caused by a limit that the user is trying to set
> anyway should be okay.  I'd rather have a reliable syscall.

This would be handled on the mem_cgroup_resize_limit layer. We are
retrying reclaim and only back off when the usage increases regardless
the reclaim after several attempts. So I do not think the reliability would
be smaller because of speculative charges.
Anyway, your implementation should be harmless for the memcg because OOM
as a result of a short race is highly improbable.

Hugetlb case is more tricky because a temporarily visible limit would
lead to a SIGBUS even though hugetlb_cgroup_write will and is supposed
to fail with EBUSY. I dunno, whether users decrease limit for hugetlb
and see this as a problem, though.

I have to think about this some more but it seems safer to not update
visible state when we know we should fail.

> But the cond_resched() is a good idea, I'll add that, thanks.
> 
> > > +/**
> > > + * page_counter_memparse - memparse() for page counter limits
> > > + * @buf: string to parse
> > > + * @nr_pages: returns the result in number of pages
> > > + *
> > > + * Returns -EINVAL, or 0 and @nr_pages on success.  @nr_pages will be
> > > + * limited to %PAGE_COUNTER_MAX.
> > > + */
> > > +int page_counter_memparse(const char *buf, unsigned long *nr_pages)
> > > +{
> > > +	char unlimited[] = "-1";
> > > +	char *end;
> > > +	u64 bytes;
> > > +
> > > +	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
> > > +		*nr_pages = PAGE_COUNTER_MAX;
> > > +		return 0;
> > > +	}
> > > +
> > > +	bytes = memparse(buf, &end);
> > > +	if (*end != '\0')
> > > +		return -EINVAL;
> > 
> > res_counter used to round up to the next page boundary and there is no
> > reason to not do the same here.
> 
> The user is specifying an exact number of bytes that she doesn't want
> the cgroup to exceed under the threat of OOM.  I see two options: if
> those few bytes really matter, it would be rude to round up a strict
> upper limit.  If they don't, it's pointless additional code.
> 
> I'm guessing the latter is the case, but either way it doesn't make
> sense to round up.

I thought about it some more and you are right. PAGE_ALIGN is and was
bogus in the original res_counter code as well because it doesn't make
much sense e.g. for hugetlb case. It doesn't make much sense in general
because res_counter/page_counter doesn't know what is the chargeable unit
of the API user. If somebody needs an aligned value it should be done by
the caller.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
