Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKrsbQ031206
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKrt6U677498
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKrsK1012934
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:54 -0400
Date: Wed, 29 Aug 2007 16:53:54 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205354.28328.30000.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 05/07] find_get_page() and find_lock_page() need to unpack the tail
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

find_get_page() and find_lock_page() need to unpack the tail

If the page being sought corresponds to the tail, and the tail is packed
in the inode, the tail must be unpacked.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/filemap.c |    3 +++
 1 file changed, 3 insertions(+)

diff -Nurp linux004/mm/filemap.c linux005/mm/filemap.c
--- linux004/mm/filemap.c	2007-08-28 09:57:20.000000000 -0500
+++ linux005/mm/filemap.c	2007-08-29 13:27:46.000000000 -0500
@@ -24,6 +24,7 @@
 #include <linux/file.h>
 #include <linux/uio.h>
 #include <linux/hash.h>
+#include <linux/vm_file_tail.h>
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
@@ -597,6 +598,7 @@ struct page * find_get_page(struct addre
 {
 	struct page *page;
 
+	vm_file_tail_unpack_index(mapping, offset);
 	read_lock_irq(&mapping->tree_lock);
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page)
@@ -621,6 +623,7 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
+	vm_file_tail_unpack_index(mapping, offset);
 	read_lock_irq(&mapping->tree_lock);
 repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
