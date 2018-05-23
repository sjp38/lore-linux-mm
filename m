Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00E366B026F
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c187-v6so13275810pfa.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d12-v6si19415599plo.551.2018.05.23.07.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:38 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/34] iomap: use __bio_add_page in iomap_dio_zero
Date: Wed, 23 May 2018 16:43:35 +0200
Message-Id: <20180523144357.18985-13-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

We don't need any merging logic, and this also replaces a BUG_ON with a
WARN_ON_ONCE inside __bio_add_page for the impossible overflow condition.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index f52209a2c270..8e28f25f086f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -949,8 +949,7 @@ iomap_dio_zero(struct iomap_dio *dio, struct iomap *iomap, loff_t pos,
 	bio->bi_end_io = iomap_dio_bio_end_io;
 
 	get_page(page);
-	if (bio_add_page(bio, page, len, 0) != len)
-		BUG();
+	__bio_add_page(bio, page, len, 0);
 	bio_set_op_attrs(bio, REQ_OP_WRITE, REQ_SYNC | REQ_IDLE);
 
 	atomic_inc(&dio->ref);
-- 
2.17.0
