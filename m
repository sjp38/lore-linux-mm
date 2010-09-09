Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2945A6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 10:32:58 -0400 (EDT)
Date: Thu, 9 Sep 2010 09:32:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct
 reclaim allocation fails
In-Reply-To: <20100909135523.GA340@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009090931360.18975@router.home>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie> <20100908163956.C930.A69D9226@jp.fujitsu.com> <20100909124138.GQ29263@csn.ul.ie> <alpine.DEB.2.00.1009090843480.18975@router.home>
 <20100909135523.GA340@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 2010, Mel Gorman wrote:

> > This will have the effect of never sending IPIs for slab allocations since
> > they do not do allocations for orders > PAGE_ALLOC_COSTLY_ORDER.
> >
>
> The question is how severe is that? There is somewhat of an expectation
> that the lower orders free naturally so it the IPI justified? That said,
> our historical behaviour would have looked like
>
> if (!page && !drained && order) {
> 	drain_all_pages();
> 	draiained = true;
> 	goto retry;
> }
>
> Play it safe for now and go with that?

I am fine with no IPIs for order <= COSTLY. Just be aware that this is
a change that may have some side effects. Lets run some tests and see
how it affect the issues that we are seeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
