Date: Thu, 2 Dec 2004 16:26:21 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Neaten page virtual choice
Message-ID: <20041202162621.GM5752@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

Make it more obvious that WANT_PAGE_VIRTUAL/HASHED_PAGE_VIRTUAL/!HIGHMEM
is a three way choice.

Index: linux/include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux-2.6/include/linux/mm.h,v
retrieving revision 1.22
diff -u -p -r1.22 mm.h
--- linux/include/linux/mm.h	29 Nov 2004 19:56:48 -0000	1.22
+++ linux/include/linux/mm.h	1 Dec 2004 20:53:38 -0000
@@ -414,29 +414,22 @@ static inline void *lowmem_page_address(
 	return __va(page_to_pfn(page) << PAGE_SHIFT);
 }
 
-#if defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL)
-#define HASHED_PAGE_VIRTUAL
-#endif
-
 #if defined(WANT_PAGE_VIRTUAL)
-#define page_address(page) ((page)->virtual)
-#define set_page_address(page, address)			\
+  #define page_address(page) ((page)->virtual)
+  #define set_page_address(page, address)			\
 	do {						\
 		(page)->virtual = (address);		\
 	} while(0)
-#define page_address_init()  do { } while(0)
-#endif
-
-#if defined(HASHED_PAGE_VIRTUAL)
-void *page_address(struct page *page);
-void set_page_address(struct page *page, void *virtual);
-void page_address_init(void);
-#endif
-
-#if !defined(HASHED_PAGE_VIRTUAL) && !defined(WANT_PAGE_VIRTUAL)
-#define page_address(page) lowmem_page_address(page)
-#define set_page_address(page, address)  do { } while(0)
-#define page_address_init()  do { } while(0)
+  #define page_address_init()  do { } while(0)
+#elif defined(CONFIG_HIGHMEM)
+  #define HASHED_PAGE_VIRTUAL
+  void *page_address(struct page *page);
+  void set_page_address(struct page *page, void *virtual);
+  void page_address_init(void);
+#else
+  #define page_address(page) lowmem_page_address(page)
+  #define set_page_address(page, address)  do { } while(0)
+  #define page_address_init()  do { } while(0)
 #endif
 
 /*
Index: linux/mm/highmem.c
===================================================================
RCS file: /var/cvs/linux-2.6/mm/highmem.c,v
retrieving revision 1.8
diff -u -p -r1.8 highmem.c
--- linux/mm/highmem.c	30 Sep 2004 12:08:53 -0000	1.8
+++ linux/mm/highmem.c	1 Dec 2004 21:49:21 -0000
@@ -483,7 +483,7 @@ void blk_queue_bounce(request_queue_t *q
 
 EXPORT_SYMBOL(blk_queue_bounce);
 
-#if defined(HASHED_PAGE_VIRTUAL)
+#ifdef HASHED_PAGE_VIRTUAL
 
 #define PA_HASH_ORDER	7
 
@@ -602,4 +602,4 @@ void __init page_address_init(void)
 	spin_lock_init(&pool_lock);
 }
 
-#endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
+#endif	/* HASHED_PAGE_VIRTUAL */

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
