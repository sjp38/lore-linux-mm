Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C94E0900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:13:39 -0400 (EDT)
Date: Mon, 18 Apr 2011 08:13:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110418001333.GA8890@localhost>
References: <20110416132546.765212221@intel.com>
 <BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
 <20110417014430.GA9419@localhost>
 <BANLkTik+Bcw7uz9aMi6OrAzwg1rJZmJL0Q@mail.gmail.com>
 <20110417041003.GA17032@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110417041003.GA17032@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Sedat,

> Please revert the last commit. It's not necessary anyway.
> 
> commit 84a9890ddef487d9c6d70934c0a2addc65923bcf
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date:   Sat Apr 16 18:38:41 2011 -0600
> 
>     writeback: scale dirty proportions period with writeout bandwidth
>     
>     CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
>     Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Please do revert that commit, because I found a sleep-inside-spinlock
bug with it. Here is the fixed one (but you don't have to track this
optional patch).

Thanks,
Fengguang
---
Subject: writeback: scale dirty proportions period with writeout bandwidth
Date: Sat Apr 16 18:38:41 CST 2011

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-17 20:52:13.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-18 07:57:01.000000000 +0800
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
+	if (abs(shift - vm_completions.pg[0].shift) <= 1)
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
@@ -1044,6 +1042,8 @@ snapshot:
 	bdi->bw_time_stamp = now;
 unlock:
 	spin_unlock(&dirty_lock);
+	if (gbdi->bw_time_stamp == now)
+		update_completion_period();
 }
 
 static unsigned long max_pause(struct backing_dev_info *bdi,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
