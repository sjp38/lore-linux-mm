Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA9616B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:35:10 -0400 (EDT)
Date: Wed, 7 Sep 2011 10:35:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 13/18] writeback: limit max dirty pause time
Message-ID: <20110907023505.GB13755@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020916.329482509@intel.com>
 <1315320726.14232.11.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315320726.14232.11.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 06, 2011 at 10:52:06PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> 
> > +static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
> > +				   unsigned long bdi_dirty)
> > +{
> > +	unsigned long hi = ilog2(bdi->write_bandwidth);
> > +	unsigned long lo = ilog2(bdi->dirty_ratelimit);
> > +	unsigned long t;
> > +
> > +	/* target for ~10ms pause on 1-dd case */
> > +	t = HZ / 50;
> 
> 1k/50 usually ends up being 20 something

Right, 20ms for max_pause. Plus that the next patch will target for
(max_pause / 2) pause time, result in ~10ms typical pause time.

That does sound twisted, so I'll change the comment to "20ms max pause".

> > +	/*
> > +	 * Scale up pause time for concurrent dirtiers in order to reduce CPU
> > +	 * overheads.
> > +	 *
> > +	 * (N * 20ms) on 2^N concurrent tasks.
> > +	 */
> > +	if (hi > lo)
> > +		t += (hi - lo) * (20 * HZ) / 1024;
> > +
> > +	/*
> > +	 * Limit pause time for small memory systems. If sleeping for too long
> > +	 * time, a small pool of dirty/writeback pages may go empty and disk go
> > +	 * idle.
> > +	 *
> > +	 * 1ms for every 1MB; may further consider bdi bandwidth.
> > +	 */
> > +	if (bdi_dirty)
> > +		t = min(t, bdi_dirty >> (30 - PAGE_CACHE_SHIFT - ilog2(HZ)));
> 
> Yeah, I would add the bdi->avg_write_bandwidth term in there, 1g/s as an
> avg bandwidth is just too wrong..

Fair enough. On average, it will take

        T = bdi_dirty / write_bw

to clean all the bdi dirty pages. Applying a safety ratio of 8 and
convert to jiffies, we get

        T' = (T / 8) * HZ
           = bdi_dirty * HZ / (write_bw * 8)

        t = min(t, T')

> > +
> > +	/*
> > +	 * The pause time will be settled within range (max_pause/4, max_pause).
> > +	 * Apply a minimal value of 4 to get a non-zero max_pause/4.
> > +	 */
> > +	return clamp_val(t, 4, MAX_PAUSE);
> 
> So you limit to 50ms min? That still seems fairly large. Is that because
> your min sleep granularity might be something like 10ms since you're
> using jiffies?

With HZ=100, the minimal valid pause range will be (10ms, 40ms), with
typical value at 20ms.

So yeah, the HZ value does impact the minimal available sleep time...

Thanks,
Fengguang
---
Subject: writeback: limit max dirty pause time
Date: Sat Jun 11 19:21:43 CST 2011

Apply two policies to scale down the max pause time for

1) small number of concurrent dirtiers
2) small memory system (comparing to storage bandwidth)

MAX_PAUSE=200ms may only be suitable for high end servers with lots of
concurrent dirtiers, where the large pause time can reduce much overheads.

Otherwise, smaller pause time is desirable whenever possible, so as to
get good responsiveness and smooth user experiences. It's actually
required for good disk utilization in the case when all the dirty pages
can be synced to disk within MAX_PAUSE=200ms.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   46 +++++++++++++++++++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-09-07 09:33:03.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-09-07 10:33:31.000000000 +0800
@@ -953,6 +953,43 @@ static unsigned long dirty_poll_interval
 	return 1;
 }
 
+static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
+				   unsigned long bdi_dirty)
+{
+	unsigned long bw = bdi->avg_write_bandwidth;
+	unsigned long hi = ilog2(bw);
+	unsigned long lo = ilog2(bdi->dirty_ratelimit);
+	unsigned long t;
+
+	/* target for 20ms max pause on 1-dd case */
+	t = HZ / 50;
+
+	/*
+	 * Scale up pause time for concurrent dirtiers in order to reduce CPU
+	 * overheads.
+	 *
+	 * (N * 20ms) on 2^N concurrent tasks.
+	 */
+	if (hi > lo)
+		t += (hi - lo) * (20 * HZ) / 1024;
+
+	/*
+	 * Limit pause time for small memory systems. If sleeping for too long
+	 * time, a small pool of dirty/writeback pages may go empty and disk go
+	 * idle.
+	 *
+	 * 8 serves as the safety ratio.
+	 */
+	if (bdi_dirty)
+		t = min(t, bdi_dirty * HZ / (8 * bw + 1);
+
+	/*
+	 * The pause time will be settled within range (max_pause/4, max_pause).
+	 * Apply a minimal value of 4 to get a non-zero max_pause/4.
+	 */
+	return clamp_val(t, 4, MAX_PAUSE);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -973,6 +1010,7 @@ static void balance_dirty_pages(struct a
 	unsigned long bdi_thresh;
 	long period;
 	long pause = 0;
+	long max_pause;
 	bool dirty_exceeded = false;
 	unsigned long task_ratelimit;
 	unsigned long dirty_ratelimit;
@@ -1058,13 +1096,15 @@ static void balance_dirty_pages(struct a
 		if (unlikely(!dirty_exceeded && bdi_async_underrun(bdi)))
 			break;
 
+		max_pause = bdi_max_pause(bdi, bdi_dirty);
+
 		dirty_ratelimit = bdi->dirty_ratelimit;
 		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
 					       background_thresh, nr_dirty,
 					       bdi_thresh, bdi_dirty);
 		if (unlikely(pos_ratio == 0)) {
-			period = MAX_PAUSE;
-			pause = MAX_PAUSE;
+			period = max_pause;
+			pause = max_pause;
 			goto pause;
 		}
 		task_ratelimit = (u64)dirty_ratelimit *
@@ -1101,7 +1141,7 @@ static void balance_dirty_pages(struct a
 			pause = 1; /* avoid resetting nr_dirtied_pause below */
 			break;
 		}
-		pause = min_t(long, pause, MAX_PAUSE);
+		pause = min(pause, max_pause);
 
 pause:
 		trace_balance_dirty_pages(bdi,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
