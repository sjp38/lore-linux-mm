Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 307D06B060E
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:49:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so3081221pge.21
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:49:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o1-v6si7269616plk.577.2018.05.18.09.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:49:09 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/34] iomap: use __bio_add_page in iomap_dio_zero
Date: Fri, 18 May 2018 18:48:08 +0200
Message-Id: <20180518164830.1552-13-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

We don't need any merging logic, and this also replaces a BUG_ON with a
WARN_ON_ONCE inside __bio_add_page for the impossible overflow condition.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index a859e15d7bec..6427627a247f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -957,8 +957,7 @@ iomap_dio_zero(struct iomap_dio *dio, struct iomap *iomap, loff_t pos,
 	bio->bi_end_io = iomap_dio_bio_end_io;
 
 	get_page(page);
-	if (bio_add_page(bio, page, len, 0) != len)
-		BUG();
+	__bio_add_page(bio, page, len, 0);
 	bio_set_op_attrs(bio, REQ_OP_WRITE, REQ_SYNC | REQ_IDLE);
 
 	atomic_inc(&dio->ref);
-- 
2.17.0
