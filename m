Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 14D916B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:12:29 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so7257837pad.36
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:12:28 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id b4si6332999pbe.118.2014.02.10.23.12.27
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 23:12:28 -0800 (PST)
Date: Tue, 11 Feb 2014 16:12:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm/compaction: disallow high-order page for
 migration target
Message-ID: <20140211071225.GA27870@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20140210132634.GE6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140210132634.GE6732@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 10, 2014 at 01:26:34PM +0000, Mel Gorman wrote:
> On Fri, Feb 07, 2014 at 02:08:42PM +0900, Joonsoo Kim wrote:
> > Purpose of compaction is to get a high order page. Currently, if we find
> > high-order page while searching migration target page, we break it to
> > order-0 pages and use them as migration target. It is contrary to purpose
> > of compaction, so disallow high-order page to be used for
> > migration target.
> > 
> > Additionally, clean-up logic in suitable_migration_target() to simply.
> > There is no functional changes from this clean-up.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 3a91a2e..bbe1260 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -217,21 +217,12 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
> >  /* Returns true if the page is within a block suitable for migration to */
> >  static bool suitable_migration_target(struct page *page)
> >  {
> > -	int migratetype = get_pageblock_migratetype(page);
> > -
> > -	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
> > -	if (migratetype == MIGRATE_RESERVE)
> > -		return false;
> > -
> 
> Why is this check removed? The reservation blocks are preserved as
> short-lived high-order atomic allocations depend on them.

Hello,

After disallowing high-order page to be used for migration target,
we only allow pages from movable or CMA pageblock for migration target on
migrate_async_suitable() check. So checking whether page comes from reserve or
isolate pageblock is useless.

> 
> > -	if (is_migrate_isolate(migratetype))
> > -		return false;
> > -
> 
> Why is this check removed?
> 
> > -	/* If the page is a large free page, then allow migration */
> > +	/* If the page is a large free page, then disallow migration */
> >  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> > -		return true;
> > +		return false;
> >  
> 
> The reason why this was originally allowed was to allow pageblocks that were
> marked MIGRATE_UNMOVABLE or MIGRATE_RECLAIMABLE to be used as compaction
> targets. However, compaction should not even be running if this is the
> case so the change makes sense.

Okay!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
