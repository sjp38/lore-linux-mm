Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 925AF6B008A
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 21:05:18 -0500 (EST)
Date: Wed, 8 Dec 2010 18:05:14 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101209020514.GE3796@hostway.ca>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca> <20101208172324.d45911f4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101208172324.d45911f4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 05:23:24PM -0800, Andrew Morton wrote:

> People at google have told me they've seen the same thing.  A fork is
> taking 15 minutes when someone else is doing a dd, because the fork
> enters direct-reclaim trying for an order-one page.  It successfully
> frees some order-one pages but before it gets back to allocate one, dd
> has gone and stolen them, or split them apart.
> 
> This problem would have got worse when slub came along doing its stupid
> unnecessary high-order allocations.

Yeah, we can all blame slub, but even when I force everything to be
order-0 except task_struct and kmalloc(>4096), I still see problems, even
if they aren't as obvious.

Until reclaim holds a page it is about to turn into an order-1, or until
it can hold all of the pages until the watermark is reached including the
allocation it may be directly reclaiming for, this operation is always
going to be non-fair so long as kswapd can run while other allocations
are happening.

Let me guess, Linus will say RCU fixes this.. ;)

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
