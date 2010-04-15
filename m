Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 81D27600375
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:34:00 -0400 (EDT)
Date: Fri, 16 Apr 2010 09:33:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if
 current is kswapd
Message-ID: <20100415233339.GW2493@dastard>
References: <20100415013436.GO2493@dastard>
 <20100415130212.D16E.A69D9226@jp.fujitsu.com>
 <20100415131106.D174.A69D9226@jp.fujitsu.com>
 <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
 <20100415093214.GV2493@dastard>
 <85DB7083-8E78-4884-9E76-5BD803C530EF@freebsd.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85DB7083-8E78-4884-9E76-5BD803C530EF@freebsd.org>
Sender: owner-linux-mm@kvack.org
To: Suleiman Souhlal <ssouhlal@freebsd.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 10:27:09AM -0700, Suleiman Souhlal wrote:
> 
> On Apr 15, 2010, at 2:32 AM, Dave Chinner wrote:
> 
> >On Thu, Apr 15, 2010 at 01:05:57AM -0700, Suleiman Souhlal wrote:
> >>
> >>On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
> >>
> >>>Now, vmscan pageout() is one of IO throuput degression source.
> >>>Some IO workload makes very much order-0 allocation and reclaim
> >>>and pageout's 4K IOs are making annoying lots seeks.
> >>>
> >>>At least, kswapd can avoid such pageout() because kswapd don't
> >>>need to consider OOM-Killer situation. that's no risk.
> >>>
> >>>Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >>
> >>What's your opinion on trying to cluster the writes done by pageout,
> >>instead of not doing any paging out in kswapd?
> >
> >XFS already does this in ->writepage to try to minimise the impact
> >of the way pageout issues IO. It helps, but it is still not as good
> >as having all the writeback come from the flusher threads because
> >it's still pretty much random IO.
> 
> Doesn't the randomness become irrelevant if you can cluster enough
> pages?

No. If you are doing full disk seeks between random chunks, then you
still lose a large amount of throughput. e.g. if the seek time is
10ms and your IO time is 10ms for each 4k page, then increasing the
size ito 64k makes it 10ms seek and 12ms for the IO. We might increase
throughput but we are still limited to 100 IOs per second. We've
gone from 400kB/s to 6MB/s, but that's still an order of magnitude
short of the 100MB/s full size IOs with little in way of seeks
between them will acheive on the same spindle...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
