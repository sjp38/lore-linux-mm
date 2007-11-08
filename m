Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id lA8IlKRl023201
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 13:47:20 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlnSu105912
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:49 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlnRo022042
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:49 -0700
Date: Thu, 8 Nov 2007 12:47:48 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194746.17862.83907.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 06/09] For readahead, leave data in tail
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

For readahead, leave data in tail

Don't unpack it until it's actually read.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/readahead.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -Nurp linux005/mm/readahead.c linux006/mm/readahead.c
--- linux005/mm/readahead.c	2007-11-07 08:14:01.000000000 -0600
+++ linux006/mm/readahead.c	2007-11-08 10:49:46.000000000 -0600
@@ -16,6 +16,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
+#include <linux/vm_file_tail.h>
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -147,6 +148,10 @@ __do_page_cache_readahead(struct address
 		if (page_offset > end_index)
 			break;
 
+		if ((page_offset == end_index) && vm_file_tail_packed(mapping))
+			/* Tail page is already packed */
+			break;
+
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
