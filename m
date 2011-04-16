Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 986E8900089
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:23:54 -0400 (EDT)
Date: Sat, 16 Apr 2011 22:21:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110416142114.GA12220@localhost>
References: <20110413220444.GF4648@quack.suse.cz>
 <20110413233122.GA6097@localhost>
 <20110413235211.GN31057@dastard>
 <20110414002301.GA9826@localhost>
 <20110414151424.GA367@localhost>
 <20110414181609.GH5054@quack.suse.cz>
 <20110415034300.GA23430@localhost>
 <20110415143711.GA17181@localhost>
 <20110415221314.GE5432@quack.suse.cz>
 <1302942809.2388.254.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Content-Disposition: inline
In-Reply-To: <1302942809.2388.254.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Apr 16, 2011 at 04:33:29PM +0800, Peter Zijlstra wrote:
> On Sat, 2011-04-16 at 00:13 +0200, Jan Kara wrote:
> > 
> > So what is a takeaway from this for me is that scaling the period
> > with the dirty limit is not the right thing. If you'd have 4-times more
> > memory, your choice of "dirty limit" as the period would be as bad as
> > current 4*"dirty limit". What would seem like a better choice of period
> > to me would be to have the period in an order of a few seconds worth of
> > writeback. That would allow the bdi limit to scale up reasonably fast when
> > new bdi starts to be used and still not make it fluctuate that much
> > (hopefully).
> 
> No best would be to scale the period with the writeout bandwidth, but
> lacking that the dirty limit had to do. Since we're counting pages, and
> bandwidth is pages/second we'll end up with a time measure, exactly the
> thing you wanted.

I owe you the patch :) Here is a tested one for doing the bandwidth
based scaling. It's based on the attached global writeout bandwidth
estimation.

I tried updating the shift both on rosed and fallen bandwidth, however
that leads to reset of the accumulated proportion values. So here the
shift will only be increased and never decreased.

Thanks,
Fengguang
---
Subject: writeback: scale dirty proportions period with writeout bandwidth
Date: Sat Apr 16 18:38:41 CST 2011

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-16 21:02:24.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-16 21:04:08.000000000 +0800
@@ -121,20 +121,13 @@ static struct prop_descriptor vm_complet
 static struct prop_descriptor vm_dirties;
 
 /*
- * couple the period to the dirty_ratio:
+ * couple the period to global write throughput:
  *
- *   period/2 ~ roundup_pow_of_two(dirty limit)
+ *   period/2 ~ roundup_pow_of_two(write IO throughput)
  */
 static int calc_period_shift(void)
 {
-	unsigned long dirty_total;
-
-	if (vm_dirty_bytes)
-		dirty_total = vm_dirty_bytes / PAGE_SIZE;
-	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
-				100;
-	return 2 + ilog2(dirty_total - 1);
+	return 2 + ilog2(default_backing_dev_info.avg_write_bandwidth);
 }
 
 /*
@@ -143,6 +136,13 @@ static int calc_period_shift(void)
 static void update_completion_period(void)
 {
 	int shift = calc_period_shift();
+
+	if (shift > PROP_MAX_SHIFT)
+		shift = PROP_MAX_SHIFT;
+
+	if (shift <= vm_completions.pg[0].shift)
+		return;
+
 	prop_change_shift(&vm_completions, shift);
 	prop_change_shift(&vm_dirties, shift);
 }
@@ -180,7 +180,6 @@ int dirty_ratio_handler(struct ctl_table
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
-		update_completion_period();
 		vm_dirty_bytes = 0;
 	}
 	return ret;
@@ -196,7 +195,6 @@ int dirty_bytes_handler(struct ctl_table
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
-		update_completion_period();
 		vm_dirty_ratio = 0;
 	}
 	return ret;
@@ -1026,6 +1024,7 @@ void bdi_update_bandwidth(struct backing
 						global_page_state(NR_WRITTEN));
 		gbdi->bw_time_stamp = now;
 		gbdi->written_stamp = global_page_state(NR_WRITTEN);
+		update_completion_period();
 	}
 	if (thresh) {
 		bdi_update_dirty_ratelimit(bdi, thresh, dirty,

--mYCpIKhGyMATD0i+
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-global-write-bandwidth.patch"

Subject: writeback: global writeback throughput
Date: Sat Apr 16 18:25:51 CST 2011


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-16 18:26:54.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-16 20:13:21.000000000 +0800
@@ -994,6 +994,7 @@ void bdi_update_bandwidth(struct backing
 	unsigned long elapsed;
 	unsigned long dirtied;
 	unsigned long written;
+	struct backing_dev_info *gbdi = &default_backing_dev_info;
 
 	if (!spin_trylock(&dirty_lock))
 		return;
@@ -1016,11 +1017,15 @@ void bdi_update_bandwidth(struct backing
 	if (elapsed <= MAX_PAUSE)
 		goto unlock;
 
-	if (thresh &&
-	    now - default_backing_dev_info.bw_time_stamp >= MAX_PAUSE) {
+	if (thresh && now - gbdi->bw_time_stamp >= MAX_PAUSE) {
 		update_dirty_limit(thresh, dirty);
-		bdi_update_dirty_smooth(&default_backing_dev_info, dirty);
-		default_backing_dev_info.bw_time_stamp = now;
+		bdi_update_dirty_smooth(gbdi, dirty);
+		if (now - gbdi->bw_time_stamp < HZ + MAX_PAUSE)
+			__bdi_update_write_bandwidth(gbdi,
+						now - gbdi->bw_time_stamp,
+						global_page_state(NR_WRITTEN));
+		gbdi->bw_time_stamp = now;
+		gbdi->written_stamp = global_page_state(NR_WRITTEN);
 	}
 	if (thresh) {
 		bdi_update_dirty_ratelimit(bdi, thresh, dirty,

--mYCpIKhGyMATD0i+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
