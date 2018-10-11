Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 518746B028F
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:14:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l6-v6so7390713qtc.12
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:14:57 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t31-v6si6476780qtd.113.2018.10.10.21.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:14:56 -0700 (PDT)
Subject: [PATCH 19/25] vfs: implement opportunistic short dedupe
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:14:45 -0700
Message-ID: <153923128529.5546.6430455638279784448.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

For a given dedupe request, the bytes_deduped field in the control
structure tells userspace if we managed to deduplicate some, but not all
of, the requested regions starting from the file offsets supplied.
However, due to sloppy coding, the current dedupe code returns
FILE_DEDUPE_RANGE_DIFFERS if any part of the range is different.
Fix this so that we can actually support partial request completion.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c    |   48 ++++++++++++++++++++++++++++++++++++++----------
 include/linux/fs.h |    7 +++++--
 2 files changed, 43 insertions(+), 12 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index c88a443d9eb2..de055cb9c5ae 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1737,13 +1737,26 @@ static struct page *vfs_dedupe_get_page(struct inode *inode, loff_t offset)
 	return page;
 }
 
+static unsigned int vfs_dedupe_memcmp(const char *s1, const char *s2,
+				      unsigned int len)
+{
+	const char *orig_s1;
+
+	for (orig_s1 = s1; len > 0; s1++, s2++, len--)
+		if (*s1 != *s2)
+			break;
+
+	return s1 - orig_s1;
+}
+
 /*
  * Compare extents of two files to see if they are the same.
  * Caller must have locked both inodes to prevent write races.
  */
 static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 					 struct inode *dest, loff_t destoff,
-					 loff_t len, bool *is_same)
+					 loff_t *req_len,
+					 unsigned int remap_flags)
 {
 	loff_t src_poff;
 	loff_t dest_poff;
@@ -1751,8 +1764,11 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 	void *dest_addr;
 	struct page *src_page;
 	struct page *dest_page;
-	loff_t cmp_len;
+	loff_t len = *req_len;
+	loff_t same_len = 0;
 	bool same;
+	unsigned int cmp_len;
+	unsigned int cmp_same;
 	int error;
 
 	error = -EINVAL;
@@ -1762,7 +1778,7 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 		dest_poff = destoff & (PAGE_SIZE - 1);
 		cmp_len = min(PAGE_SIZE - src_poff,
 			      PAGE_SIZE - dest_poff);
-		cmp_len = min(cmp_len, len);
+		cmp_len = min_t(loff_t, cmp_len, len);
 		if (cmp_len <= 0)
 			goto out_error;
 
@@ -1784,7 +1800,10 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 		flush_dcache_page(src_page);
 		flush_dcache_page(dest_page);
 
-		if (memcmp(src_addr + src_poff, dest_addr + dest_poff, cmp_len))
+		cmp_same = vfs_dedupe_memcmp(src_addr + src_poff,
+					     dest_addr + dest_poff, cmp_len);
+		same_len += cmp_same;
+		if (cmp_same != cmp_len)
 			same = false;
 
 		kunmap_atomic(dest_addr);
@@ -1802,7 +1821,17 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 		len -= cmp_len;
 	}
 
-	*is_same = same;
+	/*
+	 * If less than the whole range matched, we have to back down to the
+	 * nearest block boundary.
+	 */
+	if (*req_len != same_len) {
+		if (!(remap_flags & RFR_SHORT_DEDUPE))
+			return -EBADE;
+
+		*req_len = ALIGN_DOWN(same_len, dest->i_sb->s_blocksize);
+	}
+
 	return 0;
 
 out_error:
@@ -1881,13 +1910,11 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	 * Check that the extents are the same.
 	 */
 	if (is_dedupe) {
-		bool		is_same = false;
-
 		ret = vfs_dedupe_file_range_compare(inode_in, pos_in,
-				inode_out, pos_out, *len, &is_same);
+				inode_out, pos_out, len, remap_flags);
 		if (ret)
 			return ret;
-		if (!is_same)
+		if (*len == 0)
 			return -EBADE;
 	}
 
@@ -2013,7 +2040,8 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(RFR_SAME_DATA));
+	WARN_ON_ONCE(remap_flags & ~(RFR_SAME_DATA | RFR_CAN_SHORTEN |
+				     RFR_SHORT_DEDUPE));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f0603ed007e9..18b6db85ab64 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1727,16 +1727,19 @@ struct block_device_operations;
  * RFR_SAME_DATA: only remap if contents identical (i.e. deduplicate)
  * RFR_TO_SRC_EOF: remap to the end of the source file
  * RFR_CAN_SHORTEN: caller can handle a shortened request
+ * RFR_SHORT_DEDUPE: deduplicate from byte 0 until the file data don't match
  */
 #define RFR_SAME_DATA		(1 << 0)
 #define RFR_TO_SRC_EOF		(1 << 1)
 #define RFR_CAN_SHORTEN		(1 << 2)
+#define RFR_SHORT_DEDUPE	(1 << 3)
 
 #define RFR_VALID_FLAGS		(RFR_SAME_DATA | RFR_TO_SRC_EOF | \
-				 RFR_CAN_SHORTEN)
+				 RFR_CAN_SHORTEN | RFR_SHORT_DEDUPE)
 
 /* Implemented by the VFS, so these are advisory. */
-#define RFR_VFS_FLAGS		(RFR_TO_SRC_EOF | RFR_CAN_SHORTEN)
+#define RFR_VFS_FLAGS		(RFR_TO_SRC_EOF | RFR_CAN_SHORTEN | \
+				 RFR_SHORT_DEDUPE)
 
 /*
  * Filesystem remapping implementations should call this helper on their
