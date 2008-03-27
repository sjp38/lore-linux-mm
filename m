Date: Wed, 26 Mar 2008 19:45:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Page flags: Add PAGEFLAGS_FALSE for flags that are always false
Message-ID: <Pine.LNX.4.64.0803261943260.2242@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Applies on top of the PG_uncached flag patch.


From: Christoph Lameter <clameter@sgi.com>
Subject: Page flags: Add PAGEFLAGS_FALSE

Turns out that there a number of times that a flag is simply always returning 0.
Define a macro for that.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

Index: linux-2.6.25-rc5-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/page-flags.h	2008-03-26 19:21:50.259169581 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/page-flags.h	2008-03-26 19:37:17.456669515 -0700
@@ -145,6 +145,10 @@ static inline int TestClearPage##uname(s
 #define __PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
 	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
 
+#define PAGEFLAG_FALSE(uname) 						\
+static inline int Page##uname(struct page *page) 			\
+			{ return 0; }
+
 #define TESTSCFLAG(uname, lname)					\
 	TESTSETFLAG(uname, lname) TESTCLEARFLAG(uname, lname)
 
@@ -182,28 +186,19 @@ PAGEFLAG(Readahead, reclaim)		/* Reminde
  */
 #define PageHighMem(__p) is_highmem(page_zone(__p))
 #else
-static inline int PageHighMem(struct page *page)
-{
-	return 0;
-}
+PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
 PAGEFLAG(SwapCache, swapcache)
 #else
-static inline int PageSwapCache(struct page *page)
-{
-	return 0;
-}
+PAGEFLAG_FALSE(SwapCache)
 #endif
 
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 PAGEFLAG(Uncached, uncached)
 #else
-static inline int PageUncached(struct page *)
-{
-	return 0;
-}
+PAGEFLAG_FALSE(Uncached)
 #endif
 
 static inline int PageUptodate(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
