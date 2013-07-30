Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3A6816B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 13:45:46 -0400 (EDT)
Date: Tue, 30 Jul 2013 13:45:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: vmscan: fix numa reclaim balance problem in
 kswapd
Message-ID: <20130730174539.GF715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-2-git-send-email-hannes@cmpxchg.org>
 <20130726155319.21e8a191456bf8a0ff724199@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726155319.21e8a191456bf8a0ff724199@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 26, 2013 at 03:53:19PM -0700, Andrew Morton wrote:
> On Fri, 19 Jul 2013 16:55:23 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > When the page allocator fails to get a page from all zones in its
> > given zonelist, it wakes up the per-node kswapds for all zones that
> > are at their low watermark.
> > 
> > However, with a system under load and the free page counters being
> > per-cpu approximations, the observed counter value in a zone can
> > fluctuate enough that the allocation fails but the kswapd wakeup is
> > also skipped while the zone is still really close to the low
> > watermark.
> > 
> > When one node misses a wakeup like this, it won't be aged before all
> > the other node's zones are down to their low watermarks again.  And
> > skipping a full aging cycle is an obvious fairness problem.
> > 
> > Kswapd runs until the high watermarks are restored, so it should also
> > be woken when the high watermarks are not met.  This ages nodes more
> > equally and creates a safety margin for the page counter fluctuation.
> 
> Well yes, but what guarantee is there that the per-cpu counter error
> problem is reliably fixed?  AFAICT this patch "fixes" it because the
> gap between the low and high watermarks happens to be larger than the
> per-cpu counter fluctuation, yes?  If so, there are surely all sorts of
> situations where it will break again.
> 
> To fix this reliably, we should be looking at constraining counter
> batch sizes or performing a counter summation to get the more accurate
> estimate?

Thinking about this some more, the per-cpu fluctuation appears to be a
red herring in this case.  Kswapd wakeup uses the safe version of the
watermark checking code.  A percpu inaccuracy would result in the
allocator waking kswapd a little too early or too late, but once it
decides to wake it, we are getting an accurate picture on all zones.
The safe watermark checks are designed to catch percpu inaccuracies
between the low and the min watermark, the distance between low and
high is twice as big, so we should be good.

The fluctuation that makes individual zones miss full aging cycles
comes from true free page variation under load when the NOT OK
threshold for the allocator is the same value as the OK threshold for
skipping kswapd wakeups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
