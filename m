Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 86B106B01E3
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:53:47 -0400 (EDT)
Date: Tue, 15 Jun 2010 06:53:41 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615105341.GB31051@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * XXX: This is the Holy Hand Grenade of PotentiallyInvalidMapping. As
> +	 * the page lock has been dropped by ->writepage, that mapping could
> +	 * be anything
> +	 */

Why is this an XXX comment?

> +	/*
> +	 * Wait on writeback if requested to. This happens when
> +	 * direct reclaiming a large contiguous area and the
> +	 * first attempt to free a range of pages fails.
> +	 */
> +	if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> +		wait_on_page_writeback(page);
> +
> +	if (!PageWriteback(page)) {
> +		/* synchronous write or broken a_ops? */
> +		ClearPageReclaim(page);
> +	}

how about:

	if (PageWriteback(page) {
		if (sync_writeback == PAGEOUT_IO_SYNC)
			wait_on_page_writeback(page);
	} else {
		/* synchronous write or broken a_ops? */
		ClearPageReclaim(page);
	}

>  	if (!may_write_to_queue(mapping->backing_dev_info))
>  		return PAGE_KEEP;
>  
>  /*
> + * Clean a list of pages. It is expected that all the pages on page_list have been
> + * locked as part of isolation from the LRU.

A rather pointless line of 80 chars.  I see the point for long string
literals, but here's it's just a pain.

> + *
> + * XXX: Is there a problem with holding multiple page locks like this?

I think there is.  There's quite a few places that do hold multiple
pages locked, but they always lock pages in increasing page->inxex order.
Given that this locks basically in random order it could cause problems
for those places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
