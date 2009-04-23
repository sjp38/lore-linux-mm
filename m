Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51C076B0113
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 20:29:12 -0400 (EDT)
Date: Thu, 23 Apr 2009 01:29:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
	watermark
Message-ID: <20090423002934.GC26643@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 01:06:07PM -0700, David Rientjes wrote:
> On Wed, 22 Apr 2009, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index b174f2c..6030f49 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1154,10 +1154,15 @@ failed:
> >  	return NULL;
> >  }
> >  
> > -#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
> > -#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
> > -#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
> > -#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
> > +/* The WMARK bits are used as an index zone->pages_mark */
> > +#define ALLOC_WMARK_MIN		0x00 /* use pages_min watermark */
> > +#define ALLOC_WMARK_LOW		0x01 /* use pages_low watermark */
> > +#define ALLOC_WMARK_HIGH	0x02 /* use pages_high watermark */
> > +#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> > +
> > +/* Mask to get the watermark bits */
> > +#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> > +
> >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> >  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> 
> The watermark flags should probably be members of an anonymous enum since 
> they're being used as an index into an array.  If another watermark were 
> ever to be added it would require a value of 0x03, for instance.
> 
> 	enum {
> 		ALLOC_WMARK_MIN,
> 		ALLOC_WMARK_LOW,
> 		ALLOC_WMARK_HIGH,
> 
> 		ALLOC_WMARK_MASK = 0xf	/* no more than 16 possible watermarks */
> 	};
> 
> This eliminates ALLOC_NO_WATERMARKS and the caller that uses it would 
> simply pass 0.
> 

I'm missing something here. If ALLOC_NO_WATERMARKS was defined as zero
then thing like this break.

        if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
                if (!in_interrupt() &&
                    ((p->flags & PF_MEMALLOC) ||
                     unlikely(test_thread_flag(TIF_MEMDIE))))
                        alloc_flags |= ALLOC_NO_WATERMARKS;
        }

Also, the ALLOC_HARDER and other alloc flags need to be redefined for
ALLOC_WMARK_MASK == 0xf. I know what you are getting at but it's a bit more
involved than you're making out and I'm not seeing an advantage.

> > @@ -1445,12 +1450,7 @@ zonelist_scan:
> >  
> >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> 
> This would become
> 
> 	if (alloc_flags & ALLOC_WMARK_MASK)
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
