Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E394F6B0270
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:59:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so10994357pld.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:59:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z6-v6si16393072pln.250.2018.05.30.02.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 02:59:00 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/13] iomap: add an iomap-based bmap implementation
Date: Wed, 30 May 2018 11:58:10 +0200
Message-Id: <20180530095813.31245-11-hch@lst.de>
In-Reply-To: <20180530095813.31245-1-hch@lst.de>
References: <20180530095813.31245-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This adds a simple iomap-based implementation of the legacy ->bmap
interface.  Note that we can't easily add checks for rt or reflink
files, so these will have to remain in the callers.  This interface
just needs to die..

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/iomap.c            | 34 ++++++++++++++++++++++++++++++++++
 include/linux/iomap.h |  3 +++
 2 files changed, 37 insertions(+)

diff --git a/fs/iomap.c b/fs/iomap.c
index 74cdf8b5bbb0..b0bc928672af 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -1307,3 +1307,37 @@ int iomap_swapfile_activate(struct swap_info_struct *sis,
 }
 EXPORT_SYMBOL_GPL(iomap_swapfile_activate);
 #endif /* CONFIG_SWAP */
+
+static loff_t
+iomap_bmap_actor(struct inode *inode, loff_t pos, loff_t length,
+		void *data, struct iomap *iomap)
+{
+	sector_t *bno = data, addr;
+
+	if (iomap->type == IOMAP_MAPPED) {
+		addr = (pos - iomap->offset + iomap->addr) >> inode->i_blkbits;
+		if (addr > INT_MAX)
+			WARN(1, "would truncate bmap result\n");
+		else
+			*bno = addr;
+	}
+	return 0;
+}
+
+/* legacy ->bmap interface.  0 is the error return (!) */
+sector_t
+iomap_bmap(struct address_space *mapping, sector_t bno,
+		const struct iomap_ops *ops)
+{
+	struct inode *inode = mapping->host;
+	loff_t pos = bno >> inode->i_blkbits;
+	unsigned blocksize = i_blocksize(inode);
+
+	if (filemap_write_and_wait(mapping))
+		return 0;
+
+	bno = 0;
+	iomap_apply(inode, pos, blocksize, 0, ops, &bno, iomap_bmap_actor);
+	return bno;
+}
+EXPORT_SYMBOL_GPL(iomap_bmap);
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 819e0cd2a950..a044a824da85 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -4,6 +4,7 @@
 
 #include <linux/types.h>
 
+struct address_space;
 struct fiemap_extent_info;
 struct inode;
 struct iov_iter;
@@ -100,6 +101,8 @@ loff_t iomap_seek_hole(struct inode *inode, loff_t offset,
 		const struct iomap_ops *ops);
 loff_t iomap_seek_data(struct inode *inode, loff_t offset,
 		const struct iomap_ops *ops);
+sector_t iomap_bmap(struct address_space *mapping, sector_t bno,
+		const struct iomap_ops *ops);
 
 /*
  * Flags for direct I/O ->end_io:
-- 
2.17.0
