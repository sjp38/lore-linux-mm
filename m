Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1BF6B027F
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:14:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i76-v6so6746683pfk.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:14:01 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d35-v6si28036824pla.116.2018.10.10.21.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:14:00 -0700 (PDT)
Subject: [PATCH 12/25] vfs: pass remap flags to generic_remap_checks
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:13:49 -0700
Message-ID: <153923122899.5546.15614724337094695251.stgit@magnolia>
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

Pass the same remap flags to generic_remap_checks for consistency.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c    |    2 +-
 include/linux/fs.h |    2 +-
 mm/filemap.c       |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index bd5f8d724b13..5de5d102ef4d 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1755,7 +1755,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 
 	/* Check that we don't violate system file offset limits. */
 	ret = generic_remap_checks(file_in, pos_in, file_out, pos_out, len,
-			is_dedupe);
+			remap_flags);
 	if (ret)
 		return ret;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b67f108932a5..b59637b2f484 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2990,7 +2990,7 @@ extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
 extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
 extern int generic_remap_checks(struct file *file_in, loff_t pos_in,
 				struct file *file_out, loff_t pos_out,
-				uint64_t *count, bool is_dedupe);
+				uint64_t *count, unsigned int remap_flags);
 extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_file_write_iter(struct kiocb *, struct iov_iter *);
diff --git a/mm/filemap.c b/mm/filemap.c
index 08ad210fee49..c34a89a35d5a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3001,7 +3001,7 @@ EXPORT_SYMBOL(generic_write_checks);
  */
 int generic_remap_checks(struct file *file_in, loff_t pos_in,
 			 struct file *file_out, loff_t pos_out,
-			 uint64_t *req_count, bool is_dedupe)
+			 uint64_t *req_count, unsigned int remap_flags)
 {
 	struct inode *inode_in = file_in->f_mapping->host;
 	struct inode *inode_out = file_out->f_mapping->host;
@@ -3023,7 +3023,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	size_out = i_size_read(inode_out);
 
 	/* Dedupe requires both ranges to be within EOF. */
-	if (is_dedupe &&
+	if ((remap_flags & RFR_SAME_DATA) &&
 	    (pos_in >= size_in || pos_in + count > size_in ||
 	     pos_out >= size_out || pos_out + count > size_out))
 		return -EINVAL;
