Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA71C6B00C8
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:53:15 -0400 (EDT)
Date: Mon, 27 Apr 2009 21:54:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
	a watermark[] array
Message-ID: <20090427205400.GA23510@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com> <20090427170054.GE912@csn.ul.ie> <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 27, 2009 at 01:48:47PM -0700, David Rientjes wrote:
> On Mon, 27 Apr 2009, Mel Gorman wrote:
> 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index c1fa208..1ff59fd 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -163,6 +163,13 @@ static inline int is_unevictable_lru(enum lru_list l)
> >  #endif
> >  }
> >  
> > +enum zone_watermarks {
> > +	WMARK_MIN,
> > +	WMARK_LOW,
> > +	WMARK_HIGH,
> > +	NR_WMARK
> > +};
> > +
> >  struct per_cpu_pages {
> >  	int count;		/* number of pages in the list */
> >  	int high;		/* high watermark, emptying needed */
> > @@ -275,12 +282,9 @@ struct zone_reclaim_stat {
> >  
> >  struct zone {
> >  	/* Fields commonly accessed by the page allocator */
> > -	union {
> > -		struct {
> > -			unsigned long	pages_min, pages_low, pages_high;
> > -		};
> > -		unsigned long pages_mark[3];
> > -	};
> > +
> > +	/* zone watermarks, indexed with WMARK_LOW, WMARK_MIN and WMARK_HIGH */
> > +	unsigned long watermark[NR_WMARK];
> >  
> >  	/*
> >  	 * We don't know if the memory that we're going to allocate will be freeable
> 
> I thought the suggestion was for something like
> 
> 	#define zone_wmark_min(z)	(z->pages_mark[WMARK_MIN])
> 	...

Was it the only suggestion? I thought just replacing the union with an
array would be an option as well.

The #define approach also requires setter versions like

static inline set_zone_wmark_min(struct zone *z, unsigned long val)
{
	z->pages_mark[WMARK_MIN] = val;
}

and you need one of those for each watermark if you are to avoid weirdness like

zone_wmark_min(z) = val;

which looks all wrong. I felt this approach would look neater and be closer
in appearance to the code that is already there and therefore less surprising.

Would people prefer a getter/setter version?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
