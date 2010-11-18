Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 907B86B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:51:21 -0500 (EST)
Date: Thu, 18 Nov 2010 14:51:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
Message-ID: <20101118065111.GA8458@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.002299964@intel.com>
 <20101117150837.a18d56c1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117150837.a18d56c1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 07:08:37AM +0800, Andrew Morton wrote:
> On Wed, 17 Nov 2010 12:27:26 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > +	w = min(elapsed / (HZ/100), 128UL);
> 
> I did try setting HZ=10 many years ago, and the kernel blew up.
> 
> I do recall hearing of people who set HZ very low, perhaps because
> their huge machines were seeing performance prolems when the timer tick
> went off.  Probably there's no need to do that any more.
> 
> But still, we shouldn't hard-wire the (HZ >= 100) assumption if we
> don't absolutely need to, and I don't think it is absolutely needed
> here.  

Fair enough.  Here is the fix. The other (HZ/10) will be addressed by
another patch that increase it to MAX_PAUSE=max(HZ/5, 1).

Thanks,
Fengguang
---

Subject: writeback: prevent divide error on tiny HZ
Date: Thu Nov 18 12:19:56 CST 2010

As suggested by Andrew and Peter:

I do recall hearing of people who set HZ very low, perhaps because their
huge machines were seeing performance prolems when the timer tick went
off.  Probably there's no need to do that any more.

But still, we shouldn't hard-wire the (HZ >= 100) assumption if we don't
absolutely need to, and I don't think it is absolutely needed here.

People who do cpu bring-up on very slow FPGAs also lower HZ as far as
possible.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-11-18 12:35:18.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-18 12:35:38.000000000 +0800
@@ -490,6 +490,7 @@ void bdi_update_write_bandwidth(struct b
 				unsigned long *bw_time,
 				s64 *bw_written)
 {
+	const unsigned long unit_time = max(HZ/100, 1);
 	unsigned long written;
 	unsigned long elapsed;
 	unsigned long bw;
@@ -499,7 +500,7 @@ void bdi_update_write_bandwidth(struct b
 		goto snapshot;
 
 	elapsed = jiffies - *bw_time;
-	if (elapsed < HZ/100)
+	if (elapsed < unit_time)
 		return;
 
 	/*
@@ -513,7 +514,7 @@ void bdi_update_write_bandwidth(struct b
 
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
 	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
-	w = min(elapsed / (HZ/100), 128UL);
+	w = min(elapsed / unit_time, 128UL);
 	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
 	bdi->write_bandwidth_update_time = jiffies;
 snapshot:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
