Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C7B4B6B019A
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 12:55:48 -0400 (EDT)
Date: Thu, 8 Sep 2011 18:51:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: tail page refcounting fix #6
Message-ID: <20110908165118.GC24539@redhat.com>
References: <20110824002717.GI23870@redhat.com>
 <20110824133459.GP23870@redhat.com>
 <20110826062436.GA5847@google.com>
 <20110826161048.GE23870@redhat.com>
 <20110826185430.GA2854@redhat.com>
 <20110827094152.GA16402@google.com>
 <20110827173421.GA2967@redhat.com>
 <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
 <20110901152417.GF10779@redhat.com>
 <20110901170353.6f92b50f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110901170353.6f92b50f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Sep 01, 2011 at 05:03:53PM -0700, Andrew Morton wrote:
> The patch overall takes the x86_64 allmodconfig text size of
> arch/x86/mm/gup.o, mm/huge_memory.o, mm/memory.o and mm/swap.o from a
> total of 85059 bytes up to 85973.  That's quite a lot of bloat for a
> pretty small patch.
> 
> I'm suspecting that most of this is due to the new inlined
> get_page_foll(), which is large enough to squish an elephant.  Could
> you please take a look at reducing this impact?

It can't be get_page_foll, it's called only twice... apparently the
change to get_page is the cause of this.

The below is done with DEBUG_VM=n (we don't care that much about
DEBUG_VM that shouldn't be used by any distro and it's ok if it's a
big larger) and without gcc -Os (i.e. CONFIG_CC_OPTIMIZE_FOR_SIZE=n
which I think is the best setting, I don't trust -Os to be optimal).

before:

make-distcc -j32 arch/x86/mm/gup.o mm/huge_memory.o mm/memory.o; objdump -h -j .text mm/huge_memory.o mm/memory.o arch/x86/mm/gup.o|grep ' .text'| awk '{ print $3 }' | (x=0; while read i; do x=`expr $x + $[0x$i]`; done; echo $x)

39314

after:

39474

If I put get_page_foll out of line (i.e. moving it from mm/internal.h
to mm/swap.c):

39410

If I put get_page out of line and I keep get_page_foll in line:

39042

I tried to recraft get_page in various ways but gcc always builds it
with 39474 size.. and in fact even worse if I remove the unlikely
(even tried with likely and goto to jump from the slow path into the
fast path to do atomic_inc, it didn't change a single byte).

So it's sad but I'm afraid we'll have to live with the code bloat
unless we want to issue a "call+branch+lock incl+ret" instead of just
a branch+lock incl.

Ideally the larger code size should be out of line so I don't think
it's a problem other than for the wasted bytes of ram and disk. (but
hey it expands all over the vmlinux exactly because it's get_page so
it's more than just an hundred bytes). It's certainly better to waste
some kbyte regardless of the number of pages initialized by the
kernel, than to run slower.

> > +/*
> > + * The atomic page->_mapcount, starts from -1: so that transitions
> > + * both from it and to it can be tracked, using atomic_inc_and_test
> > + * and atomic_add_negative(-1).
> > + */
> > +static inline void reset_page_mapcount(struct page *page)
> 
> I think we should have originally named this page_mapcount_reset() This
> is extra unimportant as it's a static symbol.

Do you like me to make a patch to rename it? I guess it shall be an
incremental patch or it'll do too many things at the same time.

> >  static inline void get_page(struct page *page)
> >  {
> > +	if (unlikely(PageTail(page)))
> > +		if (likely(__get_page_tail(page)))
> > +			return;
> 
> OK so we still have approximately one test-n-branch in the non-debug
> get_page().

Like before yes.

> >  	 * Getting a normal page or the head of a compound page
> > -	 * requires to already have an elevated page->_count. Only if
> > -	 * we're getting a tail page, the elevated page->_count is
> > -	 * required only in the head page, so for tail pages the
> > -	 * bugcheck only verifies that the page->_count isn't
> > -	 * negative.
> > +	 * requires to already have an elevated page->_count.
> >  	 */
> > -	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
> > +	VM_BUG_ON(atomic_read(&page->_count) <= 0);
> 
> I wonder how many people enable VM_BUG_ON().  We're pretty profligate
> with those things in hot paths.

I think these are good to keep for now. They're VM_ because it's a
fast path so it's ok. the other ones are in __spit_huge_page_refcount
which is not a critical fast path and those aren't VM_ because it's
worth checking we don't get anything wrong there.

> > +int __get_page_tail(struct page *page)
> > +{
> > +	/*
> > +	 * This takes care of get_page() if run on a tail page
> > +	 * returned by one of the get_user_pages/follow_page variants.
> > +	 * get_user_pages/follow_page itself doesn't need the compound
> > +	 * lock because it runs __get_page_tail_foll() under the
> > +	 * proper PT lock that already serializes against
> > +	 * split_huge_page().
> > +	 */
> > +	unsigned long flags;
> > +	int got = 0;
> 
> Could be a bool if you like that sort of thing..

I like it. I just didn't think of using it.

> > +	struct page *page_head = compound_trans_head(page);
> 
> Missing newline here

Hmm ok.

> > +	if (likely(page != page_head && get_page_unless_zero(page_head))) {
> > +		/*
> > +		 * page_head wasn't a dangling pointer but it
> > +		 * may not be a head page anymore by the time
> > +		 * we obtain the lock. That is ok as long as it
> > +		 * can't be freed from under us.
> > +		 */
> > +		flags = compound_lock_irqsave(page_head);
> > +		/* here __split_huge_page_refcount won't run anymore */
> > +		if (likely(PageTail(page))) {
> > +			__get_page_tail_foll(page, false);
> > +			got = 1;
> > +		}
> > +		compound_unlock_irqrestore(page_head, flags);
> > +		if (unlikely(!got))
> > +			put_page(page_head);
> > +	}
> > +	return got;
> > +}
> > +EXPORT_SYMBOL(__get_page_tail);
> 
> Ordinarily I'd squeak about a global, exported-to-modules function
> which is undocumented.  But this one is internal to get_page(), so it's
> less necessary.
> 
> Still, documenting at least the return value (the "why" rather than the
> "what") would make get_page() more understandable.

I think it's good idea to document it should not ever be called and
it's meant only to be called only by get_page.

Thanks a lot for the review. It's unfortunate I didn't find a way to
shrink the .text without putting get_page out of line with this logic,
this is the reason of the delay in the answer but if somebody has
better ideas let me know...

Here a new version with this incremental diff:

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -376,7 +376,7 @@ static inline int page_count(struct page
 	return atomic_read(&compound_head(page)->_count);
 }
 
-extern int __get_page_tail(struct page *page);
+extern bool __get_page_tail(struct page *page);
 
 static inline void get_page(struct page *page)
 {
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -59,6 +59,11 @@ static inline void __get_page_tail_foll(
 	atomic_inc(&page->_mapcount);
 }
 
+/*
+ * This is meant to be called as the FOLL_GET operation of
+ * follow_page() and it must be called while holding the proper PT
+ * lock while the pte (or pmd_trans_huge) is still mapping the page.
+ */
 static inline void get_page_foll(struct page *page)
 {
 	if (unlikely(PageTail(page)))
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -79,6 +79,7 @@ static void put_compound_page(struct pag
 	if (unlikely(PageTail(page))) {
 		/* __split_huge_page_refcount can run under us */
 		struct page *page_head = compound_trans_head(page);
+
 		if (likely(page != page_head &&
 			   get_page_unless_zero(page_head))) {
 			unsigned long flags;
@@ -143,7 +144,11 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
-int __get_page_tail(struct page *page)
+/*
+ * This function is exported but must not be called by anything other
+ * than get_page(). It implements the slow path of get_page().
+ */
+bool __get_page_tail(struct page *page)
 {
 	/*
 	 * This takes care of get_page() if run on a tail page
@@ -154,8 +159,9 @@ int __get_page_tail(struct page *page)
 	 * split_huge_page().
 	 */
 	unsigned long flags;
-	int got = 0;
+	bool got = false;
 	struct page *page_head = compound_trans_head(page);
+
 	if (likely(page != page_head && get_page_unless_zero(page_head))) {
 		/*
 		 * page_head wasn't a dangling pointer but it
@@ -167,7 +173,7 @@ int __get_page_tail(struct page *page)
 		/* here __split_huge_page_refcount won't run anymore */
 		if (likely(PageTail(page))) {
 			__get_page_tail_foll(page, false);
-			got = 1;
+			got = true;
 		}
 		compound_unlock_irqrestore(page_head, flags);
 		if (unlikely(!got))

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
Reviewed-by: Michel Lespinasse <walken@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
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
@@ -356,36 +356,39 @@ static inline struct page *compound_head
 	return page;
 }
 
+/*
+ * The atomic page->_mapcount, starts from -1: so that transitions
+ * both from it and to it can be tracked, using atomic_inc_and_test
+ * and atomic_add_negative(-1).
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
 
+extern bool __get_page_tail(struct page *page);
+
 static inline void get_page(struct page *page)
 {
+	if (unlikely(PageTail(page)))
+		if (likely(__get_page_tail(page)))
+			return;
 	/*
 	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count. Only if
-	 * we're getting a tail page, the elevated page->_count is
-	 * required only in the head page, so for tail pages the
-	 * bugcheck only verifies that the page->_count isn't
-	 * negative.
+	 * requires to already have an elevated page->_count.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
+	VM_BUG_ON(atomic_read(&page->_count) <= 0);
 	atomic_inc(&page->_count);
-	/*
-	 * Getting a tail page will elevate both the head and tail
-	 * page->_count(s).
-	 */
-	if (unlikely(PageTail(page))) {
-		/*
-		 * This is safe only because
-		 * __split_huge_page_refcount can't run under
-		 * get_page().
-		 */
-		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
-		atomic_inc(&page->first_page->_count);
-	}
 }
 
 static inline struct page *virt_to_head_page(const void *x)
@@ -804,21 +807,6 @@ static inline pgoff_t page_index(struct 
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
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -62,10 +62,23 @@ struct page {
 			struct {
 
 				union {
-					atomic_t _mapcount;	/* Count of ptes mapped in mms,
-							 * to show when page is mapped
-							 * & limit reverse map searches.
-							 */
+					/*
+					 * Count of ptes mapped in
+					 * mms, to show when page is
+					 * mapped & limit reverse map
+					 * searches.
+					 *
+					 * Used also for tail pages
+					 * refcounting instead of
+					 * _count. Tail pages cannot
+					 * be mapped and keeping the
+					 * tail page _count zero at
+					 * all times guarantees
+					 * get_page_unless_zero() will
+					 * never succeed on tail
+					 * pages.
+					 */
+					atomic_t _mapcount;
 
 					struct {
 						unsigned inuse:16;
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
@@ -1156,6 +1156,7 @@ static void __split_huge_page_refcount(s
 	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
+	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1164,11 +1165,27 @@ static void __split_huge_page_refcount(s
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 
-		/* tail_page->_count cannot change */
-		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
-		BUG_ON(page_count(page) <= 0);
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		BUG_ON(atomic_read(&page_tail->_count) <= 0);
+		/* tail_page->_mapcount cannot change */
+		BUG_ON(page_mapcount(page_tail) < 0);
+		tail_count += page_mapcount(page_tail);
+		/* check for overflow */
+		BUG_ON(tail_count < 0);
+		BUG_ON(atomic_read(&page_tail->_count) != 0);
+		/*
+		 * tail_page->_count is zero and not changing from
+		 * under us. But get_page_unless_zero() may be running
+		 * from under us on the tail_page. If we used
+		 * atomic_set() below instead of atomic_add(), we
+		 * would then run atomic_set() concurrently with
+		 * get_page_unless_zero(), and atomic_set() is
+		 * implemented in C not using locked ops. spin_unlock
+		 * on x86 sometime uses locked ops because of PPro
+		 * errata 66, 92, so unless somebody can guarantee
+		 * atomic_set() here would be safe on all archs (and
+		 * not only on x86), it's safer to use atomic_add().
+		 */
+		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
+			   &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1186,10 +1203,7 @@ static void __split_huge_page_refcount(s
 				      (1L << PG_uptodate)));
 		page_tail->flags |= (1L << PG_dirty);
 
-		/*
-		 * 1) clear PageTail before overwriting first_page
-		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
-		 */
+		/* clear PageTail before overwriting first_page */
 		smp_wmb();
 
 		/*
@@ -1206,7 +1220,6 @@ static void __split_huge_page_refcount(s
 		 * status is achieved setting a reserved bit in the
 		 * pmd, not by clearing the present bit.
 		*/
-		BUG_ON(page_mapcount(page_tail));
 		page_tail->_mapcount = page->_mapcount;
 
 		BUG_ON(page_tail->mapping);
@@ -1223,6 +1236,8 @@ static void __split_huge_page_refcount(s
 
 		lru_add_page_tail(zone, page, page_tail);
 	}
+	atomic_sub(tail_count, &page->_count);
+	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -37,6 +37,52 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+static inline void __get_page_tail_foll(struct page *page,
+					bool get_page_head)
+{
+	/*
+	 * If we're getting a tail page, the elevated page->_count is
+	 * required only in the head page and we will elevate the head
+	 * page->_count and tail page->_mapcount.
+	 *
+	 * We elevate page_tail->_mapcount for tail pages to force
+	 * page_tail->_count to be zero at all times to avoid getting
+	 * false positives from get_page_unless_zero() with
+	 * speculative page access (like in
+	 * page_cache_get_speculative()) on tail pages.
+	 */
+	VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	VM_BUG_ON(page_mapcount(page) < 0);
+	if (get_page_head)
+		atomic_inc(&page->first_page->_count);
+	atomic_inc(&page->_mapcount);
+}
+
+/*
+ * This is meant to be called as the FOLL_GET operation of
+ * follow_page() and it must be called while holding the proper PT
+ * lock while the pte (or pmd_trans_huge) is still mapping the page.
+ */
+static inline void get_page_foll(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		/*
+		 * This is safe only because
+		 * __split_huge_page_refcount() can't run under
+		 * get_page_foll() because we hold the proper PT lock.
+		 */
+		__get_page_tail_foll(page, true);
+	else {
+		/*
+		 * Getting a normal page or the head of a compound page
+		 * requires to already have an elevated page->_count.
+		 */
+		VM_BUG_ON(atomic_read(&page->_count) <= 0);
+		atomic_inc(&page->_count);
+	}
+}
+
 extern unsigned long highest_memmap_pfn;
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1503,7 +1503,7 @@ split_fallthrough:
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
@@ -78,39 +78,22 @@ static void put_compound_page(struct pag
 {
 	if (unlikely(PageTail(page))) {
 		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = page->first_page;
-		smp_rmb();
-		/*
-		 * If PageTail is still set after smp_rmb() we can be sure
-		 * that the page->first_page we read wasn't a dangling pointer.
-		 * See __split_huge_page_refcount() smp_wmb().
-		 */
-		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
+		struct page *page_head = compound_trans_head(page);
+
+		if (likely(page != page_head &&
+			   get_page_unless_zero(page_head))) {
 			unsigned long flags;
 			/*
-			 * Verify that our page_head wasn't converted
-			 * to a a regular page before we got a
-			 * reference on it.
+			 * page_head wasn't a dangling pointer but it
+			 * may not be a head page anymore by the time
+			 * we obtain the lock. That is ok as long as it
+			 * can't be freed from under us.
 			 */
-			if (unlikely(!PageHead(page_head))) {
-				/* PageHead is cleared after PageTail */
-				smp_rmb();
-				VM_BUG_ON(PageTail(page));
-				goto out_put_head;
-			}
-			/*
-			 * Only run compound_lock on a valid PageHead,
-			 * after having it pinned with
-			 * get_page_unless_zero() above.
-			 */
-			smp_mb();
-			/* page_head wasn't a dangling pointer */
 			flags = compound_lock_irqsave(page_head);
 			if (unlikely(!PageTail(page))) {
 				/* __split_huge_page_refcount run before us */
 				compound_unlock_irqrestore(page_head, flags);
 				VM_BUG_ON(PageHead(page_head));
-			out_put_head:
 				if (put_page_testzero(page_head))
 					__put_single_page(page_head);
 			out_put_single:
@@ -121,16 +104,17 @@ static void put_compound_page(struct pag
 			VM_BUG_ON(page_head != page->first_page);
 			/*
 			 * We can release the refcount taken by
-			 * get_page_unless_zero now that
-			 * split_huge_page_refcount is blocked on the
-			 * compound_lock.
+			 * get_page_unless_zero() now that
+			 * __split_huge_page_refcount() is blocked on
+			 * the compound_lock.
 			 */
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
@@ -160,6 +144,45 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+/*
+ * This function is exported but must not be called by anything other
+ * than get_page(). It implements the slow path of get_page().
+ */
+bool __get_page_tail(struct page *page)
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
+	bool got = false;
+	struct page *page_head = compound_trans_head(page);
+
+	if (likely(page != page_head && get_page_unless_zero(page_head))) {
+		/*
+		 * page_head wasn't a dangling pointer but it
+		 * may not be a head page anymore by the time
+		 * we obtain the lock. That is ok as long as it
+		 * can't be freed from under us.
+		 */
+		flags = compound_lock_irqsave(page_head);
+		/* here __split_huge_page_refcount won't run anymore */
+		if (likely(PageTail(page))) {
+			__get_page_tail_foll(page, false);
+			got = true;
+		}
+		compound_unlock_irqrestore(page_head, flags);
+		if (unlikely(!got))
+			put_page(page_head);
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
