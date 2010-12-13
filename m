From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 31/47] writeback: increase min pause time on concurrent dirtiers
Date: Mon, 13 Dec 2010 14:43:20 +0800
Message-ID: <20101213064840.799225309@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-min-pause-time-for-concurrent-dirtiers.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Target for >60ms pause time when there are 100+ heavy dirtiers per bdi.
(will average around 100ms given 200ms max pause time)

It's OK for 1 dd task doing 100MB/s to be throttle paused 100 times per
second.  However when there are 100 tasks writing to the same disk,
That sums up to 100*100 balance_dirty_pages() calls per second and may
lead to massive cacheline bouncing on accessing the global page states
in NUMA machines.  Even in single socket boxes, we easily see >10% CPU
time reduction by increasing the pause time.

CC: Dave Chinner <david@fromorbit.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-09 12:24:45.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-09 12:24:47.000000000 +0800
@@ -666,6 +666,27 @@ static unsigned long max_pause(unsigned 
 }
 
 /*
+ * Scale up pause time for concurrent dirtiers in order to reduce CPU overheads.
+ * But ensure reasonably large [min_pause, max_pause] range size, so that
+ * nr_dirtied_pause (and hence future pause time) can stay reasonably stable.
+ */
+static unsigned long min_pause(struct backing_dev_info *bdi,
+			       unsigned long max)
+{
+	unsigned long hi = ilog2(bdi->write_bandwidth);
+	unsigned long lo = ilog2(bdi->throttle_bandwidth);
+	unsigned long t;
+
+	if (lo >= hi)
+		return 1;
+
+	/* (N * 10ms) on 2^N concurrent tasks */
+	t = (hi - lo) * (10 * HZ) / 1024;
+
+	return clamp_val(t, 1, max / 2);
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -833,7 +854,7 @@ pause:
 
 	if (pause == 0 && nr_dirty < background_thresh)
 		current->nr_dirtied_pause = ratelimit_pages(bdi);
-	else if (pause == 1)
+	else if (pause <= min_pause(bdi, pause_max))
 		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
 	else if (pause >= pause_max)
 		/*


