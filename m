Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D2436B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 13:37:37 -0400 (EDT)
Date: Fri, 3 Jun 2011 19:37:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110603173707.GL2802@random.random>
References: <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110531143734.GB13418@barrios-laptop>
 <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
 <20110602223201.GH2802@random.random>
 <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 03, 2011 at 08:01:44AM +0900, Minchan Kim wrote:
> Do you want this? (it's almost pseudo-code)

Yes that's good idea so we at least take into account if we isolated
something big, and it's pointless to insist wasting CPU on the tail
pages and even trace a fail because of tail pages after it.

I introduced a __page_count to increase readability. It's still
hackish to work on subpages in vmscan.c but at least I added a comment
and until we serialize destroy_compound_page vs compound_head, I guess
there's no better way. I didn't attempt to add out of order
serialization similar to what exists for split_huge_page vs
compound_trans_head yet, as the page can be allocated or go away from
under us, in split_huge_page vs compound_trans_head it's simpler
because both callers are required to hold a pin on the page so the
page can't go be reallocated and destroyed under it.

===
Subject: mm: no page_count without a page pin

From: Andrea Arcangeli <aarcange@redhat.com>

It's unsafe to run page_count during the physical pfn scan because
compound_head could trip on a dangling pointer when reading page->first_page if
the compound page is being freed by another CPU. Also properly take into
account if we isolated a compound page during the scan and break the loop if
we've isolated enoguh. Introduce __page_count to cleanup some atomic_read from
&page->_count in common code to cleanup.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/mm/gup.c                        |    2 -
 arch/powerpc/platforms/512x/mpc512x_shared.c |    2 -
 arch/x86/mm/gup.c                            |    2 -
 fs/nilfs2/page.c                             |    2 -
 include/linux/mm.h                           |   13 +++++++---
 mm/huge_memory.c                             |    4 +--
 mm/internal.h                                |    2 -
 mm/page_alloc.c                              |    6 ++--
 mm/swap.c                                    |    4 +--
 mm/vmscan.c                                  |   33 ++++++++++++++++++++-------
 10 files changed, 46 insertions(+), 24 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1047,7 +1047,7 @@ static unsigned long isolate_lru_pages(u
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
 		unsigned long pfn;
-		unsigned long end_pfn;
+		unsigned long start_pfn, end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
 
@@ -1087,9 +1087,9 @@ static unsigned long isolate_lru_pages(u
 		 */
 		zone_id = page_zone_id(page);
 		page_pfn = page_to_pfn(page);
-		pfn = page_pfn & ~((1 << order) - 1);
+		start_pfn = page_pfn & ~((1 << order) - 1);
 		end_pfn = pfn + (1 << order);
-		for (; pfn < end_pfn; pfn++) {
+		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
 
 			/* The target page is in the block, ignore it. */
@@ -1116,16 +1116,33 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				unsigned int isolated_pages;
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
-				nr_taken += hpage_nr_pages(page);
-				nr_lumpy_taken++;
+				isolated_pages = hpage_nr_pages(page);
+				nr_taken += isolated_pages;
+				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
-					nr_lumpy_dirty++;
+					nr_lumpy_dirty += isolated_pages;
 				scan++;
+				pfn += isolated_pages-1;
+				VM_BUG_ON(!isolated_pages);
+				VM_BUG_ON(isolated_pages > MAX_ORDER_NR_PAGES);
 			} else {
-				/* the page is freed already. */
-				if (!page_count(cursor_page))
+				/*
+				 * Check if the page is freed already.
+				 *
+				 * We can't use page_count() as that
+				 * requires compound_head and we don't
+				 * have a pin on the page here. If a
+				 * page is tail, we may or may not
+				 * have isolated the head, so assume
+				 * it's not free, it'd be tricky to
+				 * track the head status without a
+				 * page pin.
+				 */
+				if (!PageTail(cursor_page) &&
+				    !__page_count(&cursor_page))
 					continue;
 				break;
 			}
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -271,7 +271,7 @@ struct inode;
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	VM_BUG_ON(__page_count(page) == 0);
 	return atomic_dec_and_test(&page->_count);
 }
 
@@ -355,9 +355,14 @@ static inline struct page *compound_head
 	return page;
 }
 
+static inline int __page_count(struct page *page)
+{
+	return atomic_read(&page->_count);
+}
+
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_count);
+	return __page_count(compound_head(page));
 }
 
 static inline void get_page(struct page *page)
@@ -370,7 +375,7 @@ static inline void get_page(struct page
 	 * bugcheck only verifies that the page->_count isn't
 	 * negative.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
+	VM_BUG_ON(__page_count(page) < !PageTail(page));
 	atomic_inc(&page->_count);
 	/*
 	 * Getting a tail page will elevate both the head and tail
@@ -382,7 +387,7 @@ static inline void get_page(struct page
 		 * __split_huge_page_refcount can't run under
 		 * get_page().
 		 */
-		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+		VM_BUG_ON(__page_count(page->first_page) <= 0);
 		atomic_inc(&page->first_page->_count);
 	}
 }
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1203,10 +1203,10 @@ static void __split_huge_page_refcount(s
 		struct page *page_tail = page + i;
 
 		/* tail_page->_count cannot change */
-		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
+		atomic_sub(__page_count(page_tail), &page->_count);
 		BUG_ON(page_count(page) <= 0);
 		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		BUG_ON(atomic_read(&page_tail->_count) <= 0);
+		BUG_ON(__page_count(page_tail) <= 0);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -22,7 +22,7 @@ static inline void get_huge_page_tail(st
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
+	VM_BUG_ON(__page_count(page) < 0);
 	atomic_inc(&page->_count);
 }
 
--- a/arch/powerpc/platforms/512x/mpc512x_shared.c
+++ b/arch/powerpc/platforms/512x/mpc512x_shared.c
@@ -200,7 +200,7 @@ static inline void mpc512x_free_bootmem(
 {
 	__ClearPageReserved(page);
 	BUG_ON(PageTail(page));
-	BUG_ON(atomic_read(&page->_count) > 1);
+	BUG_ON(__page_count(page) > 1);
 	atomic_set(&page->_count, 1);
 	__free_page(page);
 	totalram_pages++;
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -114,7 +114,7 @@ static inline void get_huge_page_tail(st
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
+	VM_BUG_ON(__page_count(page) < 0);
 	atomic_inc(&page->_count);
 }
 
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -181,7 +181,7 @@ void nilfs_page_bug(struct page *page)
 
 	printk(KERN_CRIT "NILFS_PAGE_BUG(%p): cnt=%d index#=%llu flags=0x%lx "
 	       "mapping=%p ino=%lu\n",
-	       page, atomic_read(&page->_count),
+	       page, __page_count(page),
 	       (unsigned long long)page->index, page->flags, m, ino);
 
 	if (page_has_buffers(page)) {
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -28,7 +28,7 @@ static inline void set_page_count(struct
 static inline void set_page_refcounted(struct page *page)
 {
 	VM_BUG_ON(PageTail(page));
-	VM_BUG_ON(atomic_read(&page->_count));
+	VM_BUG_ON(__page_count(page));
 	set_page_count(page, 1);
 }
 
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -568,7 +568,7 @@ static inline int free_pages_check(struc
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(atomic_read(&page->_count) != 0) |
+		(__page_count(page) != 0) |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
 		(mem_cgroup_bad_page_check(page)))) {
 		bad_page(page);
@@ -758,7 +758,7 @@ static inline int check_new_page(struct
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(atomic_read(&page->_count) != 0)  |
+		(__page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
 		(mem_cgroup_bad_page_check(page)))) {
 		bad_page(page);
@@ -5739,7 +5739,7 @@ void dump_page(struct page *page)
 {
 	printk(KERN_ALERT
 	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
-		page, atomic_read(&page->_count), page_mapcount(page),
+		page, __page_count(page), page_mapcount(page),
 		page->mapping, page->index);
 	dump_page_flags(page->flags);
 	mem_cgroup_print_bad_page(page);
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -128,9 +128,9 @@ static void put_compound_page(struct pag
 			if (put_page_testzero(page_head))
 				VM_BUG_ON(1);
 			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(atomic_read(&page->_count) <= 0);
+			VM_BUG_ON(__page_count(page) <= 0);
 			atomic_dec(&page->_count);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+			VM_BUG_ON(__page_count(page_head) <= 0);
 			compound_unlock_irqrestore(page_head, flags);
 			if (put_page_testzero(page_head)) {
 				if (PageHead(page_head))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
