Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 168B76B016B
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 10:58:16 -0400 (EDT)
Date: Tue, 23 Aug 2011 07:57:55 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
Message-ID: <20110823145755.GA23174@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes

This first patch of four in the frontswap series makes available core
swap data structures (swap_lock, swap_list and swap_info) that are
needed by frontswap.c but we don't need to expose them to the dozens
of files that include swap.h so we create a new swapfile.h just to
extern-ify these.

Also add frontswap-related elements to swap_info_struct.  Frontswap_map
points to vzalloc'ed one-bit-per-swap-page metadata that indicates
whether the swap page is in frontswap or in the device and frontswap_pages
counts how many pages are in frontswap.

[v7: rebase to 3.0-rc3]
[v7: JBeulich@novell.com: add new swap struct elements only if config'd]
[v6: rebase to 3.0-rc1]
[v5: no change from v4]
[v4: rebase to 2.6.39]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
Acked-by: Jan Beulich <JBeulich@novell.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Rik Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

--- linux/include/linux/swapfile.h	1969-12-31 17:00:00.000000000 -0700
+++ frontswap/include/linux/swapfile.h	2011-08-23 08:20:09.757818005 -0600
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
--- linux/include/linux/swap.h	2011-08-08 08:19:25.880690134 -0600
+++ frontswap/include/linux/swap.h	2011-08-23 08:27:57.584694638 -0600
@@ -194,6 +194,10 @@ struct swap_info_struct {
 	struct block_device *bdev;	/* swap device or bdev of swap file */
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
+#ifdef CONFIG_FRONTSWAP
+	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
+	unsigned int frontswap_pages;	/* frontswap pages in-use counter */
+#endif
 };
 
 struct swap_list_t {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
