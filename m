Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF9B06B0038
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:43:22 -0500 (EST)
Received: by wghl2 with SMTP id l2so6121448wgh.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 07:43:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id my5si24216921wic.27.2015.02.24.07.43.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 07:43:20 -0800 (PST)
Date: Tue, 24 Feb 2015 16:43:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150224154318.GA14939@dhcp22.suse.cz>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424765897-27377-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> Recently, Shaohua reported that MADV_FREE is much slower than
> MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> applications went to stall with direct reclaim since kswapd's
> reclaim speed isn't fast than applications's allocation speed
> so that it causes lots of stall and lock contention.

I am not sure I understand this correctly. So the issue is that there is
huge number of MADV_FREE on the LRU and they are not close to the tail
of the list so the reclaim has to do a lot of work before it starts
dropping them?

> This patch throttles MADV_FREEing so it works only if there
> are enough pages in the system which will not trigger backgroud/
> direct reclaim. Otherwise, MADV_FREE falls back to MADV_DONTNEED
> because there is no point to delay freeing if we know system
> is under memory pressure.

Hmm, this is still conforming to the documentation because the kernel is
free to free pages at its convenience. I am not sure this is a good
idea, though. Why some MADV_FREE calls should be treated differently?
Wouldn't that lead to hard to predict behavior? E.g. LIFO reused blocks
would work without long stalls most of the time - except when there is a
memory pressure.

Comparison to MADV_DONTNEED is not very fair IMHO because the scope of the
two calls is different.

> When I test the patch on my 3G machine + 12 CPU + 8G swap,
> test: 12 processes
> 
> loop = 5;
> mmap(512M);

Who is eating the rest of the memory?

> while (loop--) {
> 	memset(512M);
> 	madvise(MADV_FREE or MADV_DONTNEED);
> }
> 
> 1) dontneed: 6.78user 234.09system 0:48.89elapsed
> 2) madvfree: 6.03user 401.17system 1:30.67elapsed
> 3) madvfree + this ptach: 5.68user 113.42system 0:36.52elapsed
> 
> It's clearly win.
> 
> Reported-by: Shaohua Li <shli@kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

I don't know. This looks like a hack with hard to predict consequences
which might trigger pathological corner cases.

> ---
>  mm/madvise.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8921c2..81bb26ecf064 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -523,8 +523,17 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  		 * XXX: In this implementation, MADV_FREE works like
>  		 * MADV_DONTNEED on swapless system or full swap.
>  		 */
> -		if (get_nr_swap_pages() > 0)
> -			return madvise_free(vma, prev, start, end);
> +		if (get_nr_swap_pages() > 0) {
> +			unsigned long threshold;
> +			/*
> +			 * If we have trobule with memory pressure(ie,
> +			 * under high watermark), free pages instantly.
> +			 */
> +			threshold = min_free_kbytes >> (PAGE_SHIFT - 10);
> +			threshold = threshold + (threshold >> 1);

Why threshold += threshold >> 1 ?

> +			if (nr_free_pages() > threshold)
> +				return madvise_free(vma, prev, start, end);
> +		}
>  		/* passthrough */
>  	case MADV_DONTNEED:
>  		return madvise_dontneed(vma, prev, start, end);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
