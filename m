Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB366B026E
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:58:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v133-v6so4960228pgb.10
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:58:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w1-v6si27219602pgp.10.2018.05.30.02.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 02:58:56 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/13] iomap: add a iomap_sector helper
Date: Wed, 30 May 2018 11:58:09 +0200
Message-Id: <20180530095813.31245-10-hch@lst.de>
In-Reply-To: <20180530095813.31245-1-hch@lst.de>
References: <20180530095813.31245-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Factor the repeated calculation of the on-disk sector for a given logical
block into a littler helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/iomap.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 85901b449146..74cdf8b5bbb0 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -96,6 +96,12 @@ iomap_apply(struct inode *inode, loff_t pos, loff_t length, unsigned flags,
 	return written ? written : ret;
 }
 
+static sector_t
+iomap_sector(struct iomap *iomap, loff_t pos)
+{
+	return (iomap->addr + pos - iomap->offset) >> SECTOR_SHIFT;
+}
+
 static void
 iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
 {
@@ -353,11 +359,8 @@ static int iomap_zero(struct inode *inode, loff_t pos, unsigned offset,
 static int iomap_dax_zero(loff_t pos, unsigned offset, unsigned bytes,
 		struct iomap *iomap)
 {
-	sector_t sector = (iomap->addr +
-			   (pos & PAGE_MASK) - iomap->offset) >> 9;
-
-	return __dax_zero_page_range(iomap->bdev, iomap->dax_dev, sector,
-			offset, bytes);
+	return __dax_zero_page_range(iomap->bdev, iomap->dax_dev,
+			iomap_sector(iomap, pos & PAGE_MASK), offset, bytes);
 }
 
 static loff_t
@@ -839,8 +842,7 @@ iomap_dio_zero(struct iomap_dio *dio, struct iomap *iomap, loff_t pos,
 
 	bio = bio_alloc(GFP_KERNEL, 1);
 	bio_set_dev(bio, iomap->bdev);
-	bio->bi_iter.bi_sector =
-		(iomap->addr + pos - iomap->offset) >> 9;
+	bio->bi_iter.bi_sector = iomap_sector(iomap, pos);
 	bio->bi_private = dio;
 	bio->bi_end_io = iomap_dio_bio_end_io;
 
@@ -934,8 +936,7 @@ iomap_dio_actor(struct inode *inode, loff_t pos, loff_t length,
 
 		bio = bio_alloc(GFP_KERNEL, nr_pages);
 		bio_set_dev(bio, iomap->bdev);
-		bio->bi_iter.bi_sector =
-			(iomap->addr + pos - iomap->offset) >> 9;
+		bio->bi_iter.bi_sector = iomap_sector(iomap, pos);
 		bio->bi_write_hint = dio->iocb->ki_hint;
 		bio->bi_private = dio;
 		bio->bi_end_io = iomap_dio_bio_end_io;
-- 
2.17.0
