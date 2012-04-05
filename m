Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 4F3BB6B007E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 17:46:22 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1330737ghr.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 14:46:21 -0700 (PDT)
Date: Thu, 5 Apr 2012 14:46:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: compaction: allow isolation of lower order buddy
 pages
In-Reply-To: <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
Message-ID: <alpine.DEB.2.00.1204051444080.17852@chino.kir.corp.google.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com> <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, 5 Apr 2012, Bartlomiej Zolnierkiewicz wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index bc77135..642c17a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -115,8 +115,8 @@ static bool suitable_migration_target(struct page *page)
>  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
>  		return false;
>  
> -	/* If the page is a large free page, then allow migration */
> -	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> +	/* If the page is a free page, then allow migration */
> +	if (PageBuddy(page))
>  		return true;
>  
>  	/* If the block is MIGRATE_MOVABLE, allow migration */

So when we try to allocate a 2M hugepage through the buddy allocator where 
the pageblock is also 2M, wouldn't this result in a lot of unnecessary 
migration of memory that may not end up defragmented enough for the 
allocation to succeed?  Sounds like a regression for hugepage allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
