Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C86098D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 14:12:26 -0400 (EDT)
Date: Tue, 5 Apr 2011 02:12:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: async write IO controllers
Message-ID: <20110404181214.GA12845@localhost>
References: <20110303064505.718671603@intel.com>
 <20110303201226.GI16720@redhat.com>
 <20110303204827.GJ16720@redhat.com>
 <20110304090609.GA1885@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <20110304090609.GA1885@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Vivek,

To explore the possibility of an integrated async write cgroup IO
controller in balance_dirty_pages(), I did the attached patches.
They should serve it well to illustrate the basic ideas.

It's based on Andrea's two supporting patches and a slightly
simplified and improved version of this v6 patchset.

        root@fat ~# cat test-blkio-cgroup.sh
        #!/bin/sh

        mount /dev/sda7 /fs  

        rmdir /cgroup/async_write
        mkdir /cgroup/async_write
        echo $$ > /cgroup/async_write/tasks
        # echo "8:16  1048576" > /cgroup/async_write/blkio.throttle.read_bps_device

        dd if=/dev/zero of=/fs/zero1 bs=1M count=100 &
        dd if=/dev/zero of=/fs/zero2 bs=1M count=100 &

2-dd case:

        root@fat ~# 100+0 records in
        100+0 records out
        104857600 bytes (105 MB) copied100+0 records in
        100+0 records out
        , 11.9477 s, 8.8 MB/s
        104857600 bytes (105 MB) copied, 11.9496 s, 8.8 MB/s

1-dd case:

        root@fat ~# 100+0 records in
        100+0 records out
        104857600 bytes (105 MB) copied, 6.21919 s, 16.9 MB/s

The patch hard codes a limit of 16MiB/s or 16.8MB/s.  So the 1-dd case
is pretty accurate, and the 2-dd case is a bit leaked due to the time
to take the throttle bandwidth from its initial value 16MiB/s to
8MiB/s. This could be compensated by some position control in future,
so that it won't leak in normal cases.

The main bits, blkcg_update_throttle_bandwidth() is in fact a minimal
version of bdi_update_throttle_bandwidth(); blkcg_update_bandwidth()
is also a cut-down version of bdi_update_bandwidth().

Thanks,
Fengguang

--9jxsPFA5p3P2qPhR
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="blk-cgroup-nr-dirtied.patch"

Subject: blkcg: dirty rate accounting
Date: Sat Apr 02 20:15:28 CST 2011

To be used by the balance_dirty_pages() async write IO controller.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/blk-cgroup.c         |    4 ++++
 include/linux/blk-cgroup.h |    1 +
 mm/page-writeback.c        |    4 ++++
 3 files changed, 9 insertions(+)

--- linux-next.orig/block/blk-cgroup.c	2011-04-02 20:17:08.000000000 +0800
+++ linux-next/block/blk-cgroup.c	2011-04-02 21:59:24.000000000 +0800
@@ -1458,6 +1458,7 @@ static void blkiocg_destroy(struct cgrou
 
 	free_css_id(&blkio_subsys, &blkcg->css);
 	rcu_read_unlock();
+	percpu_counter_destroy(&blkcg->nr_dirtied);
 	if (blkcg != &blkio_root_cgroup)
 		kfree(blkcg);
 }
@@ -1483,6 +1484,9 @@ done:
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
 
 	INIT_LIST_HEAD(&blkcg->policy_list);
+
+	percpu_counter_init(&blkcg->nr_dirtied, 0);
+
 	return &blkcg->css;
 }
 
--- linux-next.orig/include/linux/blk-cgroup.h	2011-04-02 20:17:08.000000000 +0800
+++ linux-next/include/linux/blk-cgroup.h	2011-04-02 21:59:02.000000000 +0800
@@ -111,6 +111,7 @@ struct blkio_cgroup {
 	spinlock_t lock;
 	struct hlist_head blkg_list;
 	struct list_head policy_list; /* list of blkio_policy_node */
+	struct percpu_counter nr_dirtied;
 };
 
 struct blkio_group_stats {
--- linux-next.orig/mm/page-writeback.c	2011-04-02 20:17:08.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-02 21:59:02.000000000 +0800
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/blk-cgroup.h>
 #include <trace/events/writeback.h>
 
 /*
@@ -221,6 +222,9 @@ EXPORT_SYMBOL_GPL(bdi_writeout_inc);
 
 void task_dirty_inc(struct task_struct *tsk)
 {
+	struct blkio_cgroup *blkcg = task_to_blkio_cgroup(tsk);
+	if (blkcg)
+		__percpu_counter_add(&blkcg->nr_dirtied, 1, BDI_STAT_BATCH);
 	prop_inc_single(&vm_dirties, &tsk->dirties);
 }
 

--9jxsPFA5p3P2qPhR
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-io-controller.patch"

Subject: writeback: async write IO controllers
Date: Fri Mar 04 10:38:04 CST 2011

- a bare per-task async write IO controller
- a bare per-cgroup async write IO controller

XXX: the per-task user interface is reusing RLIMIT_RSS for now.
XXX: the per-cgroup user interface is missing

CC: Vivek Goyal <vgoyal@redhat.com>
CC: Andrea Righi <arighi@develer.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/blk-cgroup.c         |    2 
 include/linux/blk-cgroup.h |    4 +
 mm/page-writeback.c        |   86 +++++++++++++++++++++++++++++++----
 3 files changed, 84 insertions(+), 8 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-05 01:26:38.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-05 01:26:53.000000000 +0800
@@ -1117,6 +1117,49 @@ static unsigned long max_pause(struct ba
 	return clamp_val(t, MIN_PAUSE, MAX_PAUSE);
 }
 
+static void blkcg_update_throttle_bandwidth(struct blkio_cgroup *blkcg,
+					    unsigned long dirtied,
+					    unsigned long elapsed)
+{
+	unsigned long bw = blkcg->throttle_bandwidth;
+	unsigned long long ref_bw;
+	unsigned long dirty_bw;
+
+	ref_bw = blkcg->async_write_bps >> (3 + PAGE_SHIFT - RATIO_SHIFT);
+	dirty_bw = ((dirtied - blkcg->dirtied_stamp)*HZ + elapsed/2) / elapsed;
+	do_div(ref_bw, dirty_bw | 1);
+	ref_bw = bw * ref_bw >> RATIO_SHIFT;
+
+	blkcg->throttle_bandwidth = (bw + ref_bw) / 2;
+}
+
+void blkcg_update_bandwidth(struct blkio_cgroup *blkcg)
+{
+	unsigned long now = jiffies;
+	unsigned long dirtied;
+	unsigned long elapsed;
+
+	if (!blkcg)
+		return;
+	if (!spin_trylock(&blkcg->lock))
+		return;
+
+	elapsed = now - blkcg->bw_time_stamp;
+	dirtied = percpu_counter_read(&blkcg->nr_dirtied);
+
+	if (elapsed > MAX_PAUSE * 2)
+		goto snapshot;
+	if (elapsed <= MAX_PAUSE)
+		goto unlock;
+
+	blkcg_update_throttle_bandwidth(blkcg, dirtied, elapsed);
+snapshot:
+	blkcg->dirtied_stamp = dirtied;
+	blkcg->bw_time_stamp = now;
+unlock:
+	spin_unlock(&blkcg->lock);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1139,6 +1182,10 @@ static void balance_dirty_pages(struct a
 	unsigned long pause_max;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
+	struct blkio_cgroup *blkcg = task_to_blkio_cgroup(current);
+
+	if (blkcg == &blkio_root_cgroup)
+		blkcg = NULL;
 
 	for (;;) {
 		unsigned long now = jiffies;
@@ -1178,6 +1225,15 @@ static void balance_dirty_pages(struct a
 		 * when the bdi limits are ramping up.
 		 */
 		if (nr_dirty <= (background_thresh + dirty_thresh) / 2) {
+			if (blkcg) {
+				pause_max = max_pause(bdi, 0);
+				goto cgroup_ioc;
+			}
+			if (current->signal->rlim[RLIMIT_RSS].rlim_cur !=
+			    RLIM_INFINITY) {
+				pause_max = max_pause(bdi, 0);
+				goto task_ioc;
+			}
 			current->paused_when = now;
 			current->nr_dirtied = 0;
 			break;
@@ -1190,21 +1246,35 @@ static void balance_dirty_pages(struct a
 			bdi_start_background_writeback(bdi);
 
 		pause_max = max_pause(bdi, bdi_dirty);
-
 		base_bw = bdi->throttle_bandwidth;
-		/*
-		 * Double the bandwidth for PF_LESS_THROTTLE (ie. nfsd) and
-		 * real-time tasks.
-		 */
-		if (current->flags & PF_LESS_THROTTLE || rt_task(current))
-			base_bw *= 2;
 		bw = position_ratio(bdi, dirty_thresh, nr_dirty, bdi_dirty);
 		if (unlikely(bw == 0)) {
 			period = pause_max;
 			pause = pause_max;
 			goto pause;
 		}
-		bw = base_bw * (u64)bw >> RATIO_SHIFT;
+		bw = (u64)base_bw * bw >> RATIO_SHIFT;
+		if (blkcg && bw > blkcg->throttle_bandwidth) {
+cgroup_ioc:
+			blkcg_update_bandwidth(blkcg);
+			bw = blkcg->throttle_bandwidth;
+			base_bw = bw;
+		}
+		if (bw > current->signal->rlim[RLIMIT_RSS].rlim_cur >>
+								PAGE_SHIFT) {
+task_ioc:
+			bw = current->signal->rlim[RLIMIT_RSS].rlim_cur >>
+								PAGE_SHIFT;
+			base_bw = bw;
+		}
+		/*
+		 * Double the bandwidth for PF_LESS_THROTTLE (ie. nfsd) and
+		 * real-time tasks.
+		 */
+		if (current->flags & PF_LESS_THROTTLE || rt_task(current)) {
+			bw *= 2;
+			base_bw = bw;
+		}
 		period = (HZ * pages_dirtied + bw / 2) / (bw | 1);
 		pause = current->paused_when + period - now;
 		/*
--- linux-next.orig/block/blk-cgroup.c	2011-04-05 01:26:38.000000000 +0800
+++ linux-next/block/blk-cgroup.c	2011-04-05 01:26:39.000000000 +0800
@@ -1486,6 +1486,8 @@ done:
 	INIT_LIST_HEAD(&blkcg->policy_list);
 
 	percpu_counter_init(&blkcg->nr_dirtied, 0);
+	blkcg->async_write_bps = 16 << 23; /* XXX: tunable interface */
+	blkcg->throttle_bandwidth = 16 << (20 - PAGE_SHIFT);
 
 	return &blkcg->css;
 }
--- linux-next.orig/include/linux/blk-cgroup.h	2011-04-05 01:26:38.000000000 +0800
+++ linux-next/include/linux/blk-cgroup.h	2011-04-05 01:26:39.000000000 +0800
@@ -112,6 +112,10 @@ struct blkio_cgroup {
 	struct hlist_head blkg_list;
 	struct list_head policy_list; /* list of blkio_policy_node */
 	struct percpu_counter nr_dirtied;
+	unsigned long bw_time_stamp;
+	unsigned long dirtied_stamp;
+	unsigned long throttle_bandwidth;
+	unsigned long async_write_bps;
 };
 
 struct blkio_group_stats {

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
