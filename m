Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF1D16B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:16:34 -0400 (EDT)
Subject: Cleancache [PATCH 5/7] (was Transcendent Memory): btrfs hooks
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vJR-0007Tc-Oq@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:15:21 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 5/7] (was Transcendent Memory): btrfs hooks

Filesystems must explicitly enable cleancache.  Also, btrfs
uses its own readpage which must be hooked.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Chris Mason <chris.mason@oracle.com>

Diffstat:
 extent_io.c                              |    9 +++++++++
 super.c                                  |    2 ++
 2 files changed, 11 insertions(+)

--- linux-2.6.34-rc5/fs/btrfs/super.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/btrfs/super.c	2010-04-21 10:08:39.000000000 -0600
@@ -39,6 +39,7 @@
 #include <linux/miscdevice.h>
 #include <linux/magic.h>
 #include <linux/slab.h>
+#include <linux/cleancache.h>
 #include "compat.h"
 #include "ctree.h"
 #include "disk-io.h"
@@ -477,6 +478,7 @@ static int btrfs_fill_super(struct super
 	sb->s_root = root_dentry;
 
 	save_mount_options(sb, data);
+	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);
 	return 0;
 
 fail_close:
--- linux-2.6.34-rc5/fs/btrfs/extent_io.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/btrfs/extent_io.c	2010-04-21 10:07:31.000000000 -0600
@@ -10,6 +10,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
+#include <linux/cleancache.h>
 #include "extent_io.h"
 #include "extent_map.h"
 #include "compat.h"
@@ -2030,6 +2031,13 @@ static int __extent_read_full_page(struc
 
 	set_page_extent_mapped(page);
 
+	if (!PageUptodate(page)) {
+		if (cleancache_get_page(page) == 1) {
+			BUG_ON(blocksize != PAGE_SIZE);
+			goto out;
+		}
+	}
+
 	end = page_end;
 	lock_extent(tree, start, end, GFP_NOFS);
 
@@ -2146,6 +2154,7 @@ static int __extent_read_full_page(struc
 		cur = cur + iosize;
 		page_offset += iosize;
 	}
+out:
 	if (!nr) {
 		if (!PageError(page))
 			SetPageUptodate(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
