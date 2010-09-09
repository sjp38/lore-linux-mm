Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8316C6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 11:06:28 -0400 (EDT)
Date: Thu, 9 Sep 2010 16:05:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
	direct reclaim allocation fails
Message-ID: <20100909150558.GB340@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie> <20100908163956.C930.A69D9226@jp.fujitsu.com> <20100909124138.GQ29263@csn.ul.ie> <alpine.DEB.2.00.1009090843480.18975@router.home> <20100909135523.GA340@csn.ul.ie> <alpine.DEB.2.00.1009090931360.18975@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009090931360.18975@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 09:32:52AM -0500, Christoph Lameter wrote:
> On Thu, 9 Sep 2010, Mel Gorman wrote:
> 
> > > This will have the effect of never sending IPIs for slab allocations since
> > > they do not do allocations for orders > PAGE_ALLOC_COSTLY_ORDER.
> > >
> >
> > The question is how severe is that? There is somewhat of an expectation
> > that the lower orders free naturally so it the IPI justified? That said,
> > our historical behaviour would have looked like
> >
> > if (!page && !drained && order) {
> > 	drain_all_pages();
> > 	draiained = true;
> > 	goto retry;
> > }
> >
> > Play it safe for now and go with that?
> 
> I am fine with no IPIs for order <= COSTLY. Just be aware that this is
> a change that may have some side effects.

I made the choice consciously. I felt that if slab or slub were depending on
IPIs to make successful allocations in low-memory conditions that it would
experience varying stalls on bigger machines due to increased interrupts that
might be difficult to diagnose while not necessarily improving allocation
success rates. I also considered that if the machine is under pressure then
slab and slub may also be releasing pages of the same order and effectively
recycling their pages without depending on IPIs.

> Lets run some tests and see
> how it affect the issues that we are seeing.
> 

Perfect, thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
