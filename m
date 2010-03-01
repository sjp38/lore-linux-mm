From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/16] readahead: limit read-ahead size for small memory systems
Date: Mon, 01 Mar 2010 13:26:56 +0800
Message-ID: <20100301053620.966418452@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyKm-00056N-8k
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:38:24 +0100
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2E41D6B0088
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:37:58 -0500 (EST)
Content-Disposition: inline; filename=readahead-small-memory-limit-readaround.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

When lifting the default readahead size from 128KB to 512KB,
make sure it won't add memory pressure to small memory systems.

For read-ahead, the memory pressure is mainly readahead buffers consumed
by too many concurrent streams. The context readahead can adapt
readahead size to thrashing threshold well.  So in principle we don't
need to adapt the default _max_ read-ahead size to memory pressure.

For read-around, the memory pressure is mainly read-around misses on
executables/libraries. Which could be reduced by scaling down
read-around size on fast "reclaim passes".

This patch presents a straightforward solution: to limit default
read-ahead size proportional to available system memory, ie.

                512MB mem => 512KB read-around size limit
                128MB mem => 128KB read-around size limit
                 32MB mem =>  32KB read-around size limit

This will allow power users to adjust read-ahead/read-around size at
once, while saving the low end from unnecessary memory pressure, under
the assumption that low end users have no need to request a large
read-around size.

CC: Matt Mackall <mpm@selenic.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- linux.orig/mm/filemap.c	2010-02-26 10:11:41.000000000 +0800
+++ linux/mm/filemap.c	2010-02-27 13:05:16.000000000 +0800
@@ -1431,7 +1431,9 @@ static void do_sync_mmap_readahead(struc
 	/*
 	 * mmap read-around
 	 */
-	ra_pages = max_sane_readahead(ra->ra_pages);
+	ra_pages = min_t(unsigned long,
+			 ra->ra_pages,
+			 roundup_pow_of_two(totalram_pages / 1024));
 	if (ra_pages) {
 		ra->start = max_t(long, 0, offset - ra_pages/2);
 		ra->size = ra_pages;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
