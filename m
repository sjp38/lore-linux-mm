Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48FSt007666
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48FqA275954
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48F1d020527
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:15 -0600
Date: Mon, 17 Jul 2006 22:08:13 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040811.11926.43206.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 001/008] Changes to common header files
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Changes to common header files

Add tail to address space and define PG_tail page flag

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux000/arch/powerpc/Kconfig linux001/arch/powerpc/Kconfig
--- linux000/arch/powerpc/Kconfig	2006-06-17 20:49:35.000000000 -0500
+++ linux001/arch/powerpc/Kconfig	2006-07-17 23:04:37.000000000 -0500
@@ -696,6 +696,15 @@ config PPC_64K_PAGES
           while on hardware with such support, it will be used to map
           normal application pages.
 
+config FILE_TAILS
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
diff -Nurp linux000/include/linux/fs.h linux001/include/linux/fs.h
--- linux000/include/linux/fs.h	2006-06-17 20:49:35.000000000 -0500
+++ linux001/include/linux/fs.h	2006-07-17 23:04:37.000000000 -0500
@@ -398,6 +398,9 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_FILE_TAILS
+	void			*tail;		/* efficiently stored tail */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -Nurp linux000/include/linux/page-flags.h linux001/include/linux/page-flags.h
--- linux000/include/linux/page-flags.h	2006-06-17 20:49:35.000000000 -0500
+++ linux001/include/linux/page-flags.h	2006-07-17 23:04:37.000000000 -0500
@@ -89,6 +89,7 @@
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_tail			21	/* Pseudo-page representing tail */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -360,6 +361,10 @@ extern void __mod_page_state_offset(unsi
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageTail(page)		test_bit(PG_tail, &(page)->flags)
+#define SetPageTail(page)	set_bit(PG_tail, &(page)->flags)
+#define ClearPageTail(page)	clear_bit(PG_tail, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
