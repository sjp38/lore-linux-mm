Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D91439000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 10:17:12 -0400 (EDT)
Date: Sun, 18 Sep 2011 22:17:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110918141705.GB15366@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <1315822779.26517.23.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2011 at 06:19:38PM +0800, Peter Zijlstra wrote:
> On Wed, 2011-09-07 at 20:31 +0800, Wu Fengguang wrote:
> > > > +   x_intercept = min(write_bw, freerun);
> > > > +   if (bdi_dirty < x_intercept) {
> > > 
> > > So the point of the freerun point is that we never throttle before it,
> > > so basically all the below shouldn't be needed at all, right? 
> > 
> > Yes!
> > 
> > > > +           if (bdi_dirty > x_intercept / 8) {
> > > > +                   pos_ratio *= x_intercept;
> > > > +                   do_div(pos_ratio, bdi_dirty);
> > > > +           } else
> > > > +                   pos_ratio *= 8;
> > > > +   }
> > > > +
> > > >     return pos_ratio;
> > > >  }
> 
> Does that mean we can remove this whole block?

Right, if the bdi freerun concept is proved to work fine.

Unfortunately I find it mostly yields lower performance than bdi
reserve area. Patch is attached. If you would like me try other
patches, I can easily kick off new tests and redo the comparison.

Here is the nr_written numbers over various JBOD test cases,
the larger, the better:

bdi-reserve     bdi-freerun    diff    case
---------------------------------------------------------------------------------------
38375271        31553807      -17.8%	JBOD-10HDD-6G/xfs-100dd-1M-16p-5895M-20
30478879        28631491       -6.1%	JBOD-10HDD-6G/xfs-10dd-1M-16p-5895M-20
29735407        28871956       -2.9%	JBOD-10HDD-6G/xfs-1dd-1M-16p-5895M-20
30850350        28344165       -8.1%	JBOD-10HDD-6G/xfs-2dd-1M-16p-5895M-20
17706200        16174684       -8.6%	JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
23374918        14376942      -38.5%	JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
20659278        19640375       -4.9%	JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
22517497        14552321      -35.4%	JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M
68287850        61078553      -10.6%	JBOD-10HDD-thresh=2G/xfs-100dd-1M-16p-5895M-2048M
33835247        32018425       -5.4%	JBOD-10HDD-thresh=2G/xfs-10dd-1M-16p-5895M-2048M
30187817        29942083       -0.8%	JBOD-10HDD-thresh=2G/xfs-1dd-1M-16p-5895M-2048M
30563144        30204022       -1.2%	JBOD-10HDD-thresh=2G/xfs-2dd-1M-16p-5895M-2048M
34476862        34645398       +0.5%	JBOD-10HDD-thresh=4G/xfs-10dd-1M-16p-5895M-4096M
30326479        30097263       -0.8%	JBOD-10HDD-thresh=4G/xfs-1dd-1M-16p-5895M-4096M
30446767        30339683       -0.4%	JBOD-10HDD-thresh=4G/xfs-2dd-1M-16p-5895M-4096M
40793956        45936678      +12.6%	JBOD-10HDD-thresh=800M/xfs-100dd-1M-16p-5895M-800M
27481305        24867282       -9.5%	JBOD-10HDD-thresh=800M/xfs-10dd-1M-16p-5895M-800M
25651257        22507406      -12.3%	JBOD-10HDD-thresh=800M/xfs-1dd-1M-16p-5895M-800M
19849350        21298787       +7.3%	JBOD-10HDD-thresh=800M/xfs-2dd-1M-16p-5895M-800M

raw data by "grep":

JBOD-10HDD-6G/xfs-100dd-1M-16p-5895M-20:10-3.1.0-rc4+/vmstat-end:nr_written 38375271
JBOD-10HDD-6G/xfs-10dd-1M-16p-5895M-20:10-3.1.0-rc4+/vmstat-end:nr_written 30478879
JBOD-10HDD-6G/xfs-1dd-1M-16p-5895M-20:10-3.1.0-rc4+/vmstat-end:nr_written 29735407
JBOD-10HDD-6G/xfs-2dd-1M-16p-5895M-20:10-3.1.0-rc4+/vmstat-end:nr_written 30850350
JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M:10-3.1.0-rc4+/vmstat-end:nr_written 17706200
JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M:10-3.1.0-rc4+/vmstat-end:nr_written 23374918
JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M:10-3.1.0-rc4+/vmstat-end:nr_written 20659278
JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M:10-3.1.0-rc4+/vmstat-end:nr_written 22517497
JBOD-10HDD-thresh=2G/xfs-100dd-1M-16p-5895M-2048M:10-3.1.0-rc4+/vmstat-end:nr_written 68287850
JBOD-10HDD-thresh=2G/xfs-10dd-1M-16p-5895M-2048M:10-3.1.0-rc4+/vmstat-end:nr_written 33835247
JBOD-10HDD-thresh=2G/xfs-1dd-1M-16p-5895M-2048M:10-3.1.0-rc4+/vmstat-end:nr_written 30187817
JBOD-10HDD-thresh=2G/xfs-2dd-1M-16p-5895M-2048M:10-3.1.0-rc4+/vmstat-end:nr_written 30563144
JBOD-10HDD-thresh=4G/xfs-10dd-1M-16p-5895M-4096M:10-3.1.0-rc4+/vmstat-end:nr_written 34476862
JBOD-10HDD-thresh=4G/xfs-1dd-1M-16p-5895M-4096M:10-3.1.0-rc4+/vmstat-end:nr_written 30326479
JBOD-10HDD-thresh=4G/xfs-2dd-1M-16p-5895M-4096M:10-3.1.0-rc4+/vmstat-end:nr_written 30446767
JBOD-10HDD-thresh=800M/xfs-100dd-1M-16p-5895M-800M:10-3.1.0-rc4+/vmstat-end:nr_written 40793956
JBOD-10HDD-thresh=800M/xfs-10dd-1M-16p-5895M-800M:10-3.1.0-rc4+/vmstat-end:nr_written 27481305
JBOD-10HDD-thresh=800M/xfs-1dd-1M-16p-5895M-800M:10-3.1.0-rc4+/vmstat-end:nr_written 25651257
JBOD-10HDD-thresh=800M/xfs-2dd-1M-16p-5895M-800M:10-3.1.0-rc4+/vmstat-end:nr_written 19849350

JBOD-10HDD-6G/xfs-100dd-1M-16p-5895M-20:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 31553807
JBOD-10HDD-6G/xfs-10dd-1M-16p-5895M-20:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 28631491
JBOD-10HDD-6G/xfs-1dd-1M-16p-5895M-20:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 28871956
JBOD-10HDD-6G/xfs-2dd-1M-16p-5895M-20:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 28344165
JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 16174684
JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 14376942
JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 19640375
JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 14552321
JBOD-10HDD-thresh=2G/xfs-100dd-1M-16p-5895M-2048M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 61078553
JBOD-10HDD-thresh=2G/xfs-10dd-1M-16p-5895M-2048M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 32018425
JBOD-10HDD-thresh=2G/xfs-1dd-1M-16p-5895M-2048M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 29942083
JBOD-10HDD-thresh=2G/xfs-2dd-1M-16p-5895M-2048M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 30204022
JBOD-10HDD-thresh=4G/xfs-10dd-1M-16p-5895M-4096M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 34645398
JBOD-10HDD-thresh=4G/xfs-1dd-1M-16p-5895M-4096M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 30097263
JBOD-10HDD-thresh=4G/xfs-2dd-1M-16p-5895M-4096M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 30339683
JBOD-10HDD-thresh=800M/xfs-100dd-1M-16p-5895M-800M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 45936678
JBOD-10HDD-thresh=800M/xfs-10dd-1M-16p-5895M-800M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 24867282
JBOD-10HDD-thresh=800M/xfs-1dd-1M-16p-5895M-800M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 22507406
JBOD-10HDD-thresh=800M/xfs-2dd-1M-16p-5895M-800M:10-3.1.0-rc4-bdi-freerun+/vmstat-end:nr_written 21298787

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=bdi-freerun

Subject: 
Date: Wed Sep 14 22:57:43 CST 2011


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-09-14 22:50:33.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-09-14 22:58:15.000000000 +0800
@@ -614,22 +614,6 @@ static unsigned long bdi_position_ratio(
 	} else
 		pos_ratio /= 4;
 
-	/*
-	 * bdi reserve area, safeguard against dirty pool underrun and disk idle
-	 *
-	 * It may push the desired control point of global dirty pages higher
-	 * than setpoint. It's not necessary in single-bdi case because a
-	 * minimal pool of @freerun dirty pages will already be guaranteed.
-	 */
-	x_intercept = min(write_bw, freerun);
-	if (bdi_dirty < x_intercept) {
-		if (bdi_dirty > x_intercept / 8) {
-			pos_ratio *= x_intercept;
-			do_div(pos_ratio, bdi_dirty);
-		} else
-			pos_ratio *= 8;
-	}
-
 	return pos_ratio;
 }
 
@@ -1089,8 +1073,14 @@ static void balance_dirty_pages(struct a
 				     nr_dirty, bdi_thresh, bdi_dirty,
 				     start_time);
 
-		if (unlikely(!dirty_exceeded && bdi_async_underrun(bdi)))
-			break;
+		freerun = min(bdi->avg_write_bandwidth + MIN_WRITEBACK_PAGES,
+			      global_dirty_limit - nr_dirty) / 8;
+		if (!dirty_exceeded) {
+			if (unlikely(bdi_dirty < freerun))
+				break;
+			if (unlikely(bdi_async_underrun(bdi)))
+				break;
+		}
 
 		max_pause = bdi_max_pause(bdi, bdi_dirty);
 

--nFreZHaLTZJo0R7j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
