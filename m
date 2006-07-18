Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I49HTA016584
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:09:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I49G1B138096
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:09:16 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I49Gth011114
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:09:16 -0600
Date: Mon, 17 Jul 2006 22:09:13 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040911.11926.36638.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 008/008] Handle file tails in mm/filemap.c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Handle file tails in mm/filemap.c

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux007/mm/filemap.c linux008/mm/filemap.c
--- linux007/mm/filemap.c	2006-06-17 20:49:35.000000000 -0500
+++ linux008/mm/filemap.c	2006-07-17 23:04:38.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/file_tail.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -117,6 +118,12 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
+#ifdef CONFIG_FILE_TAILS
+	if (PageTail(page)) {
+		kfree(mapping->tail);
+		mapping->tail = NULL;
+	}
+#endif
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -885,6 +892,11 @@ page_ok:
 		index += offset >> PAGE_CACHE_SHIFT;
 		offset &= ~PAGE_CACHE_MASK;
 
+#ifdef CONFIG_FILE_TAILS
+		if (!mapping->tail && page->index == FILE_TAIL_INDEX(mapping) &&
+		    !PageDirty(page))
+			pack_file_tail(page);
+#endif
 		page_cache_release(page);
 		if (ret == nr && desc->count)
 			continue;
@@ -2030,6 +2042,16 @@ generic_file_buffered_write(struct kiocb
 			break;
 		}
 
+#ifdef CONFIG_FILE_TAILS
+		if (PageTail(page)) {
+			/* Can't unpack the tail while holding the tail page */
+			unlock_page(page);
+			page_cache_release(page);
+			unpack_file_tail(mapping);
+			continue;
+		}
+#endif
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
