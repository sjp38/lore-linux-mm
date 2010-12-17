Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0BCB36B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 06:21:17 -0500 (EST)
Date: Fri, 17 Dec 2010 19:21:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
Message-ID: <20101217112111.GA8323@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.002158963@intel.com>
 <20101217021934.GA9525@localhost>
 <alpine.LSU.2.00.1012162239270.23229@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1012162239270.23229@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.

It also prevents

[  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050

in the balance_dirty_pages tracepoint, which will call

	dev_name(mapping->backing_dev_info->dev)

but shmem_backing_dev_info.dev is NULL.

CC: Hugh Dickins <hughd@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-17 19:09:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-17 19:09:22.000000000 +0800
@@ -899,6 +899,9 @@ void balance_dirty_pages_ratelimited_nr(
 {
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
+	if (!bdi_cap_account_dirty(bdi))
+		return;
+
 	current->nr_dirtied += nr_pages_dirtied;
 
 	if (unlikely(!current->nr_dirtied_pause))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
