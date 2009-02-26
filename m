Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8146B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 12:15:56 -0500 (EST)
Date: Thu, 26 Feb 2009 17:15:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090226171549.GH32756@csn.ul.ie>
References: <1235344649-18265-21-git-send-email-mel@csn.ul.ie> <20090223013723.1d8f11c1.akpm@linux-foundation.org> <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org> <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902261157100.7472@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 12:00:22PM -0500, Christoph Lameter wrote:
> On Thu, 26 Feb 2009, Mel Gorman wrote:
> 
> > The known-to-be-zeroed pages is interesting and something I tried but didn't
> > get far enough with. One patch I did but didn't release would zero pages on
> > the free path if the was process exiting or if it was kswapd.  It tracked if
> > the page was zero using page->index to record the order of the zerod page. On
> > allocation, it would check index and if a matching order, would not zero a
> > second time. I got this working for order-0 pages reliably but it didn't gain
> > anything because we were zeroing even more than we had to in the free path.
> 
> I tried the general use of a pool of zeroed pages back in 2005. Zeroing
> made sense only if the code allocating the page did not immediately touch
> the cachelines of the page.

Any feeling as to how often this was the case?

> The more cachelines were touched the less the
> benefit. If the page is written to immediately afterwards then the zeroing
> simply warms up the caches.
> 
> page table pages are different. We may only write to a few cachelines in
> the page. There it makes sense and that is why we have the special
> quicklists there.
> 
> > If pagetable pages were known to be zero and handed back to the allocator
> > that remember zerod pages, I bet we'd get a win.
> 
> We have quicklists that do this on various platforms.
> 

Indeed, any gain if it existed would be avoiding zeroing the pages used
by userspace. The cleanup would be reducing the amount of
architecture-specific code.

I reckon it's worth an investigate but there is still other lower-lying
fruit.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
