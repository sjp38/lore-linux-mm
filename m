Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D473D6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 21:48:43 -0500 (EST)
Date: Fri, 26 Feb 2010 10:48:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] readahead: add notes on readahead size
Message-ID: <20100226024837.GA22859@localhost>
References: <20100224031001.026464755@intel.com> <20100224031054.307027163@intel.com> <4B869682.9010709@linux.vnet.ibm.com> <20100226022907.GA22226@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100226022907.GA22226@localhost>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> readahead: limit read-ahead size for small memory systems
> 
> When lifting the default readahead size from 128KB to 512KB,
> make sure it won't add memory pressure to small memory systems.

btw, I wrote some comments to summarize the now complex readahead size
rules..

==
readahead: add notes on readahead size

Basically, currently the default max readahead size
- is 512k
- is boot time configurable with "readahead="
and is auto scaled down:
- for small devices
- for small memory systems (read-around size alone)

CC: Matt Mackall <mpm@selenic.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
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
