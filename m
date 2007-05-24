Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCCK33009872
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:20 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCCKSx529636
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:20 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCCK8N013349
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:20 -0400
Date: Thu, 24 May 2007 08:12:20 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121220.13533.54679.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 009/012] Wrap i_size_write
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wrap i_size_write

If CONFIG_FILE_TAILS is set, i_size_write is defined in file_tail.c

This adds considerable overhead to i_size_write, but i_size_read is unaffected.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/linux/fs.h |    5 +++++
 mm/file_tail.c     |   12 ++++++++++++
 2 files changed, 17 insertions(+)

diff -Nurp linux008/include/linux/fs.h linux009/include/linux/fs.h
--- linux008/include/linux/fs.h	2007-05-23 22:53:11.000000000 -0500
+++ linux009/include/linux/fs.h	2007-05-23 22:53:12.000000000 -0500
@@ -661,7 +661,12 @@ static inline loff_t i_size_read(const s
  * (normally i_mutex), otherwise on 32bit/SMP an update of i_size_seqcount
  * can be lost, resulting in subsequent i_size_read() calls spinning forever.
  */
+#ifdef CONFIG_VM_FILE_TAILS
+extern void i_size_write(struct inode *, loff_t); /* defined in file_tail.c */
+static inline void _i_size_write(struct inode *inode, loff_t i_size)
+#else
 static inline void i_size_write(struct inode *inode, loff_t i_size)
+#endif
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	write_seqcount_begin(&inode->i_size_seqcount);
diff -Nurp linux008/mm/file_tail.c linux009/mm/file_tail.c
--- linux008/mm/file_tail.c	2007-05-23 22:53:11.000000000 -0500
+++ linux009/mm/file_tail.c	2007-05-23 22:53:12.000000000 -0500
@@ -188,6 +188,18 @@ int __unpack_file_tail(struct address_sp
 	return rc;
 }
 
+void i_size_write(struct inode *inode, loff_t i_size)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	write_lock_irq(&mapping->tree_lock);
+	if (mapping->tail && (i_size > i_size_read(inode)))
+		__unpack_file_tail(mapping);
+	_i_size_write(inode, i_size);
+	write_unlock_irq(&mapping->tree_lock);
+}
+EXPORT_SYMBOL(i_size_write);
+
 static void init_once(void *ptr, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct page *page = (struct page *)ptr;

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
