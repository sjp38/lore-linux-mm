Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07EB46B0082
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 17:01:58 -0400 (EDT)
Date: Wed, 22 Sep 2010 14:00:13 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 1/4] Frontswap: swap data structure changes
Message-ID: <20100922210013.GA27324@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 1/4] Frontswap: swap data structure changes

Core swap data structures are needed by frontswap.c but we don't
need to expose them to the dozens of files that include swap.h
so create a new swapfile.h just to extern-ify these.

Add frontswap-related elements to swap_info_struct.  Don't tie
these to CONFIG_FRONTSWAP to avoid unnecessary clutter around
various frontswap hooks.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 swap.h                                   |    2 ++
 swapfile.h                               |   13 +++++++++++++
 2 files changed, 15 insertions(+)

--- linux-2.6.36-rc5/include/linux/swapfile.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-rc5-frontswap/include/linux/swapfile.h	2010-09-21 13:58:02.000000000 -0600
@@ -0,0 +1,13 @@
+#ifndef _LINUX_SWAPFILE_H
+#define _LINUX_SWAPFILE_H
+
+/*
+ * these were static in swapfile.c but frontswap.c needs them and we don't
+ * want to expose them to the dozens of source files that include swap.h
+ */
+extern spinlock_t swap_lock;
+extern struct swap_list_t swap_list;
+extern struct swap_info_struct *swap_info[];
+extern int try_to_unuse(unsigned int, bool, unsigned long);
+
+#endif /* _LINUX_SWAPFILE_H */
--- linux-2.6.36-rc5/include/linux/swap.h	2010-09-20 17:56:53.000000000 -0600
+++ linux-2.6.36-rc5-frontswap/include/linux/swap.h	2010-09-21 14:00:11.000000000 -0600
@@ -185,6 +185,8 @@ struct swap_info_struct {
 	struct block_device *bdev;	/* swap device or bdev of swap file */
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
+	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
+	unsigned int frontswap_pages;	/* frontswap pages in-use counter */
 };
 
 struct swap_list_t {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
