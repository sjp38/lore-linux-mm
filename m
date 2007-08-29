Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKrVS3030093
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:31 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKrVab513742
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKrVHZ011348
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:31 -0400
Date: Wed, 29 Aug 2007 16:53:31 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205331.28328.59704.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 01/07] Add tail to address space
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add tail to address space

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 fs/inode.c         |    3 +++
 include/linux/fs.h |    4 ++++
 mm/Kconfig         |    9 +++++++++
 3 files changed, 16 insertions(+)

diff -Nurp linux000/fs/inode.c linux001/fs/inode.c
--- linux000/fs/inode.c	2007-08-28 09:57:14.000000000 -0500
+++ linux001/fs/inode.c	2007-08-29 13:27:46.000000000 -0500
@@ -197,6 +197,9 @@ void inode_init_once(struct inode *inode
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
+#ifdef CONFIG_VM_FILE_TAILS
+	spin_lock_init(&inode->i_data.tail_lock);
+#endif
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	spin_lock_init(&inode->i_lock);
diff -Nurp linux000/include/linux/fs.h linux001/include/linux/fs.h
--- linux000/include/linux/fs.h	2007-08-28 09:57:17.000000000 -0500
+++ linux001/include/linux/fs.h	2007-08-29 13:27:46.000000000 -0500
@@ -453,6 +453,10 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_VM_FILE_TAILS
+	void			*tail;		/* file tail */
+	spinlock_t		tail_lock;	/* protect tail */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -Nurp linux000/mm/Kconfig linux001/mm/Kconfig
--- linux000/mm/Kconfig	2007-08-28 09:57:20.000000000 -0500
+++ linux001/mm/Kconfig	2007-08-29 13:27:46.000000000 -0500
@@ -176,3 +176,12 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config VM_FILE_TAILS
+	bool "Store file tails in slab cache"
+	def_bool n
+	help
+	  If the data at the end of a file, or the entire file, is small,
+	  the kernel will attempt to store that data in the slab cache,
+	  rather than allocate an entire page in the page cache.
+	  If unsure, say N here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
