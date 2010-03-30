Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5B0316B020D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 21:07:49 -0400 (EDT)
Date: Tue, 30 Mar 2010 03:06:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36 of 41] remove PG_buddy
Message-ID: <20100330010627.GD5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <27d13ddf7c8f7ca03652.1269887869@v2.random>
 <1269888584.12097.371.camel@laptop>
 <20100329221718.GA5825@random.random>
 <1269901837.9160.43341.camel@nimitz>
 <20100330001511.GB5825@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100330001511.GB5825@random.random>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

What do you think about this in replacement? It boots so it must be
perfect, no? (too bad previous version booted too ;)

----
Subject: remove PG_buddy

From: Andrea Arcangeli <aarcange@redhat.com>

PG_buddy can be converted to _mapcount == -2. So the PG_compound_lock can be
added to page->flags without overflowing (because of the sparse section bits
increasing) with CONFIG_X86_PAE=y and CONFIG_X86_PAT=y. This also has to move
the memory hotplug code from _mapcount to lru.next to avoid clashes.

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
+	return atomic_read(&page->_mapcount) == -2;
+}
+
+static inline void __SetPageBuddy(struct page *page)
+{
+	VM_BUG_ON(atomic_read(&page->_mapcount) != -1);
+	atomic_set(&page->_mapcount, -2);
+}
+
+static inline void __ClearPageBuddy(struct page *page)
+{
+	VM_BUG_ON(!PageBuddy(page));
+	atomic_set(&page->_mapcount, -1);
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
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -65,9 +65,9 @@ static void release_memory_resource(stru
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
-static void get_page_bootmem(unsigned long info,  struct page *page, int type)
+static void get_page_bootmem(unsigned long info,  struct page *page, long type)
 {
-	atomic_set(&page->_mapcount, type);
+	page->lru.next = (struct list_head *) type;
 	SetPagePrivate(page);
 	set_page_private(page, info);
 	atomic_inc(&page->_count);
@@ -77,15 +77,15 @@ static void get_page_bootmem(unsigned lo
  * so use __ref to tell modpost not to generate a warning */
 void __ref put_page_bootmem(struct page *page)
 {
-	int type;
+	long type;
 
-	type = atomic_read(&page->_mapcount);
-	BUG_ON(type >= -1);
+	type = (long) page->lru.next;
+	BUG_ON(type < NODE_INFO || type > SECTION_INFO);
 
 	if (atomic_dec_return(&page->_count) == 1) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		reset_page_mapcount(page);
+		INIT_LIST_HEAD(&page->lru);
 		__free_pages_bootmem(page, 0);
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -426,8 +426,8 @@ __find_combined_index(unsigned long page
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
  *
- * For recording whether a page is in the buddy system, we use PG_buddy.
- * Setting, clearing, and testing PG_buddy is serialized by zone->lock.
+ * For recording whether a page is in the buddy system, we set ->_mapcount -2.
+ * Setting, clearing, and testing _mapcount -2 is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -460,7 +460,7 @@ static inline int page_is_buddy(struct p
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with PG_buddy. Page's
+ * free pages of length of (1 << order) and marked with _mapcount -2. Page's
  * order is recorded in page_private(page) field.
  * So when we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were   
@@ -5251,7 +5251,6 @@ static struct trace_print_flags pageflag
 	{1UL << PG_swapcache,		"swapcache"	},
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
 	{1UL << PG_reclaim,		"reclaim"	},
-	{1UL << PG_buddy,		"buddy"		},
 	{1UL << PG_swapbacked,		"swapbacked"	},
 	{1UL << PG_unevictable,		"unevictable"	},
 #ifdef CONFIG_MMU
diff --git a/mm/sparse.c b/mm/sparse.c
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -670,10 +670,10 @@ static void __kfree_section_memmap(struc
 static void free_map_bootmem(struct page *page, unsigned long nr_pages)
 {
 	unsigned long maps_section_nr, removing_section_nr, i;
-	int magic;
+	long magic;
 
 	for (i = 0; i < nr_pages; i++, page++) {
-		magic = atomic_read(&page->_mapcount);
+		magic = (long) page->lru.next;
 
 		BUG_ON(magic == NODE_INFO);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
