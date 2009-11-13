Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 82DB56B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 07:28:28 -0500 (EST)
Date: Fri, 13 Nov 2009 12:28:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/5] page allocator: Wait on both sync and async
	congestion after direct reclaim
Message-ID: <20091113122821.GC29804@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <1258054235-3208-4-git-send-email-mel@csn.ul.ie> <20091113142526.33B3.A69D9226@jp.fujitsu.com> <20091113115558.GY8742@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091113115558.GY8742@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 12:55:58PM +0100, Jens Axboe wrote:
> On Fri, Nov 13 2009, KOSAKI Motohiro wrote:
> > (cc to Jens)
> > 
> > > Testing by Frans Pop indicated that in the 2.6.30..2.6.31 window at least
> > > that the commits 373c0a7e 8aa7e847 dramatically increased the number of
> > > GFP_ATOMIC failures that were occuring within a wireless driver. Reverting
> > > this patch seemed to help a lot even though it was pointed out that the
> > > congestion changes were very far away from high-order atomic allocations.
> > > 
> > > The key to why the revert makes such a big difference is down to timing and
> > > how long direct reclaimers wait versus kswapd. With the patch reverted,
> > > the congestion_wait() is on the SYNC queue instead of the ASYNC. As a
> > > significant part of the workload involved reads, it makes sense that the
> > > SYNC list is what was truely congested and with the revert processes were
> > > waiting on congestion as expected. Hence, direct reclaimers stalled
> > > properly and kswapd was able to do its job with fewer stalls.
> > > 
> > > This patch aims to fix the congestion_wait() behaviour for SYNC and ASYNC
> > > for direct reclaimers. Instead of making the congestion_wait() on the SYNC
> > > queue which would only fix a particular type of workload, this patch adds a
> > > third type of congestion_wait - BLK_RW_BOTH which first waits on the ASYNC
> > > and then the SYNC queue if the timeout has not been reached.  In tests, this
> > > counter-intuitively results in kswapd stalling less and freeing up pages
> > > resulting in fewer allocation failures and fewer direct-reclaim-orientated
> > > stalls.
> > 
> > Honestly, I don't like this patch. page allocator is not related to
> > sync block queue. vmscan doesn't make read operation.
> > This patch makes nearly same effect of s/congestion_wait/io_schedule_timeout/.
> > 
> > Please don't make mysterious heuristic code.
> > 
> > 
> > Sidenode: I doubt this regression was caused from page allocator.

Probably not. As noted, the major change is really in how long callers
are waiting on congestion_wait. The tarball includes graphs from an
instrumented kernel that shows how long callers are waiting due to
congestion_wait(). This has changed significantly.

I'll queue up tests over the weekend that test without dm-crypt being involved.

> > Probably we need to confirm caller change....
> 
> See the email from Chris from yesterday, he nicely explains why this
> change made a difference with dm-crypt.

Indeed.

But bear in mind that it also possible that direct reclaimers are also
congesting the queue due to swap-in.

> dm-crypt needs fixing, not a hack like this added.
> 

As noted by Chris in the same mail, dm-crypt has not changed. What has
changed is how long callers wait in congestion_wait.


> The vm needs to drop congestion hints and usage, not increase it. The
> above changelog is mostly hand-wavy nonsense, imho.
> 

Suggest an alternative that brings congestion_wait() more in line with
2.6.30 behaviour then.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
