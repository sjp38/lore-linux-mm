Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C8C956B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 23:37:51 -0500 (EST)
Date: Wed, 8 Dec 2010 12:37:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH v2] writeback: safety margin for bdi stat error
Message-ID: <20101208043746.GA15357@localhost>
References: <20101205064430.GA15027@localhost>
 <20101207165111.d79735c1.akpm@linux-foundation.org>
 <20101208043004.GB15322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101208043004.GB15322@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In a simple dd test on a 8p system with "mem=256M", I find all light
dirtier tasks on the root fs are get heavily throttled. That happens
because the global limit is exceeded. It's unbelievable at first sight,
because the test fs doing the heavy dd is under its bdi limit.  After
doing some tracing, it's discovered that

	bdi_dirty < bdi_dirty_limit() < global_dirty_limit() < nr_dirty

So the root cause is, the bdi_dirty is well under the global nr_dirty
due to accounting errors. This can be fixed by using bdi_stat_sum(),
however that's costly on large NUMA machines. So do a less costly fix
of lowering the bdi limit, so that the accounting errors won't lead to
the absurd situation "global limit exceeded but bdi limit not exceeded".

This provides guarantee when there is only 1 heavily dirtied bdi, and
works by opportunity for 2+ heavy dirtied bdi's (hopefully they won't
reach big error _and_ exceed their bdi limit at the same time).

Acked-by: Rik van Riel <riel@redhat.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

v2: add kernel doc and correct the terms in changelog.

 mm/page-writeback.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 12:26:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 12:30:45.000000000 +0800
@@ -434,10 +434,16 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-/*
+/**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
+ * @bdi: the backing_dev_info to query
+ * @dirty: global dirty limit in pages
+ * @dirty_pages: current number of dirty pages
  *
- * Allocate high/low dirty limits to fast/slow devices, in order to prevent
+ * Returns @bdi's dirty limit in pages. The term "dirty" in the context of
+ * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
+ *
+ * It allocates high/low dirty limits to fast/slow devices, in order to prevent
  * - starving fast devices
  * - piling up dirty pages (that will take long time to sync) on slow devices
  *
@@ -458,6 +464,14 @@ unsigned long bdi_dirty_limit(struct bac
 	long numerator, denominator;
 
 	/*
+	 * try to prevent "global limit exceeded but bdi limit not exceeded"
+	 */
+	if (likely(dirty > bdi_stat_error(bdi)))
+		dirty -= bdi_stat_error(bdi);
+	else
+		return 0;
+
+	/*
 	 * Provide a global safety margin of ~1%, or up to 32MB for a 20GB box.
 	 */
 	dirty -= min(dirty / 128, 32768ULL >> (PAGE_SHIFT-10));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
