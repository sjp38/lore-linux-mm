Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C678D600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 07:16:16 -0400 (EDT)
Date: Sun, 1 Aug 2010 19:15:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100801111544.GC7515@localhost>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
 <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
 <20100730150601.199c5618.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100730150601.199c5618.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> Sigh.  We have sooo many problems with writeback and latency.  Read
> https://bugzilla.kernel.org/show_bug.cgi?id=12309 and weep.  Everyone's
> running away from the issue and here we are adding code to solve some
> alleged stack-overflow problem which seems to be largely a non-problem,
> by making changes which may worsen our real problems.

This looks like some vmscan/writeback interaction issue.

Firstly, the CFQ io scheduler can already prevent read IO from being
delayed by lots of ASYNC write IO. See the commits 365722bb/8e2967555
in late 2009.

Reading a big file in an idle system:
        680897928 bytes (681 MB) copied, 15.8986 s, 42.8 MB/s

Reading a big file while doing sequential writes to another file:
        680897928 bytes (681 MB) copied, 27.6007 s, 24.7 MB/s
        680897928 bytes (681 MB) copied, 25.6592 s, 26.5 MB/s

So CFQ offers reasonable read performance under heavy writeback.

Secondly, I can only feel the responsiveness lags when there are
memory pressures _in addition to_ heavy writeback.

        cp /dev/zero /tmp

No lags.

        usemem 1g --sleep 1000

Still no lags.

        usemem 1g --sleep 1000

Still no lags.

        usemem 1g --sleep 1000

Begin to feel lags at times. My desktop has 4G memory and no swap
space. So the lags are correlated with page reclaim pressure.

The above symptoms are matched very well by the patches posted by
KOSAKI and me:

- vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
- vmscan: synchronous lumpy reclaim don't call congestion_wait()

However kernels as early as 2.6.18 are reported to have the problem,
so there may be more hidden issues.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
