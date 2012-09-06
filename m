Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id BB4B86B00A7
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 22:16:00 -0400 (EDT)
Date: Thu, 6 Sep 2012 11:17:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm: use get_page_migratetype instead of page_private
Message-ID: <20120906021734.GB31615@bbox>
References: <1346829962-31989-1-git-send-email-minchan@kernel.org>
 <1346829962-31989-2-git-send-email-minchan@kernel.org>
 <20120905090955.GD11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120905090955.GD11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mel,

On Wed, Sep 05, 2012 at 10:09:55AM +0100, Mel Gorman wrote:
> On Wed, Sep 05, 2012 at 04:26:00PM +0900, Minchan Kim wrote:
> > page allocator uses set_page_private and page_private for handling
> > migratetype when it frees page. Let's replace them with [set|get]
> > _page_migratetype to make it more clear.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Maybe it's because I'm used of setting set_page_private() in the page
> allocator and what it means but I fear that it'll be very easy to confuse
> get_page_migratetype() with get_pageblock_migratetype(). The former only
> works while the page is in the buddy allocator. The latter can be called
> at any time. I'm not against the patch as such but I'm not convinced
> either :)

How about using name "get_buddypage_migratetype" instead of "get_page_migratetype"?

> 
> One nit below
> 
> > ---
> >  include/linux/mm.h  |   10 ++++++++++
> >  mm/page_alloc.c     |   11 +++++++----
> >  mm/page_isolation.c |    2 +-
> >  3 files changed, 18 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 5c76634..86d61d6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -249,6 +249,16 @@ struct inode;
> >  #define page_private(page)		((page)->private)
> >  #define set_page_private(page, v)	((page)->private = (v))
> >  
> > +static inline void set_page_migratetype(struct page *page, int migratetype)
> > +{
> > +	set_page_private(page, migratetype);
> > +}
> > +
> > +static inline int get_page_migratetype(struct page *page)
> > +{
> > +	return page_private(page);
> > +}
> > +
> >  /*
> >   * FIXME: take this include out, include page-flags.h in
> >   * files which need it (119 of them)
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 710d91c..103ba66 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -671,8 +671,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			/* must delete as __free_one_page list manipulates */
> >  			list_del(&page->lru);
> >  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> > -			__free_one_page(page, zone, 0, page_private(page));
> > -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> > +			__free_one_page(page, zone, 0,
> > +				get_page_migratetype(page));
> > +			trace_mm_page_pcpu_drain(page, 0,
> > +				get_page_migratetype(page));
> >  		} while (--to_free && --batch_free && !list_empty(list));
> >  	}
> >  	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> > @@ -731,6 +733,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	__count_vm_events(PGFREE, 1 << order);
> >  	free_one_page(page_zone(page), page, order,
> >  					get_pageblock_migratetype(page));
> > +
> >  	local_irq_restore(flags);
> >  }
> >  
> 
> Unnecessary whitespace change.

Will fix.
Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
