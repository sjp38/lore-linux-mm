Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA71hKDa010352
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 10:43:20 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D09EF45DD79
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:43:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90D1645DD7C
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:43:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 699001DB803A
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:43:19 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 229721DB803C
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:43:19 +0900 (JST)
Date: Fri, 7 Nov 2008 10:42:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into
 pcp
Message-Id: <20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081106164644.GA14012@csn.ul.ie>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081106164644.GA14012@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008 16:46:45 +0000
Mel Gorman <mel@csn.ul.ie> wrote:
> > otherwise, the system have unnecessary memory starvation risk
> > because other cpu can't use this emergency pages.
> > 
> > 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Mel Gorman <mel@csn.ul.ie>
> > CC: Christoph Lameter <cl@linux-foundation.org>
> > 
> 
> This patch seems functionally sound but as Christoph points out, this
> adds another branch to the fast path. Now, I ran some tests and those that
> completed didn't show any problems but adding branches in the fast path can
> eventually lead to hard-to-detect performance problems.
> 
dividing pcp-list into MIGRATE_TYPES is bad ?
If divided, we can get rid of scan. 

Thanks,
-Kame



> Do you have a situation in mind that this patch fixes up?
> 
> Thanks
> 
> > ---
> >  mm/page_alloc.c |   12 +++++++++++-
> >  1 file changed, 11 insertions(+), 1 deletion(-)
> > 
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c	2008-11-06 06:01:15.000000000 +0900
> > +++ b/mm/page_alloc.c	2008-11-06 06:27:41.000000000 +0900
> > @@ -1002,6 +1002,7 @@ static void free_hot_cold_page(struct pa
> >  	struct zone *zone = page_zone(page);
> >  	struct per_cpu_pages *pcp;
> >  	unsigned long flags;
> > +	int migratetype = get_pageblock_migratetype(page);
> >  
> >  	if (PageAnon(page))
> >  		page->mapping = NULL;
> > @@ -1018,16 +1019,25 @@ static void free_hot_cold_page(struct pa
> >  	pcp = &zone_pcp(zone, get_cpu())->pcp;
> >  	local_irq_save(flags);
> >  	__count_vm_event(PGFREE);
> > +
> > +	set_page_private(page, migratetype);
> > +
> > +	/* the page for emergency shouldn't be cached */
> > +	if (migratetype == MIGRATE_RESERVE) {
> > +		free_one_page(zone, page, 0);
> > +		goto out;
> > +	}
> >  	if (cold)
> >  		list_add_tail(&page->lru, &pcp->list);
> >  	else
> >  		list_add(&page->lru, &pcp->list);
> > -	set_page_private(page, get_pageblock_migratetype(page));
> >  	pcp->count++;
> >  	if (pcp->count >= pcp->high) {
> >  		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
> >  		pcp->count -= pcp->batch;
> >  	}
> > +
> > +out:
> >  	local_irq_restore(flags);
> >  	put_cpu();
> >  }
> > 
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
