Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 224176B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:44:15 -0500 (EST)
Date: Thu, 18 Nov 2010 23:44:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: prevent bandwidth calculation overflow
Message-ID: <20101118154408.GA18582@localhost>
References: <20101118065725.GB8458@localhost>
 <4CE537BE.6090103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CE537BE.6090103@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 10:27:10PM +0800, Rik van Riel wrote:
> On 11/18/2010 01:57 AM, Wu Fengguang wrote:
> > On 32bit kernel, bdi->write_bandwidth can express at most 4GB/s.
> >
> > However the current calculation code can overflow when disk bandwidth
> > reaches 800MB/s.  Fix it by using "long long" and swapping the order of
> > multiplication/division. And further, change its unit to pages/second
> > rather than bytes/second. That allows up to 16TB/s bandwidth in 32bit
> > kernel.
> >
> > Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks. I find that the swap of multiplication/division leads to
underflow, so changed to use "long long". It's free for 64bit gcc
anyway :)

Thanks,
Fengguang
--
Subject: writeback: prevent bandwidth calculation overflow
Date: Thu Nov 18 12:55:42 CST 2010

On 32bit kernel, bdi->write_bandwidth can express at most 4GB/s.

However the current calculation code can overflow when disk bandwidth
reaches 800MB/s.  Fix it by using "long long" when doing calculations.

And further change its unit from bytes/second to pages/second.
That allows up to 16TB/s bandwidth in 32bit kernel.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c    |    4 ++--
 mm/page-writeback.c |   11 +++++------
 2 files changed, 7 insertions(+), 8 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-11-18 12:42:58.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-18 22:40:18.000000000 +0800
@@ -494,7 +494,7 @@ void bdi_update_write_bandwidth(struct b
 	unsigned long written;
 	unsigned long elapsed;
 	unsigned long bw;
-	unsigned long w;
+	unsigned long long w;
 
 	if (*bw_written == 0)
 		goto snapshot;
@@ -513,7 +513,7 @@ void bdi_update_write_bandwidth(struct b
 		goto snapshot;
 
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
-	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
+	bw = (HZ * written + elapsed/2) / elapsed;
 	w = min(elapsed / unit_time, 128UL);
 	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
 	bdi->write_bandwidth_update_time = jiffies;
@@ -539,7 +539,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	unsigned long task_thresh;
-	unsigned long bw;
+	unsigned long long bw;
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
@@ -602,8 +602,7 @@ static void balance_dirty_pages(struct a
 		 * of dirty pages have been cleaned during our pause time.
 		 */
 		if (nr_dirty < dirty_thresh &&
-		    bdi_prev_dirty - bdi_dirty >
-		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
+		    bdi_prev_dirty - bdi_dirty > bdi->write_bandwidth / 4)
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
@@ -626,7 +625,7 @@ static void balance_dirty_pages(struct a
 		bw = bw * (task_thresh - bdi_dirty);
 		bw = bw / (bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
-		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		pause = HZ * pages_dirtied / (bw + 1);
 		pause = clamp_val(pause, 1, HZ/10);
 
 pause:
--- linux-next.orig/mm/backing-dev.c	2010-11-18 14:24:45.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-11-18 14:27:00.000000000 +0800
@@ -103,7 +103,7 @@ static int bdi_debug_stats_show(struct s
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
-		   (unsigned long) bdi->write_bandwidth >> 10,
+		   (unsigned long) K(bdi->write_bandwidth),
 		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
@@ -662,7 +662,7 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
-	bdi->write_bandwidth = 100 << 20;
+	bdi->write_bandwidth = (100 << 20) / PAGE_CACHE_SIZE;
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
