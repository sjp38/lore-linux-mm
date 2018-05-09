Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8E2B6B033A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:48:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id h32-v6so3304430pld.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:48:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 31-v6si17942260pli.404.2018.05.09.00.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:48:51 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/33] fs: remove the buffer_unwritten check in page_seek_hole_data
Date: Wed,  9 May 2018 09:48:01 +0200
Message-Id: <20180509074830.16196-5-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

We only call into this function through the iomap iterators, so we already
know the buffer is unwritten.  In addition to that we always require the
uptodate flag that is ORed with the result anyway.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 13f518c7d3be..a739f3f995d9 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -610,14 +610,9 @@ page_seek_hole_data(struct page *page, loff_t lastoff, int whence)
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
-- 
2.17.0
