Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C4F7A6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:22:01 -0400 (EDT)
Date: Tue, 28 Apr 2009 18:15:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Properly account for freed pages in free_pages_bulk()
 and when allocating high-order pages in buffered_rmqueue()
In-Reply-To: <20090428165129.GA18893@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0904281810240.30878@blonde.anvils>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
 <1240819119.2567.884.camel@ymzhang> <20090427143845.GC912@csn.ul.ie>
 <1240883957.2567.886.camel@ymzhang> <20090428103159.GB23540@csn.ul.ie>
 <alpine.DEB.1.10.0904281236350.21913@qirst.com> <20090428165129.GA18893@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009, Mel Gorman wrote:
> On Tue, Apr 28, 2009 at 12:37:22PM -0400, Christoph Lameter wrote:
> > On Tue, 28 Apr 2009, Mel Gorman wrote:
> > 
> > > @@ -1151,6 +1151,7 @@ again:
> > >  	} else {
> > >  		spin_lock_irqsave(&zone->lock, flags);
> > >  		page = __rmqueue(zone, order, migratetype);
> > > +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> > >  		spin_unlock(&zone->lock);
> > >  		if (!page)
> > >  			goto failed;
> > 
> > __mod_zone_page_state takes an signed integer argument. Not sure what is
> > won by the UL suffix here.
> > 
> 
> Matches other call sites such as in __offline_isolated_pages(), habit when
> using shifts like this and matches other locations, paranoia, doesn't hurt.

Well, not a big deal, but I'd say that it does hurt: by wasting people's
time (mine!), wondering what that "UL" is for - I'd have had to ask, if
Christoph hadn't cleared this up first (thank you).  And elsewhere,
you're using an int << order to update NR_FREE_PAGES, so I don't see
the consistency argument.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
