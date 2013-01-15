Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id AA7FE6B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:36:27 -0500 (EST)
Date: Tue, 15 Jan 2013 15:36:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: remove MIGRATE_ISOLATE check in hotpath
Message-Id: <20130115153625.96265439.akpm@linux-foundation.org>
In-Reply-To: <1358209006-18859-1-git-send-email-minchan@kernel.org>
References: <1358209006-18859-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>

On Tue, 15 Jan 2013 09:16:46 +0900
Minchan Kim <minchan@kernel.org> wrote:

> Now mm several functions test MIGRATE_ISOLATE and some of those
> are hotpath but MIGRATE_ISOLATE is used only if we enable
> CONFIG_MEMORY_ISOLATION(ie, CMA, memory-hotplug and memory-failure)
> which are not common config option. So let's not add unnecessary
> overhead and code when we don't enable CONFIG_MEMORY_ISOLATION.

ugh.  Better than nothing, I guess.

There remain call sites which do open-coded

	get_pageblock_migratetype(page) != MIGRATE_ISOLATE

(undo_isolate_page_range() is one).  Wanna clean these up as well?

>
> ...
>
> @@ -683,7 +683,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  	zone->pages_scanned = 0;
>  
>  	__free_one_page(page, zone, order, migratetype);
> -	if (unlikely(migratetype != MIGRATE_ISOLATE))
> +	if (unlikely(!is_migrate_isolate(migratetype)))
>  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>  	spin_unlock(&zone->lock);
>  }

The code both before and after this patch is assuming that the
migratetype in free_one_page is likely to be MIGRATE_ISOLATE.  Seems
wrong.  If CONFIG_MEMORY_ISOLATION=n this ends up doing
if(unlikely(true)) which is harmless-but-amusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
