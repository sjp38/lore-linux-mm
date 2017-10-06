Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABDF96B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 22:45:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b124so18106398qke.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 19:45:42 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp1.pobox.com. [64.147.108.70])
        by mx.google.com with ESMTPS id n206si430943qkn.199.2017.10.05.19.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 19:45:39 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v5 3/5] cramfs: implement uncompressed and arbitrary data block positioning
Date: Thu,  5 Oct 2017 22:45:29 -0400
Message-Id: <20171006024531.8885-4-nicolas.pitre@linaro.org>
In-Reply-To: <20171006024531.8885-1-nicolas.pitre@linaro.org>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

Two new capabilities are introduced here:

- The ability to store some blocks uncompressed.

- The ability to locate blocks anywhere.

Those capabilities can be used independently, but the combination
opens the possibility for execute-in-place (XIP) of program text segments
that must remain uncompressed, and in the MMU case, must have a specific
alignment.  It is even possible to still have the writable data segments
from the same file compressed as they have to be copied into RAM anyway.

This is achieved by giving special meanings to some unused block pointer
bits while remaining compatible with legacy cramfs images.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Tested-by: Chris Brandt <chris.brandt@renesas.com>
---
 fs/cramfs/README               | 31 ++++++++++++++-
 fs/cramfs/inode.c              | 90 +++++++++++++++++++++++++++++++++---------
 include/uapi/linux/cramfs_fs.h | 26 +++++++++++-
 3 files changed, 126 insertions(+), 21 deletions(-)

diff --git a/fs/cramfs/README b/fs/cramfs/README
index 9d4e7ea311..d71b27e0ff 100644
--- a/fs/cramfs/README
+++ b/fs/cramfs/README
@@ -49,17 +49,46 @@ same as the start of the (i+1)'th <block> if there is one).  The first
 <block> immediately follows the last <block_pointer> for the file.
 <block_pointer>s are each 32 bits long.
 
+When the CRAMFS_FLAG_EXT_BLOCK_POINTERS capability bit is set, each
+<block_pointer>'s top bits may contain special flags as follows:
+
+CRAMFS_BLK_FLAG_UNCOMPRESSED (bit 31):
+	The block data is not compressed and should be copied verbatim.
+
+CRAMFS_BLK_FLAG_DIRECT_PTR (bit 30):
+	The <block_pointer> stores the actual block start offset and not
+	its end, shifted right by 2 bits. The block must therefore be
+	aligned to a 4-byte boundary. The block size is either blksize
+	if CRAMFS_BLK_FLAG_UNCOMPRESSED is also specified, otherwise
+	the compressed data length is included in the first 2 bytes of
+	the block data. This is used to allow discontiguous data layout
+	and specific data block alignments e.g. for XIP applications.
+
+
 The order of <file_data>'s is a depth-first descent of the directory
 tree, i.e. the same order as `find -size +0 \( -type f -o -type l \)
 -print'.
 
 
 <block>: The i'th <block> is the output of zlib's compress function
-applied to the i'th blksize-sized chunk of the input data.
+applied to the i'th blksize-sized chunk of the input data if the
+corresponding CRAMFS_BLK_FLAG_UNCOMPRESSED <block_ptr> bit is not set,
+otherwise it is the input data directly.
 (For the last <block> of the file, the input may of course be smaller.)
 Each <block> may be a different size.  (See <block_pointer> above.)
+
 <block>s are merely byte-aligned, not generally u32-aligned.
 
+When CRAMFS_BLK_FLAG_DIRECT_PTR is specified then the corresponding
+<block> may be located anywhere and not necessarily contiguous with
+the previous/next blocks. In that case it is minimally u32-aligned.
+If CRAMFS_BLK_FLAG_UNCOMPRESSED is also specified then the size is always
+blksize except for the last block which is limited by the file length.
+If CRAMFS_BLK_FLAG_DIRECT_PTR is set and CRAMFS_BLK_FLAG_UNCOMPRESSED
+is not set then the first 2 bytes of the block contains the size of the
+remaining block data as this cannot be determined from the placement of
+logically adjacent blocks.
+
 
 Holes
 -----
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 89bce89c05..6aa1d94ed8 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -640,34 +640,86 @@ static int cramfs_readpage(struct file *file, struct page *page)
 
 	if (page->index < maxblock) {
 		struct super_block *sb = inode->i_sb;
-		u32 blkptr_offset = OFFSET(inode) + page->index*4;
-		u32 start_offset, compr_len;
+		u32 blkptr_offset = OFFSET(inode) + page->index * 4;
+		u32 block_ptr, block_start, block_len;
+		bool uncompressed, direct;
 
-		start_offset = OFFSET(inode) + maxblock*4;
 		mutex_lock(&read_mutex);
-		if (page->index)
-			start_offset = *(u32 *) cramfs_read(sb, blkptr_offset-4,
-				4);
-		compr_len = (*(u32 *) cramfs_read(sb, blkptr_offset, 4) -
-			start_offset);
-		mutex_unlock(&read_mutex);
+		block_ptr = *(u32 *) cramfs_read(sb, blkptr_offset, 4);
+		uncompressed = (block_ptr & CRAMFS_BLK_FLAG_UNCOMPRESSED);
+		direct = (block_ptr & CRAMFS_BLK_FLAG_DIRECT_PTR);
+		block_ptr &= ~CRAMFS_BLK_FLAGS;
+
+		if (direct) {
+			/*
+			 * The block pointer is an absolute start pointer,
+			 * shifted by 2 bits. The size is included in the
+			 * first 2 bytes of the data block when compressed,
+			 * or PAGE_SIZE otherwise.
+			 */
+			block_start = block_ptr << CRAMFS_BLK_DIRECT_PTR_SHIFT;
+			if (uncompressed) {
+				block_len = PAGE_SIZE;
+				/* if last block: cap to file length */
+				if (page->index == maxblock - 1)
+					block_len =
+						offset_in_page(inode->i_size);
+			} else {
+				block_len = *(u16 *)
+					cramfs_read(sb, block_start, 2);
+				block_start += 2;
+			}
+		} else {
+			/*
+			 * The block pointer indicates one past the end of
+			 * the current block (start of next block). If this
+			 * is the first block then it starts where the block
+			 * pointer table ends, otherwise its start comes
+			 * from the previous block's pointer.
+			 */
+			block_start = OFFSET(inode) + maxblock * 4;
+			if (page->index)
+				block_start = *(u32 *)
+					cramfs_read(sb, blkptr_offset - 4, 4);
+			/* Beware... previous ptr might be a direct ptr */
+			if (unlikely(block_start & CRAMFS_BLK_FLAG_DIRECT_PTR)) {
+				/* See comments on earlier code. */
+				u32 prev_start = block_start;
+			       block_start = prev_start & ~CRAMFS_BLK_FLAGS;
+			       block_start <<= CRAMFS_BLK_DIRECT_PTR_SHIFT;
+				if (prev_start & CRAMFS_BLK_FLAG_UNCOMPRESSED) {
+					block_start += PAGE_SIZE;
+				} else {
+					block_len = *(u16 *)
+						cramfs_read(sb, block_start, 2);
+					block_start += 2 + block_len;
+				}
+			}
+			block_start &= ~CRAMFS_BLK_FLAGS;
+			block_len = block_ptr - block_start;
+		}
 
-		if (compr_len == 0)
+		if (block_len == 0)
 			; /* hole */
-		else if (unlikely(compr_len > (PAGE_SIZE << 1))) {
-			pr_err("bad compressed blocksize %u\n",
-				compr_len);
+		else if (unlikely(block_len > 2*PAGE_SIZE ||
+				  (uncompressed && block_len > PAGE_SIZE))) {
+			mutex_unlock(&read_mutex);
+			pr_err("bad data blocksize %u\n", block_len);
 			goto err;
+		} else if (uncompressed) {
+			memcpy(pgdata,
+			       cramfs_read(sb, block_start, block_len),
+			       block_len);
+			bytes_filled = block_len;
 		} else {
-			mutex_lock(&read_mutex);
 			bytes_filled = cramfs_uncompress_block(pgdata,
 				 PAGE_SIZE,
-				 cramfs_read(sb, start_offset, compr_len),
-				 compr_len);
-			mutex_unlock(&read_mutex);
-			if (unlikely(bytes_filled < 0))
-				goto err;
+				 cramfs_read(sb, block_start, block_len),
+				 block_len);
 		}
+		mutex_unlock(&read_mutex);
+		if (unlikely(bytes_filled < 0))
+			goto err;
 	}
 
 	memset(pgdata + bytes_filled, 0, PAGE_SIZE - bytes_filled);
diff --git a/include/uapi/linux/cramfs_fs.h b/include/uapi/linux/cramfs_fs.h
index e4611a9b92..ce2c885133 100644
--- a/include/uapi/linux/cramfs_fs.h
+++ b/include/uapi/linux/cramfs_fs.h
@@ -73,6 +73,7 @@ struct cramfs_super {
 #define CRAMFS_FLAG_HOLES		0x00000100	/* support for holes */
 #define CRAMFS_FLAG_WRONG_SIGNATURE	0x00000200	/* reserved */
 #define CRAMFS_FLAG_SHIFTED_ROOT_OFFSET	0x00000400	/* shifted root fs */
+#define CRAMFS_FLAG_EXT_BLOCK_POINTERS	0x00000800	/* block pointer extensions */
 
 /*
  * Valid values in super.flags.  Currently we refuse to mount
@@ -82,7 +83,30 @@ struct cramfs_super {
 #define CRAMFS_SUPPORTED_FLAGS	( 0x000000ff \
 				| CRAMFS_FLAG_HOLES \
 				| CRAMFS_FLAG_WRONG_SIGNATURE \
-				| CRAMFS_FLAG_SHIFTED_ROOT_OFFSET )
+				| CRAMFS_FLAG_SHIFTED_ROOT_OFFSET \
+				| CRAMFS_FLAG_EXT_BLOCK_POINTERS )
 
+/*
+ * Block pointer flags
+ *
+ * The maximum block offset that needs to be represented is roughly:
+ *
+ *   (1 << CRAMFS_OFFSET_WIDTH) * 4 +
+ *   (1 << CRAMFS_SIZE_WIDTH) / PAGE_SIZE * (4 + PAGE_SIZE)
+ *   = 0x11004000
+ *
+ * That leaves room for 3 flag bits in the block pointer table.
+ */
+#define CRAMFS_BLK_FLAG_UNCOMPRESSED	(1 << 31)
+#define CRAMFS_BLK_FLAG_DIRECT_PTR	(1 << 30)
+
+#define CRAMFS_BLK_FLAGS	( CRAMFS_BLK_FLAG_UNCOMPRESSED \
+				| CRAMFS_BLK_FLAG_DIRECT_PTR )
+
+/*
+ * Direct blocks are at least 4-byte aligned.
+ * Pointers to direct blocks are shifted down by 2 bits.
+ */
+#define CRAMFS_BLK_DIRECT_PTR_SHIFT	2
 
 #endif /* _UAPI__CRAMFS_H */
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
