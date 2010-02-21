Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 972776B004D
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 20:30:33 -0500 (EST)
Date: Sun, 21 Feb 2010 23:49:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100221154926.GA22038@localhost>
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100214213724.GA28392@discord.disaster> <201002151006.37294.knikanth@suse.de> <20100221142600.GA10036@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100221142600.GA10036@localhost>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> Christian, with this patch and more patches to scale down readahead
> size on small memory/device size, I guess it's no longer necessary to
> introduce a CONFIG_READAHEAD_SIZE?

This is the memory size based readahead limit :)

Thanks,
Fengguang
---
readahead: limit readahead size for small memory systems

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
 mm/readahead.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

--- linux.orig/mm/readahead.c	2010-02-21 22:42:15.000000000 +0800
+++ linux/mm/readahead.c	2010-02-21 23:43:14.000000000 +0800
@@ -19,6 +19,9 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+#define MIN_READAHEAD_PAGES DIV_ROUND_UP(VM_MIN_READAHEAD*1024, PAGE_CACHE_SIZE)
+
+static int __init user_defined_readahead_size;
 static int __init config_readahead_size(char *str)
 {
 	unsigned long bytes;
@@ -36,11 +39,33 @@ static int __init config_readahead_size(
 			bytes = 128 << 20;
 	}
 
+	user_defined_readahead_size = 1;
 	default_backing_dev_info.ra_pages = bytes / PAGE_CACHE_SIZE;
 	return 0;
 }
 early_param("readahead", config_readahead_size);
 
+static int __init readahead_init(void)
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
+fs_initcall(readahead_init);
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
