Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F15236B008A
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 14:39:57 -0400 (EDT)
Date: Sun, 21 Jun 2009 20:37:30 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090621183730.GA4796@cmpxchg.org>
References: <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost> <20090611101741.GA1974@cmpxchg.org> <20090612015927.GA6804@localhost> <20090615182216.GA1661@cmpxchg.org> <20090618091949.GA711@localhost> <20090618130121.GA1817@cmpxchg.org> <Pine.LNX.4.64.0906211858560.3968@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906211858560.3968@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 07:07:03PM +0100, Hugh Dickins wrote:
> Hi Hannes,
> 
> On Thu, 18 Jun 2009, Johannes Weiner wrote:
> > On Thu, Jun 18, 2009 at 05:19:49PM +0800, Wu Fengguang wrote:
> > 
> > Okay, evaluating this test-patch any further probably isn't worth it.
> > It's too aggressive, I think readahead is stealing pages reclaimed by
> > other allocations which in turn oom.
> > 
> > Back to the original problem: you detected increased latency for
> > launching new applications, so they get less share of the IO bandwidth
> > than without the patch.
> > 
> > I can see two reasons for this:
> > 
> >   a) the new heuristics don't work out and we read more unrelated
> >   pages than before
> > 
> >   b) we readahead more pages in total as the old code would stop at
> >   holes, as described above
> > 
> > We can verify a) by comparing major fault numbers between the two
> > kernels with your testload.  If they increase with my patch, we
> > anticipate the wrong slots and every fault has do the reading itself.
> > 
> > b) seems to be a trade-off.  After all, the IO resources you have less
> > for new applications in your test is the bandwidth that is used by
> > swapping applications.  My qsbench numbers are a sign for this as the
> > only IO going on is swap.
> > 
> > Of course, the theory is not to improve swap performance by increasing
> > the readahead window but to choose better readahead candidates.  So I
> > will run your tests and qsbench with a smaller page cluster and see if
> > this improves both loads.
> 
> Hmm, sounds rather pessimistic; but I've not decided about it either.

It seems the problem was not that real after all:

	http://lkml.org/lkml/2009/6/18/109

> May I please hand over to you this collection of adjustments to your
> v3 virtual swap readahead patch, for you to merge in or split up or
> mess around with, generally take ownership of, however you wish?
> So you can keep adjusting shmem.c to match memory.c if necessary.

I will adopt them, thank you!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
