Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8083B6B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:49:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n85so6717191pfi.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:49:33 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id d5si7583531pgh.128.2016.10.27.04.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 04:49:32 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id n85so2475831pfi.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:49:32 -0700 (PDT)
From: Eryu Guan <guaneryu@gmail.com>
Subject: [PATCH] mm/filemap: don't check partially uptodate page for pipes
Date: Thu, 27 Oct 2016 19:41:59 +0800
Message-Id: <1477568519-7891-1-git-send-email-guaneryu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, Eryu Guan <guaneryu@gmail.com>

After commit 82c156f85384 ("switch generic_file_splice_read() to use
of ->read_iter()") I started noticing some test failures of
sendfile(2) and splice(2) (sendfile0N and splice01 from LTP) when
testing on sub-page block size filesystems (tested both XFS and
ext4), these syscalls start to return EIO in the tests. e.g.

sendfile02    1  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 26, got: -1
sendfile02    2  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 24, got: -1
sendfile02    3  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 22, got: -1
sendfile02    4  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 20, got: -1

This is because that in sub-page block size cases, we don't need the
whole page to be uptodate, only the part we care about is uptodate
is OK (if fs has ->is_partially_uptodate defined). But
page_cache_pipe_buf_confirm() doesn't have the ability to check the
partially-uptodate case, it needs the whole page to be uptodate. So
it returns EIO in this case.

Prior to the change, generic_file_splice_read() doesn't allow
partially-uptodate page either, so it worked fine.

Fix it by skipping the partially-uptodate check if we're working on
a pipe in do_generic_file_read(), so we read the whole page from
disk as long as the page is not uptodate.

Signed-off-by: Eryu Guan <guaneryu@gmail.com>
---

I think the other way to fix it is to add the ability to check & allow
partially-uptodate page to page_cache_pipe_buf_confirm(), but that is much
harder to do and seems gain little.

 mm/filemap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 849f459..ae9ef9a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1734,6 +1734,8 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (inode->i_blkbits == PAGE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
+			if (unlikely(iter->type & ITER_PIPE))
+				goto page_not_up_to_date;
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
