Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JlMoa019849
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:22 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlLH2081956
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:21 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlKuC029916
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:20 -0700
Date: Thu, 8 Nov 2007 12:47:18 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194716.17862.97057.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 01/09] Add tail to address space
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add tail to address space

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 fs/inode.c         |    3 +++
 include/linux/fs.h |    4 ++++
 mm/Kconfig         |    9 +++++++++
 3 files changed, 16 insertions(+)

diff -Nurp linux000/fs/inode.c linux001/fs/inode.c
--- linux000/fs/inode.c	2007-11-07 08:13:54.000000000 -0600
+++ linux001/fs/inode.c	2007-11-08 10:49:46.000000000 -0600
@@ -213,6 +213,9 @@ void inode_init_once(struct inode *inode
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
+#ifdef CONFIG_VM_FILE_TAILS
+	spin_lock_init(&inode->i_data.tail_lock);
+#endif
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	i_size_ordered_init(inode);
diff -Nurp linux000/include/linux/fs.h linux001/include/linux/fs.h
--- linux000/include/linux/fs.h	2007-11-07 08:13:59.000000000 -0600
+++ linux001/include/linux/fs.h	2007-11-08 10:49:46.000000000 -0600
@@ -511,6 +511,10 @@ struct address_space {
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
--- linux000/mm/Kconfig	2007-11-07 08:14:01.000000000 -0600
+++ linux001/mm/Kconfig	2007-11-08 10:49:46.000000000 -0600
@@ -194,3 +194,12 @@ config NR_QUICK
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
