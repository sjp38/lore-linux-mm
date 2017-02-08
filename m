Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5404D6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:27:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so31471133wmg.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:27:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o9si2752051wmo.21.2017.02.08.07.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 07:27:52 -0800 (PST)
Date: Wed, 8 Feb 2017 16:27:47 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe
 requests -fix v2
In-Reply-To: <20170208152200.ydlvia2c7lm7ln3t@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1702081627380.3536@nanos>
References: <20170208152200.ydlvia2c7lm7ln3t@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

On Wed, 8 Feb 2017, Mel Gorman wrote:

> preempt_enable_no_resched() was used based on review feedback that had
> no strong objection at the time. The thinking was that it avoided adding
> a preemption point where one didn't exist before so the feedback was
> applied. This reasoning was wrong.
> 
> There was an indirect preemption point as explained by Thomas Gleixner where
> an interrupt could set_need_resched() followed by preempt_enable being
> a preemption point that matters. This use of preempt_enable_no_resched
> is bad from both a mainline and RT perspective and a violation of the
> preemption mechanism. Peter Zijlstra noted that "the only acceptable use
> of preempt_enable_no_resched() is if the next statement is a schedule()
> variant".
> 
> The usage was outright broken and I should have stuck to preempt_enable()
> as it was originally developed. It's known from previous tests
> that there was no detectable difference to the performance by using
> preempt_enable_no_resched().
> 
> This is a fix to the mmotm patch
> mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index eaecb4b145e6..2a36dad03dac 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2520,7 +2520,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	}
>  
>  out:
> -	preempt_enable_no_resched();
> +	preempt_enable();
>  }
>  
>  /*
> @@ -2686,7 +2686,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  		zone_statistics(preferred_zone, zone);
>  	}
> -	preempt_enable_no_resched();
> +	preempt_enable();
>  	return page;
>  }
>  
> 
> -- 
> Mel Gorman
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
