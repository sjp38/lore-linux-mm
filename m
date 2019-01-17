Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E63E8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:33:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so4012685edq.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:33:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bz21-v6si500573ejb.237.2019.01.17.09.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:33:38 -0800 (PST)
Subject: Re: [PATCH 19/25] mm, compaction: Do not consider a need to
 reschedule as contention
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-20-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1aa220a6-5517-ee7b-0a16-e72c2ecceddb@suse.cz>
Date: Thu, 17 Jan 2019 18:33:37 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-20-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> Scanning on large machines can take a considerable length of time and
> eventually need to be rescheduled. This is treated as an abort event but
> that's not appropriate as the attempt is likely to be retried after making
> numerous checks and taking another cycle through the page allocator.
> This patch will check the need to reschedule if necessary but continue
> the scanning.
> 
> The main benefit is reduced scanning when compaction is taking a long time
> or the machine is over-saturated. It also avoids an unnecessary exit of
> compaction that ends up being retried by the page allocator in the outer
> loop.
> 
>                                         4.20.0                 4.20.0
>                               synccached-v2r15        noresched-v2r15
> Amean     fault-both-3      2655.55 (   0.00%)     2736.50 (  -3.05%)
> Amean     fault-both-5      4580.67 (   0.00%)     4133.70 (   9.76%)
> Amean     fault-both-7      5740.50 (   0.00%)     5738.61 (   0.03%)
> Amean     fault-both-12     9237.55 (   0.00%)     9392.82 (  -1.68%)
> Amean     fault-both-18    12899.51 (   0.00%)    13257.15 (  -2.77%)
> Amean     fault-both-24    16342.47 (   0.00%)    16859.44 (  -3.16%)
> Amean     fault-both-30    20394.26 (   0.00%)    16249.30 *  20.32%*
> Amean     fault-both-32    17450.76 (   0.00%)    14904.71 *  14.59%*

I always assumed that this was the main factor that (clumsily) limited THP fault
latencies. Seems like it's (no longer?) the case, or the lock contention
detection alone works as well.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1a41a2dbff24..75eb0d40d4d7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -398,19 +398,11 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
>  	return true;
>  }
>  
> -/*
> - * Aside from avoiding lock contention, compaction also periodically checks
> - * need_resched() and records async compaction as contended if necessary.
> - */
> +/* Avoid soft-lockups due to long scan times */
>  static inline void compact_check_resched(struct compact_control *cc)
>  {
> -	/* async compaction aborts if contended */
> -	if (need_resched()) {
> -		if (cc->mode == MIGRATE_ASYNC)
> -			cc->contended = true;
> -
> +	if (need_resched())
>  		cond_resched();

Seems like plain "cond_resched()" is sufficient at this point, and probably
doesn't need a wrapper anymore.

> -	}
>  }
>  
>  /*
> 
