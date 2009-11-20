Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78BF26B00C0
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 09:56:44 -0500 (EST)
Date: Fri, 20 Nov 2009 14:56:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/5] page allocator: Wait on both sync and async
	congestion after direct reclaim
Message-ID: <20091120145634.GA18912@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <1258054235-3208-4-git-send-email-mel@csn.ul.ie> <20091113142526.33B3.A69D9226@jp.fujitsu.com> <20091113115558.GY8742@kernel.dk> <20091113122821.GC29804@csn.ul.ie> <20091113133211.GA8742@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091113133211.GA8742@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 02:32:12PM +0100, Jens Axboe wrote:
> On Fri, Nov 13 2009, Mel Gorman wrote:
> > On Fri, Nov 13, 2009 at 12:55:58PM +0100, Jens Axboe wrote:
> > > On Fri, Nov 13 2009, KOSAKI Motohiro wrote:
> > > > (cc to Jens)
> > > > 
> > > > > Testing by Frans Pop indicated that in the 2.6.30..2.6.31 window at least
> > > > > that the commits 373c0a7e 8aa7e847 dramatically increased the number of
> > > > > GFP_ATOMIC failures that were occuring within a wireless driver. Reverting
> > > > > this patch seemed to help a lot even though it was pointed out that the
> > > > > congestion changes were very far away from high-order atomic allocations.
> > > > > 
> > > > > The key to why the revert makes such a big difference is down to timing and
> > > > > how long direct reclaimers wait versus kswapd. With the patch reverted,
> > > > > the congestion_wait() is on the SYNC queue instead of the ASYNC. As a
> > > > > significant part of the workload involved reads, it makes sense that the
> > > > > SYNC list is what was truely congested and with the revert processes were
> > > > > waiting on congestion as expected. Hence, direct reclaimers stalled
> > > > > properly and kswapd was able to do its job with fewer stalls.
> > > > > 
> > > > > This patch aims to fix the congestion_wait() behaviour for SYNC and ASYNC
> > > > > for direct reclaimers. Instead of making the congestion_wait() on the SYNC
> > > > > queue which would only fix a particular type of workload, this patch adds a
> > > > > third type of congestion_wait - BLK_RW_BOTH which first waits on the ASYNC
> > > > > and then the SYNC queue if the timeout has not been reached.  In tests, this
> > > > > counter-intuitively results in kswapd stalling less and freeing up pages
> > > > > resulting in fewer allocation failures and fewer direct-reclaim-orientated
> > > > > stalls.
> > > > 
> > > > Honestly, I don't like this patch. page allocator is not related to
> > > > sync block queue. vmscan doesn't make read operation.
> > > > This patch makes nearly same effect of s/congestion_wait/io_schedule_timeout/.
> > > > 
> > > > Please don't make mysterious heuristic code.
> > > > 
> > > > 
> > > > Sidenode: I doubt this regression was caused from page allocator.
> > 
> > Probably not. As noted, the major change is really in how long callers
> > are waiting on congestion_wait. The tarball includes graphs from an
> > instrumented kernel that shows how long callers are waiting due to
> > congestion_wait(). This has changed significantly.
> > 
> > I'll queue up tests over the weekend that test without dm-crypt being involved.
> > 
> > > > Probably we need to confirm caller change....
> > > 
> > > See the email from Chris from yesterday, he nicely explains why this
> > > change made a difference with dm-crypt.
> > 
> > Indeed.
> > 
> > But bear in mind that it also possible that direct reclaimers are also
> > congesting the queue due to swap-in.
> 
> Are you speculating, or has this been observed? While I don't contest
> that that could happen, it's also not a new thing. And it should be an
> unlikely event.
> 
> > > dm-crypt needs fixing, not a hack like this added.
> > > 
> > 
> > As noted by Chris in the same mail, dm-crypt has not changed. What has
> > changed is how long callers wait in congestion_wait.
> 
> Right dm-crypt didn't change, it WAS ALREADY BUGGY.
> 

On a different note, I tried without dm-crypt and found by far the
greatest different to page allocator success or failure was the value of
the low_latency tunable.

low_latency == 0
2.6.32-rc6-0000000-force-highorder            Elapsed:17:50.935(stddev:002.535)   Failures:0
2.6.32-rc6-0000006-dm-crypt-unplug            Elapsed:18:44.610(stddev:002.236)   Failures:1
2.6.32-rc6-0000012-pgalloc-2.6.30             Elapsed:17:18.330(stddev:002.258)   Failures:2
2.6.32-rc6-0000123-congestion-both            Elapsed:16:17.370(stddev:002.167)   Failures:1
2.6.32-rc6-0001234-kswapd-quick-recheck       Elapsed:15:54.880(stddev:002.234)   Failures:0
2.6.32-rc6-0012345-kswapd-stay-awake-when-min Elapsed:19:26.417(stddev:002.237)   Failures:1
2.6.32-rc6-0123456-dm-crypt-unplug            Elapsed:20:19.135(stddev:001.516)   Failures:0

low_latency == 1
2.6.32-rc6-0000000-force-highorder            Elapsed:20:04.755(stddev:078.551)   Failures:22
2.6.32-rc6-0000006-dm-crypt-unplug            Elapsed:25:05.608(stddev:053.224)   Failures:12
2.6.32-rc6-0000012-pgalloc-2.6.30             Elapsed:19:01.530(stddev:002.146)   Failures:14
2.6.32-rc6-0000123-congestion-both            Elapsed:18:01.938(stddev:002.171)   Failures:2
2.6.32-rc6-0001234-kswapd-quick-recheck       Elapsed:19:52.833(stddev:064.168)   Failures:7
2.6.32-rc6-0012345-kswapd-stay-awake-when-min Elapsed:26:25.767(stddev:050.827)   Failures:1
2.6.32-rc6-0123456-dm-crypt-unplug            Elapsed:22:56.850(stddev:053.914)   Failures:1

Setting low_latency both regresses performance of the test and causes a
boatload of allocation failures. Note also the deviations. With
low_latency == 0, gitk performs predictably +/- around 2 seconds. With
low_latency == 1, there are huge varianes +/- about a minute.

Sampling writeback, I found that the number of pages in writeback with
low_latency == 1 was higher for longer.

Any theories as to why enabling low_latency has such a negative impact?
Should it be disabled by default?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
