Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCBlDg001294
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBlNt554874
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBlio024419
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:47 -0400
Date: Thu, 24 May 2007 08:11:46 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121146.13533.65647.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 003/012] Add tail to address space and define PG_pagetail page flag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add tail to address space and define PG_filetail page flag

The tail pointer in struct address_space needs to be block-aligned so that
i/o can be performed directly to/from the buffer.  The allocated buffer may
not be aligned properly, so the pointer is stored in tail_buf in order to
be freed properly.

Note: Changing from slab to slub should ensure that the allocated buffer
will be properly aligned, so only one pointer will be needed.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/Kconfig       |    9 +++++++++
 include/linux/fs.h         |    4 ++++
 include/linux/page-flags.h |    9 +++++++++
 3 files changed, 22 insertions(+)

diff -Nurp linux002/arch/powerpc/Kconfig linux003/arch/powerpc/Kconfig
--- linux002/arch/powerpc/Kconfig	2007-05-21 15:14:48.000000000 -0500
+++ linux003/arch/powerpc/Kconfig	2007-05-23 22:53:11.000000000 -0500
@@ -552,6 +552,15 @@ config PPC_64K_PAGES
 	  while on hardware with such support, it will be used to map
 	  normal application pages.
 
+config VM_FILE_TAILS
+	bool "Store file tails in slab cache"
+	depends on PPC_64K_PAGES
+	help
+	  If the data at the end of a file, or the entire file, is small,
+	  the kernel will attempt to store that data in the slab cache,
+	  rather than allocate an entire page in the page cache.
+	  If unsure, say N here.
+
 config SCHED_SMT
 	bool "SMT (Hyperthreading) scheduler support"
 	depends on PPC64 && SMP
diff -Nurp linux002/include/linux/fs.h linux003/include/linux/fs.h
--- linux002/include/linux/fs.h	2007-05-23 22:53:11.000000000 -0500
+++ linux003/include/linux/fs.h	2007-05-23 22:53:11.000000000 -0500
@@ -452,6 +452,10 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_VM_FILE_TAILS
+	void			*tail;		/* block-aligned, slab-packed file tail */
+	void			*tail_buf;	/* unaligned buffer holding tail */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -Nurp linux002/include/linux/page-flags.h linux003/include/linux/page-flags.h
--- linux002/include/linux/page-flags.h	2007-05-21 15:15:44.000000000 -0500
+++ linux003/include/linux/page-flags.h	2007-05-23 22:53:11.000000000 -0500
@@ -101,6 +101,7 @@
  * 64 bit  |           FIELDS             | ??????         FLAGS         |
  *         63                            32                              0
  */
+#define PG_filetail			30	/* Pseudo-page representing tail */
 #define PG_uncached		31	/* Page has been mapped as uncached */
 #endif
 
@@ -270,6 +271,14 @@ static inline void __ClearPageTail(struc
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#ifdef CONFIG_VM_FILE_TAILS
+#define PageFileTail(page)	test_bit(PG_filetail, &(page)->flags)
+#else
+#define PageFileTail(page)	(0)
+#endif
+#define SetPageFileTail(page)	set_bit(PG_filetail, &(page)->flags)
+#define ClearPageFileTail(page)	clear_bit(PG_filetail, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
