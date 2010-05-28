Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28D3B6B01CD
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:37:33 -0400 (EDT)
Date: Fri, 28 May 2010 10:36:51 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V2 5/7] Cleancache (was Transcendent Memory): btrfs hooks
Message-ID: <20100528173651.GA20098@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V2 5/7] Cleancache (was Transcendent Memory): btrfs hooks

Filesystems must explicitly enable cleancache.  Also, btrfs
uses its own readpage which must be hooked.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Chris Mason <chris.mason@oracle.com>

Diffstat:
 extent_io.c                              |    9 +++++++++
 super.c                                  |    2 ++
 2 files changed, 11 insertions(+)

--- linux-2.6.34/fs/btrfs/super.c	2010-05-16 15:17:36.000000000 -0600
+++ linux-2.6.34-cleancache/fs/btrfs/super.c	2010-05-24 12:14:44.000000000 -0600
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
--- linux-2.6.34/fs/btrfs/extent_io.c	2010-05-16 15:17:36.000000000 -0600
+++ linux-2.6.34-cleancache/fs/btrfs/extent_io.c	2010-05-24 12:31:01.000000000 -0600
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
+		if (cleancache_get_page(page) == CLEANCACHE_GET_PAGE_SUCCESS) {
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
