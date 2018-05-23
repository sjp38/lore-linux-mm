Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF9B86B0010
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189-v6so13286320pfp.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t127-v6si14470644pgc.519.2018.05.23.07.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:15 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/34] fs: remove the buffer_unwritten check in page_seek_hole_data
Date: Wed, 23 May 2018 16:43:27 +0200
Message-Id: <20180523144357.18985-5-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

We only call into this function through the iomap iterators, so we already
know the buffer is unwritten.  In addition to that we always require the
uptodate flag that is ORed with the result anyway.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 4a01d2f4e8e9..bef5e91d40bf 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -611,14 +611,9 @@ page_seek_hole_data(struct page *page, loff_t lastoff, int whence)
 			continue;
 
 		/*
-		 * Unwritten extents that have data in the page cache covering
-		 * them can be identified by the BH_Unwritten state flag.
-		 * Pages with multiple buffers might have a mix of holes, data
-		 * and unwritten extents - any buffer with valid data in it
-		 * should have BH_Uptodate flag set on it.
+		 * Any buffer with valid data in it should have BH_Uptodate set.
 		 */
-
-		if ((buffer_unwritten(bh) || buffer_uptodate(bh)) == seek_data)
+		if (buffer_uptodate(bh) == seek_data)
 			return lastoff;
 
 		lastoff = offset;
@@ -630,8 +625,8 @@ page_seek_hole_data(struct page *page, loff_t lastoff, int whence)
  * Seek for SEEK_DATA / SEEK_HOLE in the page cache.
  *
  * Within unwritten extents, the page cache determines which parts are holes
- * and which are data: unwritten and uptodate buffer heads count as data;
- * everything else counts as a hole.
+ * and which are data: uptodate buffer heads count as data; everything else
+ * counts as a hole.
  *
  * Returns the resulting offset on successs, and -ENOENT otherwise.
  */
-- 
2.17.0
