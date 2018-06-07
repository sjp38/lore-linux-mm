Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B90336B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 06:42:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 76-v6so4337309wmw.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 03:42:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2-v6si1461603edp.183.2018.06.07.03.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 03:42:16 -0700 (PDT)
Date: Thu, 7 Jun 2018 12:42:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mremap: Remove LATENCY_LIMIT from mremap to reduce the
 number of TLB shootdowns
Message-ID: <20180607104214.GI32433@dhcp22.suse.cz>
References: <20180606183803.k7qaw2xnbvzshv34@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180606183803.k7qaw2xnbvzshv34@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Wed 06-06-18 19:38:03, Mel Gorman wrote:
> Commit 5d1904204c99 ("mremap: fix race between mremap() and page cleanning")
> fixed races between mremap and other operations for both file-backed and
> anonymous mappings. The file-backed was the most critical as it allowed the
> possibility that data could be changed on a physical page after page_mkclean
> returned which could trigger data loss or data integrity issues. A customer
> reported that the cost of the TLBs for anonymous regressions was excessive
> and resulting in a 30-50% drop in performance overall since this commit
> on a microbenchmark. Unfortunately I neither have access to the test-case
> nor can I describe what it does other than saying that mremap operations
> dominate heavily.
> 
> This patch removes the LATENCY_LIMIT to handle TLB flushes on a PMD boundary
> instead of every 64 pages to reduce the number of TLB shootdowns by a factor
> of 8 in the ideal case. LATENCY_LIMIT was almost certainly used originally
> to limit the PTL hold times but the latency savings are likely offset by
> the cost of IPIs in many cases. This patch is not reported to completely
> restore performance but gets it within an acceptable percentage. The given
> metric here is simply described as "higher is better".
> 
> Baseline that was known good
> 002:  Metric:       91.05
> 004:  Metric:      109.45
> 008:  Metric:       73.08
> 016:  Metric:       58.14
> 032:  Metric:       61.09
> 064:  Metric:       57.76
> 128:  Metric:       55.43
> 
> Current
> 001:  Metric:       54.98
> 002:  Metric:       56.56
> 004:  Metric:       41.22
> 008:  Metric:       35.96
> 016:  Metric:       36.45
> 032:  Metric:       35.71
> 064:  Metric:       35.73
> 128:  Metric:       34.96
> 
> With patch
> 001:  Metric:       61.43
> 002:  Metric:       81.64
> 004:  Metric:       67.92
> 008:  Metric:       51.67
> 016:  Metric:       50.47
> 032:  Metric:       52.29
> 064:  Metric:       50.01
> 128:  Metric:       49.04
> 
> So for low threads, it's not restored but for larger number of threads,
> it's closer to the "known good" baseline.
> 
> Using a different mremap-intensive workload that is not representative of
> the real workload there is little difference observed outside of noise in
> the headline metrics However, the TLB shootdowns are reduced by 11% on
> average and at the peak, TLB shootdowns were reduced by 21%. Interrupts
> were sampled every second while the workload ran to get those figures.
> It's known that the figures will vary as the non-representative load is
> non-deterministic.
> 
> An alternative patch was posted that should have significantly reduced the
> TLB flushes but unfortunately it does not perform as well as this version
> on the customer test case. If revisited, the two patches can stack on top
> of each other.

Yes, I think the other patch still makes some sense. I do not see why it
is not helping much but I hope we will learn that. This is a reasonable
step in the meantime.

I like the limit removal more than the previous version to tweak it.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mremap.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 049470aa1e3e..5c2e18505f75 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -191,8 +191,6 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  		drop_rmap_locks(vma);
>  }
>  
> -#define LATENCY_LIMIT	(64 * PAGE_SIZE)
> -
>  unsigned long move_page_tables(struct vm_area_struct *vma,
>  		unsigned long old_addr, struct vm_area_struct *new_vma,
>  		unsigned long new_addr, unsigned long len,
> @@ -247,8 +245,6 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  		next = (new_addr + PMD_SIZE) & PMD_MASK;
>  		if (extent > next - new_addr)
>  			extent = next - new_addr;
> -		if (extent > LATENCY_LIMIT)
> -			extent = LATENCY_LIMIT;
>  		move_ptes(vma, old_pmd, old_addr, old_addr + extent, new_vma,
>  			  new_pmd, new_addr, need_rmap_locks, &need_flush);
>  	}

-- 
Michal Hocko
SUSE Labs
