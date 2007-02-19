In-reply-to: <20070218155916.0d3c73a9.akpm@linux-foundation.org> (message from
	Andrew Morton on Sun, 18 Feb 2007 15:59:16 -0800)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org>
Message-Id: <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 18:11:55 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

How about this?

Solves the FUSE deadlock, but not the throttle_vm_writeout() one.
I'll try to tackle that one as well.

If the per-bdi dirty counter goes below 16, balance_dirty_pages()
returns.

Does the constant need to tunable?  If it's too large, then the global
threshold is more easily exceeded.  If it's too small, then in a tight
situation progress will be slower.

Thanks,
Miklos

Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2007-02-19 17:32:41.000000000 +0100
+++ linux/mm/page-writeback.c	2007-02-19 18:05:28.000000000 +0100
@@ -198,6 +198,25 @@ static void balance_dirty_pages(struct a
 			dirty_thresh)
 				break;
 
+		/*
+		 * Acquit this producer if there's little or nothing
+		 * to write back to this particular queue
+		 *
+		 * Without this check a deadlock is possible in the
+		 * following case:
+		 *
+		 * - filesystem A writes data through filesystem B
+		 * - filesystem A has dirty pages over dirty_thresh
+		 * - writeback is started, this triggers a write in B
+		 * - balance_dirty_pages() is called synchronously
+		 * - the write to B blocks
+		 * - the writeback completes, but dirty is still over threshold
+		 * - the blocking write prevents futher writes from happening
+		 */
+		if (atomic_long_read(&bdi->nr_dirty) +
+		    atomic_long_read(&bdi->nr_writeback) < 16)
+			break;
+
 		if (!dirty_exceeded)
 			dirty_exceeded = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
