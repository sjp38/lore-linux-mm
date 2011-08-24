Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D78E6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 09:35:08 -0400 (EDT)
Date: Wed, 24 Aug 2011 15:34:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: tail page refcounting fix #2
Message-ID: <20110824133459.GP23870@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
 <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
 <20110824002717.GI23870@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110824002717.GI23870@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Aug 24, 2011 at 02:27:17AM +0200, Andrea Arcangeli wrote:
> On Wed, Aug 24, 2011 at 02:09:14AM +0200, Andrea Arcangeli wrote:
> > That's an optimization I can look into agreed. I guess I just added
> > one line and not even think too much at optimizing this,
> > split_huge_page isn't in a fast path.
> 
> So this would more or less be the optimization (untested):
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1169,8 +1169,8 @@ static void __split_huge_page_refcount(s
>  		atomic_sub(page_mapcount(page_tail), &page->_count);
>  		BUG_ON(atomic_read(&page->_count) <= 0);
>  		BUG_ON(atomic_read(&page_tail->_count) != 0);
> -		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
> -		atomic_add(page_mapcount(page_tail), &page_tail->_count);
> +		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
> +			   &page_tail->_count);
>  
>  		/* after clearing PageTail the gup refcount can be released */
>  		smp_mb();

So this is a new version incorporating only the above
microoptimization. Unless somebody can guarantee me the atomic_set is
safe in all archs (which requires get_page_unless_zero() running vs C
language page_tail->_count = 1 to provide a deterministic result) I'd
stick with the atomic_add above to be sure.

I think on even on x86 32bit it wouldn't be safe on PPro with OOSTORE
(PPro errata 66, 92) which should also have PSE.

===
Subject: thp: tail page refcounting fix

From: Andrea Arcangeli <aarcange@redhat.com>

Michel while working on the working set estimation code, noticed that calling
get_page_unless_zero() on a random pfn_to_page(random_pfn) wasn't safe, if the
pfn ended up being a tail page of a transparent hugepage under splitting by
__split_huge_page_refcount(). He then found the problem could also
theoretically materialize with page_cache_get_speculative() during the
speculative radix tree lookups that uses get_page_unless_zero() in SMP if the
radix tree page is freed and reallocated and get_user_pages is called on it
before page_cache_get_speculative has a chance to call get_page_unless_zero().

So the best way to fix the problem is to keep page_tail->_count zero at all
times. This will guarantee that get_page_unless_zero() can never succeed on any
tail page. page_tail->_mapcount is guaranteed zero and is unused for all tail
pages of a compound page, so we can simply account the tail page references
there and transfer them to tail_page->_count in __split_huge_page_refcount() (in
addition to the head_page->_mapcount).

While debugging this s/_count/_mapcount/ change I also noticed get_page is
called by direct-io.c on pages returned by get_user_pages. That wasn't entirely
safe because the two atomic_inc in get_page weren't atomic. As opposed other
get_user_page users like secondary-MMU page fault to establish the shadow
pagetables would never call any superflous get_page after get_user_page
returns. It's safer to make get_page universally safe for tail pages and to use
get_page_foll() within follow_page (inside get_user_pages()). get_page_foll()
is safe to do the refcounting for tail pages without taking any locks because
it is run within PT lock protected critical sections (PT lock for pte and
page_table_lock for pmd_trans_huge). The standard get_page() as invoked by
direct-io instead will now take the compound_lock but still only for tail
pages. The direct-io paths are usually I/O bound and the compound_lock is per
THP so very finegrined, so there's no risk of scalability issues with it. A
simple direct-io benchmarks with all lockdep prove locking and spinlock
debugging infrastructure enabled shows identical performance and no overhead.
So it's worth it. Ideally direct-io should stop calling get_page() on pages
returned by get_user_pages(). The spinlock in get_page() is already optimized
away for no-THP builds but doing get_page() on tail pages returned by GUP is
generally a rare operation and usually only run in I/O paths.

This new refcounting on page_tail->_mapcount in addition to avoiding new RCU
critical sections will also allow the working set estimation code to work
without any further complexity associated to the tail page refcounting
with THP.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Michel Lespinasse <walken@google.com>
---

diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -22,8 +22,9 @@ static inline void get_huge_page_tail(st
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(page_mapcount(page) < 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	atomic_inc(&page->_mapcount);
 }
 
 /*
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -114,8 +114,9 @@ static inline void get_huge_page_tail(st
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(page_mapcount(page) < 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	atomic_inc(&page->_mapcount);
 }
 
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -355,38 +355,80 @@ static inline struct page *compound_head
 	return page;
 }
 
+/*
+ * The atomic page->_mapcount, like _count, starts from -1:
+ * so that transitions both from it and to it can be tracked,
+ * using atomic_inc_and_test and atomic_add_negative(-1).
+ */
+static inline void reset_page_mapcount(struct page *page)
+{
+	atomic_set(&(page)->_mapcount, -1);
+}
+
+static inline int page_mapcount(struct page *page)
+{
+	return atomic_read(&(page)->_mapcount) + 1;
+}
+
 static inline int page_count(struct page *page)
 {
 	return atomic_read(&compound_head(page)->_count);
 }
 
-static inline void get_page(struct page *page)
+static inline void __get_page_tail_foll(struct page *page)
 {
 	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count. Only if
-	 * we're getting a tail page, the elevated page->_count is
-	 * required only in the head page, so for tail pages the
-	 * bugcheck only verifies that the page->_count isn't
-	 * negative.
+	 * If we're getting a tail page, the elevated page->_count is
+	 * required only in the head page and we will elevate the head
+	 * page->_count and tail page->_mapcount.
+	 *
+	 * We elevate page_tail->_mapcount for tail pages to force
+	 * page_tail->_count to be zero at all times to avoid getting
+	 * false positives from get_page_unless_zero() with
+	 * speculative page access (like in
+	 * page_cache_get_speculative()) on tail pages.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
-	atomic_inc(&page->_count);
-	/*
-	 * Getting a tail page will elevate both the head and tail
-	 * page->_count(s).
-	 */
-	if (unlikely(PageTail(page))) {
+	VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	VM_BUG_ON(page_mapcount(page) < 0);
+	atomic_inc(&page->first_page->_count);
+	atomic_inc(&page->_mapcount);
+}
+
+extern int __get_page_tail(struct page *page);
+
+static inline void get_page_foll(struct page *page)
+{
+	if (unlikely(PageTail(page)))
 		/*
 		 * This is safe only because
 		 * __split_huge_page_refcount can't run under
-		 * get_page().
+		 * get_page_foll() because we hold the proper PT lock.
 		 */
-		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
-		atomic_inc(&page->first_page->_count);
+		__get_page_tail_foll(page);
+	else {
+		/*
+		 * Getting a normal page or the head of a compound page
+		 * requires to already have an elevated page->_count.
+		 */
+		VM_BUG_ON(atomic_read(&page->_count) <= 0);
+		atomic_inc(&page->_count);
 	}
 }
 
+static inline void get_page(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		if (__get_page_tail(page))
+			return;
+	/*
+	 * Getting a normal page or the head of a compound page
+	 * requires to already have an elevated page->_count.
+	 */
+	VM_BUG_ON(atomic_read(&page->_count) <= 0);
+	atomic_inc(&page->_count);
+}
+
 static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
@@ -803,21 +845,6 @@ static inline pgoff_t page_index(struct 
 }
 
 /*
- * The atomic page->_mapcount, like _count, starts from -1:
- * so that transitions both from it and to it can be tracked,
- * using atomic_inc_and_test and atomic_add_negative(-1).
- */
-static inline void reset_page_mapcount(struct page *page)
-{
-	atomic_set(&(page)->_mapcount, -1);
-}
-
-static inline int page_mapcount(struct page *page)
-{
-	return atomic_read(&(page)->_mapcount) + 1;
-}
-
-/*
  * Return true if this page is mapped into pagetables.
  */
 static inline int page_mapped(struct page *page)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -989,7 +989,7 @@ struct page *follow_trans_huge_pmd(struc
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
 	VM_BUG_ON(!PageCompound(page));
 	if (flags & FOLL_GET)
-		get_page(page);
+		get_page_foll(page);
 
 out:
 	return page;
@@ -1164,11 +1164,13 @@ static void __split_huge_page_refcount(s
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 
-		/* tail_page->_count cannot change */
-		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
-		BUG_ON(page_count(page) <= 0);
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		BUG_ON(atomic_read(&page_tail->_count) <= 0);
+		/* tail_page->_mapcount cannot change */
+		BUG_ON(page_mapcount(page_tail) < 0);
+		atomic_sub(page_mapcount(page_tail), &page->_count);
+		BUG_ON(atomic_read(&page->_count) <= 0);
+		BUG_ON(atomic_read(&page_tail->_count) != 0);
+		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
+			   &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1206,7 +1208,6 @@ static void __split_huge_page_refcount(s
 		 * status is achieved setting a reserved bit in the
 		 * pmd, not by clearing the present bit.
 		*/
-		BUG_ON(page_mapcount(page_tail));
 		page_tail->_mapcount = page->_mapcount;
 
 		BUG_ON(page_tail->mapping);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1514,7 +1514,7 @@ split_fallthrough:
 	}
 
 	if (flags & FOLL_GET)
-		get_page(page);
+		get_page_foll(page);
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -128,9 +128,10 @@ static void put_compound_page(struct pag
 			if (put_page_testzero(page_head))
 				VM_BUG_ON(1);
 			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(atomic_read(&page->_count) <= 0);
-			atomic_dec(&page->_count);
+			VM_BUG_ON(page_mapcount(page) <= 0);
+			atomic_dec(&page->_mapcount);
 			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+			VM_BUG_ON(atomic_read(&page->_count) != 0);
 			compound_unlock_irqrestore(page_head, flags);
 			if (put_page_testzero(page_head)) {
 				if (PageHead(page_head))
@@ -160,6 +161,32 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+int __get_page_tail(struct page *page)
+{
+	/*
+	 * This takes care of get_page() if run on a tail page
+	 * returned by one of the get_user_pages/follow_page variants.
+	 * get_user_pages/follow_page itself doesn't need the compound
+	 * lock because it runs __get_page_tail_foll() under the
+	 * proper PT lock that already serializes against
+	 * split_huge_page().
+	 */
+	unsigned long flags;
+	int got = 0;
+	struct page *head_page = compound_trans_head(page);
+	if (likely(page != head_page)) {
+		flags = compound_lock_irqsave(head_page);
+		/* here __split_huge_page_refcount won't run anymore */
+		if (likely(PageTail(page))) {
+			__get_page_tail_foll(page);
+			got = 1;
+		}
+		compound_unlock_irqrestore(head_page, flags);
+	}
+	return got;
+}
+EXPORT_SYMBOL(__get_page_tail);
+
 /**
  * put_pages_list() - release a list of pages
  * @pages: list of pages threaded on page->lru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
