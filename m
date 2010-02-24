From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/15] readahead: limit readahead size for small memory systems
Date: Wed, 24 Feb 2010 11:10:06 +0800
Message-ID: <20100224031054.307027163@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7ga-0006YT-AK
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:13:16 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 71CEA6B008C
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:13:09 -0500 (EST)
Content-Disposition: inline; filename=readahead-small-memory-limit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
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
readahead size proportional to available system memory, ie.
                512MB mem => 512KB readahead size
                128MB mem => 128KB readahead size
                 32MB mem =>  32KB readahead size (minimal)

Strictly speaking, only read-around size has to be limited.  However we
don't bother to seperate read-around size from read-ahead size for now.

CC: Matt Mackall <mpm@selenic.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

--- linux.orig/mm/readahead.c	2010-02-24 10:44:42.000000000 +0800
+++ linux/mm/readahead.c	2010-02-24 10:44:42.000000000 +0800
@@ -19,6 +19,10 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+#define MIN_READAHEAD_PAGES DIV_ROUND_UP(VM_MIN_READAHEAD*1024, PAGE_CACHE_SIZE)
+
+static int __initdata user_defined_readahead_size;
+
 static int __init config_readahead_size(char *str)
 {
 	unsigned long bytes;
@@ -36,11 +40,33 @@ static int __init config_readahead_size(
 			bytes = 128 << 20;
 	}
 
+	user_defined_readahead_size = 1;
 	default_backing_dev_info.ra_pages = bytes / PAGE_CACHE_SIZE;
 	return 0;
 }
 early_param("readahead", config_readahead_size);
 
+static int __init check_readahead_size(void)
+{
+	/*
+	 * Scale down default readahead size for small memory systems.
+	 * For example, a 64MB box will do 64KB read-ahead/read-around
+	 * instead of the default 512KB.
+	 *
+	 * Note that the default readahead size will also be scaled down
+	 * for small devices in add_disk().
+	 */
+	if (!user_defined_readahead_size) {
+		unsigned long max = roundup_pow_of_two(totalram_pages / 1024);
+		if (default_backing_dev_info.ra_pages > max)
+		    default_backing_dev_info.ra_pages = max;
+		if (default_backing_dev_info.ra_pages < MIN_READAHEAD_PAGES)
+		    default_backing_dev_info.ra_pages = MIN_READAHEAD_PAGES;
+	}
+	return 0;
+}
+fs_initcall(check_readahead_size);
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
