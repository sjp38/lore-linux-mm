Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A500E6B060C
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:49:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p19-v6so5355930plo.14
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:49:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p12-v6si6380056pgr.660.2018.05.18.09.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:49:06 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to gfs2
Date: Fri, 18 May 2018 18:48:07 +0200
Message-Id: <20180518164830.1552-12-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Just define a range of fs specific flags and use that in gfs2 instead of
exposing this internal flag flobally.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/gfs2/bmap.c        | 8 +++++---
 include/linux/iomap.h | 9 +++++++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index cbeedd3cfb36..8efa6297e19c 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -683,6 +683,8 @@ static void gfs2_stuffed_iomap(struct inode *inode, struct iomap *iomap)
 	iomap->type = IOMAP_INLINE;
 }
 
+#define IOMAP_F_GFS2_BOUNDARY IOMAP_F_PRIVATE
+
 /**
  * gfs2_iomap_begin - Map blocks from an inode to disk blocks
  * @inode: The inode
@@ -774,7 +776,7 @@ int gfs2_iomap_begin(struct inode *inode, loff_t pos, loff_t length,
 	bh = mp.mp_bh[ip->i_height - 1];
 	len = gfs2_extent_length(bh->b_data, bh->b_size, ptr, lend - lblock, &eob);
 	if (eob)
-		iomap->flags |= IOMAP_F_BOUNDARY;
+		iomap->flags |= IOMAP_F_GFS2_BOUNDARY;
 	iomap->length = (u64)len << inode->i_blkbits;
 
 out_release:
@@ -846,12 +848,12 @@ int gfs2_block_map(struct inode *inode, sector_t lblock,
 
 	if (iomap.length > bh_map->b_size) {
 		iomap.length = bh_map->b_size;
-		iomap.flags &= ~IOMAP_F_BOUNDARY;
+		iomap.flags &= ~IOMAP_F_GFS2_BOUNDARY;
 	}
 	if (iomap.addr != IOMAP_NULL_ADDR)
 		map_bh(bh_map, inode->i_sb, iomap.addr >> inode->i_blkbits);
 	bh_map->b_size = iomap.length;
-	if (iomap.flags & IOMAP_F_BOUNDARY)
+	if (iomap.flags & IOMAP_F_GFS2_BOUNDARY)
 		set_buffer_boundary(bh_map);
 	if (iomap.flags & IOMAP_F_NEW)
 		set_buffer_new(bh_map);
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 13d19b4c29a9..819e0cd2a950 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -27,8 +27,7 @@ struct vm_fault;
  * written data and requires fdatasync to commit them to persistent storage.
  */
 #define IOMAP_F_NEW		0x01	/* blocks have been newly allocated */
-#define IOMAP_F_BOUNDARY	0x02	/* mapping ends at metadata boundary */
-#define IOMAP_F_DIRTY		0x04	/* uncommitted metadata */
+#define IOMAP_F_DIRTY		0x02	/* uncommitted metadata */
 
 /*
  * Flags that only need to be reported for IOMAP_REPORT requests:
@@ -36,6 +35,12 @@ struct vm_fault;
 #define IOMAP_F_MERGED		0x10	/* contains multiple blocks/extents */
 #define IOMAP_F_SHARED		0x20	/* block shared with another file */
 
+/*
+ * Flags from 0x1000 up are for file system specific usage:
+ */
+#define IOMAP_F_PRIVATE		0x1000
+
+
 /*
  * Magic value for addr:
  */
-- 
2.17.0
