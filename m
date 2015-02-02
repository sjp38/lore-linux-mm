Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 221E26B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:01:14 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so78624480pab.9
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:01:13 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bk8si15527171pdb.44.2015.02.01.23.01.12
        for <linux-mm@kvack.org>;
        Sun, 01 Feb 2015 23:01:13 -0800 (PST)
Date: Mon, 2 Feb 2015 16:02:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 3/4] mm/page_alloc: separate steal decision from steal
 behaviour part
Message-ID: <20150202070248.GA6488@js1304-P5Q-DELUXE>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1422621252-29859-4-git-send-email-iamjoonsoo.kim@lge.com>
 <54CB94E6.7010805@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54CB94E6.7010805@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 03:27:50PM +0100, Vlastimil Babka wrote:
> On 01/30/2015 01:34 PM, Joonsoo Kim wrote:
> > From: Joonsoo <iamjoonsoo.kim@lge.com>
> > 
> > This is preparation step to use page allocator's anti fragmentation logic
> > in compaction. This patch just separates steal decision part from actual
> > steal behaviour part so there is no functional change.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/page_alloc.c | 49 ++++++++++++++++++++++++++++++++-----------------
> >  1 file changed, 32 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8d52ab1..ef74750 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1122,6 +1122,24 @@ static void change_pageblock_range(struct page *pageblock_page,
> >  	}
> >  }
> >  
> > +static bool can_steal_freepages(unsigned int order,
> > +				int start_mt, int fallback_mt)
> > +{
> > +	if (is_migrate_cma(fallback_mt))
> > +		return false;
> > +
> > +	if (order >= pageblock_order)
> > +		return true;
> > +
> > +	if (order >= pageblock_order / 2 ||
> > +		start_mt == MIGRATE_RECLAIMABLE ||
> > +		start_mt == MIGRATE_UNMOVABLE ||
> > +		page_group_by_mobility_disabled)
> > +		return true;
> > +
> > +	return false;
> > +}
> > +
> >  /*
> >   * When we are falling back to another migratetype during allocation, try to
> >   * steal extra free pages from the same pageblocks to satisfy further
> > @@ -1138,9 +1156,10 @@ static void change_pageblock_range(struct page *pageblock_page,
> >   * as well.
> >   */
> >  static void try_to_steal_freepages(struct zone *zone, struct page *page,
> > -				  int start_type, int fallback_type)
> > +				  int start_type)
> 
> It's actually not 'try_to_' anymore, is it? But could be, see below.
> 
> >  {
> >  	int current_order = page_order(page);
> > +	int pages;
> >  
> >  	/* Take ownership for orders >= pageblock_order */
> >  	if (current_order >= pageblock_order) {
> > @@ -1148,19 +1167,12 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
> >  		return;
> >  	}
> >  
> > -	if (current_order >= pageblock_order / 2 ||
> > -	    start_type == MIGRATE_RECLAIMABLE ||
> > -	    start_type == MIGRATE_UNMOVABLE ||
> > -	    page_group_by_mobility_disabled) {
> > -		int pages;
> > +	pages = move_freepages_block(zone, page, start_type);
> >  
> > -		pages = move_freepages_block(zone, page, start_type);
> > -
> > -		/* Claim the whole block if over half of it is free */
> > -		if (pages >= (1 << (pageblock_order-1)) ||
> > -				page_group_by_mobility_disabled)
> > -			set_pageblock_migratetype(page, start_type);
> > -	}
> > +	/* Claim the whole block if over half of it is free */
> > +	if (pages >= (1 << (pageblock_order-1)) ||
> > +			page_group_by_mobility_disabled)
> > +		set_pageblock_migratetype(page, start_type);
> >  }
> >  
> >  /* Remove an element from the buddy allocator from the fallback list */
> > @@ -1170,6 +1182,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  	struct free_area *area;
> >  	unsigned int current_order;
> >  	struct page *page;
> > +	bool can_steal;
> >  
> >  	/* Find the largest possible block of pages in the other list */
> >  	for (current_order = MAX_ORDER-1;
> > @@ -1192,10 +1205,11 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  					struct page, lru);
> >  			area->nr_free--;
> >  
> > -			if (!is_migrate_cma(migratetype)) {
> > +			can_steal = can_steal_freepages(current_order,
> > +					start_migratetype, migratetype);
> > +			if (can_steal) {
> 
> can_steal is only used once, why not do if (can_steal_freepages()) directly?
> 
> Or, call can_steal_freepages() from try_to_steal_freepages() and make
> try_to_steal_freepages() return its result. Then here it simplifies to:
> 
> if (!try_to_steal_freepages(...) && is_migrate_cma(...))
> 	buddy_type = migratetype;

You're right. Your commented code loosk better.

Your comment on 3/4 and 4/4 makes me reconsider this code factorization
and I found better solution.
I will send it soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
