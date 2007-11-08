Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JlbsS011645
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:37 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8Jlb0s110844
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlbRo004187
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:37 -0500
Date: Thu, 8 Nov 2007 14:47:37 -0500
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194735.17862.85053.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 04/09] Unpack or remove file tail when inode is resized
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Unpack or remove file tail when inode is resized

If the inode size grows, we need to unpack the tail into a page.
If the inode shrinks, such that the entire tail is beyond the end of the
file, discard the tail.  If the file shrinks, but part of the tail is still
valid, just leave it.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/linux/fs.h |   14 ++++++++++++++
 mm/file_tail.c     |   11 +++++++++++
 2 files changed, 25 insertions(+)

diff -Nurp linux003/include/linux/fs.h linux004/include/linux/fs.h
--- linux003/include/linux/fs.h	2007-11-08 10:49:46.000000000 -0600
+++ linux004/include/linux/fs.h	2007-11-08 10:49:46.000000000 -0600
@@ -715,6 +715,19 @@ static inline loff_t i_size_read(const s
 #endif
 }
 
+#ifdef CONFIG_VM_FILE_TAILS
+void __vm_file_tail_unpack_on_resize(struct inode *, loff_t);
+
+static inline void vm_file_tail_unpack_on_resize(struct inode *inode,
+						 loff_t size)
+{
+	if (inode->i_mapping && inode->i_mapping->tail)
+		__vm_file_tail_unpack_on_resize(inode, size);
+}
+#else
+#define vm_file_tail_unpack_on_resize(mapping, new_size) do {} while (0)
+#endif
+
 /*
  * NOTE: unlike i_size_read(), i_size_write() does need locking around it
  * (normally i_mutex), otherwise on 32bit/SMP an update of i_size_seqcount
@@ -722,6 +735,7 @@ static inline loff_t i_size_read(const s
  */
 static inline void i_size_write(struct inode *inode, loff_t i_size)
 {
+	vm_file_tail_unpack_on_resize(inode, i_size);
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	write_seqcount_begin(&inode->i_size_seqcount);
 	inode->i_size = i_size;
diff -Nurp linux003/mm/file_tail.c linux004/mm/file_tail.c
--- linux003/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
+++ linux004/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
@@ -13,6 +13,7 @@
 #include <linux/buffer_head.h>
 #include <linux/fs.h>
 #include <linux/hardirq.h>
+#include <linux/module.h>
 #include <linux/vm_file_tail.h>
 
 /*
@@ -167,3 +168,13 @@ out:
 	unlock_page(page);
 	return ret;
 }
+
+void __vm_file_tail_unpack_on_resize(struct inode *inode, loff_t new_size)
+{
+	loff_t old_size = i_size_read(inode);
+	if (new_size > old_size)
+		vm_file_tail_unpack(inode->i_mapping);
+	else if (new_size >> PAGE_CACHE_SHIFT != old_size >> PAGE_CACHE_SHIFT)
+		vm_file_tail_free(inode->i_mapping);
+}
+EXPORT_SYMBOL(__vm_file_tail_unpack_on_resize);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
