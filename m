Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF256B0608
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:49:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so5062890pfh.3
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:49:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q12-v6si3060225pgs.293.2018.05.18.09.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:48:59 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/34] iomap: inline data should be an iomap type, not a flag
Date: Fri, 18 May 2018 18:48:05 +0200
Message-Id: <20180518164830.1552-10-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Inline data is fundamentally different from our normal mapped case in that
it doesn't even have a block address.  So instead of having a flag for it
it should be an entirely separate iomap range type.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ext4/inline.c      |  4 ++--
 fs/gfs2/bmap.c        |  3 +--
 fs/iomap.c            | 21 ++++++++++++---------
 include/linux/iomap.h |  2 +-
 4 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index 70cf4c7b268a..e1f00891ef95 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -1835,8 +1835,8 @@ int ext4_inline_data_iomap(struct inode *inode, struct iomap *iomap)
 	iomap->offset = 0;
 	iomap->length = min_t(loff_t, ext4_get_inline_size(inode),
 			      i_size_read(inode));
-	iomap->type = 0;
-	iomap->flags = IOMAP_F_DATA_INLINE;
+	iomap->type = IOMAP_INLINE;
+	iomap->flags = 0;
 
 out:
 	up_read(&EXT4_I(inode)->xattr_sem);
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 278ed0869c3c..cbeedd3cfb36 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -680,8 +680,7 @@ static void gfs2_stuffed_iomap(struct inode *inode, struct iomap *iomap)
 		      sizeof(struct gfs2_dinode);
 	iomap->offset = 0;
 	iomap->length = i_size_read(inode);
-	iomap->type = IOMAP_MAPPED;
-	iomap->flags = IOMAP_F_DATA_INLINE;
+	iomap->type = IOMAP_INLINE;
 }
 
 /**
diff --git a/fs/iomap.c b/fs/iomap.c
index 0fecd5789d7b..a859e15d7bec 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -503,10 +503,13 @@ static int iomap_to_fiemap(struct fiemap_extent_info *fi,
 	case IOMAP_DELALLOC:
 		flags |= FIEMAP_EXTENT_DELALLOC | FIEMAP_EXTENT_UNKNOWN;
 		break;
+	case IOMAP_MAPPED:
+		break;
 	case IOMAP_UNWRITTEN:
 		flags |= FIEMAP_EXTENT_UNWRITTEN;
 		break;
-	case IOMAP_MAPPED:
+	case IOMAP_INLINE:
+		flags |= FIEMAP_EXTENT_DATA_INLINE;
 		break;
 	}
 
@@ -514,8 +517,6 @@ static int iomap_to_fiemap(struct fiemap_extent_info *fi,
 		flags |= FIEMAP_EXTENT_MERGED;
 	if (iomap->flags & IOMAP_F_SHARED)
 		flags |= FIEMAP_EXTENT_SHARED;
-	if (iomap->flags & IOMAP_F_DATA_INLINE)
-		flags |= FIEMAP_EXTENT_DATA_INLINE;
 
 	return fiemap_fill_next_extent(fi, iomap->offset,
 			iomap->addr != IOMAP_NULL_ADDR ? iomap->addr : 0,
@@ -1326,14 +1327,16 @@ static loff_t iomap_swapfile_activate_actor(struct inode *inode, loff_t pos,
 	struct iomap_swapfile_info *isi = data;
 	int error;
 
-	/* No inline data. */
-	if (iomap->flags & IOMAP_F_DATA_INLINE) {
+	switch (iomap->type) {
+	case IOMAP_MAPPED:
+	case IOMAP_UNWRITTEN:
+		/* Only real or unwritten extents. */
+		break;
+	case IOMAP_INLINE:
+		/* No inline data. */
 		pr_err("swapon: file is inline\n");
 		return -EINVAL;
-	}
-
-	/* Only real or unwritten extents. */
-	if (iomap->type != IOMAP_MAPPED && iomap->type != IOMAP_UNWRITTEN) {
+	default:
 		pr_err("swapon: file has unallocated extents\n");
 		return -EINVAL;
 	}
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 4bd87294219a..8f7095fc514e 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -18,6 +18,7 @@ struct vm_fault;
 #define IOMAP_DELALLOC	0x02	/* delayed allocation blocks */
 #define IOMAP_MAPPED	0x03	/* blocks allocated at @addr */
 #define IOMAP_UNWRITTEN	0x04	/* blocks allocated at @addr in unwritten state */
+#define IOMAP_INLINE	0x05	/* data inline in the inode */
 
 /*
  * Flags for all iomap mappings:
@@ -34,7 +35,6 @@ struct vm_fault;
  */
 #define IOMAP_F_MERGED		0x10	/* contains multiple blocks/extents */
 #define IOMAP_F_SHARED		0x20	/* block shared with another file */
-#define IOMAP_F_DATA_INLINE	0x40	/* data inline in the inode */
 
 /*
  * Magic value for addr:
-- 
2.17.0
