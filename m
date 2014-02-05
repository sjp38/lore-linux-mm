Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 18D6D6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 15:57:29 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so847993pbc.8
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 12:57:28 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id mj6si30391126pab.130.2014.02.05.12.57.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 12:57:27 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id p10so827649pdj.31
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 12:57:27 -0800 (PST)
Date: Wed, 5 Feb 2014 12:56:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch v2] mm, compaction: avoid isolating pinned pages
In-Reply-To: <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1402051232530.3440@eggly.anvils>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com> <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com> <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com> <20140204021533.GA14924@lge.com> <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014, David Rientjes wrote:

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
> 	compact_pages_moved 8450
> 	compact_pagemigrate_failed 15614415
> 
> 0.05% of pages isolated are successfully migrated and explicitly 
> triggering memory compaction takes 102 seconds.  After the patch:
> 
> 	compact_pages_moved 9197
> 	compact_pagemigrate_failed 7
> 
> 99.9% of pages isolated are now successfully migrated in this 
> configuration and memory compaction takes less than one second.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: address page count issue per Joonsoo
> 
>  mm/compaction.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -578,6 +578,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			continue;
>  		}
>  
> +		/*
> +		 * Migration will fail if an anonymous page is pinned in memory,
> +		 * so avoid taking lru_lock and isolating it unnecessarily in an
> +		 * admittedly racy check.
> +		 */
> +		if (!page_mapping(page) &&
> +		    page_count(page) > page_mapcount(page))
> +			continue;
> +
>  		/* Check if it is ok to still hold the lock */
>  		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,

Much better, maybe good enough as an internal patch to fix a particular
problem you're seeing; but not yet good enough to go upstream.

Anonymous pages are not the only pages which might be pinned,
and your test doesn't mention PageAnon, so does not match your comment.

I've remembered is_page_cache_freeable() in mm/vmscan.c, which gives
more assurance that a page_count - page_has_private test is appropriate,
whatever the filesystem and migrate method to be used.

So I think the test you're looking for is

		pincount = page_count(page) - page_mapcount(page);
		if (page_mapping(page))
			pincount -= 1 + page_has_private(page);
		if (pincount > 0)
			continue;

but please cross-check and test that out, it's easy to be off-by-one etc.

For a moment I thought a PageWriteback test would be useful too,
but no, that should already appear in the pincount.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
