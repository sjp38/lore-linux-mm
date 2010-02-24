From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/15] readahead: pagecache context based mmap read-around
Date: Wed, 24 Feb 2010 11:10:16 +0800
Message-ID: <20100224031055.738182009@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7fg-0006Dn-8R
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:12:20 +0100
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A69D26B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:12:07 -0500 (EST)
Content-Disposition: inline; filename=readahead-mmap-around-context.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Do mmap read-around when there are cached pages in the nearby 256KB
(covered by one radix tree node).

There is a failure case though: for a sequence of page faults at page
index 64*i+1, i=1,2,3,..., this heuristic will keep doing pointless
read-arounds.  Hopefully the pattern won't appear in real workloads.
Note that the readahead heuristic has similiar failure case.

CC: Nick Piggin <npiggin@suse.de>
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
