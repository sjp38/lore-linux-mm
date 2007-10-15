Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9F8SnRt424792
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 08:28:49 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9F8SnNx3018832
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 09:28:49 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9F8SgO3014220
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 09:28:42 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
MIME-Version: 1.0
Content-Disposition: inline
Date: Mon, 15 Oct 2007 10:28:34 +0200
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200710151028.34407.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit unmaintained,
so decided to sent the patch to you :-).
I have CCed Ted, who did work on the code in the 90s. I found no current
email address of Chad Page.

We have seen ramdisk based install systems, where some pages of mapped 
libraries and programs were suddendly zeroed under memory pressure. This 
should not happen, as the ramdisk avoids freeing its pages by keeping them 
dirty all the time.

It turns out that there is a case, where the VM makes a ramdisk page clean, 
without telling the ramdisk driver.
On memory pressure shrink_zone runs and it starts to run shrink_active_list. 
There is a check for buffer_heads_over_limit, and if true, pagevec_strip is 
called. pagevec_strip calls try_to_release_page. If the mapping has no 
releasepage callback, try_to_free_buffers is called. try_to_free_buffers has 
now a special logic for some file systems to make a dirty page clean, if all 
buffers are clean. Thats what happened in our test case.

The solution is to provide a noop-releasepage callback for the ramdisk driver.
This avoids try_to_free_buffers for ramdisk pages. 

To trigger the problem, you have to make buffer_heads_over_limit true, which
means:
- lower max_buffer_heads 
or
- have a system with lots of high memory

Andrew, if there are no objections - please apply. The patch applies against
todays git.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

---
 drivers/block/rd.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c
+++ linux-2.6/drivers/block/rd.c
@@ -189,6 +189,18 @@ static int ramdisk_set_page_dirty(struct
 	return 0;
 }
 
+/*
+ * releasepage is called by pagevec_strip/try_to_release_page if
+ * buffers_heads_over_limit is true. Without a releasepage function
+ * try_to_free_buffers is called instead. That can unset the dirty
+ * bit of our ram disk pages, which will be eventually freed, even
+ * if the page is still in use.
+ */
+static int ramdisk_releasepage(struct page *page, gfp_t dummy)
+{
+	return 0;
+}
+
 static const struct address_space_operations ramdisk_aops = {
 	.readpage	= ramdisk_readpage,
 	.prepare_write	= ramdisk_prepare_write,
@@ -196,6 +208,7 @@ static const struct address_space_operat
 	.writepage	= ramdisk_writepage,
 	.set_page_dirty	= ramdisk_set_page_dirty,
 	.writepages	= ramdisk_writepages,
+	.releasepage	= ramdisk_releasepage,
 };
 
 static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
