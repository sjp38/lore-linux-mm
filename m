Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 486908D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 04:10:54 -0500 (EST)
Date: Fri, 4 Mar 2011 17:06:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/27] IO-less dirty throttling v6
Message-ID: <20110304090609.GA1885@localhost>
References: <20110303064505.718671603@intel.com>
 <20110303201226.GI16720@redhat.com>
 <20110303204827.GJ16720@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303204827.GJ16720@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 04, 2011 at 04:48:27AM +0800, Vivek Goyal wrote:
> On Thu, Mar 03, 2011 at 03:12:26PM -0500, Vivek Goyal wrote:
> > On Thu, Mar 03, 2011 at 02:45:05PM +0800, Wu Fengguang wrote:
> > 
> > [..]
> > > - serve as simple IO controllers: if provide an interface for the user
> > >   to set task_bw directly (by returning the user specified value
> > >   directly at the beginning of dirty_throttle_bandwidth(), plus always
> > >   throttle such tasks even under the background dirty threshold), we get
> > >   a bandwidth based per-task async write IO controller; let the user
> > >   scale up/down the @priority parameter in dirty_throttle_bandwidth(),
> > >   we get a priority based IO controller. It's possible to extend the
> > >   capabilities to the scope of cgroup, too.
> > > 
> > 
> > Hi Fengguang,
> > 
> > Above simple IO controller capabilities sound interesting and I was
> > looking at the patch to figure out the details. 
> > 
> > You seem to be mentioning that user can explicitly set the upper rate
> > limit per task for async IO. Can't really figure that out where is the
> > interface for setting such upper limits. Can you please point me to that.
> 
> Never mind. Jeff moyer pointed out that you mentioned above as possible
> future enhancements on top of this patchset.

Hi Vivek,

Here is an update show the bandwidth limit possibility. I tested it by
starting 8 or 10 concurrent dd's, doing "ulimit -m $((i<<10))" before
starting the i'th dd. The first 3 dd's progress are shown in the
following graphs.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/BW-LIMIT/xfs-10dd-1M-8p-2975M-20%25-2.6.38-rc7-dt6+-2011-03-04-16-22/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/BW-LIMIT/xfs-8dd-1M-8p-2975M-20%25-2.6.38-rc7-dt6+-2011-03-04-16-15/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/BW-LIMIT/ext4-10dd-1M-8p-2975M-20%25-2.6.38-rc7-dt6+-2011-03-04-16-29/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/BW-LIMIT/btrfs-10dd-1M-8p-2975M-20%25-2.6.38-rc7-dt6+-2011-03-04-16-35/balance_dirty_pages-task-bw.png

The bandwidth limit is not perfect in two of the above cases:
- the xfs 10dd case: tasks could be hard throttled on dirty exceeding
- the ext4 10dd case: filesystem makes >500ms latencies (smaller ones will be compensated)

Thanks,
Fengguang
---

Subject: writeback: per-task async write bandwidth limit
Date: Fri Mar 04 10:38:04 CST 2011

XXX: the user interface is reusing RLIMIT_RSS for now.

CC: Vivek Goyal <vgoyal@redhat.com>
CC: Andrea Righi <arighi@develer.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-03-04 10:33:06.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-04 16:03:52.000000000 +0800
@@ -428,6 +428,11 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+static unsigned long hard_dirty_limit(unsigned long thresh)
+{
+	return max(thresh, default_backing_dev_info.dirty_threshold);
+}
+
 /*
  * If we can dirty N more pages globally, honour N/8 to the bdi that runs low,
  * so as to help it ramp up.
@@ -589,7 +594,7 @@ static unsigned long dirty_throttle_band
 					      unsigned long bdi_dirty,
 					      struct task_struct *tsk)
 {
-	unsigned long limit = default_backing_dev_info.dirty_threshold;
+	unsigned long limit = hard_dirty_limit(thresh);
 	unsigned long bdi_thresh = bdi->dirty_threshold;
 	unsigned long origin;
 	unsigned long goal;
@@ -1221,6 +1226,11 @@ static void balance_dirty_pages(struct a
 		 * when the bdi limits are ramping up.
 		 */
 		if (nr_dirty <= (background_thresh + dirty_thresh) / 2) {
+			if (current->signal->rlim[RLIMIT_RSS].rlim_cur !=
+			    RLIM_INFINITY) {
+				pause_max = MAX_PAUSE;
+				goto calc_bw;
+			}
 			current->paused_when = jiffies;
 			current->nr_dirtied = 0;
 			break;
@@ -1233,7 +1243,7 @@ static void balance_dirty_pages(struct a
 			bdi_start_background_writeback(bdi);
 
 		pause_max = max_pause(bdi, bdi_dirty);
-
+calc_bw:
 		bw = dirty_throttle_bandwidth(bdi, dirty_thresh, nr_dirty,
 					      bdi_dirty, current);
 		if (unlikely(bw == 0)) {
@@ -1241,6 +1251,8 @@ static void balance_dirty_pages(struct a
 			pause = pause_max;
 			goto pause;
 		}
+		bw = min(bw, current->signal->rlim[RLIMIT_RSS].rlim_cur >>
+								PAGE_SHIFT);
 		period = (HZ * pages_dirtied + bw / 2) / bw;
 		pause = current->paused_when + period - jiffies;
 		/*
@@ -1292,8 +1304,8 @@ pause:
 		current->paused_when += pause;
 		current->nr_dirtied = 0;
 
-		if (nr_dirty < default_backing_dev_info.dirty_threshold +
-		    default_backing_dev_info.dirty_threshold / DIRTY_MARGIN)
+		dirty_thresh = hard_dirty_limit(dirty_thresh);
+		if (nr_dirty < dirty_thresh + dirty_thresh / DIRTY_MARGIN)
 			break;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
