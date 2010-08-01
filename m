Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C8C7B600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 07:56:57 -0400 (EDT)
Date: Sun, 1 Aug 2010 19:56:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100801115640.GA18943@localhost>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
 <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
 <20100730150601.199c5618.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100730150601.199c5618.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> Sigh.  We have sooo many problems with writeback and latency.  Read
> https://bugzilla.kernel.org/show_bug.cgi?id=12309 and weep.  Everyone's
> running away from the issue and here we are adding code to solve some
> alleged stack-overflow problem which seems to be largely a non-problem,
> by making changes which may worsen our real problems.

I'm sweeping bug 12309. Most people reports some data writes, though
relative few explicitly stated memory pressure is another necessary
condition.

One interesting report is #3. Thomas reported the same slowdown
_without_ any IO. He was able to narrow down the bug to somewhere
between 2.6.20.21 and 2.6.22.19. I searched through the git and found
a congestion_wait() in commit 232ea4d69d (throttle_vm_writeout():
don't loop on GFP_NOFS and GFP_NOIO allocations) which was later
removed by commit 369f2389e7 (writeback: remove unnecessary wait in
throttle_vm_writeout()).

How can the congestion_wait(HZ/10) be a problem? Because it
unconditionally enters wait loop. So if no IO is underway, it
virtually becomes a schedule_timeout(HZ/10) because there are
no IO completion events to wake it up.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
