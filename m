From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/16] readahead: add notes on readahead size
Date: Mon, 01 Mar 2010 13:26:57 +0800
Message-ID: <20100301053621.102557225@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyLL-0005Hm-G0
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:38:59 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B899A6B0089
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:38:57 -0500 (EST)
Content-Disposition: inline; filename=readahead-size-comment.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Basically, currently the default max readahead size
- is 512k
- is boot time configurable with "readahead="
and is auto scaled down:
- for small devices
- for small memory systems (read-around size alone)

CC: Matt Mackall <mpm@selenic.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

--- linux.orig/mm/readahead.c	2010-02-26 10:11:41.000000000 +0800
+++ linux/mm/readahead.c	2010-02-26 10:11:55.000000000 +0800
@@ -7,6 +7,28 @@
  *		Initial version.
  */
 
+/*
+ * Notes on readahead size.
+ *
+ * The default max readahead size is VM_MAX_READAHEAD=512k,
+ * which can be changed by user with boot time parameter "readahead="
+ * or runtime interface "/sys/devices/virtual/bdi/default/read_ahead_kb".
+ * The latter normally only takes effect in future for hot added devices.
+ *
+ * The effective max readahead size for each block device can be accessed with
+ * 1) the `blockdev` command
+ * 2) /sys/block/sda/queue/read_ahead_kb
+ * 3) /sys/devices/virtual/bdi/$(env stat -c '%t:%T' /dev/sda)/read_ahead_kb
+ *
+ * They are typically initialized with the global default size, however may be
+ * auto scaled down for small devices in add_disk(). NFS, software RAID, btrfs
+ * etc. have special rules to setup their default readahead size.
+ *
+ * The mmap read-around size typically equals with readahead size, with an
+ * extra limit proportional to system memory size.  For example, a 64MB box
+ * will have a 64KB read-around size limit, 128MB mem => 128KB limit, etc.
+ */
+
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/memcontrol.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
