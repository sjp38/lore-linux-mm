From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/16] readahead: pagecache context based mmap read-around
Date: Mon, 01 Mar 2010 13:27:07 +0800
Message-ID: <20100301053622.514378154@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyLS-0005KL-Bs
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:39:06 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 43DA26B0095
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:38:58 -0500 (EST)
Content-Disposition: inline; filename=readahead-mmap-around-context.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Do mmap read-around when there are cached pages in the nearby 256KB
(covered by one radix tree node).

There is a failure case though: for a sequence of page faults at page
index 64*i+1, i=1,2,3,..., this heuristic will keep doing pointless
read-arounds.  Hopefully the pattern won't appear in real workloads.
Note that the readahead heuristic has similiar failure case.

CC: Nick Piggin <npiggin@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

--- linux.orig/mm/filemap.c	2010-02-23 13:20:39.000000000 +0800
+++ linux/mm/filemap.c	2010-02-23 13:22:36.000000000 +0800
@@ -1421,11 +1421,17 @@ static void do_sync_mmap_readahead(struc
 
 
 	/*
-	 * Do we miss much more than hit in this file? If so,
-	 * stop bothering with read-ahead. It will only hurt.
+	 * Do we miss much more than hit in this file? If so, stop bothering
+	 * with read-around, unless some nearby pages were accessed recently.
 	 */
-	if (ra_mmap_miss_inc(ra) > MMAP_LOTSAMISS)
-		return;
+	if (ra_mmap_miss_inc(ra) > MMAP_LOTSAMISS) {
+		struct radix_tree_node *node;
+		rcu_read_lock();
+		node = radix_tree_lookup_leaf_node(&mapping->page_tree, offset);
+		rcu_read_unlock();
+		if (!node)
+			return;
+	}
 
 	/*
 	 * mmap read-around


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
