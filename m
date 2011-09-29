Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 136B49000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 08:15:10 -0400 (EDT)
Date: Thu, 29 Sep 2011 20:15:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110929121501.GA19582@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
 <20110918143721.GA17240@localhost>
 <20110918144751.GA18645@localhost>
 <20110928140205.GA26617@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
In-Reply-To: <20110928140205.GA26617@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 28, 2011 at 10:02:05PM +0800, Wu Fengguang wrote:
> Hi Peter,
> 
> On Sun, Sep 18, 2011 at 10:47:51PM +0800, Wu Fengguang wrote:
> > > BTW, I also compared the IO-less patchset and the vanilla kernel's
> > > JBOD performance. Basically, the performance is lightly improved
> > > under large memory, and reduced a lot in small memory servers.
> > > 
> > >  vanillla IO-less  
> > > --------------------------------------------------------------------------------
> > [...]
> > >  26508063 17706200      -33.2%  JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
> > >  23767810 23374918       -1.7%  JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
> > >  28032891 20659278      -26.3%  JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
> > >  26049973 22517497      -13.6%  JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M
> > > 
> > > There are still some itches in JBOD..
> > 
> > OK, in the dirty_bytes=100M case, I find that the bdi threshold _and_
> > writeout bandwidth may drop close to 0 in long periods. This change
> > may avoid one bdi being stuck:
> > 
> >         /*
> >          * bdi reserve area, safeguard against dirty pool underrun and disk idle
> >          *
> >          * It may push the desired control point of global dirty pages higher
> >          * than setpoint. It's not necessary in single-bdi case because a
> >          * minimal pool of @freerun dirty pages will already be guaranteed.
> >          */
> > -       x_intercept = min(write_bw, freerun);
> > +       x_intercept = min(write_bw + MIN_WRITEBACK_PAGES, freerun);
> 
> After lots of experiments, I end up with this bdi reserve point
> 
> +       x_intercept = bdi_thresh / 2 + MIN_WRITEBACK_PAGES;
> 
> together with this chunk to avoid a bdi stuck in bdi_thresh=0 state:
> 
> @@ -590,6 +590,7 @@ static unsigned long bdi_position_ratio(
>          */
>         if (unlikely(bdi_thresh > thresh))
>                 bdi_thresh = thresh;
> +       bdi_thresh = max(bdi_thresh, (limit - dirty) / 8);
>         /*
>          * scale global setpoint to bdi's:
>          *      bdi_setpoint = setpoint * bdi_thresh / thresh
> 
> The above changes are good enough to keep reasonable amount of bdi
> dirty pages, so the bdi underrun flag ("[PATCH 11/18] block: add bdi
> flag to indicate risk of io queue underrun") is dropped.
> 
> I also tried various bdi freerun patches, however the results are not
> satisfactory. Basically the bdi reserve area approach (this patch)
> yields noticeably more smooth/resilient behavior than the
> freerun/underrun approaches. I noticed that the bdi underrun flag
> could lead to sudden surge of dirty pages (especially if not
> safeguarded by the dirty_exceeded condition) in the very small
> window..
> 
> To dig performance increases/drops out of the large number of test
> results, I wrote a convenient script (attached) to compare the
> vmstat:nr_written numbers between 2+ set of test runs. It helped a lot
> for fine tuning the parameters for different cases.
> 
> The current JBOD performance numbers are encouraging:
> 
> $ ./compare.rb JBOD*/*-vanilla+ JBOD*/*-bgthresh3+
>       3.1.0-rc4-vanilla+      3.1.0-rc4-bgthresh3+
> ------------------------  ------------------------
>                 52934365        +3.2%     54643527  JBOD-10HDD-thresh=100M/ext4-100dd-1M-24p-16384M-100M:10-X
>                 45488896       +18.2%     53785605  JBOD-10HDD-thresh=100M/ext4-10dd-1M-24p-16384M-100M:10-X
>                 47217534       +12.2%     53001031  JBOD-10HDD-thresh=100M/ext4-1dd-1M-24p-16384M-100M:10-X
>                 32286924       +25.4%     40492312  JBOD-10HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
>                 38676965       +14.2%     44177606  JBOD-10HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
>                 59662173       +11.1%     66269621  JBOD-10HDD-thresh=800M/ext4-10dd-1M-24p-16384M-800M:10-X
>                 57510438        +2.3%     58855181  JBOD-10HDD-thresh=800M/ext4-1dd-1M-24p-16384M-800M:10-X
>                 63691922       +64.0%    104460352  JBOD-10HDD-thresh=800M/xfs-100dd-1M-24p-16384M-800M:10-X
>                 51978567       +16.0%     60298210  JBOD-10HDD-thresh=800M/xfs-10dd-1M-24p-16384M-800M:10-X
>                 47641062        +6.4%     50681038  JBOD-10HDD-thresh=800M/xfs-1dd-1M-24p-16384M-800M:10-X
[snip]

I forgot to mention one important change that lead to the increased
JBOD performance: the per-bdi background threshold as in the below
patch.

One thing puzzled me is that in JBOD case, the per-disk writeout
performance is smaller than the corresponding single-disk case even
when they have comparable bdi_thresh. So I wrote the attached tracing
patch and find that in single disk case, bdi_writeback is always kept
high while in JBOD case, it could drop low from time to time and
correspondingly bdi_reclaimable could sometimes rush high.

The fix is to watch bdi_reclaimable and kick background writeback as
soon as it goes high. This resembles the global background threshold
but in per-bdi manner. The trick is, as long as bdi_reclaimable does
not go high, bdi_writeback naturally won't go low because
bdi_reclaimable+bdi_writeback ~= bdi_thresh. With enough writeback
pages, good performance is maintained.

Thanks,
Fengguang
---

--- linux-next.orig/fs/fs-writeback.c	2011-09-25 10:08:43.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-09-25 15:36:41.000000000 +0800
@@ -678,14 +678,18 @@ long writeback_inodes_wb(struct bdi_writ
 	return nr_pages - work.nr_pages;
 }
 
-static inline bool over_bground_thresh(void)
+static bool over_bground_thresh(struct backing_dev_info *bdi)
 {
 	unsigned long background_thresh, dirty_thresh;
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+		return true;
+
+	return bdi_stat(bdi, BDI_RECLAIMABLE) >
+				bdi_dirty_limit(bdi, background_thresh);
 }
 
 /*
@@ -747,7 +751,7 @@ static long wb_writeback(struct bdi_writ
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh())
+		if (work->for_background && !over_bground_thresh(wb->bdi))
 			break;
 
 		if (work->for_kupdate) {
@@ -831,7 +835,7 @@ static unsigned long get_nr_dirty_pages(
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh()) {
+	if (over_bground_thresh(wb->bdi)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,

--J2SCkAp4GZ/dPZZf
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="trace-bdi-dirty-state.patch"

Subject: 
Date: Thu Sep 01 09:56:44 CST 2011


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   41 ++++++++++++++++++++++++++++-
 mm/page-writeback.c              |    2 +
 2 files changed, 42 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-09-01 10:09:58.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-09-01 10:13:38.000000000 +0800
@@ -1104,6 +1104,8 @@ static void balance_dirty_pages(struct a
 			bdi_dirty = bdi_reclaimable +
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
+		trace_bdi_dirty_state(bdi, bdi_thresh,
+				      bdi_dirty, bdi_reclaimable);
 
 		dirty_exceeded = (bdi_dirty > bdi_thresh) ||
 				  (nr_dirty > dirty_thresh);
--- linux-next.orig/include/trace/events/writeback.h	2011-09-01 10:09:58.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-09-01 10:12:54.000000000 +0800
@@ -265,6 +264,46 @@ TRACE_EVENT(global_dirty_state,
 	)
 );
 
+TRACE_EVENT(bdi_dirty_state,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long bdi_thresh,
+		 unsigned long bdi_dirty,
+		 unsigned long bdi_reclaimable
+	),
+
+	TP_ARGS(bdi, bdi_thresh, bdi_dirty, bdi_reclaimable),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	bdi_reclaimable)
+		__field(unsigned long,	bdi_writeback)
+		__field(unsigned long,	bdi_thresh)
+		__field(unsigned long,	bdi_dirtied)
+		__field(unsigned long,	bdi_written)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->bdi_reclaimable	= bdi_reclaimable;
+		__entry->bdi_writeback		= bdi_dirty - bdi_reclaimable;
+		__entry->bdi_thresh		= bdi_thresh;
+		__entry->bdi_dirtied		= bdi_stat(bdi, BDI_DIRTIED);
+		__entry->bdi_written		= bdi_stat(bdi, BDI_WRITTEN);
+	),
+
+	TP_printk("bdi %s: reclaimable=%lu writeback=%lu "
+		  "thresh=%lu "
+		  "dirtied=%lu written=%lu",
+		  __entry->bdi,
+		  __entry->bdi_reclaimable,
+		  __entry->bdi_writeback,
+		  __entry->bdi_thresh,
+		  __entry->bdi_dirtied,
+		  __entry->bdi_written
+	)
+);
+
 #define KBps(x)			((x) << (PAGE_SHIFT - 10))
 
 TRACE_EVENT(dirty_ratelimit,

--J2SCkAp4GZ/dPZZf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
