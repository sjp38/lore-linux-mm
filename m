From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/15] readahead: reduce MMAP_LOTSAMISS for mmap read-around
Date: Wed, 24 Feb 2010 11:10:15 +0800
Message-ID: <20100224031055.594006457@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7gd-0006ZQ-4U
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:13:19 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A94B86B0092
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:13:09 -0500 (EST)
Content-Disposition: inline; filename=readahead-mmap-around.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Now that we lifts readahead size from 128KB to 512KB,
the MMAP_LOTSAMISS shall be shrinked accordingly.

We shrink it a bit more, so that for sparse random access patterns,
only 10*512KB or ~5MB memory will be wasted, instead of the previous
100*128KB or ~12MB. The new threshold "10" is still big enough to avoid
turning off read-around for typical executable/lib page faults.

CC: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/mm/filemap.c	2010-02-21 23:56:22.000000000 +0800
+++ linux/mm/filemap.c	2010-02-21 23:56:26.000000000 +0800
@@ -1393,7 +1393,7 @@ static int page_cache_read(struct file *
 	return ret;
 }
 
-#define MMAP_LOTSAMISS  (100)
+#define MMAP_LOTSAMISS  (10)
 
 /*
  * Synchronous readahead happens when we don't even find


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
