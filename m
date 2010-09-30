Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 829D26B0078
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:33 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:32 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 01/12] mm: remove temporary variable on generic_file_direct_write()
Date: Thu, 30 Sep 2010 12:50:10 +0900
Message-Id: <1285818621-29890-2-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

'end' shadows earlier one and is not necessary at all. Remove it
and use 'pos' instead. This removes following sparse warnings:

 mm/filemap.c:2180:24: warning: symbol 'end' shadows an earlier one
 mm/filemap.c:2132:25: originally declared here

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/filemap.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3d4df44..4a05bf1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2177,12 +2177,12 @@ generic_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	}
 
 	if (written > 0) {
-		loff_t end = pos + written;
-		if (end > i_size_read(inode) && !S_ISBLK(inode->i_mode)) {
-			i_size_write(inode,  end);
+		pos += written;
+		if (pos > i_size_read(inode) && !S_ISBLK(inode->i_mode)) {
+			i_size_write(inode, pos);
 			mark_inode_dirty(inode);
 		}
-		*ppos = end;
+		*ppos = pos;
 	}
 out:
 	return written;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
