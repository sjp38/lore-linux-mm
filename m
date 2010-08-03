Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EB35D6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 03:29:18 -0400 (EDT)
Date: Tue, 3 Aug 2010 15:34:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/9] Reduce writeback from page reclaim context V5
Message-ID: <20100803073449.GA21452@localhost>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
 <20100729084523.GA537@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729084523.GA537@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 04:45:23PM +0800, Christoph Hellwig wrote:
> Btw, I'm very happy with all this writeback related progress we've made
> for the 2.6.36 cycle.  The only major thing that's really missing, and
> which should help dramatically with the I/O patters is stopping direct
> writeback from balance_dirty_pages().  I've seen patches frrom Wu and
> and Jan for this and lots of discussion.  If we get either variant in
> this should be once of the best VM release from the filesystem point of
> view.

Sorry for the delay. But I'm not feeling good about the current
patches, both mine and Jan's.

Accounting overheads/accuracy are the obvious problem. Both patches do
not perform well on large NUMA machines and fast storage. They are found
hard to improve in previous discussions.

We might do dirty throttling based on throughput, ignoring the
writeback completions totally. The basic idea is, for current process,
we already have a per-bdi-and-task threshold B as the local throttle
target. When dirty pages go beyond B*80% for example, we start
throttling the task's writeback throughput. The more closer to B, the
lower throughput. When reaches B or global threshold, we completely
stop it. The hope is, the throughput will be sustained at some balance
point. This will need careful calculation to perform stable/robust.

In this way, the throttle can be made very smooth.  My old experiments
show that the current writeback completion based throttling fluctuates
a lot for the stall time. In particular it makes bumpy writeback for
NFS, so that some times the network pipe is not active at all and
performance is impacted noticeably.

By the way, we'll harvest a writeback IO controller :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
