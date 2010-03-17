Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B7F4C6B00D1
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 06:31:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2HAVsJ0008946
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Mar 2010 19:31:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A1B545DE53
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:31:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 743CA45DE51
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:31:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 515D9E18001
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:31:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F1D1DB803C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:31:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/11] Memory compaction core
In-Reply-To: <1268412087-13536-8-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-8-git-send-email-mel@csn.ul.ie>
Message-Id: <20100317170116.870A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Mar 2010 19:31:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

nit

> +static int compact_zone(struct zone *zone, struct compact_control *cc)
> +{
> +	int ret = COMPACT_INCOMPLETE;
> +
> +	/* Setup to move all movable pages to the end of the zone */
> +	cc->migrate_pfn = zone->zone_start_pfn;
> +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> +
> +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> +		unsigned long nr_migrate, nr_remaining;
> +		if (!isolate_migratepages(zone, cc))
> +			continue;
> +
> +		nr_migrate = cc->nr_migratepages;
> +		migrate_pages(&cc->migratepages, compaction_alloc,
> +						(unsigned long)cc, 0);
> +		update_nr_listpages(cc);
> +		nr_remaining = cc->nr_migratepages;
> +
> +		count_vm_event(COMPACTBLOCKS);

V1 did compaction per pageblock. but current patch doesn't.
so, Is COMPACTBLOCKS still good name?


> +		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> +		if (nr_remaining)
> +			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> +
> +		/* Release LRU pages not migrated */
> +		if (!list_empty(&cc->migratepages)) {
> +			putback_lru_pages(&cc->migratepages);
> +			cc->nr_migratepages = 0;
> +		}
> +
> +		mod_zone_page_state(zone, NR_ISOLATED_ANON, -cc->nr_anon);
> +		mod_zone_page_state(zone, NR_ISOLATED_FILE, -cc->nr_file);

I think you don't need decrease this vmstatistics here. migrate_pages() and
putback_lru_pages() alredy does.


other parts, looks good.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
