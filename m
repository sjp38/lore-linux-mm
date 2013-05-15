Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7C88D6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 15:44:32 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 18/22] mm: page allocator: Split magazine lock in two to reduce contention
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
	<1368028987-8369-19-git-send-email-mgorman@suse.de>
Date: Wed, 15 May 2013 12:44:31 -0700
In-Reply-To: <1368028987-8369-19-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Wed, 8 May 2013 17:03:03 +0100")
Message-ID: <m24ne43u5c.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:
>  
> -static inline struct free_area_magazine *find_lock_filled_magazine(struct zone *zone)
> +static inline struct free_magazine *find_lock_magazine(struct zone *zone)
>  {
> -	struct free_area_magazine *area = &zone->_noirq_magazine;
> -	if (!area->nr_free)
> +	int i = (raw_smp_processor_id() >> 1) & (NR_MAGAZINES-1);
> +	int start = i;
> +
> +	do {
> +		if (spin_trylock(&zone->noirq_magazine[i].lock))
> +			goto out;

I'm not sure doing it this way is great. It optimizes for lock
contention vs the initial cost of just fetching the cache line.
Doing the try lock already has to fetch the cache line, even
if the lock is contended.

Page allocation should be limited more by the cache line bouncing
than long contention

So you may be paying the fetch cost multiple times without actually
amortizing it.

If you want to do it this way I would read the lock only. That can
be much cheaper because it doesn't have to take the cache line 
exclusive. It may still need to transfer it though (because another
CPU just took it exclusive), which may be already somewhat expensive.

So overall I'm not sure it's a good idea.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
