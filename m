Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id l0V4715Q007551
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 04:07:01 GMT
Received: from ug-out-1314.google.com (ugn78.prod.google.com [10.66.14.78])
	by spaceape9.eur.corp.google.com with ESMTP id l0V46uL4023731
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 04:06:56 GMT
Received: by ug-out-1314.google.com with SMTP id 78so65053ugn
        for <linux-mm@kvack.org>; Tue, 30 Jan 2007 20:06:56 -0800 (PST)
Message-ID: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
Date: Tue, 30 Jan 2007 20:06:55 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] simplify shmem_aops.set_page_dirty method
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

shmem backed file does not have page write back, nor it participates in
BDI_CAP_NO_ACCT_DIRTY or BDI_CAP_NO_WRITEBACK accounting. So using generic
__set_page_dirty_nobuffers() for its .set_page_dirty aops method is a bit
overkill.  It unnecessarily prolonged shm unmap latency.

For example, on a densely populated large shm segment (sevearl GBs), the
unmapping operation becomes painfully long. Because at unmap, kernel
transfers dirty bit in PTE into page struct and to the radix tree tag. The
operation of tagging the radix tree is particularlly expensive because it
has to traverse the tree from the root to the leaf node on every dirty page.
What's bothering is that radix tree tag is used for page write back. However,
shmem is memory backed and there is no page write back for such file system.
And in the end, we spend all that time tagging radix tree and none of that
fancy tagging will be used.  So let's simplify it by introduce a new aops
__set_page_dirty_no_write_back and this will speed up shm unmap.


Signed-off-by: Ken Chen <kenchen@google.com>

---
Hugh, would you please kindly review this patch?


diff -Nurp linux-2.6.20-rc6/include/linux/mm.h
linux-2.6.20-rc6.unmap/include/linux/mm.h
--- linux-2.6.20-rc6/include/linux/mm.h	2007-01-30 19:23:44.000000000 -0800
+++ linux-2.6.20-rc6.unmap/include/linux/mm.h	2007-01-30
19:25:06.000000000 -0800
@@ -785,6 +785,7 @@ extern int try_to_release_page(struct pa
 extern void do_invalidatepage(struct page *page, unsigned long offset);

 int __set_page_dirty_nobuffers(struct page *page);
+int __set_page_dirty_no_write_back(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
 int FASTCALL(set_page_dirty(struct page *page));
diff -Nurp linux-2.6.20-rc6/mm/page-writeback.c
linux-2.6.20-rc6.unmap/mm/page-writeback.c
--- linux-2.6.20-rc6/mm/page-writeback.c	2007-01-30 19:23:45.000000000 -0800
+++ linux-2.6.20-rc6.unmap/mm/page-writeback.c	2007-01-30
19:58:46.000000000 -0800
@@ -742,6 +742,21 @@ int write_one_page(struct page *page, in
 EXPORT_SYMBOL(write_one_page);

 /*
+ * For address_spaces which do not use buffers nor page write back.
+ */
+int __set_page_dirty_no_write_back(struct page *page)
+{
+	if (!TestSetPageDirty(page)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping && mapping->host) {
+			/* !PageAnon && !swapper_space */
+			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+		}
+	}
+	return 0;
+}
+
+/*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
  *
diff -Nurp linux-2.6.20-rc6/mm/shmem.c linux-2.6.20-rc6.unmap/mm/shmem.c
--- linux-2.6.20-rc6/mm/shmem.c	2007-01-30 19:23:45.000000000 -0800
+++ linux-2.6.20-rc6.unmap/mm/shmem.c	2007-01-30 19:38:26.000000000 -0800
@@ -2316,7 +2316,7 @@ static void destroy_inodecache(void)

 static const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= __set_page_dirty_no_write_back,
 #ifdef CONFIG_TMPFS
 	.prepare_write	= shmem_prepare_write,
 	.commit_write	= simple_commit_write,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
