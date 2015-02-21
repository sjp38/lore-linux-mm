Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 13D416B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:06:31 -0500 (EST)
Received: by padet14 with SMTP id et14so12806565pad.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:06:30 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id pz3si8905454pbb.216.2015.02.20.20.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:06:29 -0800 (PST)
Received: by pdjz10 with SMTP id z10so11956999pdj.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:06:29 -0800 (PST)
Date: Fri, 20 Feb 2015 20:06:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 09/24] huge tmpfs: try to allocate huge pages, split into a
 team
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202005080.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now we get down to work.  The idea here is that compound pages were
ideal for hugetlbfs, with its own separate pool to which huge pages
must be freed.  Not so suitable for anonymous THP, which was forced
to adopt a strange refcount-in-mapcount technique to track its tails -
compare v2.6.37's mm/swap.c:put_compound_page() with a current version!
And not at all suitable for pagecache THP, where one process may want
to map 4kB of a file while another maps 2MB spanning the same offset.

And since anonymous THP was confined to private mappings, that blurred
the distinction between the mapping and the object mapped: so splitting
the mapping entailed splitting the object (the compound page).  For a
long time, pagecache THP appeared to be an even greater challenge: but
that's when you try to follow the anonymous lead too closely.  Actually
pagecache THP is easier, once you abandon compound pages, and consider
the object and its mapping separately.

(I think it was probably a mistake to use compound pages for anonymous
THP, and that it can be simplified by conversion to the same as we do
here: but I have spent no time thinking that through, I may be quite
wrong, and it's certainly no part of this patch series to change how
anonymous THP works today.)

This and the next patches are entirely concerned with the object and
not its mapping: but there will be no chance of mapping the object
with huge pmds, unless it is allocated in huge extents.  Mounting
a tmpfs with the huge=1 option requests that objects be allocated
in huge extents, when memory fragmentation and pressure permit.

The main change here is, of course, to shmem_alloc_page(), and to
shmem_add_to_page_cache(): with attention to the races which may
well occur in between the two calls - which involves a rather ugly
"hugehint" interface between them, and the shmem_hugeteam_lookup()
helper which checks the surrounding area for a previously allocated
huge page, or a small page implying earlier huge allocation failure.

shmem_getpage_gfp() works in terms of small (meaning typically 4kB)
pages just as before; the radix_tree holds a slot for each small
page just as before; memcg is charged for small pages just as before;
the LRUs hold small pages just as before; get_user_pages() will work
on ordinarily-refcounted small pages just as before.  Which keeps it
all reassuringly simple, but is sure to show up in greater overhead
than hugetlbfs, when first establishing an object; and reclaim from
LRU (with 512 items to go through when only 1 will free them) is sure
to demand cleverer handling in later patches.

The huge page itself is allocated (currently with __GFP_NORETRY)
as a high-order page, but not as a compound page; and that high-order
page is immediately split into its separately refcounted subpages (no
overhead to that: establishing a compound page itself has to set up
each tail page).  Only the small page that was asked for is put into
the radix_tree ("page cache") at that time, the remainder left unused
(but with page count 1).  The whole is loosely "held together" with a
new PageTeam flag on the head page (whether or not it was put in the
cache), and then one by one, on each tail page as it is instantiated.
There is no requirement that the file be written sequentially.

PageSwapBacked proves useful to distinguish a page which has been
instantiated from one which has not: particularly in the case of that
head page marked PageTeam even when not yet instantiated.  Although
conceptually very different, PageTeam is successfully reusing the
CONFIG_TRANSPARENT_HUGEPAGE PG_compound_lock, so no need to beg for a
new flag bit: just a few places may also need to check for !PageHead
or !PageAnon to distinguish - see next patch.

Truncation (and hole-punch and eviction) needs to disband the
team before any page is freed from it; and although it will only be
important once we get to mapping the page, even now take the lock on
the head page when truncating any team member (though commonly the head
page will be the first truncated anyway).  That does need a trylock,
and sometimes even a busyloop waiting for PageTeam to be cleared, but
I don't see an actual problem with it (no worse than waiting to take
a bitspinlock).  When disbanding a team, ask free_hot_cold_page() to
free to the cold end of the pcp list, so the subpages are more likely
to be buddied back together.

In reclaim (shmem_writepage), simply redirty any tail page of the team,
and only when the head is to be reclaimed, proceed to disband and swap.
(Unless head remains uninstantiated: then tail may disband and swap.)
This strategy will still be safe once we get to mapping the huge page:
the head (and hence the huge) can never be mapped at this point.

With this patch, the ShmemHugePages line of /proc/meminfo is shown,
but it totals the amount of huge page memory allocated, not the
amount fully used: so it may show ShmemHugePages exceeding Shmem.

Disclaimer: I have used PAGE_SIZE, PAGE_SHIFT throughout this series,
paying no attention to when it should actually say PAGE_CACHE_SIZE,
PAGE_CACHE_SHIFT: enforcing that hypothetical distinction requires
a different mindset, better left to a later exercise.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/page-flags.h |    6 
 include/linux/pageteam.h   |   32 +++
 mm/shmem.c                 |  357 ++++++++++++++++++++++++++++++++---
 3 files changed, 367 insertions(+), 28 deletions(-)

--- thpfs.orig/include/linux/page-flags.h	2014-10-05 12:23:04.000000000 -0700
+++ thpfs/include/linux/page-flags.h	2015-02-20 19:34:06.224004747 -0800
@@ -108,6 +108,7 @@ enum pageflags {
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
+	PG_team = PG_compound_lock,	/* used for huge shmem (thpfs) */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -180,6 +181,9 @@ static inline int Page##uname(const stru
 #define SETPAGEFLAG_NOOP(uname)						\
 static inline void SetPage##uname(struct page *page) {  }
 
+#define __SETPAGEFLAG_NOOP(uname)					\
+static inline void __SetPage##uname(struct page *page) {  }
+
 #define CLEARPAGEFLAG_NOOP(uname)					\
 static inline void ClearPage##uname(struct page *page) {  }
 
@@ -458,7 +462,9 @@ static inline int PageTransTail(struct p
 	return PageTail(page);
 }
 
+PAGEFLAG(Team, team) __SETPAGEFLAG(Team, team)
 #else
+PAGEFLAG_FALSE(Team) __SETPAGEFLAG_NOOP(Team)
 
 static inline int PageTransHuge(struct page *page)
 {
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:34:06.224004747 -0800
@@ -0,0 +1,32 @@
+#ifndef _LINUX_PAGETEAM_H
+#define _LINUX_PAGETEAM_H
+
+/*
+ * Declarations and definitions for PageTeam pages and page->team_usage:
+ * as implemented for "huge tmpfs" in mm/shmem.c and mm/huge_memory.c, when
+ * CONFIG_TRANSPARENT_HUGEPAGE=y, and tmpfs is mounted with the huge=1 option.
+ */
+
+#include <linux/huge_mm.h>
+#include <linux/mm_types.h>
+#include <linux/mmdebug.h>
+#include <asm/page.h>
+
+static inline struct page *team_head(struct page *page)
+{
+	struct page *head = page - (page->index & (HPAGE_PMD_NR-1));
+	/*
+	 * Locating head by page->index is a faster calculation than by
+	 * pfn_to_page(page_to_pfn), and we only use this function after
+	 * page->index has been set (never on tail holes): but check that.
+	 *
+	 * Although this is only used on a PageTeam(page), the team might be
+	 * disbanded racily, so it's not safe to VM_BUG_ON(!PageTeam(page));
+	 * but page->index remains stable across disband and truncation.
+	 */
+	VM_BUG_ON_PAGE(head != pfn_to_page(page_to_pfn(page) &
+			~((unsigned long)HPAGE_PMD_NR-1)), page);
+	return head;
+}
+
+#endif /* _LINUX_PAGETEAM_H */
--- thpfs.orig/mm/shmem.c	2015-02-20 19:34:01.464015631 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:34:06.224004747 -0800
@@ -60,6 +60,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/security.h>
 #include <linux/sysctl.h>
 #include <linux/swapops.h>
+#include <linux/pageteam.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
 #include <linux/ctype.h>
@@ -299,49 +300,236 @@ static bool shmem_confirm_swap(struct ad
 #define SHMEM_HUGE_DENY		(-1)
 #define SHMEM_HUGE_FORCE	(2)
 
+/* hugehint values: NULL to choose a small page always */
+#define SHMEM_ALLOC_SMALL_PAGE	((struct page *)1)
+#define SHMEM_ALLOC_HUGE_PAGE	((struct page *)2)
+#define SHMEM_RETRY_HUGE_PAGE	((struct page *)3)
+/* otherwise hugehint is the hugeteam page to be used */
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
 int shmem_huge __read_mostly;
 
+static struct page *shmem_hugeteam_lookup(struct address_space *mapping,
+					  pgoff_t index, bool speculative)
+{
+	pgoff_t start;
+	pgoff_t indice;
+	void __rcu **pagep;
+	struct page *cachepage;
+	struct page *headpage;
+	struct page *page;
+
+	/*
+	 * First called speculatively, under rcu_read_lock(), by the huge
+	 * shmem_alloc_page(): to decide whether to allocate a new huge page,
+	 * or a new small page, or use a previously allocated huge team page.
+	 *
+	 * Later called under mapping->tree_lock, by shmem_add_to_page_cache(),
+	 * to confirm the decision just before inserting into the radix_tree.
+	 */
+
+	start = round_down(index, HPAGE_PMD_NR);
+restart:
+	if (!radix_tree_gang_lookup_slot(&mapping->page_tree,
+					 &pagep, &indice, start, 1))
+		return SHMEM_ALLOC_HUGE_PAGE;
+	cachepage = rcu_dereference_check(*pagep,
+		lockdep_is_held(&mapping->tree_lock));
+	if (!cachepage || indice >= start + HPAGE_PMD_NR)
+		return SHMEM_ALLOC_HUGE_PAGE;
+	if (radix_tree_exception(cachepage)) {
+		if (radix_tree_deref_retry(cachepage))
+			goto restart;
+		return SHMEM_ALLOC_SMALL_PAGE;
+	}
+	if (!PageTeam(cachepage))
+		return SHMEM_ALLOC_SMALL_PAGE;
+	/* headpage is very often its first cachepage, but not necessarily */
+	headpage = cachepage - (indice - start);
+	page = headpage + (index - start);
+	if (speculative && !page_cache_get_speculative(page))
+		goto restart;
+	if (!PageTeam(headpage) ||
+	    headpage->mapping != mapping || headpage->index != start) {
+		if (speculative)
+			page_cache_release(page);
+		goto restart;
+	}
+	return page;
+}
+
+static int shmem_disband_hugehead(struct page *head)
+{
+	struct address_space *mapping;
+	struct zone *zone;
+	int nr = -1;
+
+	mapping = head->mapping;
+	zone = page_zone(head);
+
+	spin_lock_irq(&mapping->tree_lock);
+	if (PageTeam(head)) {
+		ClearPageTeam(head);
+		__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
+		nr = 1;
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+	return nr;
+}
+
+static void shmem_disband_hugetails(struct page *head)
+{
+	struct page *page;
+	struct page *endpage;
+
+	page = head;
+	endpage = head + HPAGE_PMD_NR;
+
+	/* Condition follows in next commit */ {
+		/*
+		 * The usual case: disbanding team and freeing holes as cold
+		 * (cold being more likely to preserve high-order extents).
+		 */
+		if (!PageSwapBacked(page)) {	/* head was not in cache */
+			page->mapping = NULL;
+			if (put_page_testzero(page))
+				free_hot_cold_page(page, 1);
+		}
+		while (++page < endpage) {
+			if (PageTeam(page))
+				ClearPageTeam(page);
+			else if (put_page_testzero(page))
+				free_hot_cold_page(page, 1);
+		}
+	}
+}
+
+static void shmem_disband_hugeteam(struct page *page)
+{
+	struct page *head = team_head(page);
+	int nr_used;
+
+	/*
+	 * In most cases, shmem_disband_hugeteam() is called with this page
+	 * locked.  But shmem_getpage_gfp()'s alloced_huge failure case calls
+	 * it after unlocking and releasing: because it has not exposed the
+	 * page, and prefers free_hot_cold_page to free it all cold together.
+	 *
+	 * The truncation case may need a second lock, on the head page,
+	 * to guard against races while shmem fault prepares a huge pmd.
+	 * Little point in returning error, it has to check PageTeam anyway.
+	 */
+	if (head != page) {
+		if (!get_page_unless_zero(head))
+			return;
+		if (!trylock_page(head)) {
+			page_cache_release(head);
+			return;
+		}
+		if (!PageTeam(head)) {
+			unlock_page(head);
+			page_cache_release(head);
+			return;
+		}
+	}
+
+	/*
+	 * Disable preemption because truncation may end up spinning until a
+	 * tail PageTeam has been cleared: we hold the lock as briefly as we
+	 * can (splitting disband in two stages), but better not be preempted.
+	 */
+	preempt_disable();
+	nr_used = shmem_disband_hugehead(head);
+	if (head != page)
+		unlock_page(head);
+	if (nr_used >= 0)
+		shmem_disband_hugetails(head);
+	if (head != page)
+		page_cache_release(head);
+	preempt_enable();
+}
+
 #else /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define shmem_huge SHMEM_HUGE_DENY
 
+static inline struct page *shmem_hugeteam_lookup(struct address_space *mapping,
+					pgoff_t index, bool speculative)
+{
+	BUILD_BUG();
+	return SHMEM_ALLOC_SMALL_PAGE;
+}
+
+static inline void shmem_disband_hugeteam(struct page *page)
+{
+	BUILD_BUG();
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /*
  * Like add_to_page_cache_locked, but error if expected item has gone.
  */
-static int shmem_add_to_page_cache(struct page *page,
-				   struct address_space *mapping,
-				   pgoff_t index, void *expected)
+static int
+shmem_add_to_page_cache(struct page *page, struct address_space *mapping,
+			pgoff_t index, void *expected, struct page *hugehint)
 {
+	struct zone *zone = page_zone(page);
 	int error;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG_ON(expected && hugehint);
+
+	spin_lock_irq(&mapping->tree_lock);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugehint) {
+		if (shmem_hugeteam_lookup(mapping, index, false) != hugehint) {
+			error = -EEXIST;	/* will retry */
+			goto errout;
+		}
+		if (!PageSwapBacked(page)) {	/* huge needs special care */
+			SetPageSwapBacked(page);
+			SetPageTeam(page);
+		}
+	}
 
-	page_cache_get(page);
 	page->mapping = mapping;
 	page->index = index;
+	/* smp_wmb()?  That's in radix_tree_insert()'s rcu_assign_pointer() */
 
-	spin_lock_irq(&mapping->tree_lock);
 	if (!expected)
 		error = radix_tree_insert(&mapping->page_tree, index, page);
 	else
 		error = shmem_radix_tree_replace(mapping, index, expected,
 								 page);
-	if (!error) {
-		mapping->nrpages++;
-		__inc_zone_page_state(page, NR_FILE_PAGES);
-		__inc_zone_page_state(page, NR_SHMEM);
-		spin_unlock_irq(&mapping->tree_lock);
-	} else {
-		page->mapping = NULL;
-		spin_unlock_irq(&mapping->tree_lock);
-		page_cache_release(page);
+	if (unlikely(error)) {
+		/* Beware: did above make some flags fleetingly visible? */
+		VM_BUG_ON(page == hugehint);
+		goto errout;
 	}
+
+	if (!PageTeam(page))
+		page_cache_get(page);
+	else if (hugehint == SHMEM_ALLOC_HUGE_PAGE)
+		__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
+
+	mapping->nrpages++;
+	__inc_zone_state(zone, NR_FILE_PAGES);
+	__inc_zone_state(zone, NR_SHMEM);
+	spin_unlock_irq(&mapping->tree_lock);
+	return 0;
+
+errout:
+	if (PageTeam(page)) {
+		/* We use SwapBacked to indicate if already in cache */
+		ClearPageSwapBacked(page);
+		if (index & (HPAGE_PMD_NR-1)) {
+			ClearPageTeam(page);
+			page->mapping = NULL;
+		}
+	} else
+		page->mapping = NULL;
+	spin_unlock_irq(&mapping->tree_lock);
 	return error;
 }
 
@@ -427,15 +615,16 @@ static void shmem_undo_range(struct inod
 	struct pagevec pvec;
 	pgoff_t indices[PAGEVEC_SIZE];
 	long nr_swaps_freed = 0;
+	pgoff_t warm_index = 0;
 	pgoff_t index;
 	int i;
 
 	if (lend == -1)
 		end = -1;	/* unsigned, so actually very big */
 
-	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
+		pagevec_init(&pvec, index < warm_index);
 		pvec.nr = find_get_entries(mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			pvec.pages, indices);
@@ -461,7 +650,21 @@ static void shmem_undo_range(struct inod
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
-					truncate_inode_page(mapping, page);
+					if (PageTeam(page)) {
+						/*
+						 * Try preserve huge pages by
+						 * freeing to tail of pcp list.
+						 */
+						pvec.cold = 1;
+						warm_index = round_up(
+						    index + 1, HPAGE_PMD_NR);
+						shmem_disband_hugeteam(page);
+						/* but that may not succeed */
+					}
+					if (!PageTeam(page)) {
+						truncate_inode_page(mapping,
+								    page);
+					}
 				}
 			}
 			unlock_page(page);
@@ -503,7 +706,8 @@ static void shmem_undo_range(struct inod
 	index = start;
 	while (index < end) {
 		cond_resched();
-
+		/* Carrying warm_index from first pass is the best we can do */
+		pagevec_init(&pvec, index < warm_index);
 		pvec.nr = find_get_entries(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 				pvec.pages, indices);
@@ -538,7 +742,26 @@ static void shmem_undo_range(struct inod
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
-					truncate_inode_page(mapping, page);
+					if (PageTeam(page)) {
+						/*
+						 * Try preserve huge pages by
+						 * freeing to tail of pcp list.
+						 */
+						pvec.cold = 1;
+						warm_index = round_up(
+						    index + 1, HPAGE_PMD_NR);
+						shmem_disband_hugeteam(page);
+						/* but that may not succeed */
+					}
+					if (!PageTeam(page)) {
+						truncate_inode_page(mapping,
+								    page);
+					} else if (end != -1) {
+						/* Punch retry disband now */
+						unlock_page(page);
+						index--;
+						break;
+					}
 				} else {
 					/* Page was replaced by swap: retry */
 					unlock_page(page);
@@ -690,7 +913,7 @@ static int shmem_unuse_inode(struct shme
 	 */
 	if (!error)
 		error = shmem_add_to_page_cache(*pagep, mapping, index,
-						radswap);
+						radswap, NULL);
 	if (error != -ENOMEM) {
 		/*
 		 * Truncation and eviction use free_swap_and_cache(), which
@@ -827,10 +1050,25 @@ static int shmem_writepage(struct page *
 		SetPageUptodate(page);
 	}
 
+	if (PageTeam(page)) {
+		struct page *head = team_head(page);
+		/*
+		 * Only proceed if this is head, or if head is unpopulated.
+		 */
+		if (page != head && PageSwapBacked(head))
+			goto redirty;
+	}
+
 	swap = get_swap_page();
 	if (!swap.val)
 		goto redirty;
 
+	if (PageTeam(page)) {
+		shmem_disband_hugeteam(page);
+		if (PageTeam(page))
+			goto putswap;
+	}
+
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
 	 * if it's not already there.  Do it now before the page is
@@ -859,6 +1097,7 @@ static int shmem_writepage(struct page *
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
+putswap:
 	swapcache_free(swap);
 redirty:
 	set_page_dirty(page);
@@ -926,8 +1165,8 @@ static struct page *shmem_swapin(swp_ent
 	return page;
 }
 
-static struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
+static struct page *shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
+	pgoff_t index, struct page **hugehint, struct page **alloced_huge)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
@@ -939,12 +1178,54 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && *hugehint) {
+		struct address_space *mapping = info->vfs_inode.i_mapping;
+		struct page *head;
+
+		rcu_read_lock();
+		*hugehint = shmem_hugeteam_lookup(mapping, index, true);
+		rcu_read_unlock();
+
+		if (*hugehint == SHMEM_ALLOC_HUGE_PAGE) {
+			head = alloc_pages_vma(gfp|__GFP_NORETRY|__GFP_NOWARN,
+				HPAGE_PMD_ORDER, &pvma, 0, numa_node_id());
+			if (head) {
+				split_page(head, HPAGE_PMD_ORDER);
+
+				/* Prepare head page for add_to_page_cache */
+				__SetPageTeam(head);
+				head->mapping = mapping;
+				head->index = round_down(index, HPAGE_PMD_NR);
+				*alloced_huge = head;
+
+				/* Prepare wanted page for add_to_page_cache */
+				page = head + (index & (HPAGE_PMD_NR-1));
+				page_cache_get(page);
+				__set_page_locked(page);
+				goto out;
+			}
+		} else if (*hugehint != SHMEM_ALLOC_SMALL_PAGE) {
+			page = *hugehint;
+			head = page - (index & (HPAGE_PMD_NR-1));
+			/*
+			 * This page is already visible: so we cannot use the
+			 * __nonatomic ops, must check that it has not already
+			 * been added, and cannot set the flags it needs until
+			 * add_to_page_cache has the tree_lock.
+			 */
+			lock_page(page);
+			if (PageSwapBacked(page) || !PageTeam(head))
+				*hugehint = SHMEM_RETRY_HUGE_PAGE;
+			goto out;
+		}
+	}
+
 	page = alloc_pages_vma(gfp, 0, &pvma, 0, numa_node_id());
 	if (page) {
 		__set_page_locked(page);
 		__SetPageSwapBacked(page);
 	}
-
+out:
 	/* Drop reference taken by mpol_shared_policy_lookup() */
 	mpol_cond_put(pvma.vm_policy);
 
@@ -975,6 +1256,7 @@ static int shmem_replace_page(struct pag
 	struct address_space *swap_mapping;
 	pgoff_t swap_index;
 	int error;
+	struct page *hugehint = NULL;
 
 	oldpage = *pagep;
 	swap_index = page_private(oldpage);
@@ -985,7 +1267,7 @@ static int shmem_replace_page(struct pag
 	 * limit chance of success by further cpuset and node constraints.
 	 */
 	gfp &= ~GFP_CONSTRAINT_MASK;
-	newpage = shmem_alloc_page(gfp, info, index);
+	newpage = shmem_alloc_page(gfp, info, index, &hugehint, &hugehint);
 	if (!newpage)
 		return -ENOMEM;
 
@@ -1051,6 +1333,8 @@ static int shmem_getpage_gfp(struct inod
 	int error;
 	int once = 0;
 	int alloced = 0;
+	struct page *hugehint;
+	struct page *alloced_huge = NULL;
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
@@ -1127,7 +1411,7 @@ repeat:
 		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
-						swp_to_radix_entry(swap));
+						swp_to_radix_entry(swap), NULL);
 			/*
 			 * We already confirmed swap under page lock, and make
 			 * no memory allocation here, so usually no possibility
@@ -1176,11 +1460,23 @@ repeat:
 			percpu_counter_inc(&sbinfo->used_blocks);
 		}
 
-		page = shmem_alloc_page(gfp, info, index);
+		/* Take huge hint from super, except for shmem_symlink() */
+		hugehint = NULL;
+		if (mapping->a_ops == &shmem_aops &&
+		    (shmem_huge == SHMEM_HUGE_FORCE ||
+		     (sbinfo->huge && shmem_huge != SHMEM_HUGE_DENY)))
+			hugehint = SHMEM_ALLOC_HUGE_PAGE;
+
+		page = shmem_alloc_page(gfp, info, index,
+					&hugehint, &alloced_huge);
 		if (!page) {
 			error = -ENOMEM;
 			goto decused;
 		}
+		if (hugehint == SHMEM_RETRY_HUGE_PAGE) {
+			error = -EEXIST;
+			goto decused;
+		}
 
 		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
 		if (error)
@@ -1188,7 +1484,7 @@ repeat:
 		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
-							NULL);
+							NULL, hugehint);
 			radix_tree_preload_end();
 		}
 		if (error) {
@@ -1229,7 +1525,8 @@ clear:
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
-		if (alloced)
+		alloced_huge = NULL;	/* already exposed: maybe now in use */
+		if (alloced && !PageTeam(page))
 			goto trunc;
 		else
 			goto failed;
@@ -1263,6 +1560,10 @@ unlock:
 		unlock_page(page);
 		page_cache_release(page);
 	}
+	if (alloced_huge) {
+		shmem_disband_hugeteam(alloced_huge);
+		alloced_huge = NULL;
+	}
 	if (error == -ENOSPC && !once++) {
 		info = SHMEM_I(inode);
 		spin_lock(&info->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
