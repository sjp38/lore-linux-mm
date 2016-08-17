Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCF316B0263
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:18:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so184523292pab.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 22:18:38 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id xm1si35809253pab.3.2016.08.16.22.18.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 22:18:38 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0OC1003H7G1CZFC0@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 17 Aug 2016 14:17:36 +0900 (KST)
From: Daeho Jeong <daeho.jeong@samsung.com>
Subject: [RFC 3/3] ext4: tag asynchronous writeback io
Date: Wed, 17 Aug 2016 14:20:45 +0900
Message-id: <1471411245-5186-4-git-send-email-daeho.jeong@samsung.com>
In-reply-to: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
References: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, tytso@mit.edu, adilger.kernel@dilger.ca, jack@suse.com, linux-block@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Daeho Jeong <daeho.jeong@samsung.com>

Set the page with PG_asyncwb and PG_plugged, and set the bio with
BIO_ASYNC_WB when submitting asynchronous writeback I/O in order to
mark which pages are flushed as asynchronous writeback I/O and which
one stays in the plug list.

Signed-off-by: Daeho Jeong <daeho.jeong@samsung.com>
---
 fs/ext4/page-io.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 2a01df9..5912e59 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -370,6 +370,10 @@ static int io_submit_init_bio(struct ext4_io_submit *io,
 	bio->bi_private = ext4_get_io_end(io->io_end);
 	io->io_bio = bio;
 	io->io_next_block = bh->b_blocknr;
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	if (io->io_wbc->sync_mode == WB_SYNC_NONE)
+		bio->bi_flags |= (1 << BIO_ASYNC_WB);
+#endif
 	return 0;
 }
 
@@ -416,6 +420,13 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageWriteback(page));
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	if (wbc->sync_mode == WB_SYNC_NONE) {
+		SetPagePlugged(page);
+		SetPageAsyncWB(page);
+	}
+#endif
+
 	if (keep_towrite)
 		set_page_writeback_keepwrite(page);
 	else
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
