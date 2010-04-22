Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 988346B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 05:28:43 -0400 (EDT)
Date: Thu, 22 Apr 2010 10:28:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100422092819.GR30306@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004210927550.4959@router.home> <20100421150037.GJ30306@csn.ul.ie> <alpine.DEB.2.00.1004211004360.4959@router.home> <20100421151417.GK30306@csn.ul.ie> <alpine.DEB.2.00.1004211027120.4959@router.home> <20100421153421.GM30306@csn.ul.ie> <alpine.DEB.2.00.1004211038020.4959@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004211038020.4959@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 10:46:45AM -0500, Christoph Lameter wrote:
> On Wed, 21 Apr 2010, Mel Gorman wrote:
> 
> > > > 2. Is the BUG_ON check in
> > > >    include/linux/swapops.h#migration_entry_to_page() now wrong? (I
> > > >    think yes, but I'm not sure and I'm having trouble verifying it)
> > >
> > > The bug check ensures that migration entries only occur when the page
> > > is locked. This patch changes that behavior. This is going too oops
> > > therefore in unmap_and_move() when you try to remove the migration_ptes
> > > from an unlocked page.
> > >
> >
> > It's not unmap_and_move() that the problem is occurring on but during a
> > page fault - presumably in do_swap_page but I'm not 100% certain.
> 
> remove_migration_pte() calls migration_entry_to_page(). So it must do that
> only if the page is still locked.
> 

Correct, but the other call path is

do_swap_page
  -> migration_entry_wait
    -> migration_entry_to_page

with migration_entry_wait expecting the page to be locked. There is a dangling
migration PTEs coming from somewhere. I thought it was from unmapped swapcache
first, but that cannot be the case. There is a race somewhere.

> You need to ensure that the page is not unlocked in move_to_new_page() if
> the migration ptes are kept.
> 
> move_to_new_page() only unlocks the new page not the original page. So that is safe.
> 
> And it seems that the old page is also unlocked in unmap_and_move() only
> after the migration_ptes have been removed? So we are fine after all...?
> 

You'd think but migration PTEs are being left behind in some circumstance. I
thought it was due to this series, but it's unlikely. It's more a case that
compaction heavily exercises migration.

We can clean up the old migration PTEs though when they are encountered
like in the following patch for example? I'll continue investigating why
this dangling migration pte exists as closing that race would be a
better fix.

==== CUT HERE ====
mm,migration: Remove dangling migration ptes pointing to unlocked pages

Due to some yet-to-be-identified race, it is possible for migration PTEs
to be left behind, When later paged-in, a BUG is triggered that assumes
that all migration PTEs are point to a page currently being migrated and
so must be locked.

Rather than calling BUG, this patch notes the existance of dangling migration
PTEs in migration_entry_wait() and cleans them up.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/swapops.h |   11 ++++++-----
 mm/memory.c             |    2 +-
 mm/migrate.c            |   24 ++++++++++++++++++++----
 3 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index cd42e30..01fba71 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -95,14 +95,15 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 	return unlikely(swp_type(entry) == SWP_MIGRATION_WRITE);
 }
 
-static inline struct page *migration_entry_to_page(swp_entry_t entry)
+static inline struct page *migration_entry_to_page(swp_entry_t entry,
+				bool lock_required)
 {
 	struct page *p = pfn_to_page(swp_offset(entry));
 	/*
 	 * Any use of migration entries may only occur while the
 	 * corresponding page is locked
 	 */
-	BUG_ON(!PageLocked(p));
+	BUG_ON(!PageLocked(p) && lock_required);
 	return p;
 }
 
@@ -112,7 +113,7 @@ static inline void make_migration_entry_read(swp_entry_t *entry)
 }
 
 extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
-					unsigned long address);
+					unsigned long address, bool lock_required);
 #else
 
 #define make_migration_entry(page, write) swp_entry(0, 0)
@@ -121,9 +122,9 @@ static inline int is_migration_entry(swp_entry_t swp)
 	return 0;
 }
 #define migration_entry_to_page(swp) NULL
-static inline void make_migration_entry_read(swp_entry_t *entryp) { }
+static inline void make_migration_entry_read(swp_entry_t *entryp, bool lock_required) { }
 static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
-					 unsigned long address) { }
+					 unsigned long address, bool lock_required) { }
 static inline int is_write_migration_entry(swp_entry_t entry)
 {
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 833952d..9719138 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2619,7 +2619,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
-			migration_entry_wait(mm, pmd, address);
+			migration_entry_wait(mm, pmd, address, false);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index 4afd6fe..308639b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -114,7 +114,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	entry = pte_to_swp_entry(pte);
 
 	if (!is_migration_entry(entry) ||
-	    migration_entry_to_page(entry) != old)
+	    migration_entry_to_page(entry, true) != old)
 		goto unlock;
 
 	get_page(new);
@@ -148,19 +148,23 @@ static void remove_migration_ptes(struct page *old, struct page *new)
 
 /*
  * Something used the pte of a page under migration. We need to
- * get to the page and wait until migration is finished.
+ * get to the page and wait until migration is finished. Alternatively,
+ * the migration of an unmapped swapcache page could have left a
+ * dangling migration pte due to the  lack of certainity about an
+ * anon_vma. In that case, the migration pte is removed and rechecked.
  * When we return from this function the fault will be retried.
  *
  * This function is called from do_swap_page().
  */
 void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
-				unsigned long address)
+				unsigned long address, bool lock_required)
 {
 	pte_t *ptep, pte;
 	spinlock_t *ptl;
 	swp_entry_t entry;
 	struct page *page;
 
+recheck:
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
@@ -170,7 +174,7 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	if (!is_migration_entry(entry))
 		goto out;
 
-	page = migration_entry_to_page(entry);
+	page = migration_entry_to_page(entry, lock_required);
 
 	/*
 	 * Once radix-tree replacement of page migration started, page_count
@@ -181,6 +185,18 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	 */
 	if (!get_page_unless_zero(page))
 		goto out;
+
+	/* If unlocked, this is a dangling migration pte that needs removal */
+	if (!PageLocked(page)) {
+		BUG_ON(lock_required);
+		pte_unmap_unlock(ptep, ptl);
+		lock_page(page);
+		remove_migration_pte(page, find_vma(mm, address), address, page);
+		unlock_page(page);
+		put_page(page);
+		goto recheck;
+	}
+
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
 	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
