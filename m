Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A52356B00EE
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 03:19:08 -0400 (EDT)
Date: Sun, 7 Aug 2011 15:18:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110807071857.GC3287@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
 <20110806164656.GA1590@thinkpad>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20110806164656.GA1590@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Andrea,

On Sun, Aug 07, 2011 at 12:46:56AM +0800, Andrea Righi wrote:
> On Sat, Aug 06, 2011 at 04:44:52PM +0800, Wu Fengguang wrote:

> > So here is a pause time oriented approach, which tries to control the
> > pause time in each balance_dirty_pages() invocations, by controlling
> > the number of pages dirtied before calling balance_dirty_pages(), for
> > smooth and efficient dirty throttling:
> >
> > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > - avoid too small pause time (less than   4ms, which burns CPU power)
> > - avoid too large pause time (more than 200ms, which hurts responsiveness)
> > - avoid big fluctuations of pause times
> 
> I definitely agree that too small pauses must be avoided. However, I
> don't understand very well from the code how the minimum sleep time is
> regulated.

Thanks for pointing this out. Yes, the sleep time regulation is not
here and I should have mentioned that above. Since this is only the
core bits, there will be some followup patches to fix the rough edges.
(attached the two relevant patches)

> I've added a simple tracepoint (see below) to monitor the pause times in
> balance_dirty_pages().
> 
> Sometimes I see very small pause time if I set a low dirty threshold
> (<=32MB).

Yeah, it's definitely possible.

> Example:
> 
>  # echo $((16 * 1024 * 1024)) > /proc/sys/vm/dirty_bytes
>  # iozone -A >/dev/null &
>  # cat /sys/kernel/debug/tracing/trace_pipe
>  ...
>           iozone-2075  [001]   380.604961: writeback_dirty_throttle: 1
>           iozone-2075  [001]   380.605966: writeback_dirty_throttle: 2
>           iozone-2075  [001]   380.608405: writeback_dirty_throttle: 0
>           iozone-2075  [001]   380.608980: writeback_dirty_throttle: 1
>           iozone-2075  [001]   380.609952: writeback_dirty_throttle: 1
>           iozone-2075  [001]   380.610952: writeback_dirty_throttle: 2
>           iozone-2075  [001]   380.612662: writeback_dirty_throttle: 0
>           iozone-2075  [000]   380.613799: writeback_dirty_throttle: 1
>           iozone-2075  [000]   380.614771: writeback_dirty_throttle: 1
>           iozone-2075  [000]   380.615767: writeback_dirty_throttle: 2
>  ...
> 
> BTW, I can see this behavior only in the first minute while iozone is
> running. Ater ~1min things seem to get stable (sleeps are usually
> between 50ms and 200ms).
> 

Yeah, it's roughly in line with this graph, where the red dots are the
pause time:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/512M/xfs-1dd-4k-8p-438M-20:10-3.0.0-next-20110802+-2011-08-06.11:03/balance_dirty_pages-pause.png

Note that the big change of pattern in the middle is due to a
deliberate disturb: a dd will be started at 100s _reading_ 1GB data,
which effectively livelocked the other dd dirtier task with the CFQ io
scheduler. 

> I wonder if we shouldn't add an explicit check also for the minimum
> sleep time.
 
With the more complete patchset including the pause time regulation,
the pause time distribution should look much better, falling nicely
into the range (5ms, 20ms):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/3G/xfs-1dd-4k-8p-2948M-20:10-3.0.0-rc2-next-20110610+-2011-06-12.21:51/balance_dirty_pages-pause.png

> +TRACE_EVENT(writeback_dirty_throttle,
> +       TP_PROTO(unsigned long sleep),
> +       TP_ARGS(sleep),

btw, I've just pushed two more tracing patches to the git tree.
Hope it helps :)

Thanks,
Fengguang

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=max-pause

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
 mm/page-writeback.c |   43 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 41 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-07 14:23:45.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-07 14:25:29.000000000 +0800
@@ -856,6 +856,42 @@ static unsigned long ratelimit_pages(uns
 	return 1;
 }
 
+static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
+				   unsigned long bdi_dirty)
+{
+	unsigned long hi = ilog2(bdi->write_bandwidth);
+	unsigned long lo = ilog2(bdi->dirty_ratelimit);
+	unsigned long t;
+
+	/* target for ~10ms pause on 1-dd case */
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
+	 * 1ms for every 1MB; may further consider bdi bandwidth.
+	 */
+	if (bdi_dirty)
+		t = min(t, bdi_dirty >> (30 - PAGE_CACHE_SHIFT - ilog2(HZ)));
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
@@ -873,6 +909,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	long pause = 0;
+	long max_pause;
 	bool dirty_exceeded = false;
 	unsigned long bw;
 	unsigned long base_bw;
@@ -930,16 +967,18 @@ static void balance_dirty_pages(struct a
 		if (unlikely(!writeback_in_progress(bdi)))
 			bdi_start_background_writeback(bdi);
 
+		max_pause = bdi_max_pause(bdi, bdi_dirty);
+
 		base_bw = bdi->dirty_ratelimit;
 		bw = bdi_position_ratio(bdi, dirty_thresh, nr_dirty,
 					bdi_thresh, bdi_dirty);
 		if (unlikely(bw == 0)) {
-			pause = MAX_PAUSE;
+			pause = max_pause;
 			goto pause;
 		}
 		bw = (u64)base_bw * bw >> BANDWIDTH_CALC_SHIFT;
 		pause = (HZ * pages_dirtied + bw / 2) / (bw | 1);
-		pause = min(pause, MAX_PAUSE);
+		pause = min(pause, max_pause);
 
 pause:
 		trace_balance_dirty_pages(bdi,

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=max-pause-adaption

Subject: writeback: control dirty pause time
Date: Sat Jun 11 19:32:32 CST 2011

The dirty pause time shall ultimately be controlled by adjusting
nr_dirtied_pause, since there is relationship

	pause = pages_dirtied / pos_bw

Assuming

	pages_dirtied ~= nr_dirtied_pause
	pos_bw ~= base_bw

We get

	nr_dirtied_pause ~= base_bw * desired_pause

Here base_bw is preferred over pos_bw because it's more stable.

It's also important to limit possible large transitional errors:

- bw is changing quickly
- pages_dirtied << nr_dirtied_pause on entering dirty exceeded area
- pages_dirtied >> nr_dirtied_pause on btrfs (to be improved by a
  separate fix, but still expect non-trivial errors)

So we end up using the above formula inside clamp_val().

The best test case for this code is to run 100 "dd bs=4M" tasks on
btrfs and check its pause time distribution.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-07 14:51:18.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-07 15:02:08.000000000 +0800
@@ -1021,7 +1021,19 @@ pause:
 		bdi->dirty_exceeded = 0;
 
 	current->nr_dirtied = 0;
-	current->nr_dirtied_pause = ratelimit_pages(nr_dirty, dirty_thresh);
+	if (pause == 0)
+		current->nr_dirtied_pause =
+				ratelimit_pages(nr_dirty, dirty_thresh);
+	else if (pause < max_pause / 4)
+		current->nr_dirtied_pause = clamp_val(
+						base_bw * (max_pause/2) / HZ,
+						pages_dirtied + pages_dirtied/8,
+						pages_dirtied * 4);
+	else if (pause > max_pause)
+		current->nr_dirtied_pause = 1 | clamp_val(
+						base_bw * (max_pause*3/8) / HZ,
+						current->nr_dirtied_pause / 4,
+						current->nr_dirtied_pause*7/8);
 
 	if (writeback_in_progress(bdi))
 		return;

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
