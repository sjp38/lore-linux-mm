Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 921406B04A3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:29:50 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b130so20467658oii.4
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:29:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m96si5623143oik.412.2017.07.31.08.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 08:29:49 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] mm: remove optimizations based on i_size in mapping writeback waits
Date: Mon, 31 Jul 2017 11:29:46 -0400
Message-Id: <20170731152946.13976-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>

From: Jeff Layton <jlayton@redhat.com>

Marcelo added this i_size based optimization with a patch in 2004
(commit 765dad09b4ac in the linux-history tree):

    commit 765dad09b4ac101a32d87af2bb793c3060497d3c
    Author: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
    Date:   Tue Sep 7 17:51:17 2004 -0700

	small wait_on_page_writeback_range() optimization

	filemap_fdatawait() calls wait_on_page_writeback_range() with -1
	as "end" parameter.  This is not needed since we know the EOF
	from the inode.  Use that instead.

There may be races here, particularly with clustered or network
filesystems. Block devices always have an i_size of 0 as well, which
makes using this with a blockdev inode sort of pointless.

It also seems like a bit of a layering violation since we're operating
on an address_space here, not an inode.

Finally, it's also questionable whether this optimization really helps
on workloads that we care about. Should we be optimizing for writeback
vs. truncate races in a codepath where we expect to wait anyway? It
doesn't seem worth the risk.

Remove this optimization from the filemap_fdatawait codepaths. This
means that filemap_fdatawait becomes a trivial wrapper around
filemap_fdatawait_range.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/fs.h |  9 +++++++--
 mm/filemap.c       | 30 +-----------------------------
 2 files changed, 8 insertions(+), 31 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index af592ca3d509..656e04c6983e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2538,10 +2538,15 @@ extern int invalidate_inode_pages2_range(struct address_space *mapping,
 extern int write_inode_now(struct inode *, int);
 extern int filemap_fdatawrite(struct address_space *);
 extern int filemap_flush(struct address_space *);
-extern int filemap_fdatawait(struct address_space *);
-extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
 extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
 				   loff_t lend);
+extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
+
+static inline int filemap_fdatawait(struct address_space *mapping)
+{
+	return filemap_fdatawait_range(mapping, 0, LLONG_MAX);
+}
+
 extern bool filemap_range_has_page(struct address_space *, loff_t lstart,
 				  loff_t lend);
 extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
diff --git a/mm/filemap.c b/mm/filemap.c
index 394bb5e96f87..85dfe3bee324 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -512,39 +512,11 @@ EXPORT_SYMBOL(file_fdatawait_range);
  */
 int filemap_fdatawait_keep_errors(struct address_space *mapping)
 {
-	loff_t i_size = i_size_read(mapping->host);
-
-	if (i_size == 0)
-		return 0;
-
-	__filemap_fdatawait_range(mapping, 0, i_size - 1);
+	__filemap_fdatawait_range(mapping, 0, LLONG_MAX);
 	return filemap_check_and_keep_errors(mapping);
 }
 EXPORT_SYMBOL(filemap_fdatawait_keep_errors);
 
-/**
- * filemap_fdatawait - wait for all under-writeback pages to complete
- * @mapping: address space structure to wait for
- *
- * Walk the list of under-writeback pages of the given address space
- * and wait for all of them.  Check error status of the address space
- * and return it.
- *
- * Since the error status of the address space is cleared by this function,
- * callers are responsible for checking the return value and handling and/or
- * reporting the error.
- */
-int filemap_fdatawait(struct address_space *mapping)
-{
-	loff_t i_size = i_size_read(mapping->host);
-
-	if (i_size == 0)
-		return 0;
-
-	return filemap_fdatawait_range(mapping, 0, i_size - 1);
-}
-EXPORT_SYMBOL(filemap_fdatawait);
-
 static bool mapping_needs_writeback(struct address_space *mapping)
 {
 	return (!dax_mapping(mapping) && mapping->nrpages) ||
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
