Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DD8190013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 10:11:01 -0400 (EDT)
Date: Wed, 10 Aug 2011 22:10:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: dirty rate control
Message-ID: <20110810141052.GC29724@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.878435971@intel.com>
 <1312909016.1083.47.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <1312909016.1083.47.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 10, 2011 at 12:56:56AM +0800, Peter Zijlstra wrote:
> On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> >              bdi->dirty_ratelimit = (bw * 3 + ref_bw) / 4;
> 
> I can't actually find this low-pass filter in the code.. could be I'm
> blind from staring at it too long though..

Sorry, it's implemented in another patch (attached). I've also removed
it from _this_ changelog.

Here you can find all the other patches in addition to the core bits.

http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=shortlog;h=refs/heads/dirty-throttling-v8%2B

Thanks,
Fengguang

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=smooth-base-bw

Subject: writeback: make dirty_ratelimit stable/smooth
Date: Thu Aug 04 22:05:05 CST 2011

Half the dirty_ratelimit update step size to avoid overshooting, and
further slow down the updates when the tracking error is smaller than
(base_rate / 8).

It's desirable to have a _constant_ dirty_ratelimit given a stable
workload. Because each jolt of dirty_ratelimit will directly show up
in all the bdi tasks' dirty rate.

The cost will be slightly increased dirty position error, which is
pretty acceptable.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-10 21:35:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-10 21:35:31.000000000 +0800
@@ -741,6 +741,7 @@ static void bdi_update_dirty_ratelimit(s
 	unsigned long dirty_rate;
 	unsigned long pos_rate;
 	unsigned long balanced_rate;
+	unsigned long delta;
 	unsigned long long pos_ratio;
 
 	/*
@@ -755,7 +756,6 @@ static void bdi_update_dirty_ratelimit(s
 	 * pos_rate reflects each dd's dirty rate enforced for the past 200ms.
 	 */
 	pos_rate = base_rate * pos_ratio >> BANDWIDTH_CALC_SHIFT;
-	pos_rate++;  /* this avoids bdi->dirty_ratelimit get stuck in 0 */
 
 	/*
 	 * balanced_rate = pos_rate * write_bw / dirty_rate
@@ -777,14 +777,32 @@ static void bdi_update_dirty_ratelimit(s
 	 * makes it more stable, but also is essential for preventing it being
 	 * driven away by possible systematic errors in balanced_rate.
 	 */
+	delta = 0;
 	if (base_rate > pos_rate) {
 		if (base_rate > balanced_rate)
-			base_rate = max(balanced_rate, pos_rate);
+			delta = base_rate - max(balanced_rate, pos_rate);
 	} else {
 		if (base_rate < balanced_rate)
-			base_rate = min(balanced_rate, pos_rate);
+			delta = min(balanced_rate, pos_rate) - base_rate;
 	}
 
+	/*
+	 * Don't pursue 100% rate matching. It's impossible since the balanced
+	 * rate itself is constantly fluctuating. So decrease the track speed
+	 * when it gets close to the target. Eliminates unnecessary jolting.
+	 */
+	delta >>= base_rate / (8 * delta + 1);
+	/*
+	 * Limit the step size to avoid overshooting. It also implicitly
+	 * prevents dirty_ratelimit from dropping to 0.
+	 */
+	delta >>= 2;
+
+	if (base_rate < pos_rate)
+		base_rate += delta;
+	else
+		base_rate -= delta;
+
 	bdi->dirty_ratelimit = base_rate;
 
 	trace_dirty_ratelimit(bdi, dirty_rate, pos_rate, balanced_rate);

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
