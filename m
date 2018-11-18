Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 904606B1497
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 07:03:07 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id s14so520312pfk.16
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 04:03:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor19558975ply.14.2018.11.18.04.03.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Nov 2018 04:03:06 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/filemap.c: minor optimization in write_iter file operation
Date: Sun, 18 Nov 2018 20:02:18 +0800
Message-Id: <1542542538-11938-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, akpm@linux-foundation.org, darrick.wong@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yafang Shao <laoar.shao@gmail.com>

This little adjustment on bitwise operation could make the code a little
faster.
As write_iter is used in lots of critical path, so this code change is
useful for performance.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/filemap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8..a65056ea 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2881,7 +2881,8 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	if (iocb->ki_flags & IOCB_APPEND)
 		iocb->ki_pos = i_size_read(inode);
 
-	if ((iocb->ki_flags & IOCB_NOWAIT) && !(iocb->ki_flags & IOCB_DIRECT))
+	if ((iocb->ki_flags & (IOCB_NOWAIT | IOCB_DIRECT)) ==
+	    IOCB_NOWAIT)
 		return -EINVAL;
 
 	count = iov_iter_count(from);
-- 
1.8.3.1
