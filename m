Date: Wed, 26 Mar 2008 19:21:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: page flags: Handle PG_uncached like all other flags
Message-ID: <Pine.LNX.4.64.0803261920130.2183@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Subject: page flags: Handle PG_uncached like all other flags
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, dcn@sgi.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

Remove the special setup for PG_uncached and simply make it part of the enum.
The page flag will only be allocated when the kernel build includes the uncached
allocator.

Cc: Dean Nelson <dcn@sgi.com>
Cc: Jes Sorensen <jes@trained-monkey.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

Index: linux-2.6.25-rc5-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/page-flags.h	2008-03-25 21:22:16.312931059 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/page-flags.h	2008-03-25 21:22:53.466668675 -0700
@@ -99,16 +99,8 @@ enum pageflags {
 	 * read ahead needs to be done.
 	 */
 	PG_buddy,		/* Page is free, on buddy lists */
-
-#if (BITS_PER_LONG > 32)
-/*
- * 64-bit-only flags build down from bit 31
- *
- * 32 bit  -------------------------------| FIELDS |       FLAGS         |
- * 64 bit  |           FIELDS             | ??????         FLAGS         |
- *         63                            32                              0
- */
-	PG_uncached = 31,		/* Page has been mapped as uncached */
+#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
+	PG_uncached,		/* Page has been mapped as uncached */
 #endif
 	__NR_PAGEFLAGS
 };
@@ -205,8 +197,13 @@ static inline int PageSwapCache(struct p
 }
 #endif
 
-#if (BITS_PER_LONG > 32)
+#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 PAGEFLAG(Uncached, uncached)
+#else
+static inline int PageUncached(struct page *)
+{
+	return 0;
+}
 #endif
 
 static inline int PageUptodate(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
