Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DEAF48D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:55 -0500 (EST)
Message-Id: <20110303074949.419321686@intel.com>
Date: Thu, 03 Mar 2011 14:45:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/27] btrfs: lower the dirty balance poll interval
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=btrfs-limit-nr-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Call balance_dirty_pages_ratelimit_nr() on every 32 pages dirtied.

Tests show that original larger intervals can easily make the bdi
dirty limit exceeded on 100 concurrent dd.

CC: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/file.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- linux-next.orig/fs/btrfs/file.c	2011-03-02 20:15:19.000000000 +0800
+++ linux-next/fs/btrfs/file.c	2011-03-02 20:35:07.000000000 +0800
@@ -949,9 +949,8 @@ static ssize_t btrfs_file_aio_write(stru
 	}
 
 	iov_iter_init(&i, iov, nr_segs, count, num_written);
-	nrptrs = min((iov_iter_count(&i) + PAGE_CACHE_SIZE - 1) /
-		     PAGE_CACHE_SIZE, PAGE_CACHE_SIZE /
-		     (sizeof(struct page *)));
+	nrptrs = min(DIV_ROUND_UP(iov_iter_count(&i), PAGE_CACHE_SIZE),
+		     min(32UL, PAGE_CACHE_SIZE / sizeof(struct page *)));
 	pages = kmalloc(nrptrs * sizeof(struct page *), GFP_KERNEL);
 	if (!pages) {
 		ret = -ENOMEM;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
