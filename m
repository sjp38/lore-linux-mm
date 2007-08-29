Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKs00W018287
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:54:00 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKs0Ul568182
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:54:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKs06k027316
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:54:00 -0400
Date: Wed, 29 Aug 2007 16:54:00 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205359.28328.89933.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 06/07] For readahead, leave data in tail
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

For readahead, leave data in tail

Don't unpack it until it's actually read.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/readahead.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -Nurp linux005/mm/readahead.c linux006/mm/readahead.c
--- linux005/mm/readahead.c	2007-08-28 09:57:20.000000000 -0500
+++ linux006/mm/readahead.c	2007-08-29 13:27:46.000000000 -0500
@@ -15,6 +15,7 @@
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/pagevec.h>
+#include <linux/vm_file_tail.h>
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -163,6 +164,10 @@ __do_page_cache_readahead(struct address
 		if (page_offset > end_index)
 			break;
 
+		if ((page_offset == end_index) && vm_file_tail_packed(mapping))
+			/* Tail page is already packed */
+			break;
+
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		if (page)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
