Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCAE6B427B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 17:04:35 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v9-v6so56507ply.13
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 14:04:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f10-v6si271076pgj.397.2018.08.27.14.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 14:04:34 -0700 (PDT)
Date: Mon, 27 Aug 2018 14:04:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/3] mm: don't miss the last page because of
 round-off error
Message-Id: <20180827140432.b3c792f60235a13739038808@linux-foundation.org>
In-Reply-To: <20180827162621.30187-3-guro@fb.com>
References: <20180827162621.30187-1-guro@fb.com>
	<20180827162621.30187-3-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>

On Mon, 27 Aug 2018 09:26:21 -0700 Roman Gushchin <guro@fb.com> wrote:

> I've noticed, that dying memory cgroups are  often pinned
> in memory by a single pagecache page. Even under moderate
> memory pressure they sometimes stayed in such state
> for a long time. That looked strange.
> 
> My investigation showed that the problem is caused by
> applying the LRU pressure balancing math:
> 
>   scan = div64_u64(scan * fraction[lru], denominator),
> 
> where
> 
>   denominator = fraction[anon] + fraction[file] + 1.
> 
> Because fraction[lru] is always less than denominator,
> if the initial scan size is 1, the result is always 0.
> 
> This means the last page is not scanned and has
> no chances to be reclaimed.
> 
> Fix this by rounding up the result of the division.
> 
> In practice this change significantly improves the speed
> of dying cgroups reclaim.
> 
> ...
>
> --- a/include/linux/math64.h
> +++ b/include/linux/math64.h
> @@ -281,4 +281,6 @@ static inline u64 mul_u64_u32_div(u64 a, u32 mul, u32 divisor)
>  }
>  #endif /* mul_u64_u32_div */
>  
> +#define DIV64_U64_ROUND_UP(ll, d)	div64_u64((ll) + (d) - 1, (d))

This macro references arg `d' more than once.  That can cause problems
if the passed expression has side-effects and is poor practice.  Can
we please redo this with a temporary?

>  #endif /* _LINUX_MATH64_H */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d649b242b989..2c67a0121c6d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2446,9 +2446,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  			/*
>  			 * Scan types proportional to swappiness and
>  			 * their relative recent reclaim efficiency.
> +			 * Make sure we don't miss the last page
> +			 * because of a round-off error.
>  			 */
> -			scan = div64_u64(scan * fraction[file],
> -					 denominator);
> +			scan = DIV64_U64_ROUND_UP(scan * fraction[file],
> +						  denominator);
>  			break;
>  		case SCAN_FILE:
>  		case SCAN_ANON:
