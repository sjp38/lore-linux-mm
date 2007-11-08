Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8Jlhsc011917
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:43 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlhfY137800
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:43 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8Jlhqg014588
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:43 -0500
Date: Thu, 8 Nov 2007 14:47:42 -0500
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194741.17862.24983.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 05/09] find_get_page() and find_lock_page() need to unpack the tail
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

find_get_page() and find_lock_page() need to unpack the tail

If the page being sought corresponds to the tail, and the tail is packed
in the inode, the tail must be unpacked.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/filemap.c |    3 +++
 1 file changed, 3 insertions(+)

diff -Nurp linux004/mm/filemap.c linux005/mm/filemap.c
--- linux004/mm/filemap.c	2007-11-07 08:14:01.000000000 -0600
+++ linux005/mm/filemap.c	2007-11-08 10:49:46.000000000 -0600
@@ -24,6 +24,7 @@
 #include <linux/file.h>
 #include <linux/uio.h>
 #include <linux/hash.h>
+#include <linux/vm_file_tail.h>
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
@@ -600,6 +601,7 @@ struct page * find_get_page(struct addre
 {
 	struct page *page;
 
+	vm_file_tail_unpack_index(mapping, offset);
 	read_lock_irq(&mapping->tree_lock);
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page)
@@ -624,6 +626,7 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
+	vm_file_tail_unpack_index(mapping, offset);
 repeat:
 	read_lock_irq(&mapping->tree_lock);
 	page = radix_tree_lookup(&mapping->page_tree, offset);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
