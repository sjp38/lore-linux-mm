Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF3D6B04AA
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 12:49:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s21so23459954oie.5
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:49:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s67si11079712oig.379.2017.07.31.09.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 09:49:29 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3] mm: add file_fdatawait_range and file_write_and_wait
Date: Mon, 31 Jul 2017 12:49:25 -0400
Message-Id: <20170731164925.2158-1-jlayton@kernel.org>
In-Reply-To: <20170726175538.13885-3-jlayton@kernel.org>
References: <20170726175538.13885-3-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

Necessary now for gfs2_fsync and sync_file_range, but there will
eventually be other callers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/fs.h | 11 ++++++++++-
 mm/filemap.c       | 23 +++++++++++++++++++++++
 2 files changed, 33 insertions(+), 1 deletion(-)

v3: make file_write_and_wait a wrapper around file_write_and_wait_range

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 526b6a9f30d4..909210bd6366 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2549,6 +2549,8 @@ static inline int filemap_fdatawait(struct address_space *mapping)
 
 extern bool filemap_range_has_page(struct address_space *, loff_t lstart,
 				  loff_t lend);
+extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
+						loff_t lend);
 extern int filemap_write_and_wait(struct address_space *mapping);
 extern int filemap_write_and_wait_range(struct address_space *mapping,
 				        loff_t lstart, loff_t lend);
@@ -2557,12 +2559,19 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
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
 
+static inline int file_write_and_wait(struct file *file)
+{
+	return file_write_and_wait_range(file, 0, LLONG_MAX);
+}
+
 /**
  * filemap_set_wb_err - set a writeback error on an address_space
  * @mapping: mapping in which to set writeback error
diff --git a/mm/filemap.c b/mm/filemap.c
index 953804b29a75..85dfe3bee324 100644
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
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
