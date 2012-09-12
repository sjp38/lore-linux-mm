Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 5AC4A6B00F7
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 16:07:34 -0400 (EDT)
Date: Wed, 12 Sep 2012 13:07:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous
 allocation instead of migration
Message-Id: <20120912130732.99ecf764.akpm@linux-foundation.org>
In-Reply-To: <1347324112-14134-1-git-send-email-minchan@kernel.org>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Tue, 11 Sep 2012 09:41:52 +0900
Minchan Kim <minchan@kernel.org> wrote:

> This patch drops clean cache pages instead of migration during
> alloc_contig_range() to minimise allocation latency by reducing the amount
> of migration is necessary. It's useful for CMA because latency of migration
> is more important than evicting the background processes working set.
> In addition, as pages are reclaimed then fewer free pages for migration
> targets are required so it avoids memory reclaiming to get free pages,
> which is a contributory factor to increased latency.
> 
> * from v1
>   * drop migrate_mode_t
>   * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support - Mel
> 
> I measured elapsed time of __alloc_contig_migrate_range which migrates
> 10M in 40M movable zone in QEMU machine.
> 
> Before - 146ms, After - 7ms
> 
> ...
>
> @@ -758,7 +760,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			wait_on_page_writeback(page);
>  		}
>  
> -		references = page_check_references(page, sc);
> +		if (!force_reclaim)
> +			references = page_check_references(page, sc);

grumble.  Could we please document `enum page_references' and
page_check_references()?

And the `force_reclaim' arg could do with some documentation.  It only
forces reclaim under certain circumstances.  They should be described,
and a reson should be provided.

Why didn't this patch use PAGEREF_RECLAIM_CLEAN?  It is possible for
someone to dirty one of these pages after we tested its cleanness and
we'll then go off and write it out, but we won't be reclaiming it?

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
