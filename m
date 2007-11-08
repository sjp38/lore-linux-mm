Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8Jm3T6019831
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:48:03 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8Jm2Lv064504
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:48:02 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8Jm2J8014188
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:48:02 -0700
Date: Thu, 8 Nov 2007 12:48:01 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194759.17862.44869.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 08/09] generic_file_aio_read can read directly from the tail.  No need to unpack
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

generic_file_aio_read can read directly from the tail.  No need to unpack

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 include/linux/vm_file_tail.h |   13 ++++++++++
 mm/file_tail.c               |   54 +++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                 |    4 ++-
 3 files changed, 70 insertions(+), 1 deletion(-)

diff -Nurp linux007/include/linux/vm_file_tail.h linux008/include/linux/vm_file_tail.h
--- linux007/include/linux/vm_file_tail.h	2007-11-08 10:49:46.000000000 -0600
+++ linux008/include/linux/vm_file_tail.h	2007-11-08 10:49:46.000000000 -0600
@@ -53,6 +53,18 @@ static inline void vm_file_tail_unpack_i
 		vm_file_tail_unpack(mapping);
 }
 
+extern int __vm_file_tail_read(struct file *, loff_t *, read_descriptor_t *);
+
+static inline int vm_file_tail_read(struct file *filp, loff_t *ppos,
+				    read_descriptor_t *desc)
+{
+	struct address_space *mapping = filp->f_mapping;
+	unsigned long index = *ppos >> PAGE_CACHE_SHIFT;
+
+	if (mapping->tail && index == vm_file_tail_index(mapping))
+		return __vm_file_tail_read(filp, ppos, desc);
+	return 0;
+}
 #else /* !CONFIG_VM_FILE_TAILS */
 
 #define vm_file_tail_packed(mapping) 0
@@ -60,6 +72,7 @@ static inline void vm_file_tail_unpack_i
 #define vm_file_tail_pack(page) 0
 #define vm_file_tail_unpack(mapping) do {} while (0)
 #define vm_file_tail_unpack_index(mapping, index) do {} while (0)
+#define vm_file_tail_read(filp, ppos, desc) 0
 
 #endif /* CONFIG_VM_FILE_TAILS */
 
diff -Nurp linux007/mm/file_tail.c linux008/mm/file_tail.c
--- linux007/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
+++ linux008/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
@@ -178,3 +178,57 @@ void __vm_file_tail_unpack_on_resize(str
 		vm_file_tail_free(inode->i_mapping);
 }
 EXPORT_SYMBOL(__vm_file_tail_unpack_on_resize);
+
+/*
+ * Copy tail data to user buffer
+ *
+ * Returns 1 on success
+ */
+int __vm_file_tail_read(struct file *filp, loff_t *ppos,
+			read_descriptor_t *desc)
+{
+	unsigned long count = desc->count;
+	unsigned int flags;
+	unsigned long left;
+	struct address_space *mapping = filp->f_mapping;
+	unsigned long offset;
+	unsigned long index = *ppos >> PAGE_CACHE_SHIFT;
+	unsigned long size;
+
+	if (fault_in_pages_writeable(desc->arg.buf, count))
+		/*
+		 * Keep this simple since this path is an optimization.  Let
+		 * the tricky stuff get handled in the fallback path.
+		 */
+		return 0;
+
+	spin_lock_irqsave(&mapping->tail_lock, flags);
+
+	offset = *ppos & ~PAGE_CACHE_MASK;
+	if (!mapping->tail || index != vm_file_tail_index(mapping) ||
+	    offset >= vm_file_tail_length(mapping)) {
+		spin_unlock_irqrestore(&mapping->tail_lock, flags);
+		return 0;
+	}
+
+	size = vm_file_tail_length(mapping) - offset;
+	if (size > count)
+		size = count;
+
+	left = __copy_to_user_inatomic(desc->arg.buf,
+				       (char *)mapping->tail + offset, size);
+
+	spin_unlock_irqrestore(&mapping->tail_lock, flags);
+
+	if (left) {
+		size -= left;
+		desc->error = -EFAULT;
+	}
+	desc->count = count - size;
+	desc->written += size;
+	desc->arg.buf += size;
+	*ppos += size;
+	file_accessed(filp);
+
+	return 1;
+}
diff -Nurp linux007/mm/filemap.c linux008/mm/filemap.c
--- linux007/mm/filemap.c	2007-11-08 10:49:46.000000000 -0600
+++ linux008/mm/filemap.c	2007-11-08 10:49:46.000000000 -0600
@@ -1195,7 +1195,9 @@ generic_file_aio_read(struct kiocb *iocb
 			if (desc.count == 0)
 				continue;
 			desc.error = 0;
-			do_generic_file_read(filp,ppos,&desc,file_read_actor);
+			if (!vm_file_tail_read(filp, ppos, &desc))
+				do_generic_file_read(filp, ppos, &desc,
+						     file_read_actor);
 			retval += desc.written;
 			if (desc.error) {
 				retval = retval ?: desc.error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
