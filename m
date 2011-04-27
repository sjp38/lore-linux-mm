Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A79E9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:46:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 226EB3EE0BC
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:46:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0533B45DE60
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:46:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D8F0045DE5A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:46:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA285E08004
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:46:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D55A1DB8042
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:46:00 +0900 (JST)
Date: Wed, 27 Apr 2011 17:39:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 8/8] compaction: make compaction use in-order putback
Message-Id: <20110427173922.4d65534b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 27 Apr 2011 01:25:25 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Compaction is good solution to get contiguos page but it makes
> LRU churing which is not good.
> This patch makes that compaction code use in-order putback so
> after compaction completion, migrated pages are keeping LRU ordering.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/compaction.c |   22 +++++++++++++++-------
>  1 files changed, 15 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a2f6e96..480d2ac 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -211,11 +211,11 @@ static void isolate_freepages(struct zone *zone,
>  /* Update the number of anon and file isolated pages in the zone */
>  static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  {
> -	struct page *page;
> +	struct pages_lru *pages_lru;
>  	unsigned int count[NR_LRU_LISTS] = { 0, };
>  
> -	list_for_each_entry(page, &cc->migratepages, lru) {
> -		int lru = page_lru_base_type(page);
> +	list_for_each_entry(pages_lru, &cc->migratepages, lru) {
> +		int lru = page_lru_base_type(pages_lru->page);
>  		count[lru]++;
>  	}
>  
> @@ -281,6 +281,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	spin_lock_irq(&zone->lru_lock);
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;
> +		struct pages_lru *pages_lru;
>  		bool locked = true;
>  
>  		/* give a chance to irqs before checking need_resched() */
> @@ -334,10 +335,16 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  			continue;
>  		}
>  
> +		pages_lru = kmalloc(sizeof(struct pages_lru), GFP_ATOMIC);
> +		if (pages_lru)
> +			continue;

Hmm, can't we use fixed size of statically allocated pages_lru, per-node or
per-zone ? I think using kmalloc() in memory reclaim path is risky.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
