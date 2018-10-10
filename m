Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5086B028B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:14:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i76-v6so3231966pfk.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:14:27 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v33-v6si21882685pga.450.2018.10.09.17.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:14:26 -0700 (PDT)
Subject: [PATCH 20/25] vfs: implement opportunistic short dedupe
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:14:17 -0700
Message-ID: <153913045787.32295.7018909865132108315.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

For a given dedupe request, the bytes_deduped field in the control
structure tells userspace if we managed to deduplicate some, but not all
of, the requested regions starting from the file offsets supplied.
However, due to sloppy coding, the current dedupe code returns
FILE_DEDUPE_RANGE_DIFFERS if any part of the range is different.
Fix this so that we can actually support partial request completion.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/read_write.c |   59 +++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 48 insertions(+), 11 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index 57627202bd50..8be3c3add030 100644
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
+		if (!(remap_flags & RFR_CAN_SHORTEN))
+			return -EINVAL;
+
+		*req_len = ALIGN_DOWN(same_len, dest->i_sb->s_blocksize);
+	}
+
 	return 0;
 
 out_error:
@@ -1879,13 +1908,11 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
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
 
@@ -1988,7 +2015,7 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(RFR_IDENTICAL_DATA));
+	WARN_ON_ONCE(remap_flags & ~(RFR_IDENTICAL_DATA | RFR_CAN_SHORTEN));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
@@ -2037,6 +2064,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 	int i;
 	int ret;
 	u16 count = same->dest_count;
+	unsigned int remap_flags = 0;
 	loff_t deduped;
 
 	if (!(file->f_mode & FMODE_READ))
@@ -2073,6 +2101,15 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 		same->info[i].status = FILE_DEDUPE_RANGE_SAME;
 	}
 
+	/*
+	 * We can't allow the dedupe implementation to shorten the request if
+	 * there are multiple dedupe candidates because each candidate might
+	 * shorten the request by a different amount due to EOF and allocation
+	 * block size mismatches.
+	 */
+	if (count == 1)
+		remap_flags |= RFR_CAN_SHORTEN;
+
 	for (i = 0, info = same->info; i < count; i++, info++) {
 		struct fd dst_fd = fdget(info->dest_fd);
 		struct file *dst_file = dst_fd.file;
@@ -2089,7 +2126,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
 						    info->dest_offset, len,
-						    0);
+						    remap_flags);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
