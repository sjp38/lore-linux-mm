Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F0B196B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:23:55 -0500 (EST)
Received: by pdev10 with SMTP id v10so12042764pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:23:55 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id vy6si24357705pbc.138.2015.02.20.20.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:23:54 -0800 (PST)
Received: by pabrd3 with SMTP id rd3so12937950pab.4
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:23:54 -0800 (PST)
Date: Fri, 20 Feb 2015 20:23:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 20/24] huge tmpfs: use Unevictable lru with variable
 hpage_nr_pages()
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202022260.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A big advantage of huge tmpfs over hugetlbfs is that its pages can
be swapped out; but too often it OOMs before swapping them out.

At first I tried changing page_evictable(), to treat all tail pages
of a hugely mapped team as unevictable: the anon LRUs were otherwise
swamped by pages that could not be freed before the head.

That worked quite well, some of the time, but has some drawbacks.

Most obviously, /proc/meminfo is liable to show 511/512ths of all
the ShmemPmdMapped as Unevictable; which is rather sad for a feature
intended to improve on hugetlbfs by letting the pages be swappable.

But more seriously, although it is helpful to have those tails out
of the way on the Unevictable list, page reclaim can very easily come
to a point where all the team heads to be freed are on the Active list,
but the Inactive is large enough that !inactive_anon_is_low(), so the
Active is never scanned to unmap those heads to release all the tails.
Eventually we OOM.

Perhaps that could be dealt with by hacking inactive_anon_is_low():
but it wouldn't help the Unevictable numbers, and has never been
necessary for anon THP.  How does anon THP avoid this?  It doesn't
put tails on the LRU at all, so doesn't then need to shift them to
Unevictable; but there would still be the danger of an Active list
full of heads, holding the unseen tails, but the ratio too high for
for Active scanning - except that hpage_nr_pages() weights each THP
head by the number of small pages the huge page holds, instead of the
usual 1, and that is what keeps the Active/Inactive balance working.

So in this patch we try to do the same for huge tmpfs pages.  However,
a team is not one huge compound page, but a collection of independent
pages, and the fair and lazy way to accomplish this seems to be to
transfer each tail's weight to head at the time when shmem_writepage()
has been asked to evict the page, but refuses because the head has not
yet been evicted.  So although the failed-to-be-evicted tails are moved
to the Unevictable LRU, each counts for 0kB in the Unevictable amount,
its 4kB going to the head in the Active(anon) or Inactive(anon) amount.

Apart from mlock.c (next patch), hpage_nr_pages() is now only called
on a maybe-PageTeam page while under lruvec lock, and we do need to
hold lruvec lock when transferring weight from one page to another.
That is a new overhead, which shmem_disband_hugehead() prefers to
avoid, if the head's weight is just the default 1.  And it's not
clear how well this will all play out if different pages of a team
are charged to different memcgs: but the code allows for that, and
it should be fine while that's just an exceptional minority case.

A change I like in principle, but have not made, and do not intend
to make unless we see a workload that demands it: it would be natural
for mark_page_accessed() to retrieve such a 0-weight page from the
Unevictable LRU, assigning it weight again and giving it a new life
on the Active and Inactive LRUs.  As it is, I'm hoping PageReferenced
gives a good enough hint as to whether a page should be retained, when
shmem_evictify_hugetails() brings it back from Unevictable to Inactive.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/huge_mm.h  |   13 +++
 include/linux/pageteam.h |   48 ++++++++++-
 mm/memcontrol.c          |   10 ++
 mm/shmem.c               |  158 ++++++++++++++++++++++++++++++-------
 mm/swap.c                |    5 +
 mm/vmscan.c              |   42 +++++++++
 6 files changed, 243 insertions(+), 33 deletions(-)

--- thpfs.orig/include/linux/huge_mm.h	2015-02-20 19:34:32.363944978 -0800
+++ thpfs/include/linux/huge_mm.h	2015-02-20 19:35:04.303871947 -0800
@@ -150,10 +150,23 @@ static inline void vma_adjust_trans_huge
 #endif
 	__vma_adjust_trans_huge(vma, start, end, adjust_next);
 }
+
+/* Repeat definition from linux/pageteam.h to force error if different */
+#define TEAM_LRU_WEIGHT_MASK	((1L << (HPAGE_PMD_ORDER + 1)) - 1)
+
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
 		return HPAGE_PMD_NR;
+	/*
+	 * PG_team == PG_compound_lock, but PageTransHuge == PageHead.
+	 * The question of races here is interesting, but not for now:
+	 * this can only be relied on while holding the lruvec lock,
+	 * or knowing that the page is anonymous, not from huge tmpfs.
+	 */
+	if (PageTeam(page))
+		return atomic_long_read(&page->team_usage) &
+					TEAM_LRU_WEIGHT_MASK;
 	return 1;
 }
 
--- thpfs.orig/include/linux/pageteam.h	2015-02-20 19:34:48.083909034 -0800
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:35:04.303871947 -0800
@@ -30,11 +30,32 @@ static inline struct page *team_head(str
 }
 
 /*
+ * Mask for lower bits of team_usage, giving the weight 0..HPAGE_PMD_NR of the
+ * page on its LRU: normal pages have weight 1, tails held unevictable until
+ * head is evicted have weight 0, and the head gathers weight 1..HPAGE_PMD_NR.
+ */
+#define TEAM_LRU_WEIGHT_ONE	1L
+#define TEAM_LRU_WEIGHT_MASK	((1L << (HPAGE_PMD_ORDER + 1)) - 1)
+
+#define TEAM_HIGH_COUNTER	(1L << (HPAGE_PMD_ORDER + 1))
+/*
+ * Count how many pages of team are instantiated, as it is built up.
+ */
+#define TEAM_PAGE_COUNTER	TEAM_HIGH_COUNTER
+#define TEAM_COMPLETE		(TEAM_PAGE_COUNTER << HPAGE_PMD_ORDER)
+/*
+ * And when complete, count how many huge mappings (like page_mapcount): an
+ * incomplete team cannot be hugely mapped (would expose uninitialized holes).
+ */
+#define TEAM_MAPPING_COUNTER	TEAM_HIGH_COUNTER
+#define TEAM_HUGELY_MAPPED	(TEAM_COMPLETE + TEAM_MAPPING_COUNTER)
+
+/*
  * Returns true if this team is mapped by pmd somewhere.
  */
 static inline bool team_hugely_mapped(struct page *head)
 {
-	return atomic_long_read(&head->team_usage) > HPAGE_PMD_NR;
+	return atomic_long_read(&head->team_usage) >= TEAM_HUGELY_MAPPED;
 }
 
 /*
@@ -43,7 +64,8 @@ static inline bool team_hugely_mapped(st
  */
 static inline bool inc_hugely_mapped(struct page *head)
 {
-	return atomic_long_inc_return(&head->team_usage) == HPAGE_PMD_NR+1;
+	return atomic_long_add_return(TEAM_MAPPING_COUNTER, &head->team_usage)
+		< TEAM_HUGELY_MAPPED + TEAM_MAPPING_COUNTER;
 }
 
 /*
@@ -52,7 +74,27 @@ static inline bool inc_hugely_mapped(str
  */
 static inline bool dec_hugely_mapped(struct page *head)
 {
-	return atomic_long_dec_return(&head->team_usage) == HPAGE_PMD_NR;
+	return atomic_long_sub_return(TEAM_MAPPING_COUNTER, &head->team_usage)
+		< TEAM_HUGELY_MAPPED;
+}
+
+static inline void inc_lru_weight(struct page *head)
+{
+	atomic_long_inc(&head->team_usage);
+	VM_BUG_ON_PAGE((atomic_long_read(&head->team_usage) &
+			TEAM_LRU_WEIGHT_MASK) > HPAGE_PMD_NR, head);
+}
+
+static inline void set_lru_weight(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_long_read(&page->team_usage) != 0, page);
+	atomic_long_set(&page->team_usage, 1);
+}
+
+static inline void clear_lru_weight(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_long_read(&page->team_usage) != 1, page);
+	atomic_long_set(&page->team_usage, 0);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
--- thpfs.orig/mm/memcontrol.c	2015-02-20 19:34:11.231993296 -0800
+++ thpfs/mm/memcontrol.c	2015-02-20 19:35:04.303871947 -0800
@@ -1319,6 +1319,16 @@ void mem_cgroup_update_lru_size(struct l
 		*lru_size += nr_pages;
 
 	size = *lru_size;
+	if (!size && !empty && lru == LRU_UNEVICTABLE) {
+		struct page *page;
+		/*
+		 * The unevictable list might be full of team tail pages of 0
+		 * weight: check the first, and skip the warning if that fits.
+		 */
+		page = list_first_entry(lruvec->lists + lru, struct page, lru);
+		if (hpage_nr_pages(page) == 0)
+			empty = true;
+	}
 	if (WARN(size < 0 || empty != !size,
 	"mem_cgroup_update_lru_size(%p, %d, %d): lru_size %ld but %sempty\n",
 			lruvec, lru, nr_pages, size, empty ? "" : "not ")) {
--- thpfs.orig/mm/shmem.c	2015-02-20 19:34:59.051883956 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:35:04.307871938 -0800
@@ -63,6 +63,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/swapops.h>
 #include <linux/pageteam.h>
 #include <linux/mempolicy.h>
+#include <linux/mm_inline.h>
 #include <linux/namei.h>
 #include <linux/ctype.h>
 #include <linux/migrate.h>
@@ -373,11 +374,10 @@ restart:
 
 static int shmem_freeholes(struct page *head)
 {
-	/*
-	 * Note: team_usage will also be used to count huge mappings,
-	 * so treat a negative value from shmem_freeholes() as none.
-	 */
-	return HPAGE_PMD_NR - atomic_long_read(&head->team_usage);
+	long nr = atomic_long_read(&head->team_usage);
+
+	return (nr >= TEAM_COMPLETE) ? 0 :
+		HPAGE_PMD_NR - (nr / TEAM_PAGE_COUNTER);
 }
 
 static void shmem_clear_tag_hugehole(struct address_space *mapping,
@@ -404,18 +404,16 @@ static void shmem_added_to_hugeteam(stru
 {
 	struct address_space *mapping = page->mapping;
 	struct page *head = team_head(page);
-	int nr;
 
 	if (hugehint == SHMEM_ALLOC_HUGE_PAGE) {
-		atomic_long_set(&head->team_usage, 1);
+		atomic_long_set(&head->team_usage,
+				TEAM_PAGE_COUNTER + TEAM_LRU_WEIGHT_ONE);
 		radix_tree_tag_set(&mapping->page_tree, page->index,
 					SHMEM_TAG_HUGEHOLE);
 		__mod_zone_page_state(zone, NR_SHMEM_FREEHOLES, HPAGE_PMD_NR-1);
 	} else {
-		/* We do not need atomic ops until huge page gets mapped */
-		nr = atomic_long_read(&head->team_usage) + 1;
-		atomic_long_set(&head->team_usage, nr);
-		if (nr == HPAGE_PMD_NR) {
+		if (atomic_long_add_return(TEAM_PAGE_COUNTER,
+				&head->team_usage) >= TEAM_COMPLETE) {
 			shmem_clear_tag_hugehole(mapping, head->index);
 			__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
 		}
@@ -459,36 +457,61 @@ static int shmem_populate_hugeteam(struc
 	return 0;
 }
 
-static int shmem_disband_hugehead(struct page *head)
+static int shmem_disband_hugehead(struct page *head, int *head_lru_weight)
 {
 	struct address_space *mapping;
+	bool lru_locked = false;
+	unsigned long flags;
 	struct zone *zone;
-	int nr = -1;
+	long team_usage;
+	long nr = -1;
 
 	/*
 	 * Only in the shrinker migration case might head have been truncated.
 	 * But although head->mapping may then be zeroed at any moment, mapping
 	 * stays safe because shmem_evict_inode must take our shrinklist lock.
 	 */
+	*head_lru_weight = 0;
 	mapping = ACCESS_ONCE(head->mapping);
 	if (!mapping)
 		return nr;
 
 	zone = page_zone(head);
-	spin_lock_irq(&mapping->tree_lock);
+	team_usage = atomic_long_read(&head->team_usage);
+again1:
+	if ((team_usage & TEAM_LRU_WEIGHT_MASK) != TEAM_LRU_WEIGHT_ONE) {
+		spin_lock_irq(&zone->lru_lock);
+		lru_locked = true;
+	}
+	spin_lock_irqsave(&mapping->tree_lock, flags);
 
 	if (PageTeam(head)) {
-		nr = atomic_long_read(&head->team_usage);
-		atomic_long_set(&head->team_usage, 0);
+again2:
+		nr = atomic_long_cmpxchg(&head->team_usage, team_usage,
+					 TEAM_LRU_WEIGHT_ONE);
+		if (unlikely(nr != team_usage)) {
+			team_usage = nr;
+			if (lru_locked ||
+			    (team_usage & TEAM_LRU_WEIGHT_MASK) ==
+						    TEAM_LRU_WEIGHT_ONE)
+				goto again2;
+			spin_unlock_irqrestore(&mapping->tree_lock, flags);
+			goto again1;
+		}
+		*head_lru_weight = nr & TEAM_LRU_WEIGHT_MASK;
+		nr /= TEAM_PAGE_COUNTER;
+
 		/*
-		 * Disable additions to the team.
-		 * Ensure head->private is written before PageTeam is
-		 * cleared, so shmem_writepage() cannot write swap into
-		 * head->private, then have it overwritten by that 0!
+		 * Disable additions to the team.  The cmpxchg above
+		 * ensures head->team_usage is read before PageTeam is cleared,
+		 * when shmem_writepage() might write swap into head->private.
 		 */
-		smp_mb__before_atomic();
 		ClearPageTeam(head);
 
+		if (PageLRU(head) && *head_lru_weight > 1)
+			update_lru_size(mem_cgroup_page_lruvec(head, zone),
+					page_lru(head), 1 - *head_lru_weight);
+
 		if (nr >= HPAGE_PMD_NR) {
 			__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
 			VM_BUG_ON(nr != HPAGE_PMD_NR);
@@ -499,10 +522,72 @@ static int shmem_disband_hugehead(struct
 		} /* else shmem_getpage_gfp disbanding a failed alloced_huge */
 	}
 
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+	if (lru_locked)
+		spin_unlock_irq(&zone->lru_lock);
 	return nr;
 }
 
+static void shmem_evictify_hugetails(struct page *head, int head_lru_weight)
+{
+	struct page *page;
+	struct lruvec *lruvec = NULL;
+	struct zone *zone = page_zone(head);
+	bool lru_locked = false;
+
+	/*
+	 * The head has been sheltering the rest of its team from reclaim:
+	 * if any were moved to the unevictable list, now make them evictable.
+	 */
+again:
+	for (page = head + HPAGE_PMD_NR - 1; page > head; page--) {
+		if (!PageTeam(page))
+			continue;
+		if (atomic_long_read(&page->team_usage) == TEAM_LRU_WEIGHT_ONE)
+			continue;
+
+		/*
+		 * Delay getting lru lock until we reach a page that needs it.
+		 */
+		if (!lru_locked) {
+			spin_lock_irq(&zone->lru_lock);
+			lru_locked = true;
+		}
+		lruvec = mem_cgroup_page_lruvec(page, zone);
+
+		VM_BUG_ON_PAGE(atomic_long_read(&page->team_usage), page);
+		VM_BUG_ON_PAGE(!PageLRU(page), page);
+		VM_BUG_ON_PAGE(!PageUnevictable(page), page);
+		VM_BUG_ON_PAGE(PageActive(page), page);
+
+		set_lru_weight(page);
+		head_lru_weight--;
+
+		if (!page_evictable(page)) {
+			update_lru_size(lruvec, LRU_UNEVICTABLE, 1);
+			continue;
+		}
+
+		ClearPageUnevictable(page);
+		update_lru_size(lruvec, LRU_INACTIVE_ANON, 1);
+
+		list_del(&page->lru);
+		list_add_tail(&page->lru, lruvec->lists + LRU_INACTIVE_ANON);
+	}
+
+	if (lru_locked) {
+		spin_unlock_irq(&zone->lru_lock);
+		lru_locked = false;
+	}
+
+	/*
+	 * But how can we be sure that a racing putback_inactive_pages()
+	 * did its clear_lru_weight() before we checked team_usage above?
+	 */
+	if (unlikely(head_lru_weight != TEAM_LRU_WEIGHT_ONE))
+		goto again;
+}
+
 static void shmem_disband_hugetails(struct page *head,
 				    struct list_head *list, int nr)
 {
@@ -579,6 +664,7 @@ static void shmem_disband_hugetails(stru
 static void shmem_disband_hugeteam(struct page *page)
 {
 	struct page *head = team_head(page);
+	int head_lru_weight;
 	int nr_used;
 
 	/*
@@ -622,9 +708,11 @@ static void shmem_disband_hugeteam(struc
 	 * can (splitting disband in two stages), but better not be preempted.
 	 */
 	preempt_disable();
-	nr_used = shmem_disband_hugehead(head);
+	nr_used = shmem_disband_hugehead(head, &head_lru_weight);
 	if (head != page)
 		unlock_page(head);
+	if (head_lru_weight > TEAM_LRU_WEIGHT_ONE)
+		shmem_evictify_hugetails(head, head_lru_weight);
 	if (nr_used >= 0)
 		shmem_disband_hugetails(head, NULL, 0);
 	if (head != page)
@@ -680,6 +768,7 @@ static unsigned long shmem_choose_hugeho
 	struct page *topage = NULL;
 	struct page *page;
 	pgoff_t index;
+	int head_lru_weight;
 	int fromused;
 	int toused;
 	int nid;
@@ -721,8 +810,10 @@ static unsigned long shmem_choose_hugeho
 	if (!frompage)
 		goto unlock;
 	preempt_disable();
-	fromused = shmem_disband_hugehead(frompage);
+	fromused = shmem_disband_hugehead(frompage, &head_lru_weight);
 	spin_unlock(&shmem_shrinklist_lock);
+	if (head_lru_weight > TEAM_LRU_WEIGHT_ONE)
+		shmem_evictify_hugetails(frompage, head_lru_weight);
 	if (fromused > 0)
 		shmem_disband_hugetails(frompage, fromlist, -fromused);
 	preempt_enable();
@@ -776,8 +867,10 @@ static unsigned long shmem_choose_hugeho
 	if (!topage)
 		goto unlock;
 	preempt_disable();
-	toused = shmem_disband_hugehead(topage);
+	toused = shmem_disband_hugehead(topage, &head_lru_weight);
 	spin_unlock(&shmem_shrinklist_lock);
+	if (head_lru_weight > TEAM_LRU_WEIGHT_ONE)
+		shmem_evictify_hugetails(topage, head_lru_weight);
 	if (toused > 0) {
 		if (HPAGE_PMD_NR - toused >= fromused)
 			shmem_disband_hugetails(topage, tolist, fromused);
@@ -927,7 +1020,11 @@ shmem_add_to_page_cache(struct page *pag
 		}
 		if (!PageSwapBacked(page)) {	/* huge needs special care */
 			SetPageSwapBacked(page);
-			SetPageTeam(page);
+			if (!PageTeam(page)) {
+				atomic_long_set(&page->team_usage,
+						TEAM_LRU_WEIGHT_ONE);
+				SetPageTeam(page);
+			}
 		}
 	}
 
@@ -1514,9 +1611,13 @@ static int shmem_writepage(struct page *
 		struct page *head = team_head(page);
 		/*
 		 * Only proceed if this is head, or if head is unpopulated.
+		 * Redirty any others, without setting PageActive, and then
+		 * putback_inactive_pages() will shift them to unevictable.
 		 */
-		if (page != head && PageSwapBacked(head))
+		if (page != head && PageSwapBacked(head)) {
+			wbc->for_reclaim = 0;
 			goto redirty;
+		}
 	}
 
 	swap = get_swap_page();
@@ -1660,7 +1761,8 @@ static struct page *shmem_alloc_page(gfp
 				split_page(head, HPAGE_PMD_ORDER);
 
 				/* Prepare head page for add_to_page_cache */
-				atomic_long_set(&head->team_usage, 0);
+				atomic_long_set(&head->team_usage,
+						TEAM_LRU_WEIGHT_ONE);
 				__SetPageTeam(head);
 				head->mapping = mapping;
 				head->index = round_down(index, HPAGE_PMD_NR);
--- thpfs.orig/mm/swap.c	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/mm/swap.c	2015-02-20 19:35:04.307871938 -0800
@@ -702,6 +702,11 @@ void lru_cache_add_active_or_unevictable
 					 struct vm_area_struct *vma)
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
+	/*
+	 * Using hpage_nr_pages() on a huge tmpfs team page might not give the
+	 * 1 NR_MLOCK needs below; but this seems to be for anon pages only.
+	 */
+	VM_BUG_ON_PAGE(!PageAnon(page), page);
 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
 		SetPageActive(page);
--- thpfs.orig/mm/vmscan.c	2015-02-20 19:34:11.235993287 -0800
+++ thpfs/mm/vmscan.c	2015-02-20 19:35:04.307871938 -0800
@@ -19,6 +19,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/vmpressure.h>
@@ -1419,6 +1420,42 @@ putback_inactive_pages(struct lruvec *lr
 			continue;
 		}
 
+		if (PageTeam(page) && !PageAnon(page) && !PageActive(page)) {
+			struct page *head = team_head(page);
+			struct address_space *mapping = head->mapping;
+			bool transferring_weight = false;
+			unsigned long flags;
+			/*
+			 * Team tail page was ready for eviction, but has
+			 * been sent back from shmem_writepage(): transfer
+			 * its weight to head, and move tail to unevictable.
+			 *
+			 * Barrier below so PageTeam guarantees good "mapping".
+			 */
+			smp_rmb();
+			if (page != head && PageTeam(head)) {
+				lruvec = mem_cgroup_page_lruvec(head, zone);
+				spin_lock_irqsave(&mapping->tree_lock, flags);
+				if (PageTeam(head)) {
+					inc_lru_weight(head);
+					transferring_weight = true;
+				}
+				spin_unlock_irqrestore(
+						&mapping->tree_lock, flags);
+			}
+			if (transferring_weight) {
+				if (PageLRU(head))
+					update_lru_size(lruvec,
+							page_lru(head), 1);
+				/* Get this tail page out of the way for now */
+				SetPageUnevictable(page);
+				clear_lru_weight(page);
+			} else {
+				/* Traditional case of unswapped & redirtied */
+				SetPageActive(page);
+			}
+		}
+
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		SetPageLRU(page);
@@ -3705,11 +3742,12 @@ int zone_reclaim(struct zone *zone, gfp_
  * Reasons page might not be evictable:
  * (1) page's mapping marked unevictable
  * (2) page is part of an mlocked VMA
- *
+ * (3) page is held in memory as part of a team
  */
 int page_evictable(struct page *page)
 {
-	return !mapping_unevictable(page_mapping(page)) && !PageMlocked(page);
+	return !mapping_unevictable(page_mapping(page)) &&
+		!PageMlocked(page) && hpage_nr_pages(page);
 }
 
 #ifdef CONFIG_SHMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
