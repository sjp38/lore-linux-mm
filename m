Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B8E8C6B022F
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:41:46 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 36 of 41] remove PG_buddy
Message-Id: <27d13ddf7c8f7ca03652.1269887869@v2.random>
In-Reply-To: <patchbomb.1269887833@v2.random>
References: <patchbomb.1269887833@v2.random>
Date: Mon, 29 Mar 2010 20:37:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

PG_buddy can be converted to page->_count == -1. So the PG_compound_lock can be
added to page->flags without overflowing (because of the section bits
increasing) with CONFIG_X86_PAE=y.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/fs/proc/page.c b/fs/proc/page.c
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -116,15 +116,17 @@ u64 stable_page_flags(struct page *page)
 	if (PageHuge(page))
 		u |= 1 << KPF_HUGE;
 
+	/*
+	 * Caveats on high order pages: page->_count will only be set
+	 * -1 on the head page; SLUB/SLQB do the same for PG_slab;
+	 * SLOB won't set PG_slab at all on compound pages.
+	 */
+	if (PageBuddy(page))
+		u |= 1 << KPF_BUDDY;
+
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
-	/*
-	 * Caveats on high order pages:
-	 * PG_buddy will only be set on the head page; SLUB/SLQB do the same
-	 * for PG_slab; SLOB won't set PG_slab at all on compound pages.
-	 */
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
-	u |= kpf_copy_bit(k, KPF_BUDDY,		PG_buddy);
 
 	u |= kpf_copy_bit(k, KPF_ERROR,		PG_error);
 	u |= kpf_copy_bit(k, KPF_DIRTY,		PG_dirty);
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -358,6 +358,27 @@ static inline void init_page_count(struc
 	atomic_set(&page->_count, 1);
 }
 
+/*
+ * PageBuddy() indicate that the page is free and in the buddy system
+ * (see mm/page_alloc.c).
+ */
+static inline int PageBuddy(struct page *page)
+{
+	return atomic_read(&page->_count) == -1;
+}
+
+static inline void __SetPageBuddy(struct page *page)
+{
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	atomic_set(&page->_count, -1);
+}
+
+static inline void __ClearPageBuddy(struct page *page)
+{
+	VM_BUG_ON(!PageBuddy(page));
+	atomic_set(&page->_count, 0);
+}
+
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -48,9 +48,6 @@
  * struct page (these bits with information) are always mapped into kernel
  * address space...
  *
- * PG_buddy is set to indicate that the page is free and in the buddy system
- * (see mm/page_alloc.c).
- *
  * PG_hwpoison indicates that a page got corrupted in hardware and contains
  * data with incorrect ECC bits that triggered a machine check. Accessing is
  * not safe since it may cause another machine check. Don't touch!
@@ -96,7 +93,6 @@ enum pageflags {
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
-	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
 	PG_unevictable,		/* Page is "unevictable"  */
 #ifdef CONFIG_MMU
@@ -235,7 +231,6 @@ PAGEFLAG(OwnerPriv1, owner_priv_1) TESTC
  * risky: they bypass page accounting.
  */
 TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
-__PAGEFLAG(Buddy, buddy)
 PAGEFLAG(MappedToDisk, mappedtodisk)
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
@@ -430,7 +425,7 @@ static inline void ClearPageCompound(str
 #define PAGE_FLAGS_CHECK_AT_FREE \
 	(1 << PG_lru	 | 1 << PG_locked    | \
 	 1 << PG_private | 1 << PG_private_2 | \
-	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
+	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
 	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
 	 __PG_COMPOUND_LOCK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -426,8 +426,8 @@ __find_combined_index(unsigned long page
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
  *
- * For recording whether a page is in the buddy system, we use PG_buddy.
- * Setting, clearing, and testing PG_buddy is serialized by zone->lock.
+ * For recording whether a page is in the buddy system, we set page->_count -1.
+ * Setting, clearing, and testing page->_count -1 is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -440,10 +440,8 @@ static inline int page_is_buddy(struct p
 	if (page_zone_id(page) != page_zone_id(buddy))
 		return 0;
 
-	if (PageBuddy(buddy) && page_order(buddy) == order) {
-		VM_BUG_ON(page_count(buddy) != 0);
+	if (PageBuddy(buddy) && page_order(buddy) == order)
 		return 1;
-	}
 	return 0;
 }
 
@@ -460,7 +458,7 @@ static inline int page_is_buddy(struct p
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with PG_buddy. Page's
+ * free pages of length of (1 << order) and marked with page->count -1. Page's
  * order is recorded in page_private(page) field.
  * So when we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were   
@@ -5251,7 +5249,6 @@ static struct trace_print_flags pageflag
 	{1UL << PG_swapcache,		"swapcache"	},
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
 	{1UL << PG_reclaim,		"reclaim"	},
-	{1UL << PG_buddy,		"buddy"		},
 	{1UL << PG_swapbacked,		"swapbacked"	},
 	{1UL << PG_unevictable,		"unevictable"	},
 #ifdef CONFIG_MMU

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
