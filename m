Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 047576B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 19:45:36 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: use-once mapped file pages
Date: Tue, 15 Sep 2009 01:46:15 +0200
Message-Id: <1252971975-15218-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

The eviction code directly activates mapped pages (or pages backing a
mapped file while being unmapped themselves) when they have been
referenced from a page table or have their PG_referenced bit set from
read() or the unmap path.

Anonymous pages start out on the active list and have their initial
reference cleared on deactivation.  But mapped file pages start out
referenced on the inactive list and are thus garuanteed to be
activated on first scan.

This has detrimental impact on a common real-world load that maps
subsequent chunks of a file to calculate its checksum (rtorrent
hashing).  All the mapped file pages get activated even though they
are never used again.  Worse, even already unmapped pages get
activated because the file itself is still mapped by the chunk that is
currently hashed.

When dropping into reclaim, the VM has a hard time making progress
with these pages dominating.  And since all mapped pages are treated
equally (i.e. anon pages as well), a major part of the anon working
set is swapped out before the hashing completes as well.

Failing reclaim and swapping show up pretty quickly in decreasing
overall system interactivity, but also in the throughput of the
hashing process itself.

This patch implements a use-once strategy for mapped file pages.

For this purpose, mapped file pages with page table references are not
directly activated at the end of the inactive list anymore but marked
with PG_referenced and sent on another roundtrip on the inactive list.
If such a page comes in again, another page table reference activates
it while the lack thereof leads to its eviction.

The deactivation path does not clear this mark so that a subsequent
page table reference for a page coming from the active list means
reactivation as well.

By re-using the PG_referenced bit, we trade the following behaviour:
clean, unmapped pages that are backing a mapped file and have
PG_referenced set from read() or a page table teardown do no longer
enjoy the same protection as actually mapped and referenced file pages
- they are treated just like other unmapped file pages.  That could be
preserved by opting for a different page flag, but we do not see any
obvious reasons for this special treatment.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/rmap.c   |    3 --
 mm/vmscan.c |  104 +++++++++++++++++++++++++++++++++++++---------------------
 2 files changed, 66 insertions(+), 41 deletions(-)

The effects for the described load are rather dramatic.  rtorrent
hashing a file bigger than memory on an unpatched kernel makes the
system almost unusable while with this patch applied, I don't even
notice it running.

A test that replicates this situation - sha1 hashing a file in mmap'd
chunks while measuring latency of forks - shows the following results
for example:

Hashing a 1.5G file on 900M RAM in chunks of 32M, measuring the
latency of pipe(), fork(), write("done") to pipe (child), read() from
pipe (parent) cycles every two seconds:

	old: latency max=1.403658s mean=0.325557s stddev=0.414985
	hashing 58.655560s thruput=27118344.83b/s

	new: latency max=0.334673s mean=0.059005s stddev=0.083150
	hashing 25.189077s thruput=62914560.00b/s

While this fixes the problem at hand, it has not yet enjoyed broader
testing than running on my desktop and my laptop for a few days.  If
it is going to be accepted, it would be good to have it sit in -mm for
some time.

diff --git a/mm/rmap.c b/mm/rmap.c
index 28aafe2..0c88813 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -508,9 +508,6 @@ int page_referenced(struct page *page,
 {
 	int referenced = 0;
 
-	if (TestClearPageReferenced(page))
-		referenced++;
-
 	*vm_flags = 0;
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4a7b0d5..c8907a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -263,27 +263,6 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -570,6 +549,64 @@ redo:
 	put_page(page);		/* drop ref from isolate */
 }
 
+enum page_reference {
+	PAGEREF_RECLAIM,
+	PAGEREF_KEEP,
+	PAGEREF_ACTIVATE,
+};
+
+static enum page_reference page_check_references(struct scan_control *sc,
+						struct page *page)
+{
+	unsigned long vm_flags;
+	int pte_ref, page_ref;
+
+	pte_ref = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	page_ref = TestClearPageReferenced(page);
+
+	/*
+	 * Lumpy reclaim, ignore references.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		return PAGEREF_RECLAIM;
+
+	/*
+	 * If a PG_mlocked page lost the isolation race,
+	 * try_to_unmap() moves it to unevictable list.
+	 */
+	if (vm_flags & VM_LOCKED)
+		return PAGEREF_RECLAIM;
+
+	/*
+	 * All mapped pages start out with page table references.  To
+	 * keep use-once mapped file pages off the active list, use
+	 * PG_referenced to filter them out.
+	 *
+	 * If we see the page for the first time here, send it on
+	 * another roundtrip on the inactive list.
+	 *
+	 * If we see it again with another page table reference,
+	 * activate it.
+	 *
+	 * The deactivation code won't remove the mark, thus a page
+	 * table reference after deactivation reactivates the page
+	 * again.
+	 */
+	if (pte_ref) {
+		if (PageAnon(page))
+			return PAGEREF_ACTIVATE;
+		SetPageReferenced(page);
+		if (page_ref)
+			return PAGEREF_ACTIVATE;
+		return PAGEREF_KEEP;
+	}
+
+	if (page_ref && PageDirty(page))
+		return PAGEREF_KEEP;
+
+	return PAGEREF_RECLAIM;
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -581,7 +618,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
-	unsigned long vm_flags;
 
 	cond_resched();
 
@@ -590,7 +626,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		int referenced;
 
 		cond_resched();
 
@@ -632,17 +667,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
-		/*
-		 * In active use or really unfreeable?  Activate it.
-		 * If page which have PG_mlocked lost isoltation race,
-		 * try_to_unmap moves it to unevictable list
-		 */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page)
-					&& !(vm_flags & VM_LOCKED))
+		switch (page_check_references(sc, page)) {
+		case PAGEREF_KEEP:
+			goto keep_locked;
+		case PAGEREF_ACTIVATE:
 			goto activate_locked;
+		case PAGEREF_RECLAIM:
+			; /* try to free the page below */
+		}
 
 		/*
 		 * Anonymous process memory has backing store?
@@ -676,8 +708,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
-				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
 			if (!sc->may_writepage)
@@ -1346,9 +1376,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		/* page_referenced clears PageReferenced */
-		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
 			nr_rotated++;
 			/*
 			 * Identify referenced, file-backed active pages and
-- 
1.6.4.13.ge6580

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
