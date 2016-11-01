Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 640FB6B02A6
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 03:43:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rt15so27729942pab.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 00:43:58 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g16si29199231pfj.150.2016.11.01.00.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 00:43:57 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id a136so7582212pfa.0
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 00:43:57 -0700 (PDT)
From: Eryu Guan <guaneryu@gmail.com>
Subject: [PATCH v2] mm/filemap: don't allow partially uptodate page for pipes
Date: Tue,  1 Nov 2016 15:43:07 +0800
Message-Id: <1477986187-12717-1-git-send-email-guaneryu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jack@suse.cz, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Eryu Guan <guaneryu@gmail.com>

Starting from 4.9-rc1 kernel, I started noticing some test failures
of sendfile(2) and splice(2) (sendfile0N and splice01 from LTP) when
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

This is a regression introduced by commit 82c156f85384 ("switch
generic_file_splice_read() to use of ->read_iter()"). Prior to the
change, generic_file_splice_read() doesn't allow partially-uptodate
page either, so it worked fine.

Fix it by skipping the partially-uptodate check if we're working on
a pipe in do_generic_file_read(), so we read the whole page from
disk as long as the page is not uptodate.

Signed-off-by: Eryu Guan <guaneryu@gmail.com>
---

I think the other way to fix it is to add the ability to check & allow
partially-uptodate page to page_cache_pipe_buf_confirm(), but that is much
harder to do and seems gain little.

v2:
- Update summary a little bit
- Update commit log
- Add comment to the code
- Add more people/list to cc

v1: http://marc.info/?l=linux-mm&m=147756897431777&w=2

 mm/filemap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 849f459..670264d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1734,6 +1734,9 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (inode->i_blkbits == PAGE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
+			/* pipes can't handle partially uptodate pages */
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
