Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE2B528089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 01:22:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so223134413pfw.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 22:22:58 -0800 (PST)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id x5si9220733pgf.20.2017.02.08.22.22.57
        for <linux-mm@kvack.org>;
        Wed, 08 Feb 2017 22:22:57 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170208152200.ydlvia2c7lm7ln3t@techsingularity.net>
In-Reply-To: <20170208152200.ydlvia2c7lm7ln3t@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe requests -fix v2
Date: Thu, 09 Feb 2017 14:22:52 +0800
Message-ID: <00d201d2829c$f233b630$d69b2290$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Thomas Gleixner' <tglx@linutronix.de>, 'Peter Zijlstra' <peterz@infradead.org>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Ingo Molnar' <mingo@kernel.org>


On February 08, 2017 11:22 PM Mel Gorman wrote: 
> 
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
> ---
Thanks for fixing it.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
