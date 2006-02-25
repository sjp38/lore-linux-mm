Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k1P0PTOX011798
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 18:25:29 -0600
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k1P0gWa516085331
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 16:42:32 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k1P0PSnB25492468
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 16:25:28 -0800 (PST)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FCnFY-0006Nm-00
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 16:25:28 -0800
Date: Fri, 24 Feb 2006 16:24:15 -0800 (PST)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: page migration: fail if page is in a vma flagged VM_LOCKED
Message-ID: <Pine.LNX.4.64.0602241617450.24013@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0602241625210.24013@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

page migration currently simply retries a couple of times
if try_to_unmap() fails without inspecting the return code.

However, SWAP_FAIL indicates that the page is in a vma that has the 
VM_LOCKED flag set (if ignore_refs ==1). We can check for that return code 
and avoid retrying the migration.

migrate_page_remove_references() now needs to return a reason
why the failure occured. So switch migrate_page_remove_references
to use -Exx style error messages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc4/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc4.orig/mm/vmscan.c	2006-02-17 14:23:45.000000000 -0800
+++ linux-2.6.16-rc4/mm/vmscan.c	2006-02-24 15:49:36.000000000 -0800
@@ -700,7 +700,7 @@ int migrate_page_remove_references(struc
 	 * the page.
 	 */
 	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
-		return 1;
+		return -EAGAIN;
 
 	/*
 	 * Establish swap ptes for anonymous pages or destroy pte
@@ -721,13 +721,15 @@ int migrate_page_remove_references(struc
 	 * If the page was not migrated then the PageSwapCache bit
 	 * is still set and the operation may continue.
 	 */
-	try_to_unmap(page, 1);
+	if (try_to_unmap(page, 1) == SWAP_FAIL)
+		/* A vma has VM_LOCKED set -> Permanent failure */
+		return -EPERM;
 
 	/*
 	 * Give up if we were unable to remove all mappings.
 	 */
 	if (page_mapcount(page))
-		return 1;
+		return -EAGAIN;
 
 	write_lock_irq(&mapping->tree_lock);
 
@@ -738,7 +740,7 @@ int migrate_page_remove_references(struc
 	if (!page_mapping(page) || page_count(page) != nr_refs ||
 			*radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
-		return 1;
+		return -EAGAIN;
 	}
 
 	/*
@@ -813,10 +815,14 @@ EXPORT_SYMBOL(migrate_page_copy);
  */
 int migrate_page(struct page *newpage, struct page *page)
 {
+	int rc;
+
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	if (migrate_page_remove_references(newpage, page, 2))
-		return -EAGAIN;
+	rc = migrate_page_remove_references(newpage, page, 2);
+
+	if (rc)
+		return rc;
 
 	migrate_page_copy(newpage, page);
 
Index: linux-2.6.16-rc4/fs/buffer.c
===================================================================
--- linux-2.6.16-rc4.orig/fs/buffer.c	2006-02-17 14:23:45.000000000 -0800
+++ linux-2.6.16-rc4/fs/buffer.c	2006-02-24 15:47:35.000000000 -0800
@@ -3060,6 +3060,7 @@ int buffer_migrate_page(struct page *new
 {
 	struct address_space *mapping = page->mapping;
 	struct buffer_head *bh, *head;
+	int rc;
 
 	if (!mapping)
 		return -EAGAIN;
@@ -3069,8 +3070,9 @@ int buffer_migrate_page(struct page *new
 
 	head = page_buffers(page);
 
-	if (migrate_page_remove_references(newpage, page, 3))
-		return -EAGAIN;
+	rc = migrate_page_remove_references(newpage, page, 3);
+	if (rc)
+		return rc;
 
 	bh = head;
 	do {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
