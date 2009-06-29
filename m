Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 354266B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 05:15:19 -0400 (EDT)
Date: Mon, 29 Jun 2009 10:15:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Performance degradation seen after using one list for hot/cold
	pages.
Message-ID: <20090629091542.GC28597@csn.ul.ie>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20> <20090622165236.GE3981@csn.ul.ie> <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 09:06:30AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 22 Jun 2009 17:52:36 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Jun 22, 2009 at 11:32:03AM +0000, NARAYANAN GOPALAKRISHNAN wrote:
> > > Hi,
> > > 
> > > We are running on VFAT.
> > > We are using iozone performance benchmarking tool (http://www.iozone.org/src/current/iozone3_326.tar) for testing.
> > > 
> > > The parameters are 
> > > /iozone -A -s10M -e -U /tmp -f /tmp/iozone_file
> > > 
> > > Our block driver requires requests to be merged to get the best performance.
> > > This was not happening due to non-contiguous pages in all kernels >= 2.6.25.
> > > 
> > 
> > Ok, by the looks of things, all the aio_read() requests are due to readahead
> > as opposed to explicit AIO  requests from userspace. In this case, nothing
> > springs to mind that would avoid excessive requests for cold pages.
> > 
> > It looks like the simpliest solution is to go with the patch I posted.
> > Does anyone see a better alternative that doesn't branch in rmqueue_bulk()
> > or add back the hot/cold PCP lists?
> > 
> No objection.  But 2 questions...
> 
> > -        list_add(&page->lru, list);
> > +        if (likely(cold == 0))
> > +            list_add(&page->lru, list);
> > +        else
> > +            list_add_tail(&page->lru, list);
> >          set_page_private(page, migratetype);
> >          list = &page->lru;
> >      }
> 
> 1. if (likely(coild == 0))
> 	"likely" is necessary ?
> 

Is likely/unlikely ever really necessary? The branch is small so maybe it
doesn't matter but the expectation is that the !cold path is hotter and more
commonly used. I can drop this is you like.

> 2. Why moving pointer "list" rather than following ?
> 
> 	if (cold)
> 		list_add(&page->lru, list);
> 	else
> 		list_add_tail(&page->lru, list);
> 

So that the list head from the caller is at the beginning of the newly
allocated contiguous pages. Lets say the free list looked something like

head -> 212 -> 200 -> 198

and then we add a few pages that are contiguous using list_add_tail

1 -> 2 -> 3 -> head -> 212 -> 200 -> 198

With this arrangement, we have to consume the existing pages before we get to
the contiguous pages and the struct pages that were more recently accessed
are further down the list so we potentially access a new cache line after
returning so the struct page for PFN 212 is accessed. With the list head
moving forward it, the returned list should look more like

head -> 1 -> 2 -> 3 -> 212 -> 200 -> 198

so we are accessing the contiguous pages first and a recently accessed struct
page. This was the intention at least of the list head moving forward.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
