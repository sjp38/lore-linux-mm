Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 12C226008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:45:15 -0400 (EDT)
Date: Tue, 3 Aug 2010 14:52:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/9] Reduce writeback from page reclaim context V5
Message-ID: <20100803125249.GD3322@quack.suse.cz>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
 <20100729084523.GA537@infradead.org>
 <20100803073449.GA21452@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803073449.GA21452@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue 03-08-10 15:34:49, Wu Fengguang wrote:
> On Thu, Jul 29, 2010 at 04:45:23PM +0800, Christoph Hellwig wrote:
> > Btw, I'm very happy with all this writeback related progress we've made
> > for the 2.6.36 cycle.  The only major thing that's really missing, and
> > which should help dramatically with the I/O patters is stopping direct
> > writeback from balance_dirty_pages().  I've seen patches frrom Wu and
> > and Jan for this and lots of discussion.  If we get either variant in
> > this should be once of the best VM release from the filesystem point of
> > view.
> 
> Sorry for the delay. But I'm not feeling good about the current
> patches, both mine and Jan's.
> 
> Accounting overheads/accuracy are the obvious problem. Both patches do
> not perform well on large NUMA machines and fast storage. They are found
> hard to improve in previous discussions.
  Yes, my patch for balance_dirty_pages() has a problem with percpu counter
(im)precision and resorting to pure atomic type could result in bouncing
of the cache line among CPUs completing the IO (at least that is the reason
why all other BDI stats are per-cpu I believe).
  We could solve the problem by doing the accounting on page IO submission
time (there using the atomic type should be fine as we mostly submit IO
from the flusher thread anyway). It's just that doing the accounting on
completion time has the nice property that we really hold the throttled
thread upto the moment when vm can really reuse the pages.

> We might do dirty throttling based on throughput, ignoring the
> writeback completions totally. The basic idea is, for current process,
> we already have a per-bdi-and-task threshold B as the local throttle
  Do we? The limit is currently just per-bdi, isn't it? Or do you mean
the ratelimiting - i.e. how often do we call balance_dirty_pages()?
That is per-cpu if I'm right.

> target. When dirty pages go beyond B*80% for example, we start
> throttling the task's writeback throughput. The more closer to B, the
> lower throughput. When reaches B or global threshold, we completely
> stop it. The hope is, the throughput will be sustained at some balance
> point. This will need careful calculation to perform stable/robust.
  But what do you exactly mean by throttling the task in your scenario?
What would it wait on?

> In this way, the throttle can be made very smooth.  My old experiments
> show that the current writeback completion based throttling fluctuates
> a lot for the stall time. In particular it makes bumpy writeback for
> NFS, so that some times the network pipe is not active at all and
> performance is impacted noticeably.
> 
> By the way, we'll harvest a writeback IO controller :)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
