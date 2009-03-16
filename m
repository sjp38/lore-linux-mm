Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACAB6B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:42:56 -0400 (EDT)
Date: Mon, 16 Mar 2009 16:42:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 23/35] Update NR_FREE_PAGES only as necessary
Message-ID: <20090316164238.GK24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-24-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161214080.32577@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903161214080.32577@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 12:17:15PM -0400, Christoph Lameter wrote:
> On Mon, 16 Mar 2009, Mel Gorman wrote:
> 
> > When pages are being freed to the buddy allocator, the zone
> > NR_FREE_PAGES counter must be updated. In the case of bulk per-cpu page
> > freeing, it's updated once per page. This retouches cache lines more
> > than necessary. Update the counters one per per-cpu bulk free.
> 
> Not sure about the reasoning here since the individual updates are batched

Each update take places between lots of other work with different cache
lines. With enough buddy merging, I believed the line holding the counters
could at least get pushed out of L1 although probably not L2 cache.

> and you are touching the same cacheline as the pcp you are operating on
> and have to touch anyways.
> 
> But if its frequent that __rmqueue_smallest() and free_pages_bulk() are
> called with multiple pages then its always a win.
> 

It's frequent enough that it showed up in profiles

> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 
> > +	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order) * i);
> 
> A multiplication? Okay with contemporary cpus I guess.
> 

Replaced with

__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
