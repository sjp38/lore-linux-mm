Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OBAUKV014704
	for <linux-mm@kvack.org>; Thu, 24 May 2007 07:10:30 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCCb5W500782
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCCaPl026057
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:36 -0400
Date: Thu, 24 May 2007 08:12:36 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121236.13533.38890.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 012/012] Add tail hooks into file_map.c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add tail hooks into file_map.c

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/filemap.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff -Nurp linux011/mm/filemap.c linux012/mm/filemap.c
--- linux011/mm/filemap.c	2007-05-21 15:15:48.000000000 -0500
+++ linux012/mm/filemap.c	2007-05-23 22:53:12.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/file_tail.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -116,6 +117,13 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
+	/*
+	 * mapping->tail is kept in sync with the tail page's existence
+	 * in the radix tree, so we need to clear it here while holding
+	 * the tree_lock
+	 */
+	page_cache_free_tail_buffer(page);
+
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -890,6 +898,13 @@ void do_generic_mapping_read(struct addr
 		goto out;
 
 	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+
+	/*
+	 * If the last page in the request is a candidate for a tail page,
+	 * allocate it before we call page_cache_readahead()
+	 */
+	preallocate_page_cache_tail(mapping, end_index);
+
 	for (;;) {
 		struct page *page;
 		unsigned long nr, ret;
@@ -2146,6 +2161,17 @@ generic_file_buffered_write(struct kiocb
 			goto zero_length_segment;
 		}
 
+		if (PageFileTail(page) &&
+		    ((pos + bytes) > i_size_read(inode))) {
+			/* Can't unpack the tail while holding the tail page */
+			unlock_page(page);
+			page_cache_release(page);
+			status = (long)unpack_file_tail(mapping);
+			if (status)
+				break;
+			continue;
+		}
+
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
 		if (unlikely(status)) {
 			loff_t isize = i_size_read(inode);

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
