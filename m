Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE3E6B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:55:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v68so13992964oia.14
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:55:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p131si653186oib.339.2017.07.26.10.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:55:45 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 2/4] mm: add file_fdatawait_range and file_write_and_wait
Date: Wed, 26 Jul 2017 13:55:36 -0400
Message-Id: <20170726175538.13885-3-jlayton@kernel.org>
In-Reply-To: <20170726175538.13885-1-jlayton@kernel.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

Some filesystem fsync routines will need these.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/fs.h |  7 ++++++-
 mm/filemap.c       | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 21e7df1ad613..bc57a79294f0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2544,6 +2544,8 @@ extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
 				   loff_t lend);
 extern bool filemap_range_has_page(struct address_space *, loff_t lstart,
 				  loff_t lend);
+extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
+						loff_t lend);
 extern int filemap_write_and_wait(struct address_space *mapping);
 extern int filemap_write_and_wait_range(struct address_space *mapping,
 				        loff_t lstart, loff_t lend);
@@ -2552,11 +2554,14 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
 extern int filemap_check_errors(struct address_space *mapping);
-
 extern void __filemap_set_wb_err(struct address_space *mapping, int err);
+
+extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
+						loff_t lend);
 extern int __must_check file_check_and_advance_wb_err(struct file *file);
 extern int __must_check file_write_and_wait_range(struct file *file,
 						loff_t start, loff_t end);
+extern int __must_check file_write_and_wait(struct file *file);
 
 /**
  * filemap_set_wb_err - set a writeback error on an address_space
diff --git a/mm/filemap.c b/mm/filemap.c
index 72e46e6f0d9a..b904a8dfa43d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -476,6 +476,29 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 EXPORT_SYMBOL(filemap_fdatawait_range);
 
 /**
+ * file_fdatawait_range - wait for writeback to complete
+ * @file:		file pointing to address space structure to wait for
+ * @start_byte:		offset in bytes where the range starts
+ * @end_byte:		offset in bytes where the range ends (inclusive)
+ *
+ * Walk the list of under-writeback pages of the address space that file
+ * refers to, in the given range and wait for all of them.  Check error
+ * status of the address space vs. the file->f_wb_err cursor and return it.
+ *
+ * Since the error status of the file is advanced by this function,
+ * callers are responsible for checking the return value and handling and/or
+ * reporting the error.
+ */
+int file_fdatawait_range(struct file *file, loff_t start_byte, loff_t end_byte)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	__filemap_fdatawait_range(mapping, start_byte, end_byte);
+	return file_check_and_advance_wb_err(file);
+}
+EXPORT_SYMBOL(file_fdatawait_range);
+
+/**
  * filemap_fdatawait_keep_errors - wait for writeback without clearing errors
  * @mapping: address space structure to wait for
  *
@@ -675,6 +698,39 @@ int file_write_and_wait_range(struct file *file, loff_t lstart, loff_t lend)
 EXPORT_SYMBOL(file_write_and_wait_range);
 
 /**
+ * file_write_and_wait - write out whole file and wait on it and return any
+ * 			 writeback errors since we last checked
+ * @file: file to write back and wait on
+ *
+ * Write back the whole file and wait on its mapping. Afterward, check for
+ * errors that may have occurred since our file->f_wb_err cursor was last
+ * updated.
+ */
+int file_write_and_wait(struct file *file)
+{
+	int err = 0, err2;
+	struct address_space *mapping = file->f_mapping;
+
+	if ((!dax_mapping(mapping) && mapping->nrpages) ||
+	    (dax_mapping(mapping) && mapping->nrexceptional)) {
+		err = filemap_fdatawrite(mapping);
+		/* See comment of filemap_write_and_wait() */
+		if (err != -EIO) {
+			loff_t i_size = i_size_read(mapping->host);
+
+			if (i_size != 0)
+				__filemap_fdatawait_range(mapping, 0,
+							  i_size - 1);
+		}
+	}
+	err2 = file_check_and_advance_wb_err(file);
+	if (!err)
+		err = err2;
+	return err;
+}
+EXPORT_SYMBOL(file_write_and_wait);
+
+/**
  * replace_page_cache_page - replace a pagecache page with a new one
  * @old:	page to be replaced
  * @new:	page to replace with
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
