Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C5346B01AF
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 21:40:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o651dwm8011096
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 5 Jul 2010 10:39:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7538645DE6F
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:39:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 57F8B45DE6E
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:39:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 426AD1DB803A
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:39:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B22E81DB8041
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:39:54 +0900 (JST)
Date: Mon, 5 Jul 2010 10:35:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/14] Avoid overflowing of stack during page reclaim V3
Message-Id: <20100705103506.8fbd1509.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100702123315.667c6eac.akpm@linux-foundation.org>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<20100702123315.667c6eac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jul 2010 12:33:15 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 29 Jun 2010 12:34:34 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Here is V3 that depends again on flusher threads to do writeback in
> > direct reclaim rather than stack switching which is not something I'm
> > likely to get done before xfs/btrfs are ignoring writeback in mainline
> > (phd sucking up time).
> 
> IMO, implemetning stack switching for this is not a good idea.  We
> _already_ have a way of doing stack-switching.  It's called
> "schedule()".
> 
Sure. 

> The only reason I can see for implementing an in-place stack switch
> would be if schedule() is too expensive.  And if we were to see
> excessive context-switch overheads in this code path (and we won't)
> then we should get in there and try to reduce the contect switch rate
> first.
> 

Maybe a concern of in-place stack exchange lovers is that it's difficult
to guarantee when the pageout() will be issued.

I'd like to try to add a call as

 - pageout_request(page) .... request to pageout a page to a daemon(kswapd).
 - pageout_barrier(zone? node?) .... wait until all writebacks ends.

Implementation dilemmna:

Because page->lru is very useful link to implement calls like above, but
there is a concern that using it will hide pages from vmscan unnecessarily.
Avoding to use of page->lru means to use another structure like pagevec,
but it means page_count()+1 and pins pages unnecessarily. I'm now considering
how to implement safe&scalable way to pageout-in-another-stack(thread)...
I wonder it will require some throttling method for pageout, anyway.

And my own problem is that I should add per-memcg threads or using some
thread-pool ;( But it will be an another topic.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
