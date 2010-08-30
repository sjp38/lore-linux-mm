Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2E906B01F3
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:33:51 -0400 (EDT)
Date: Mon, 30 Aug 2010 15:33:03 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V4 6/8] Cleancache: btrfs hooks for cleancache
Message-ID: <20100830223303.GA1342@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

[PATCH V4 6/8] Cleancache: btrfs hooks for cleancache

Filesystems must explicitly enable cleancache by calling
cleancache_init_fs anytime a instance of the filesystem
is mounted and must save the returned poolid.  Btrfs
uses its own readpage which must be hooked, but all other
cleancache hooks are in the VFS layer including
the matching cleancache_flush_fs hook which must be
called on unmount.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Chris Mason <chris.mason@oracle.com>

Diffstat:
 extent_io.c                              |    9 +++++++++
 super.c                                  |    2 ++
 2 files changed, 11 insertions(+)

--- linux-2.6.36-rc3/fs/btrfs/super.c	2010-08-29 09:36:04.000000000 -0600
+++ linux-2.6.36-rc3-cleancache/fs/btrfs/super.c	2010-08-30 09:20:42.000000000 -0600
@@ -39,6 +39,7 @@
 #include <linux/miscdevice.h>
 #include <linux/magic.h>
 #include <linux/slab.h>
+#include <linux/cleancache.h>
 #include "compat.h"
 #include "ctree.h"
 #include "disk-io.h"
@@ -479,6 +480,7 @@ static int btrfs_fill_super(struct super
 	sb->s_root = root_dentry;
 
 	save_mount_options(sb, data);
+	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);
 	return 0;
 
 fail_close:
--- linux-2.6.36-rc3/fs/btrfs/extent_io.c	2010-08-29 09:36:04.000000000 -0600
+++ linux-2.6.36-rc3-cleancache/fs/btrfs/extent_io.c	2010-08-30 09:20:42.000000000 -0600
@@ -10,6 +10,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
+#include <linux/cleancache.h>
 #include "extent_io.h"
 #include "extent_map.h"
 #include "compat.h"
@@ -2027,6 +2028,13 @@ static int __extent_read_full_page(struc
 
 	set_page_extent_mapped(page);
 
+	if (!PageUptodate(page)) {
+		if (cleancache_get_page(page) == 0) {
+			BUG_ON(blocksize != PAGE_SIZE);
+			goto out;
+		}
+	}
+
 	end = page_end;
 	while (1) {
 		lock_extent(tree, start, end, GFP_NOFS);
@@ -2151,6 +2159,7 @@ static int __extent_read_full_page(struc
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
