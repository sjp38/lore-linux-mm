Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2056B00BC
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 05:32:38 -0500 (EST)
Date: Tue, 9 Mar 2010 21:32:32 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 3/3] vmscan: Put kswapd to sleep on its own waitqueue,
 not congestion
Message-ID: <20100309103232.GH8653@laptop>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
 <1268048904-19397-4-git-send-email-mel@csn.ul.ie>
 <20100309100044.GE8653@laptop>
 <20100309102145.GB4883@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309102145.GB4883@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 10:21:46AM +0000, Mel Gorman wrote:
> On Tue, Mar 09, 2010 at 09:00:44PM +1100, Nick Piggin wrote:
> > On Mon, Mar 08, 2010 at 11:48:23AM +0000, Mel Gorman wrote:
> > > If kswapd is raising its priority to get the zone over the high
> > > watermark, it may call congestion_wait() ostensibly to allow congestion
> > > to clear. However, there is no guarantee that the queue is congested at
> > > this point because it depends on kswapds previous actions as well as the
> > > rest of the system. Kswapd could simply be working hard because there is
> > > a lot of SYNC traffic in which case it shouldn't be sleeping.
> > > 
> > > Rather than waiting on congestion and potentially sleeping for longer
> > > than it should, this patch puts kswapd back to sleep on the kswapd_wait
> > > queue for the timeout. If direct reclaimers are in trouble, kswapd will
> > > be rewoken as it should instead of sleeping when there is work to be
> > > done.
> > 
> > Well but it is quite possible that many allocators are coming in to
> > wake it up. So with your patch, I think we'd need to consider the case
> > where the timeout approaches 0 here (if it's always being woken).
> > 
> 
> True, similar to how zonepressure_wait() rechecks the watermarks if
> there is still a timeout left and deciding whether to sleep again or
> not.
> 
> > Direct reclaimers need not be involved because the pages might be
> > hovering around the asynchronous reclaim watermarks (which would be
> > the ideal case of system operation).
> > 
> > In which case, can you explain how this change makes sense? Why is
> > it a good thing not to wait when we previously did wait?
> > 
> 
> Well, it makes sense from the perspective it's better for kswapd to be doing
> work than direct reclaim. If processes are hitting the watermarks then
> why should kswapd be asleep?

Well I said we should consider the case where level is remaining within
the asynch watermarks.

The kswapd waitqueue does not correlate so well to direct reclaimers.

And I don't know if I agree with your assertion really. Once we _know_
we have to do direct reclaim anyway, it is too late to wait for kswapd
(unless we change that aspect of reclaim so it actually does wait for
kswapd or limit direct reclaimers).

And also, once we know we have to do direct reclaim (eg. under serious
memory pressure), then maybe it actually would be better to account
CPU time to the processes doing the allocations rather than kswapd.

kswapd seems a good thing for when we *are* able to keep up with asynch
watermarks, but after that it isn't quite so clear (FS|IO reclaim
context is obviously also a good thing too).

 
> That said, if the timeout was non-zero it should be able to make some decision
> on whether it should be really awake. Putting the page allocator and kswapd
> patches into the same series was a mistake because it's conflating two
> different problems as one. I'm going to drop this one for the moment and
> treat the page allocator patch in isolation.

Probably a good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
