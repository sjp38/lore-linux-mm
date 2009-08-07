Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 60FCE6B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 21:03:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7713dBb004120
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Aug 2009 10:03:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F5D45DE52
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:03:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 28F7445DE4E
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:03:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCD41DB8038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:03:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BADC11DB8041
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:03:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] tracing, page-allocator: Add trace event for page traffic related to the buddy lists
In-Reply-To: <20090805094346.GC21950@csn.ul.ie>
References: <20090805182034.5BCD.A69D9226@jp.fujitsu.com> <20090805094346.GC21950@csn.ul.ie>
Message-Id: <20090807095937.5BD9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  7 Aug 2009 10:03:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > >  	TP_PROTO(const void *page,
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index c2c90cd..35b92a9 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -535,6 +535,7 @@ static void free_pages_bulk(struct zone *zone, int count,
> > >  		page = list_entry(list->prev, struct page, lru);
> > >  		/* have to delete it as __free_one_page list manipulates */
> > >  		list_del(&page->lru);
> > > +		trace_mm_page_pcpu_drain(page, order, page_private(page));
> > 
> > pcp refill (trace_mm_page_alloc_zone_locked) logged migratetype, but
> > this tracepoint doesn't. why?
> > 
> 
> It does log migratetype as migratetype is in page_private(page) in this
> context.

sorry, my fault.
thanks correct me.



> > >  		__free_one_page(page, zone, order, page_private(page));
> > >  	}
> > >  	spin_unlock(&zone->lock);
> > > @@ -878,6 +879,7 @@ retry_reserve:
> > >  		}
> > >  	}
> > >  
> > > +	trace_mm_page_alloc_zone_locked(page, order, migratetype, order == 0);
> > >  	return page;
> > >  }
> > 
> > Umm, Can we assume order-0 always mean pcp refill?
> 
> Right now, that assumption is accurate. Which callpath ends up here with
> order == 0 and it's not a PCP refill?

you are right.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
