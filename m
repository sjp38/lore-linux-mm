Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D800F6B01F0
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:45:21 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 02 of 41] compound_lock
Message-Id: <3b4cec7fa55a646af239.1270168889@v2.random>
In-Reply-To: <patchbomb.1270168887@v2.random>
References: <patchbomb.1270168887@v2.random>
Date: Fri, 02 Apr 2010 02:41:29 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add a new compound_lock() needed to serialize put_page against
__split_huge_page_refcount().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -13,6 +13,7 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/range.h>
+#include <linux/bit_spinlock.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -297,6 +298,20 @@ static inline int is_vmalloc_or_module_a
 }
 #endif
 
+static inline void compound_lock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_lock(PG_compound_lock, &page->flags);
+#endif
+}
+
+static inline void compound_unlock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_unlock(PG_compound_lock, &page->flags);
+#endif
+}
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,6 +108,9 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	PG_compound_lock,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -399,6 +402,12 @@ static inline void __ClearPageTail(struc
 #define __PG_MLOCKED		0
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
+#else
+#define __PG_COMPOUND_LOCK		0
+#endif
+
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
@@ -408,7 +417,8 @@ static inline void __ClearPageTail(struc
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 __PG_COMPOUND_LOCK)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
