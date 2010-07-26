Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BA5006B02A4
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 04:25:46 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1124684pzk.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 01:25:45 -0700 (PDT)
Date: Mon, 26 Jul 2010 16:25:42 +0800
From: wzt.wzt@gmail.com
Subject: [PATCH] mm: Check NULL pointer Dereference in mm/filemap.c
Message-ID: <20100726082542.GA2646@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

mapping->a_ops->direct_IO() is not checked, if it's a NULL pointer, 
that will casue an oops. pagecache_write_begin/end is exported to
other functions, so they need to check null pointer before use them. 

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

---
 mm/filemap.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 20e5642..e81e264 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1300,6 +1300,9 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			retval = filemap_write_and_wait_range(mapping, pos,
 					pos + iov_length(iov, nr_segs) - 1);
 			if (!retval) {
+				if (unlikely(!mapping->a_ops ||
+					!mapping->a_ops->direct_IO))
+					goto out;
 				retval = mapping->a_ops->direct_IO(READ, iocb,
 							iov, pos, nr_segs);
 			}
@@ -1581,6 +1584,8 @@ retry_find:
 	return ret | VM_FAULT_LOCKED;
 
 no_cached_page:
+	if (unlikely(!mapping->a_ops || !mapping->a_ops->readpage))
+		return VM_FAULT_SIGBUS;
 	/*
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
@@ -2103,6 +2108,8 @@ int pagecache_write_begin(struct file *file, struct address_space *mapping,
 {
 	const struct address_space_operations *aops = mapping->a_ops;
 
+	if (unlikely(!aops || !aops->write_begin))
+		return -EINVAL;
 	return aops->write_begin(file, mapping, pos, len, flags,
 							pagep, fsdata);
 }
@@ -2114,6 +2121,9 @@ int pagecache_write_end(struct file *file, struct address_space *mapping,
 {
 	const struct address_space_operations *aops = mapping->a_ops;
 
+	if (unlikely(!aops || !aops->write_end))
+		return -EINVAL;
+
 	mark_page_accessed(page);
 	return aops->write_end(file, mapping, pos, len, copied, page, fsdata);
 }
@@ -2161,6 +2171,9 @@ generic_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		}
 	}
 
+	if (unlikely(!mapping->a_ops || !mapping->a_ops->direct_IO))
+		goto out;
+
 	written = mapping->a_ops->direct_IO(WRITE, iocb, iov, pos, *nr_segs);
 
 	/*
-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
