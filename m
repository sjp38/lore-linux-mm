Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 998BB6B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 00:33:11 -0400 (EDT)
Date: Wed, 10 Aug 2011 12:33:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110810043305.GE24486@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
 <20110809191622.GH6482@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
In-Reply-To: <20110809191622.GH6482@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 10, 2011 at 03:16:22AM +0800, Vivek Goyal wrote:
> On Sat, Aug 06, 2011 at 04:44:52PM +0800, Wu Fengguang wrote:
> 
> [..]
> > -/*
> > - * task_dirty_limit - scale down dirty throttling threshold for one task
> > - *
> > - * task specific dirty limit:
> > - *
> > - *   dirty -= (dirty/8) * p_{t}
> > - *
> > - * To protect light/slow dirtying tasks from heavier/fast ones, we start
> > - * throttling individual tasks before reaching the bdi dirty limit.
> > - * Relatively low thresholds will be allocated to heavy dirtiers. So when
> > - * dirty pages grow large, heavy dirtiers will be throttled first, which will
> > - * effectively curb the growth of dirty pages. Light dirtiers with high enough
> > - * dirty threshold may never get throttled.
> > - */
> 
> Hi Fengguang,
> 
> So we have got rid of the notion of per task dirty limit based on their
> fraction? What replaces it.

It's simply removed :)

> I can't see any code which is replacing it.

The think time compensation feature (patch attached) will be providing
the same protection for light/slow dirtiers. With it, the slower
dirtiers won't be throttled at all, because the pause time calculated
by

        period = pages_dirtied / rate
        pause = period - think

will be <= 0.

For example, given write_bw = 100MB/s and

- 2 dd tasks that dirty pages as fast as possible
- 1 scp whose dirty rate is limited by network bandwidth 10MB/s

Then with think time compensation, the real dirty rates will be

- 2 dd tasks: (100-10)/2 = 45MB/s (each)
- 1 scp task: 10MB/s

The scp task won't be throttled by balance_dirty_pages() any more.
This is a tested feature. In the below graph, the dirty rate (the
slope of the lines) of the last 3 tasks are 2, 4, 8 MB/s

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/btrfs-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-45/balance_dirty_pages-task-bw.png

given this fio workload, which started one full speed dirtier and
four 1, 2, 4, 8 MB/s rate limited dirtiers

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/btrfs-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-45/fio-rates

> If yes, I am wondering how
> do you get fairness among tasks which share this bdi.
> 
> Also wondering what did this patch series to do make sure that tasks
> share bdi more fairly and get write_bw/N bandwidth.

Each of the N dd tasks will be rate limited by

        rate = base_rate * pos_ratio

At any time snapshot, each bdi task will see almost the same base_rate
and pos_ratio, so will be throttled almost at the same rate. This is a
strong guarantee of fairness under all situations.

Since pos_ratio is fluctuating (evenly) around 1.0, and
base_rate=bdi->dirty_ratelimit is fluctuating around (write_bw/N),
on average we get

        avg_rate = (write_bw/N) * 1.0

(I'll explain the "dirty_ratelimit = write_bw/N" magic other emails.)

The below graphs demonstrate the dirty progress of the last 3 dd tasks.
The slope of each curve is the dirty rate.

They vividly show three curves progressing at the same pace in all of
the 3 stages

- rampup stage (20-100s) 

- disturbed stage (120s-160s)
  (disturbed by starting a 1GB read dd in the middle of the tests)

- stable stage (after 160s)

And dirtied almost the same amount of pages during the test.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/8G/xfs-10dd-4k-32p-6802M-20:10-3.0.0-next-20110802+-2011-08-06.16:26/balance_dirty_pages-task-bw.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/2G/xfs-10dd-4k-8p-1947M-20:10-3.0.0-next-20110802+-2011-08-06.15:49/balance_dirty_pages-task-bw.png

Thanks,
Fengguang

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=think-time-compensation

Subject: writeback: dirty ratelimit - think time compensation
Date: Sat Jun 11 19:25:42 CST 2011

Compensate the task's think time when computing the final pause time,
so that ->dirty_ratelimit can be executed accurately.

In the rare case that the task slept longer than the period time (result
in negative pause time), the extra sleep time will be compensated in
next period if it's not too big (<500ms).

Accumulated errors are carefully avoided as long as the max pause area
is not hitted.

Pseudo code:

	period = pages_dirtied / bw;
	think = jiffies - dirty_paused_when;
	pause = period - think;

case 1: period > think

                pause = period - think
                dirty_paused_when += pause

                             period time
              |======================================>|
                  think time
              |===============>|
        ------|----------------|----------------------|-----------
        dirty_paused_when   jiffies


case 2: period <= think

                don't pause; reduce future pause time by:
                dirty_paused_when += period

                       period time
              |=========================>|
                             think time
              |======================================>|
        ------|--------------------------+------------|-----------
        dirty_paused_when                          jiffies

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/sched.h |    1 +
 kernel/fork.c         |    1 +
 mm/page-writeback.c   |   34 +++++++++++++++++++++++++++++++---
 3 files changed, 33 insertions(+), 3 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-08-09 07:53:31.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-08-09 07:54:12.000000000 +0800
@@ -1531,6 +1531,7 @@ struct task_struct {
 	 */
 	int nr_dirtied;
 	int nr_dirtied_pause;
+	unsigned long dirty_paused_when; /* start of a write-and-pause period */
 
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
--- linux-next.orig/mm/page-writeback.c	2011-08-09 07:53:31.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-09 08:08:11.000000000 +0800
@@ -817,6 +817,7 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	long period;
 	long pause = 0;
 	bool dirty_exceeded = false;
 	unsigned long bw;
@@ -825,6 +826,8 @@ static void balance_dirty_pages(struct a
 	unsigned long start_time = jiffies;
 
 	for (;;) {
+		unsigned long now = jiffies;
+
 		/*
 		 * Unstable writes are a feature of certain networked
 		 * filesystems (i.e. NFS) in which data may have been
@@ -842,8 +845,11 @@ static void balance_dirty_pages(struct a
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_dirty <= (background_thresh + dirty_thresh) / 2)
+		if (nr_dirty <= (background_thresh + dirty_thresh) / 2) {
+			current->dirty_paused_when = now;
+			current->nr_dirtied = 0;
 			break;
+		}
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
 
@@ -879,17 +885,40 @@ static void balance_dirty_pages(struct a
 		bw = bdi_position_ratio(bdi, dirty_thresh, nr_dirty,
 					bdi_thresh, bdi_dirty);
 		if (unlikely(bw == 0)) {
+			period = MAX_PAUSE;
 			pause = MAX_PAUSE;
 			goto pause;
 		}
 		bw = (u64)base_bw * bw >> BANDWIDTH_CALC_SHIFT;
-		pause = (HZ * pages_dirtied + bw / 2) / (bw | 1);
+		period = (HZ * pages_dirtied + bw / 2) / (bw | 1);
+		pause = current->dirty_paused_when + period - now;
+		/*
+		 * For less than 1s think time (ext3/4 may block the dirtier
+		 * for up to 800ms from time to time on 1-HDD; so does xfs,
+		 * however at much less frequency), try to compensate it in
+		 * future periods by updating the virtual time; otherwise just
+		 * do a reset, as it may be a light dirtier.
+		 */
+		if (unlikely(pause <= 0)) {
+			if (pause < -HZ) {
+				current->dirty_paused_when = now;
+				current->nr_dirtied = 0;
+			} else if (period) {
+				current->dirty_paused_when += period;
+				current->nr_dirtied = 0;
+			}
+			pause = 1; /* avoid resetting nr_dirtied_pause below */
+			break;
+		}
 		pause = min(pause, MAX_PAUSE);
 
 pause:
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
 
+		current->dirty_paused_when = now + pause;
+		current->nr_dirtied = 0;
+
 		dirty_thresh = hard_dirty_limit(dirty_thresh);
 		/*
 		 * max-pause area. If dirty exceeded but still within this
@@ -916,7 +945,6 @@ pause:
 	if (!dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
-	current->nr_dirtied = 0;
 	current->nr_dirtied_pause = ratelimit_pages(nr_dirty, dirty_thresh);
 
 	if (writeback_in_progress(bdi))
--- linux-next.orig/kernel/fork.c	2011-08-09 07:53:31.000000000 +0800
+++ linux-next/kernel/fork.c	2011-08-09 07:54:12.000000000 +0800
@@ -1303,6 +1303,7 @@ static struct task_struct *copy_process(
 
 	p->nr_dirtied = 0;
 	p->nr_dirtied_pause = 128 >> (PAGE_SHIFT - 10);
+	p->dirty_paused_when = 0;
 
 	/*
 	 * Ok, make it visible to the rest of the system.

--17pEHd4RhPHOinZp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
