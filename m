Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id F1CD182F64
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:46:46 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so147602417wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 05:46:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si15728797wif.44.2015.10.12.05.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 05:46:45 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH] mm: Make sendfile(2) killable
Date: Mon, 12 Oct 2015 14:45:23 +0200
Message-Id: <1444653923-22111-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, Jan Kara <jack@suse.com>

Currently a simple program below issues a sendfile(2) system call which
takes about 62 days to complete in my test KVM instance.

        int fd;
        off_t off = 0;

        fd = open("file", O_RDWR | O_TRUNC | O_SYNC | O_CREAT, 0644);
        ftruncate(fd, 2);
        lseek(fd, 0, SEEK_END);
        sendfile(fd, fd, &off, 0xfffffff);

Now you should not ask kernel to do a stupid stuff like copying 256MB in
2-byte chunks and call fsync(2) after each chunk but if you do, sysadmin
should have a way to stop you.

We actually do have a check for fatal_signal_pending() in
generic_perform_write() which triggers in this path however because we
always succeed in writing something before the check is done, we return
value > 0 from generic_perform_write() and thus the information about
signal gets lost.

Fix the problem by doing the signal check before writing anything. That
way generic_perform_write() returns -EINTR, the error gets propagated up
and the sendfile loop terminates early.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Jan Kara <jack@suse.com>
---
 mm/filemap.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1cc5467cf36c..327910c2400c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2488,6 +2488,11 @@ again:
 			break;
 		}
 
+		if (fatal_signal_pending(current)) {
+			status = -EINTR;
+			break;
+		}
+
 		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
 						&page, &fsdata);
 		if (unlikely(status < 0))
@@ -2525,10 +2530,6 @@ again:
 		written += copied;
 
 		balance_dirty_pages_ratelimited(mapping);
-		if (fatal_signal_pending(current)) {
-			status = -EINTR;
-			break;
-		}
 	} while (iov_iter_count(i));
 
 	return written ? written : status;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
