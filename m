Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05A3C6B01C1
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:22:39 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:22:10 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 8/8] Cleancache: ocfs2 hook for cleancache
Message-ID: <20100621232210.GA28024@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 8/8] Cleancache: ocfs2 hook for cleancache

Filesystems must explicitly enable cleancache by calling
cleancache_init_fs anytime a instance of the filesystem
is mounted and must save the returned poolid.  Ocfs2 is
currently the only user of the clustered filesystem
interface but nevertheless, the cleancache hooks in the
VFS layer are sufficient for ocfs2 including
the matching cleancache_flush_fs hook which must be
called on unmount.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Joel Becker <joel.becker@oracle.com>

Diffstat:
 super.c                                  |    3 +++
 1 file changed, 3 insertions(+)

--- linux-2.6.35-rc2/fs/ocfs2/super.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/fs/ocfs2/super.c	2010-06-11 09:01:37.000000000 -0600
@@ -42,6 +42,7 @@
 #include <linux/seq_file.h>
 #include <linux/quotaops.h>
 #include <linux/smp_lock.h>
+#include <linux/cleancache.h>
 
 #define MLOG_MASK_PREFIX ML_SUPER
 #include <cluster/masklog.h>
@@ -2285,6 +2286,8 @@ static int ocfs2_initialize_super(struct
 		mlog_errno(status);
 		goto bail;
 	}
+	sb->cleancache_poolid =
+		cleancache_init_shared_fs((char *)&uuid_net_key, PAGE_SIZE);
 
 bail:
 	mlog_exit(status);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
