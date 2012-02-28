Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A39846B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 20:15:18 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E05AC3EE0BD
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:15:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5AEF45DEB3
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:15:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2B1745DE9E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:15:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 956D41DB803F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:15:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E49E1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:15:16 +0900 (JST)
Date: Tue, 28 Feb 2012 10:13:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 16/21] mm: handle lruvec relocks in compaction
Message-Id: <20120228101348.fb38e5f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135256.12988.24796.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135256.12988.24796.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:56 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Prepare for lru_lock splitting in memory compaction code.
> 
> * disable irqs in acct_isolated() for __mod_zone_page_state(),
>   lru_lock isn't required there.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  mm/compaction.c |   30 ++++++++++++++++--------------
>  1 files changed, 16 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a976b28..54340e4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -224,8 +224,10 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  	list_for_each_entry(page, &cc->migratepages, lru)
>  		count[!!page_is_file_cache(page)]++;
>  
> +	local_irq_disable();
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
>  	__mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
> +	local_irq_enable();

Why we need to disable Irq here ??



>  }
>  
>  /* Similar to reclaim, but different enough that they don't share logic */
> @@ -262,7 +264,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	unsigned long nr_scanned = 0, nr_isolated = 0;
>  	struct list_head *migratelist = &cc->migratepages;
>  	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
> -	struct lruvec *lruvec;
> +	struct lruvec *lruvec = NULL;
>  
>  	/* Do not scan outside zone boundaries */
>  	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> @@ -294,25 +296,24 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  
>  	/* Time to isolate some pages for migration */
>  	cond_resched();
> -	spin_lock_irq(&zone->lru_lock);
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;
> -		bool locked = true;
>  
>  		/* give a chance to irqs before checking need_resched() */
>  		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
> -			spin_unlock_irq(&zone->lru_lock);
> -			locked = false;
> +			if (lruvec)
> +				unlock_lruvec_irq(lruvec);
> +			lruvec = NULL;
>  		}
> -		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
> -			if (locked)
> -				spin_unlock_irq(&zone->lru_lock);
> +		if (need_resched() ||
> +		    (lruvec && spin_is_contended(&zone->lru_lock))) {
> +			if (lruvec)
> +				unlock_lruvec_irq(lruvec);
> +			lruvec = NULL;
>  			cond_resched();
> -			spin_lock_irq(&zone->lru_lock);
>  			if (fatal_signal_pending(current))
>  				break;
> -		} else if (!locked)
> -			spin_lock_irq(&zone->lru_lock);
> +		}
>  
>  		/*
>  		 * migrate_pfn does not necessarily start aligned to a
> @@ -359,7 +360,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  			continue;
>  		}
>  
> -		if (!PageLRU(page))
> +		if (!__lock_page_lruvec_irq(&lruvec, page))
>  			continue;

Could you add more comments onto __lock_page_lruvec_irq() ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
