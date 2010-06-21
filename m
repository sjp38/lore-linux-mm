Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E45866B01BE
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:21:04 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:20:40 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 5/8] Cleancache: ext3 hook for cleancache
Message-ID: <20100621232040.GA19617@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 5/8] Cleancache: ext3 hook for cleancache

Filesystems must explicitly enable cleancache by calling
cleancache_init_fs anytime a instance of the filesystem
is mounted and must save the returned poolid.  For ext3,
all other cleancache hooks are in the VFS layer including
the matching cleancache_flush_fs hook which must be
called on unmount.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Andreas Dilger <adilger@sun.com>

Diffstat:
 super.c                                  |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.35-rc2/fs/ext3/super.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/fs/ext3/super.c	2010-06-11 09:01:37.000000000 -0600
@@ -37,6 +37,7 @@
 #include <linux/quotaops.h>
 #include <linux/seq_file.h>
 #include <linux/log2.h>
+#include <linux/cleancache.h>
 
 #include <asm/uaccess.h>
 
@@ -1362,6 +1363,7 @@ static int ext3_setup_super(struct super
 	} else {
 		ext3_msg(sb, KERN_INFO, "using internal journal");
 	}
+	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);
 	return res;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
