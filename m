Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A3B57600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 12:18:26 -0400 (EDT)
Date: Thu, 8 Apr 2010 18:18:14 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408161814.GC28964@cmpxchg.org>
References: <patchbomb.1270691443@v2.random> <a86f1d01d86dffb4ab53.1270691499@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a86f1d01d86dffb4ab53.1270691499@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Andrea,

On Thu, Apr 08, 2010 at 03:51:39AM +0200, Andrea Arcangeli wrote:
> +static unsigned long isolate_migratepages(struct zone *zone,
> +					struct compact_control *cc)
> +{
> +	unsigned long low_pfn, end_pfn;
> +	struct list_head *migratelist = &cc->migratepages;
> +
> +	/* Do not scan outside zone boundaries */
> +	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> +
> +	/* Only scan within a pageblock boundary */
> +	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> +
> +	/* Do not cross the free scanner or scan within a memory hole */
> +	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
> +		cc->migrate_pfn = end_pfn;
> +		return 0;
> +	}
> +
> +	/*
> +	 * Ensure that there are not too many pages isolated from the LRU
> +	 * list by either parallel reclaimers or compaction. If there are,
> +	 * delay for some time until fewer pages are isolated
> +	 */
> +	while (unlikely(too_many_isolated(zone))) {
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +
> +		if (fatal_signal_pending(current))
> +			return 0;
> +	}
> +
> +	/* Time to isolate some pages for migration */
> +	spin_lock_irq(&zone->lru_lock);
> +	for (; low_pfn < end_pfn; low_pfn++) {
> +		struct page *page;
> +		if (!pfn_valid_within(low_pfn))
> +			continue;
> +
> +		/* Get the page and skip if free */
> +		page = pfn_to_page(low_pfn);
> +		if (PageBuddy(page)) {

Should this be

		if (PageBuddy(page) || PageTransHuge(page)) {

> +			low_pfn += (1 << page_order(page)) - 1;
> +			continue;
> +		}

instead?

> +
> +		/* Try isolate the page */
> +		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
> +			continue;
> +
> +		/* Successfully isolated */
> +		del_page_from_lru_list(zone, page, page_lru(page));
> +		list_add(&page->lru, migratelist);
> +		mem_cgroup_del_lru(page);
> +		cc->nr_migratepages++;
> +
> +		/* Avoid isolating too much */
> +		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
> +			break;
> +	}
> +
> +	acct_isolated(zone, cc);
> +
> +	spin_unlock_irq(&zone->lru_lock);
> +	cc->migrate_pfn = low_pfn;
> +
> +	return cc->nr_migratepages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
