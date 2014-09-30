Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CC2AF6B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 07:06:26 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so4013247wib.0
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 04:06:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eg3si9788368wic.35.2014.09.30.04.06.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 04:06:24 -0700 (PDT)
Date: Tue, 30 Sep 2014 13:06:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20140930110622.GB4456@dhcp22.suse.cz>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 11:43:08, Johannes Weiner wrote:
> Memory is internally accounted in bytes, using spinlock-protected
> 64-bit counters, even though the smallest accounting delta is a page.
> The counter interface is also convoluted and does too many things.
> 
> Introduce a new lockless word-sized page counter API, then change all
> memory accounting over to it and remove the old one.  The translation
> from and to bytes then only happens when interfacing with userspace.
> 
> Aside from the locking costs, this gets rid of the icky unsigned long
> long types in the very heart of memcg, which is great for 32 bit and
> also makes the code a lot more readable.

Please describe the usual use pattern of the API. It is much easier to
read it here than pulling it out from the source.

Also I would expect some testing results. Especially on a larger machine
(I guess you rely on Dave here, right?).

Thanks for splitting the original patch and extracting the counter
to a separate file. I think we should add F: mm/page_counter.c under
MEMCG maintenance section.

More comments inline (I only got to page_counter for now and will check
the res_counter replacement in another go)

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/cgroups/memory.txt |   4 +-
>  include/linux/memcontrol.h       |   5 +-
>  include/linux/page_counter.h     |  49 +++
>  include/net/sock.h               |  26 +-
>  init/Kconfig                     |   5 +-
>  mm/Makefile                      |   1 +
>  mm/memcontrol.c                  | 635 ++++++++++++++++++---------------------
>  mm/page_counter.c                | 191 ++++++++++++
>  net/ipv4/tcp_memcontrol.c        |  87 +++---
>  9 files changed, 598 insertions(+), 405 deletions(-)
>  create mode 100644 include/linux/page_counter.h
>  create mode 100644 mm/page_counter.c
> 
[...]
> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
> new file mode 100644
> index 000000000000..d92d18949474
> --- /dev/null
> +++ b/include/linux/page_counter.h
> @@ -0,0 +1,49 @@
> +#ifndef _LINUX_PAGE_COUNTER_H
> +#define _LINUX_PAGE_COUNTER_H
> +
> +#include <linux/atomic.h>
> +
> +struct page_counter {
> +	atomic_long_t count;
> +	unsigned long limit;
> +	struct page_counter *parent;
> +
> +	/* legacy */
> +	unsigned long watermark;

The name suggest this is a restriction not a highest usage mark.
max_count would be less confusing.

> +	unsigned long failcnt;
> +};
> +
> +#if BITS_PER_LONG == 32
> +#define PAGE_COUNTER_MAX LONG_MAX
> +#else
> +#define PAGE_COUNTER_MAX (LONG_MAX / PAGE_SIZE)
> +#endif

It is not clear to me why you need a separate definitions here. LONG_MAX
seems to be good for both 32b and 64b.

[...]
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> new file mode 100644
> index 000000000000..51c45921b8d1
> --- /dev/null
> +++ b/mm/page_counter.c
> @@ -0,0 +1,191 @@
> +/*
> + * Lockless hierarchical page accounting & limiting
> + *
> + * Copyright (C) 2014 Red Hat, Inc., Johannes Weiner
> + */
> +#include <linux/page_counter.h>
> +#include <linux/atomic.h>
> +
> +/**
> + * page_counter_cancel - take pages out of the local counter
> + * @counter: counter
> + * @nr_pages: number of pages to cancel
> + *
> + * Returns whether there are remaining pages in the counter.
> + */
> +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	long new;
> +
> +	new = atomic_long_sub_return(nr_pages, &counter->count);
> +

This really deserves a comment IMO. Something like the following:
	/*
	 * Charges and uncharges are always ordered properly from memory
	 * ordering point of view. The only case where underflow can happen
	 * is a mismatched uncharge. Report it and fix it up now rather
	 * than blow up later.
	 */
> +	if (WARN_ON_ONCE(new < 0))
> +		atomic_long_add(nr_pages, &counter->count);

anyway this doesn't look correct because you can have false positives:
[counter->count = 1]
	CPU0					CPU1
new = atomic_long_sub_return(THP)
					new = atomic_long_sub_return(1)
(new < 0)				(new < 0)
  atomic_long_add(THP)			  atomic_add(1)

So we will end up with counter->count = 1 rather than 0. I think you
need to use a lock in the slow path. Something like

	if (new < 0) {
		unsigned long flags;

		/*
		 * Multiple uncharger might race together and we do not
		 * want to let any of them revert the uncharge just
		 * because a faulty uncharge and the fixup are not
		 * atomic.
		 */
		atomic_lond_add(nr_pages, &counter->count);

		spin_lock_irqsave(&counter->lock, flags);
		new = atomic_long_sub_return(nr_pages, &counter->count);
		if (WARN_ON(new < 0))
			atomic_long_add(nr_pages, &counter->count);
		spin_unlock_irqrestore(&counter->lock, flags);
	}

> +
> +	return new > 0;
> +}
> +
> +/**
> + * page_counter_charge - hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + *
> + * NOTE: This may exceed the configured counter limits.

The name is rather awkward. It sounds like a standard way to charge the
counter. I would rather stick to _nofail suffix and the following
addition to the doc.
"
Can be called only from contexts where the charge failure cannot be
handled. This should be rare and used with extreme caution.
"

> + */
> +void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	struct page_counter *c;
> +
> +	for (c = counter; c; c = c->parent) {
> +		long new;
> +
> +		new = atomic_long_add_return(nr_pages, &c->count);
> +		/*
> +		 * This is racy, but with the per-cpu caches on top
> +		 * it's just a ballpark metric anyway; and with lazy
> +		 * cache reclaim, the majority of workloads peg the
> +		 * watermark to the group limit soon after launch.
> +		 */
> +		if (new > c->watermark)
> +			c->watermark = new;
> +	}
> +}
> +
> +/**
> + * page_counter_try_charge - try to hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + * @fail: points first counter to hit its limit, if any
> + *
> + * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> + * its ancestors has hit its limit.
> + */
> +int page_counter_try_charge(struct page_counter *counter,
> +			    unsigned long nr_pages,
> +			    struct page_counter **fail)
> +{
> +	struct page_counter *c;
> +
> +	for (c = counter; c; c = c->parent) {
> +		long new;
> +		/*
> +		 * Charge speculatively to avoid an expensive CAS.  If
> +		 * a bigger charge fails, it might falsely lock out a
> +		 * racing smaller charge and send it into reclaim
> +		 * eraly, but the error is limited to the difference
> +		 * between the two sizes, which is less than 2M/4M in
> +		 * case of a THP locking out a regular page charge.
> +		 */

If this ever turns out to be a problem then we can check the size of the
overflow and retry if it is > nr_online_cpus or something like that. Not
worth bothering now I guess but definitely good to have this documented.
I would even like to have it in the changelog for users bisecting an
excessive reclaim because it is easier to find that in the changelog
than in the code.

> +		new = atomic_long_add_return(nr_pages, &c->count);
> +		if (new > c->limit) {
> +			atomic_long_sub(nr_pages, &c->count);
> +			/*
> +			 * This is racy, but the failcnt is only a
> +			 * ballpark metric anyway.
> +			 */
> +			c->failcnt++;
> +			*fail = c;
> +			goto failed;
> +		}
> +		/*
> +		 * This is racy, but with the per-cpu caches on top
> +		 * it's just a ballpark metric anyway; and with lazy
> +		 * cache reclaim, the majority of workloads peg the
> +		 * watermark to the group limit soon after launch.
> +		 */
> +		if (new > c->watermark)
> +			c->watermark = new;
> +	}
> +	return 0;
> +
> +failed:
> +	for (c = counter; c != *fail; c = c->parent)
> +		page_counter_cancel(c, nr_pages);
> +
> +	return -ENOMEM;
> +}
[...]
> +/**
> + * page_counter_limit - limit the number of pages allowed
> + * @counter: counter
> + * @limit: limit to set
> + *
> + * Returns 0 on success, -EBUSY if the current number of pages on the
> + * counter already exceeds the specified limit.
> + *
> + * The caller must serialize invocations on the same counter.
> + */
> +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> +{
> +	for (;;) {
> +		unsigned long old;
> +		long count;
> +
> +		count = atomic_long_read(&counter->count);
> +
> +		old = xchg(&counter->limit, limit);
> +
> +		if (atomic_long_read(&counter->count) != count) {
> +			counter->limit = old;
> +			continue;
> +		}
> +
> +		if (count > limit) {
> +			counter->limit = old;
> +			return -EBUSY;
> +		}

Ordering doesn't make much sense to me here. Say you really want to set
limit < count. You are effectively pushing all concurrent charges to
the reclaim even though you would revert your change and return with
EBUSY later on.
Wouldn't (count > limit) check make more sense right after the first
atomic_long_read?
Also the second count check should be sufficient to check > count and
retry only when the count has increased.
Finally continuous flow of charges can keep this loop running for quite
some time and trigger lockup detector. cond_resched before continue
would handle that. Something like the following:

	for (;;) {
		unsigned long old;
		long count;

		count = atomic_long_read(&counter->count);
		if (count > limit)
			return -EBUSY;

		old = xchg(&counter->limit, limit);

		/* Recheck for concurrent charges */
		if (atomic_long_read(&counter->count) > count) {
			counter->limit = old;
			cond_resched();
			continue;
		}

		return 0;
	}

> +
> +		return 0;
> +	}
> +}
> +
> +/**
> + * page_counter_memparse - memparse() for page counter limits
> + * @buf: string to parse
> + * @nr_pages: returns the result in number of pages
> + *
> + * Returns -EINVAL, or 0 and @nr_pages on success.  @nr_pages will be
> + * limited to %PAGE_COUNTER_MAX.
> + */
> +int page_counter_memparse(const char *buf, unsigned long *nr_pages)
> +{
> +	char unlimited[] = "-1";
> +	char *end;
> +	u64 bytes;
> +
> +	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
> +		*nr_pages = PAGE_COUNTER_MAX;
> +		return 0;
> +	}
> +
> +	bytes = memparse(buf, &end);
> +	if (*end != '\0')
> +		return -EINVAL;

res_counter used to round up to the next page boundary and there is no
reason to not do the same here. 

	bytes = PAGE_ALIGN(bytes);

> +
> +	*nr_pages = min(bytes / PAGE_SIZE, (u64)PAGE_COUNTER_MAX);
> +
> +	return 0;
> +}
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
