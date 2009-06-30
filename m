Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BCFDC6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 11:10:48 -0400 (EDT)
Date: Tue, 30 Jun 2009 16:11:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
Message-ID: <20090630151103.GF17561@csn.ul.ie>
References: <20090623200846.223C.A69D9226@jp.fujitsu.com> <20090629084114.GA28597@csn.ul.ie> <20090630092847.A730.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090630092847.A730.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 09:31:04AM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> Thank you new version.
> 
> > ==== CUT HERE ====
> > mm: Warn once when a page is freed with PG_mlocked set
> >     
> > When a page is freed with the PG_mlocked set, it is considered an unexpected
> > but recoverable situation. A counter records how often this event happens
> > but it is easy to miss that this event has occured at all. This patch warns
> > once when PG_mlocked is set to prompt debuggers to check the counter to
> > see how often it is happening.
> >     
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > --- 
> >  mm/page_alloc.c |   16 ++++++++++++----
> >  1 file changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 5d714f8..519ea6e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -495,8 +495,16 @@ static inline void free_page_mlock(struct page *page)
> >  static void free_page_mlock(struct page *page) { }
> >  #endif
> >  
> > -static inline int free_pages_check(struct page *page)
> > -{
> > +static inline int free_pages_check(struct page *page, int wasMlocked)
> > +{
> > +	if (unlikely(wasMlocked)) {
> > +		WARN_ONCE(1, KERN_WARNING
> > +			"Page flag mlocked set for process %s at pfn:%05lx\n"
> > +			"page:%p flags:0x%lX\n",
> 
> 0x%lX is a bit redundunt.
> %lX insert "0x" string by itself, I think.
> 

It does not automatically insert the 0x for me and I just did a quick
test there. Can you double check please?

> 
> > +			current->comm, page_to_pfn(page),
> > +			page, page->flags|__PG_MLOCKED);
> > +	}
> > +
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> >  		(atomic_read(&page->_count) != 0) |
> > @@ -562,7 +570,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	kmemcheck_free_shadow(page, order);
> >  
> >  	for (i = 0 ; i < (1 << order) ; ++i)
> > -		bad += free_pages_check(page + i);
> > +		bad += free_pages_check(page + i, wasMlocked);
> >  	if (bad)
> >  		return;
> >  
> > @@ -1027,7 +1035,7 @@ static void free_hot_cold_page(struct page *page, int cold)
> >  
> >  	if (PageAnon(page))
> >  		page->mapping = NULL;
> > -	if (free_pages_check(page))
> > +	if (free_pages_check(page, wasMlocked))
> >  		return;
> >  
> >  	if (!PageHighMem(page)) {
> 
> Other part looks fine. thanks.
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
