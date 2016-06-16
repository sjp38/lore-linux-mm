Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1B16B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:22:53 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v78so36932174ywa.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:22:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c82si25614230qkj.237.2016.06.16.02.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:22:52 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH] Revert "mm: rename _count, field of the struct page, to _refcount"
Date: Thu, 16 Jun 2016 11:22:46 +0200
Message-Id: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

_count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
it is definitely possible to fix this particular tool I'm not sure about
other tools which might be doing the same.

I suggest we remember the "we don't break userspace" rule and revert for
4.7 while it's not too late.

This is a partial revert, useful hunks in drivers which do
page_ref_{sub,add,inc} instead of open coded atomic_* operations stay.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 Documentation/vm/transhuge.txt   | 10 +++++-----
 arch/tile/mm/init.c              |  2 +-
 drivers/block/aoe/aoecmd.c       |  2 +-
 drivers/hwtracing/intel_th/msu.c |  2 +-
 fs/proc/page.c                   |  2 +-
 include/linux/mm.h               |  2 +-
 include/linux/mm_types.h         | 14 +++++---------
 include/linux/page_ref.h         | 26 +++++++++++++-------------
 include/linux/pagemap.h          |  8 ++++----
 kernel/kexec_core.c              |  2 +-
 mm/huge_memory.c                 |  4 ++--
 mm/internal.h                    |  2 +-
 mm/page_alloc.c                  |  4 ++--
 mm/slub.c                        |  4 ++--
 mm/vmscan.c                      |  4 ++--
 15 files changed, 42 insertions(+), 46 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 7c871d6..75c774c 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -394,9 +394,9 @@ hugepage natively. Once finished you can drop the page table lock.
 Refcounting on THP is mostly consistent with refcounting on other compound
 pages:
 
-  - get_page()/put_page() and GUP operate in head page's ->_refcount.
+  - get_page()/put_page() and GUP operate in head page's ->_count.
 
-  - ->_refcount in tail pages is always zero: get_page_unless_zero() never
+  - ->_count in tail pages is always zero: get_page_unless_zero() never
     succeed on tail pages.
 
   - map/unmap of the pages with PTE entry increment/decrement ->_mapcount
@@ -426,15 +426,15 @@ requests to split pinned huge page: it expects page count to be equal to
 sum of mapcount of all sub-pages plus one (split_huge_page caller must
 have reference for head page).
 
-split_huge_page uses migration entries to stabilize page->_refcount and
+split_huge_page uses migration entries to stabilize page->_count and
 page->_mapcount.
 
 We safe against physical memory scanners too: the only legitimate way
 scanner can get reference to a page is get_page_unless_zero().
 
-All tail pages have zero ->_refcount until atomic_add(). This prevents the
+All tail pages have zero ->_count until atomic_add(). This prevents the
 scanner from getting a reference to the tail page up to that point. After the
-atomic_add() we don't care about the ->_refcount value.  We already known how
+atomic_add() we don't care about the ->_count value.  We already known how
 many references should be uncharged from the head page.
 
 For head page get_page_unless_zero() will succeed and we don't mind. It's
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index adce254..a0582b7 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -679,7 +679,7 @@ static void __init init_free_pfn_range(unsigned long start, unsigned long end)
 			 * Hacky direct set to avoid unnecessary
 			 * lock take/release for EVERY page here.
 			 */
-			p->_refcount.counter = 0;
+			p->_count.counter = 0;
 			p->_mapcount.counter = -1;
 		}
 		init_page_count(page);
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index d597e43..437b3a8 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -861,7 +861,7 @@ rqbiocnt(struct request *r)
  * discussion.
  *
  * We cannot use get_page in the workaround, because it insists on a
- * positive page count as a precondition.  So we use _refcount directly.
+ * positive page count as a precondition.  So we use _count directly.
  */
 static void
 bio_pageinc(struct bio *bio)
diff --git a/drivers/hwtracing/intel_th/msu.c b/drivers/hwtracing/intel_th/msu.c
index e8d55a1..0974090 100644
--- a/drivers/hwtracing/intel_th/msu.c
+++ b/drivers/hwtracing/intel_th/msu.c
@@ -1172,7 +1172,7 @@ static void msc_mmap_close(struct vm_area_struct *vma)
 	if (!atomic_dec_and_mutex_lock(&msc->mmap_count, &msc->buf_mutex))
 		return;
 
-	/* drop page _refcounts */
+	/* drop page _counts */
 	for (pg = 0; pg < msc->nr_pages; pg++) {
 		struct page *page = msc_buffer_get_page(msc, pg);
 
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 3ecd445..712f1b9 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -142,7 +142,7 @@ u64 stable_page_flags(struct page *page)
 
 
 	/*
-	 * Caveats on high order pages: page->_refcount will only be set
+	 * Caveats on high order pages: page->_count will only be set
 	 * -1 on the head page; SLUB/SLQB do the same for PG_slab;
 	 * SLOB won't set PG_slab at all on compound pages.
 	 */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5df5feb..574e055 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -739,7 +739,7 @@ static inline void get_page(struct page *page)
 	page = compound_head(page);
 	/*
 	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_refcount.
+	 * requires to already have an elevated page->_count.
 	 */
 	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
 	page_ref_inc(page);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ca3e517..dd3e765 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -74,9 +74,9 @@ struct page {
 			unsigned long counters;
 #else
 			/*
-			 * Keep _refcount separate from slub cmpxchg_double
-			 * data.  As the rest of the double word is protected by
-			 * slab_lock but _refcount is not.
+			 * Keep _count separate from slub cmpxchg_double data.
+			 * As the rest of the double word is protected by
+			 * slab_lock but _count is not.
 			 */
 			unsigned counters;
 #endif
@@ -98,11 +98,7 @@ struct page {
 					};
 					int units;	/* SLOB */
 				};
-				/*
-				 * Usage count, *USE WRAPPER FUNCTION*
-				 * when manual accounting. See page_ref.h
-				 */
-				atomic_t _refcount;
+				atomic_t _count;		/* Usage count, see below. */
 			};
 			unsigned int active;	/* SLAB */
 		};
@@ -253,7 +249,7 @@ struct page_frag_cache {
 	__u32 offset;
 #endif
 	/* we maintain a pagecount bias, so that we dont dirty cache line
-	 * containing page->_refcount every time we allocate a fragment.
+	 * containing page->_count every time we allocate a fragment.
 	 */
 	unsigned int		pagecnt_bias;
 	bool pfmemalloc;
diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 8b5e0a9..e596d5d9 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -63,17 +63,17 @@ static inline void __page_ref_unfreeze(struct page *page, int v)
 
 static inline int page_ref_count(struct page *page)
 {
-	return atomic_read(&page->_refcount);
+	return atomic_read(&page->_count);
 }
 
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_refcount);
+	return atomic_read(&compound_head(page)->_count);
 }
 
 static inline void set_page_count(struct page *page, int v)
 {
-	atomic_set(&page->_refcount, v);
+	atomic_set(&page->_count, v);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
 		__page_ref_set(page, v);
 }
@@ -89,35 +89,35 @@ static inline void init_page_count(struct page *page)
 
 static inline void page_ref_add(struct page *page, int nr)
 {
-	atomic_add(nr, &page->_refcount);
+	atomic_add(nr, &page->_count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, nr);
 }
 
 static inline void page_ref_sub(struct page *page, int nr)
 {
-	atomic_sub(nr, &page->_refcount);
+	atomic_sub(nr, &page->_count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -nr);
 }
 
 static inline void page_ref_inc(struct page *page)
 {
-	atomic_inc(&page->_refcount);
+	atomic_inc(&page->_count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, 1);
 }
 
 static inline void page_ref_dec(struct page *page)
 {
-	atomic_dec(&page->_refcount);
+	atomic_dec(&page->_count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -1);
 }
 
 static inline int page_ref_sub_and_test(struct page *page, int nr)
 {
-	int ret = atomic_sub_and_test(nr, &page->_refcount);
+	int ret = atomic_sub_and_test(nr, &page->_count);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -nr, ret);
@@ -126,7 +126,7 @@ static inline int page_ref_sub_and_test(struct page *page, int nr)
 
 static inline int page_ref_dec_and_test(struct page *page)
 {
-	int ret = atomic_dec_and_test(&page->_refcount);
+	int ret = atomic_dec_and_test(&page->_count);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -1, ret);
@@ -135,7 +135,7 @@ static inline int page_ref_dec_and_test(struct page *page)
 
 static inline int page_ref_dec_return(struct page *page)
 {
-	int ret = atomic_dec_return(&page->_refcount);
+	int ret = atomic_dec_return(&page->_count);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
 		__page_ref_mod_and_return(page, -1, ret);
@@ -144,7 +144,7 @@ static inline int page_ref_dec_return(struct page *page)
 
 static inline int page_ref_add_unless(struct page *page, int nr, int u)
 {
-	int ret = atomic_add_unless(&page->_refcount, nr, u);
+	int ret = atomic_add_unless(&page->_count, nr, u);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
 		__page_ref_mod_unless(page, nr, ret);
@@ -153,7 +153,7 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
 
 static inline int page_ref_freeze(struct page *page, int count)
 {
-	int ret = likely(atomic_cmpxchg(&page->_refcount, count, 0) == count);
+	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_freeze))
 		__page_ref_freeze(page, count, ret);
@@ -165,7 +165,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON_PAGE(page_count(page) != 0, page);
 	VM_BUG_ON(count == 0);
 
-	atomic_set(&page->_refcount, count);
+	atomic_set(&page->_count, count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
 		__page_ref_unfreeze(page, count);
 }
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9735410..ce53eff 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -90,12 +90,12 @@ void release_pages(struct page **pages, int nr, bool cold);
 
 /*
  * speculatively take a reference to a page.
- * If the page is free (_refcount == 0), then _refcount is untouched, and 0
- * is returned. Otherwise, _refcount is incremented by 1 and 1 is returned.
+ * If the page is free (_count == 0), then _count is untouched, and 0
+ * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
  *
  * This function must be called inside the same rcu_read_lock() section as has
  * been used to lookup the page in the pagecache radix-tree (or page table):
- * this allows allocators to use a synchronize_rcu() to stabilize _refcount.
+ * this allows allocators to use a synchronize_rcu() to stabilize _count.
  *
  * Unless an RCU grace period has passed, the count of all pages coming out
  * of the allocator must be considered unstable. page_count may return higher
@@ -111,7 +111,7 @@ void release_pages(struct page **pages, int nr, bool cold);
  * 2. conditionally increment refcount
  * 3. check the page is still in pagecache (if no, goto 1)
  *
- * Remove-side that cares about stability of _refcount (eg. reclaim) has the
+ * Remove-side that cares about stability of _count (eg. reclaim) has the
  * following (with tree_lock held for write):
  * A. atomically check refcount is correct and set it to 0 (atomic_cmpxchg)
  * B. remove page from pagecache
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 56b3ed0..9b3744f 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1409,7 +1409,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_STRUCT_SIZE(list_head);
 	VMCOREINFO_SIZE(nodemask_t);
 	VMCOREINFO_OFFSET(page, flags);
-	VMCOREINFO_OFFSET(page, _refcount);
+	VMCOREINFO_OFFSET(page, _count);
 	VMCOREINFO_OFFSET(page, mapping);
 	VMCOREINFO_OFFSET(page, lru);
 	VMCOREINFO_OFFSET(page, _mapcount);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9ed5853..a73fa7a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3123,7 +3123,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	VM_BUG_ON_PAGE(page_ref_count(page_tail) != 0, page_tail);
 
 	/*
-	 * tail_page->_refcount is zero and not changing from under us. But
+	 * tail_page->_count is zero and not changing from under us. But
 	 * get_page_unless_zero() may be running from under us on the
 	 * tail_page. If we used atomic_set() below instead of atomic_inc(), we
 	 * would then run atomic_set() concurrently with
@@ -3350,7 +3350,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (mlocked)
 		lru_add_drain();
 
-	/* Prevent deferred_split_scan() touching ->_refcount */
+	/* Prevent deferred_split_scan() touching ->_count */
 	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
diff --git a/mm/internal.h b/mm/internal.h
index a37e5b6..3711310d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -58,7 +58,7 @@ static inline unsigned long ra_submit(struct file_ra_state *ra,
 }
 
 /*
- * Turn a non-refcounted page (->_refcount == 0) into refcounted with
+ * Turn a non-refcounted page (->_count == 0) into refcounted with
  * a count of one.
  */
 static inline void set_page_refcounted(struct page *page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..82481d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -912,7 +912,7 @@ static void free_pages_check_bad(struct page *page)
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(page_ref_count(page) != 0))
-		bad_reason = "nonzero _refcount";
+		bad_reason = "nonzero _count";
 	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
 		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
 		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
@@ -7213,7 +7213,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * We can't use page_count without pin a page
 		 * because another CPU can free compound page.
 		 * This check already skips compound tails of THP
-		 * because their page->_refcount is zero at all time.
+		 * because their page->_count is zero at all time.
 		 */
 		if (!page_ref_count(page)) {
 			if (PageBuddy(page))
diff --git a/mm/slub.c b/mm/slub.c
index 825ff45..72d0f96 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -329,8 +329,8 @@ static inline void set_page_slub_counters(struct page *page, unsigned long count
 	tmp.counters = counters_new;
 	/*
 	 * page->counters can cover frozen/inuse/objects as well
-	 * as page->_refcount.  If we assign to ->counters directly
-	 * we run the risk of losing updates to page->_refcount, so
+	 * as page->_count.  If we assign to ->counters directly
+	 * we run the risk of losing updates to page->_count, so
 	 * be careful and only assign to the fields we need.
 	 */
 	page->frozen  = tmp.frozen;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4a2f45..074fe2e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -633,7 +633,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	 *
 	 * Reversing the order of the tests ensures such a situation cannot
 	 * escape unnoticed. The smp_rmb is needed to ensure the page->flags
-	 * load is not satisfied before that of page->_refcount.
+	 * load is not satisfied before that of page->_count.
 	 *
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
@@ -1716,7 +1716,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
  *
- * The downside is that we have to touch page->_refcount against each page.
+ * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
  */
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
