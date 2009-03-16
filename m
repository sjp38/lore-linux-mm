Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 63D6C6B004F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:52:23 -0400 (EDT)
Date: Mon, 16 Mar 2009 16:52:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 31/35] Optimistically check the first page on the PCP
	free list is suitable
Message-ID: <20090316165220.GO24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-32-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161232130.32577@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903161232130.32577@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 12:33:44PM -0400, Christoph Lameter wrote:
> On Mon, 16 Mar 2009, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bb5bd5e..8568284 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1212,6 +1212,12 @@ again:
> >  				if (pcp_page_suit(page, order))
> >  					break;
> >  		} else {
> > +			/* Optimistic before we start a list search */
> > +			page = list_entry(list->next, struct page, lru);
> > +			if (pcp_page_suit(page, order))
> > +				goto found;
> > +
> > +			/* Do the search */
> >  			list_for_each_entry(page, list, lru)
> >  				if (pcp_page_suit(page, order))
> >  					break;
> 
> I am not convinced that this is beneficial. If it would then the compiler
> would unroll the loop.
> 

It hit a large number of times when I checked (although I don't have the
figures any more) and the list_for_each_entry() does a prefetch
possibly fetching in a line we don't need.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
