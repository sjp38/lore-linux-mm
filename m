Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6825C6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 13:58:59 -0400 (EDT)
Date: Mon, 8 Jun 2009 19:58:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc][patch] swap: virtual swap readahead
Message-ID: <20090608175808.GD7563@cmpxchg.org>
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org> <20090608075246.GA12644@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090608075246.GA12644@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 03:52:46PM +0800, Wu Fengguang wrote:
> On Wed, May 27, 2009 at 05:05:46PM +0200, Johannes Weiner wrote:
> > The current swap readahead implementation reads a physically
> > contiguous group of swap slots around the faulting page to take
> > advantage of the disk head's position and in the hope that the
> > surrounding pages will be needed soon as well.
> > 
> > This works as long as the physical swap slot order approximates the
> > LRU order decently, otherwise it wastes memory and IO bandwidth to
> > read in pages that are unlikely to be needed soon.
> > 
> > However, the physical swap slot layout diverges from the LRU order
> > with increasing swap activity, i.e. high memory pressure situations,
> > and this is exactly the situation where swapin should not waste any
> > memory or IO bandwidth as both are the most contended resources at
> > this point.
> > 
> > This patch makes swap-in base its readaround window on the virtual
> > proximity of pages in the faulting VMA, as an indicator for pages
> > needed in the near future, while still taking physical locality of
> > swap slots into account.
> > 
> > This has the advantage of reading in big batches when the LRU order
> > matches the swap slot order while automatically throttling readahead
> > when the system is thrashing and swap slots are no longer nicely
> > grouped by LRU order.
> 
> Hi Johannes,
> 
> You may want to test the patch against a real desktop :)
> The attached scripts can do that. I also have the setup to
> test it out conveniently, so if you send me the latest patch..

Thanks a bunch for the offer!  I'm just now incorporating Hugh's
feedback and hope I will be back soon with the next version.  I will
let you know, for sure.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
