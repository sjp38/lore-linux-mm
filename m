Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA23F6B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 08:17:45 -0400 (EDT)
Date: Wed, 15 Jul 2009 13:56:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
	(resend)
Message-ID: <20090715125652.GA29749@csn.ul.ie>
References: <20090715104833.GB9267@csn.ul.ie> <20090715124509.GA1854@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090715124509.GA1854@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 15, 2009 at 02:45:09PM +0200, Johannes Weiner wrote:
> Hello Mel,
> 
> On Wed, Jul 15, 2009 at 11:48:34AM +0100, Mel Gorman wrote:
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
> > index caa9268..f8902e7 100644
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
> > +			current->comm, page_to_pfn(page),
> > +			page, page->flags|__PG_MLOCKED);
> 
> Since the warning is the only action in this branch, wouldn't
> WARN_ONCE(wasMlocked, KERN_WARNING ...) be better?
> 

It was to have the unlikely() but now that I look at WARN_ONCE(), it
looks like it does the unlikely() part already. Will send another
version. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
