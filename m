Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 67C4B6B01F3
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 16:34:49 -0400 (EDT)
Date: Wed, 24 Mar 2010 13:33:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-Id: <20100324133347.9b4b2789.akpm@linux-foundation.org>
In-Reply-To: <1269347146-7461-8-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-8-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 12:25:42 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> This patch is the core of a mechanism which compacts memory in a zone by
> relocating movable pages towards the end of the zone.
> 
> A single compaction run involves a migration scanner and a free scanner.
> Both scanners operate on pageblock-sized areas in the zone. The migration
> scanner starts at the bottom of the zone and searches for all movable pages
> within each area, isolating them onto a private list called migratelist.
> The free scanner starts at the top of the zone and searches for suitable
> areas and consumes the free pages within making them available for the
> migration scanner. The pages isolated for migration are then migrated to
> the newly isolated free pages.

General comment: it looks like there are some codepaths which could
hold zone->lock for a long time.  It's unclear that they're all
constrained by COMPACT_CLUSTER_MAX. Is there a a latency issue here?

>
> ...
>
> +static struct page *compaction_alloc(struct page *migratepage,
> +					unsigned long data,
> +					int **result)
> +{
> +	struct compact_control *cc = (struct compact_control *)data;
> +	struct page *freepage;
> +
> +	VM_BUG_ON(cc == NULL);

It's a bit strange to test this when we're about to oops anyway.  The
oops will tell us the same thing.

> +	/* Isolate free pages if necessary */
> +	if (list_empty(&cc->freepages)) {
> +		isolate_freepages(cc->zone, cc);
> +
> +		if (list_empty(&cc->freepages))
> +			return NULL;
> +	}
> +
> +	freepage = list_entry(cc->freepages.next, struct page, lru);
> +	list_del(&freepage->lru);
> +	cc->nr_freepages--;
> +
> +	return freepage;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
