Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD186B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:25:49 -0500 (EST)
Date: Wed, 8 Dec 2010 17:23:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-Id: <20101208172324.d45911f4.akpm@linux-foundation.org>
In-Reply-To: <20101209003621.GB3796@hostway.ca>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:

> On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
> 
> > Kswapd tries to rebalance zones persistently until their high
> > watermarks are restored.
> > 
> > If the amount of unreclaimable pages in a zone makes this impossible
> > for reclaim, though, kswapd will end up in a busy loop without a
> > chance of reaching its goal.
> > 
> > This behaviour was observed on a virtual machine with a tiny
> > Normal-zone that filled up with unreclaimable slab objects.
> > 
> > This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> > leaves them to direct reclaim.
> 
> Hi!
> 
> We are experiencing a similar issue, though with a 757 MB Normal zone,
> where kswapd tries to rebalance Normal after an order-3 allocation while
> page cache allocations (order-0) keep splitting it back up again.  It can
> run the whole day like this (SSD storage) without sleeping.

People at google have told me they've seen the same thing.  A fork is
taking 15 minutes when someone else is doing a dd, because the fork
enters direct-reclaim trying for an order-one page.  It successfully
frees some order-one pages but before it gets back to allocate one, dd
has gone and stolen them, or split them apart.

This problem would have got worse when slub came along doing its stupid
unnecessary high-order allocations.

Billions of years ago a direct-reclaimer had a one-deep cache in the
task_struct into which it freed the page to prevent it from getting
stolen.

Later, we took that out because pages were being freed into the
per-cpu-pages magazine, which is effectively task-local anyway.  But
per-cpu-pages are only for order-0 pages.  See slub stupidity, above.

I expect that this is happening so repeatably because the
direct-reclaimer is dong a sleep somewhere after freeing the pages it
needs - if it wasn't doing that then surely the window wouldn't be wide
enough for it to happen so often.  But I didn't look.

Suitable fixes might be

a) don't go to sleep after the successful direct-reclaim.

b) reinstate the one-deep task-local free page cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
