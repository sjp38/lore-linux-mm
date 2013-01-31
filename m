Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 2DDC46B000C
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:50:31 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/6] fs: Don't call dio_cleanup() before submitting all bios
Date: Thu, 31 Jan 2013 22:49:52 +0100
Message-Id: <1359668994-13433-5-git-send-email-jack@suse.cz>
In-Reply-To: <1359668994-13433-1-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

do_blockdev_direct_IO() can call dio_cleanup() before submitting
all bios. This will be inconvenient for us because we need to keep
preallocated structure in sdio which we attach to bio on submit and
it is natural to cleanup unused allocation in dio_cleanup().

Since dio_cleanup() is called again after submitting the last bio it is
enough to just remove the first dio_cleanup() call.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/direct-io.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index cf5b44b..3a430f3 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -1209,10 +1209,8 @@ do_blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 			((sdio.final_block_in_request - sdio.block_in_file) <<
 					blkbits);
 
-		if (retval) {
-			dio_cleanup(dio, &sdio);
+		if (retval)
 			break;
-		}
 	} /* end iovec loop */
 
 	if (retval == -ENOTBLK) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
