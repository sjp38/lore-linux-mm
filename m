Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7BEE6B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 21:17:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n771HxWP024548
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Aug 2009 10:17:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E64DC45DE4F
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:17:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C578A45DE4E
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:17:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6C4C1DB803C
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:17:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E6681DB8038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:17:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] tracing, page-allocator: Add trace events for page allocation and page freeing
In-Reply-To: <20090805094019.GB21950@csn.ul.ie>
References: <20090805165302.5BC8.A69D9226@jp.fujitsu.com> <20090805094019.GB21950@csn.ul.ie>
Message-Id: <20090807100502.5BDC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  7 Aug 2009 10:17:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index d052abb..843bdec 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1905,6 +1905,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> > >  				zonelist, high_zoneidx, nodemask,
> > >  				preferred_zone, migratetype);
> > >  
> > > +	trace_mm_page_alloc(_RET_IP_, page, order, gfp_mask, migratetype);
> > >  	return page;
> > >  }
> > 
> > In almost case, __alloc_pages_nodemask() is called from alloc_pages_current().
> > Can you add call_site argument? (likes slab_alloc)
> > 
> 
> In the NUMA case, this will be true but addressing it involves passing down
> an additional argument in the non-tracing case which I wanted to avoid.
> As the stacktrace option is available to ftrace, I think I'll drop call_site
> altogether as anyone who really needs that information has options.

Insted, can we move this tracepoint to alloc_pages_current(), alloc_pages_node() et al ?
On page tracking case, call_site information is one of most frequently used one.
if we need multiple trace combination, it become hard to use and reduce usefulness a bit.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
