Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 959476B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:24:53 -0400 (EDT)
Date: Thu, 6 Sep 2012 13:24:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/2]compaction: check lock contention first before taking
 lock
Message-ID: <20120906122449.GR11266@suse.de>
References: <20120906104429.GB12718@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120906104429.GB12718@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu, Sep 06, 2012 at 06:44:29PM +0800, Shaohua Li wrote:
> isolate_migratepages_range will take zone->lru_lock first and check if the lock
> is contented, if yes, it will release the lock. This isn't efficient. If the
> lock is truly contented, a lock/unlock pair will increase the lock contention.
> We'd better check if the lock is contended first. compact_trylock_irqsave
> perfectly meets the requirement.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  mm/compaction.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: linux/mm/compaction.c
> ===================================================================
> --- linux.orig/mm/compaction.c	2012-09-06 14:46:13.923144263 +0800
> +++ linux/mm/compaction.c	2012-09-06 14:46:58.118588574 +0800
> @@ -295,9 +295,9 @@ isolate_migratepages_range(struct zone *
>  	}
>  
>  	/* Time to isolate some pages for migration */
> -	cond_resched();

Why did you remove the cond_resched()? I expect it's because
compact_checklock_irqsave() does a need_resched() check and if it is true
will either call cond_resched() or abort compaction. If it is aborting it
will not call cond_resched() but there is a reasonable expectation that
the caller will schedule soon. If this is the reasoning then it should be
included in the changelog. If it's an accident then leave the cond_resched()
where it is.

> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	locked = true;
> +	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
> +	if (!locked)
> +		goto skip;

There is no need for the goto. No useful work has taken place at this
point and there is no need to even trigger the tracepoint. Just return
0.

>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;
>  
> @@ -400,6 +400,7 @@ isolate_migratepages_range(struct zone *
>  	if (locked)
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  
> +skip:
>  	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>  
>  	if (!nr_isolated)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
