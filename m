Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 681696B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 04:53:34 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so11369870wgh.31
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 01:53:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw3si9574567wjb.23.2014.02.03.01.53.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 01:53:32 -0800 (PST)
Date: Mon, 3 Feb 2014 09:53:29 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages
Message-ID: <20140203095329.GH6732@suse.de>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Feb 01, 2014 at 09:46:26PM -0800, David Rientjes wrote:
> Page migration will fail for memory that is pinned in memory with, for
> example, get_user_pages().  In this case, it is unnecessary to take
> zone->lru_lock or isolating the page and passing it to page migration
> which will ultimately fail.
> 
> This is a racy check, the page can still change from under us, but in
> that case we'll just fail later when attempting to move the page.
> 
> This avoids very expensive memory compaction when faulting transparent
> hugepages after pinning a lot of memory with a Mellanox driver.
> 
> On a 128GB machine and pinning ~120GB of memory, before this patch we
> see the enormous disparity in the number of page migration failures
> because of the pinning (from /proc/vmstat):
> 
> compact_blocks_moved 7609
> compact_pages_moved 3431
> compact_pagemigrate_failed 133219
> compact_stall 13
> 
> After the patch, it is much more efficient:
> 
> compact_blocks_moved 7998
> compact_pages_moved 6403
> compact_pagemigrate_failed 3
> compact_stall 15
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -578,6 +578,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			continue;
>  		}
>  
> +		/*
> +		 * Migration will fail if an anonymous page is pinned in memory,
> +		 * so avoid taking zone->lru_lock and isolating it unnecessarily
> +		 * in an admittedly racy check.
> +		 */
> +		if (!page_mapping(page) && page_count(page))
> +			continue;
> +

Are you sure about this? The page_count check migration does is this

        int expected_count = 1 + extra_count;
        if (!mapping) {
                if (page_count(page) != expected_count)
                        return -EAGAIN;
                return MIGRATEPAGE_SUCCESS;
        }

        spin_lock_irq(&mapping->tree_lock);

        pslot = radix_tree_lookup_slot(&mapping->page_tree,
                                        page_index(page));

        expected_count += 1 + page_has_private(page);

Migration expects and can migrate pages with no mapping and a page count
but you are now skipping them. I think you may have intended to split
migrations page count into a helper or copy the logic.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
