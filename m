Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C62D6B028E
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:20:09 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id td3so18107741pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:20:09 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id g17si5230811pfj.184.2016.04.05.14.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:20:07 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id e128so18405852pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:20:07 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:20:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 06/31] huge tmpfs: shrinker to migrate and free underused
 holes
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051417530.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Using 2MB for each small file is wasteful, and on average even a large
file is likely to waste 1MB at the end.  We could say that a huge tmpfs
is only suitable for huge files, but I would much prefer not to limit
it in that way, and would not be very able to test such a filesystem.

In our model, the unused space in the team is not put on any LRU (nor
charged to any memcg), so not yet accessible to page reclaim: we need
a shrinker to disband the team, and free up the unused space, under
memory pressure.  (Typically the freeable space is at the end, but
there's no assumption that it's at end of huge page or end of file.)

shmem_shrink_hugehole() is usually called from vmscan's shrink_slabs();
but I've found a direct call from shmem_alloc_page(), when it fails
to allocate a huge page (perhaps because too much memory is occupied
by shmem huge holes), is also helpful before a retry.

But each team holds a valuable resource: an extent of contiguous
memory that could be used for another team (or for an anonymous THP).
So try to proceed in such a way as to conserve that resource: rather
than just freeing the unused space and leaving yet another huge page
fragmented, also try to migrate the used space to another partially
occupied huge page.

The algorithm in shmem_choose_hugehole() (find least occupied huge page
in older half of shrinklist, and migrate its cachepages into the most
occupied huge page with enough space to fit, again chosen from older
half of shrinklist) is unlikely to be ideal; but easy to implement as
a demonstration of the pieces which can be used by any algorithm,
and good enough for now.  A radix_tree tag helps to locate the
partially occupied huge pages more quickly: the tag available
since shmem does not participate in dirty/writeback accounting.

The "team_usage" field added to struct page (in union with "private")
is somewhat vaguely named: because while the huge page is sparsely
occupied, it counts the occupancy; but once the huge page is fully
occupied, it will come to be used differently in a later patch, as
the huge mapcount (offset by the HPAGE_PMD_NR occupancy) - it is
never possible to map a sparsely occupied huge page, because that
would expose stale data to the user.

With this patch, the ShmemHugePages and ShmemFreeHoles lines of
/proc/meminfo are shown correctly; but ShmemPmdMapped remains 0.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/tmpfs.txt |    9 
 include/linux/migrate.h             |    1 
 include/linux/mm_types.h            |    1 
 include/linux/shmem_fs.h            |    3 
 include/trace/events/migrate.h      |    3 
 mm/shmem.c                          |  440 +++++++++++++++++++++++++-
 6 files changed, 443 insertions(+), 14 deletions(-)

--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -159,6 +159,15 @@ may require compaction), and slower to s
 (since a team of small pages is managed instead of a single compound page);
 but once set up and mapped, huge tmpfs performance should match hugetlbfs.
 
+When a file is created on a huge tmpfs (or copied there), a hugepage is
+allocated to it if possible.  Initially only one small page of the hugepage
+will actually be used for the file: then the neighbouring free holes filled
+as more data is added, until the hugepage is completed.  But if the hugepage
+is left incomplete, and memory needs to be reclaimed, then a shrinker can
+disband the team and free those holes; or page reclaim disband the team
+and swap out the tmpfs pagecache.  Free holes are not charged to any
+memcg, and are counted in MemAvailable; but are not counted in MemFree.
+
 /proc/sys/vm/shmem_huge (intended for experimentation only):
 
 Default 0; write 1 to set tmpfs mount option huge=1 on the kernel's
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -24,6 +24,7 @@ enum migrate_reason {
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
 	MR_CMA,
+	MR_SHMEM_HUGEHOLE,
 	MR_TYPES
 };
 
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -183,6 +183,7 @@ struct page {
 #endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+		atomic_long_t team_usage;	/* In shmem's PageTeam page */
 	};
 
 #ifdef CONFIG_MEMCG
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -16,8 +16,9 @@ struct shmem_inode_info {
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
 	unsigned long		swapped;	/* subtotal assigned to swap */
-	struct shared_policy	policy;		/* NUMA memory alloc policy */
+	struct list_head	shrinklist;	/* shrinkable hpage inodes */
 	struct list_head	swaplist;	/* chain of maybes on swap */
+	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
 	struct inode		vfs_inode;
 };
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -19,7 +19,8 @@
 	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
-	EMe(MR_CMA,		"cma")
+	EM( MR_CMA,		"cma")				\
+	EMe(MR_SHMEM_HUGEHOLE,	"shmem_hugehole")
 
 /*
  * First define the enums in the above macros to be exported to userspace
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -58,6 +58,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/falloc.h>
 #include <linux/splice.h>
 #include <linux/security.h>
+#include <linux/shrinker.h>
 #include <linux/sysctl.h>
 #include <linux/swapops.h>
 #include <linux/pageteam.h>
@@ -304,6 +305,14 @@ static bool shmem_confirm_swap(struct ad
 #define SHMEM_RETRY_HUGE_PAGE	((struct page *)3)
 /* otherwise hugehint is the hugeteam page to be used */
 
+/* tag for shrinker to locate unfilled hugepages */
+#define SHMEM_TAG_HUGEHOLE	PAGECACHE_TAG_DIRTY
+
+/* list of inodes with unfilled hugepages, from which shrinker may free */
+static LIST_HEAD(shmem_shrinklist);
+static unsigned long shmem_shrinklist_depth;
+static DEFINE_SPINLOCK(shmem_shrinklist_lock);
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
@@ -358,28 +367,106 @@ restart:
 	return page;
 }
 
+static int shmem_freeholes(struct page *head)
+{
+	unsigned long nr = atomic_long_read(&head->team_usage);
+
+	return (nr >= HPAGE_PMD_NR) ? 0 : HPAGE_PMD_NR - nr;
+}
+
+static void shmem_clear_tag_hugehole(struct address_space *mapping,
+				     pgoff_t index)
+{
+	struct page *page = NULL;
+
+	/*
+	 * The tag was set on the first subpage to be inserted in cache.
+	 * When written sequentially, or instantiated by a huge fault,
+	 * it will be on the head page, but that's not always so.  And
+	 * radix_tree_tag_clear() succeeds when it finds a slot, whether
+	 * tag was set on it or not.  So first lookup and then clear.
+	 */
+	radix_tree_gang_lookup_tag(&mapping->page_tree, (void **)&page,
+					index, 1, SHMEM_TAG_HUGEHOLE);
+	VM_BUG_ON(!page || page->index >= index + HPAGE_PMD_NR);
+	radix_tree_tag_clear(&mapping->page_tree, page->index,
+					SHMEM_TAG_HUGEHOLE);
+}
+
+static void shmem_added_to_hugeteam(struct page *page, struct zone *zone,
+				    struct page *hugehint)
+{
+	struct address_space *mapping = page->mapping;
+	struct page *head = team_head(page);
+	int nr;
+
+	if (hugehint == SHMEM_ALLOC_HUGE_PAGE) {
+		atomic_long_set(&head->team_usage, 1);
+		radix_tree_tag_set(&mapping->page_tree, page->index,
+					SHMEM_TAG_HUGEHOLE);
+		__mod_zone_page_state(zone, NR_SHMEM_FREEHOLES, HPAGE_PMD_NR-1);
+	} else {
+		/* We do not need atomic ops until huge page gets mapped */
+		nr = atomic_long_read(&head->team_usage) + 1;
+		atomic_long_set(&head->team_usage, nr);
+		if (nr == HPAGE_PMD_NR) {
+			shmem_clear_tag_hugehole(mapping, head->index);
+			__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
+		}
+		__dec_zone_state(zone, NR_SHMEM_FREEHOLES);
+	}
+}
+
 static int shmem_disband_hugehead(struct page *head)
 {
 	struct address_space *mapping;
 	struct zone *zone;
 	int nr = -EALREADY;	/* A racing task may have disbanded the team */
 
-	mapping = head->mapping;
-	zone = page_zone(head);
+	/*
+	 * In most cases the head page is locked, or not yet exposed to others:
+	 * only in the shrinker migration case might head have been truncated.
+	 * But although head->mapping may then be zeroed at any moment, mapping
+	 * stays safe because shmem_evict_inode must take the shrinklist_lock,
+	 * and our caller shmem_choose_hugehole is already holding that lock.
+	 */
+	mapping = READ_ONCE(head->mapping);
+	if (!mapping)
+		return nr;
 
+	zone = page_zone(head);
 	spin_lock_irq(&mapping->tree_lock);
+
 	if (PageTeam(head)) {
+		nr = atomic_long_read(&head->team_usage);
+		atomic_long_set(&head->team_usage, 0);
+		/*
+		 * Disable additions to the team.
+		 * Ensure head->private is written before PageTeam is
+		 * cleared, so shmem_writepage() cannot write swap into
+		 * head->private, then have it overwritten by that 0!
+		 */
+		smp_mb__before_atomic();
 		ClearPageTeam(head);
 		if (!PageSwapBacked(head))
 			head->mapping = NULL;
-		__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
-		nr = 0;
+
+		if (nr >= HPAGE_PMD_NR) {
+			__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
+			VM_BUG_ON(nr != HPAGE_PMD_NR);
+		} else if (nr) {
+			shmem_clear_tag_hugehole(mapping, head->index);
+			__mod_zone_page_state(zone, NR_SHMEM_FREEHOLES,
+						nr - HPAGE_PMD_NR);
+		}
 	}
+
 	spin_unlock_irq(&mapping->tree_lock);
 	return nr;
 }
 
-static void shmem_disband_hugetails(struct page *head)
+static void shmem_disband_hugetails(struct page *head,
+				    struct list_head *list, int nr)
 {
 	struct page *page;
 	struct page *endpage;
@@ -387,7 +474,7 @@ static void shmem_disband_hugetails(stru
 	page = head;
 	endpage = head + HPAGE_PMD_NR;
 
-	/* Condition follows in next but one commit */ {
+	if (!nr) {
 		/*
 		 * The usual case: disbanding team and freeing holes as cold
 		 * (cold being more likely to preserve high-order extents).
@@ -402,7 +489,50 @@ static void shmem_disband_hugetails(stru
 			else if (put_page_testzero(page))
 				free_hot_cold_page(page, 1);
 		}
+	} else if (nr < 0) {
+		struct zone *zone = page_zone(page);
+		int orig_nr = nr;
+		/*
+		 * Shrinker wants to migrate cache pages from this team.
+		 */
+		if (!PageSwapBacked(page)) {	/* head was not in cache */
+			if (put_page_testzero(page))
+				free_hot_cold_page(page, 1);
+		} else if (isolate_lru_page(page) == 0) {
+			list_add_tail(&page->lru, list);
+			nr++;
+		}
+		while (++page < endpage) {
+			if (PageTeam(page)) {
+				if (isolate_lru_page(page) == 0) {
+					list_add_tail(&page->lru, list);
+					nr++;
+				}
+				ClearPageTeam(page);
+			} else if (put_page_testzero(page))
+				free_hot_cold_page(page, 1);
+		}
+		/* Yes, shmem counts in NR_ISOLATED_ANON but NR_FILE_PAGES */
+		mod_zone_page_state(zone, NR_ISOLATED_ANON, nr - orig_nr);
+	} else {
+		/*
+		 * Shrinker wants free pages from this team to migrate into.
+		 */
+		if (!PageSwapBacked(page)) {	/* head was not in cache */
+			list_add_tail(&page->lru, list);
+			nr--;
+		}
+		while (++page < endpage) {
+			if (PageTeam(page))
+				ClearPageTeam(page);
+			else if (nr) {
+				list_add_tail(&page->lru, list);
+				nr--;
+			} else if (put_page_testzero(page))
+				free_hot_cold_page(page, 1);
+		}
 	}
+	VM_BUG_ON(nr > 0);	/* maybe a few were not isolated */
 }
 
 static void shmem_disband_hugeteam(struct page *page)
@@ -444,12 +574,254 @@ static void shmem_disband_hugeteam(struc
 	if (head != page)
 		unlock_page(head);
 	if (nr_used >= 0)
-		shmem_disband_hugetails(head);
+		shmem_disband_hugetails(head, NULL, 0);
 	if (head != page)
 		put_page(head);
 	preempt_enable();
 }
 
+static struct page *shmem_get_hugehole(struct address_space *mapping,
+				       unsigned long *index)
+{
+	struct page *page;
+	struct page *head;
+
+	rcu_read_lock();
+	while (radix_tree_gang_lookup_tag(&mapping->page_tree, (void **)&page,
+					  *index, 1, SHMEM_TAG_HUGEHOLE)) {
+		if (radix_tree_exception(page))
+			continue;
+		if (!page_cache_get_speculative(page))
+			continue;
+		if (!PageTeam(page) || page->mapping != mapping)
+			goto release;
+		head = team_head(page);
+		if (head != page) {
+			if (!page_cache_get_speculative(head))
+				goto release;
+			put_page(page);
+			page = head;
+			if (!PageTeam(page) || page->mapping != mapping)
+				goto release;
+		}
+		if (shmem_freeholes(head) > 0) {
+			rcu_read_unlock();
+			*index = head->index + HPAGE_PMD_NR;
+			return head;
+		}
+release:
+		put_page(page);
+	}
+	rcu_read_unlock();
+	return NULL;
+}
+
+static unsigned long shmem_choose_hugehole(struct list_head *fromlist,
+					   struct list_head *tolist)
+{
+	unsigned long freed = 0;
+	unsigned long double_depth;
+	struct list_head *this, *next;
+	struct shmem_inode_info *info;
+	struct address_space *mapping;
+	struct page *frompage = NULL;
+	struct page *topage = NULL;
+	struct page *page;
+	pgoff_t index;
+	int fromused;
+	int toused;
+	int nid;
+
+	double_depth = 0;
+	spin_lock(&shmem_shrinklist_lock);
+	list_for_each_safe(this, next, &shmem_shrinklist) {
+		info = list_entry(this, struct shmem_inode_info, shrinklist);
+		mapping = info->vfs_inode.i_mapping;
+		if (!radix_tree_tagged(&mapping->page_tree,
+					SHMEM_TAG_HUGEHOLE)) {
+			list_del_init(&info->shrinklist);
+			shmem_shrinklist_depth--;
+			continue;
+		}
+		index = 0;
+		while ((page = shmem_get_hugehole(mapping, &index))) {
+			/* Choose to migrate from page with least in use */
+			if (!frompage ||
+			    shmem_freeholes(page) > shmem_freeholes(frompage)) {
+				if (frompage)
+					put_page(frompage);
+				frompage = page;
+				if (shmem_freeholes(page) == HPAGE_PMD_NR-1) {
+					/* No point searching further */
+					double_depth = -3;
+					break;
+				}
+			} else
+				put_page(page);
+		}
+
+		/* Only reclaim from the older half of the shrinklist */
+		double_depth += 2;
+		if (double_depth >= min(shmem_shrinklist_depth, 2000UL))
+			break;
+	}
+
+	if (!frompage)
+		goto unlock;
+	preempt_disable();
+	fromused = shmem_disband_hugehead(frompage);
+	spin_unlock(&shmem_shrinklist_lock);
+	if (fromused > 0)
+		shmem_disband_hugetails(frompage, fromlist, -fromused);
+	preempt_enable();
+	nid = page_to_nid(frompage);
+	put_page(frompage);
+
+	if (fromused <= 0)
+		return 0;
+	freed = HPAGE_PMD_NR - fromused;
+	if (fromused > HPAGE_PMD_NR/2)
+		return freed;
+
+	double_depth = 0;
+	spin_lock(&shmem_shrinklist_lock);
+	list_for_each_safe(this, next, &shmem_shrinklist) {
+		info = list_entry(this, struct shmem_inode_info, shrinklist);
+		mapping = info->vfs_inode.i_mapping;
+		if (!radix_tree_tagged(&mapping->page_tree,
+					SHMEM_TAG_HUGEHOLE)) {
+			list_del_init(&info->shrinklist);
+			shmem_shrinklist_depth--;
+			continue;
+		}
+		index = 0;
+		while ((page = shmem_get_hugehole(mapping, &index))) {
+			/* Choose to migrate to page with just enough free */
+			if (shmem_freeholes(page) >= fromused &&
+			    page_to_nid(page) == nid) {
+				if (!topage || shmem_freeholes(page) <
+					      shmem_freeholes(topage)) {
+					if (topage)
+						put_page(topage);
+					topage = page;
+					if (shmem_freeholes(page) == fromused) {
+						/* No point searching further */
+						double_depth = -3;
+						break;
+					}
+				} else
+					put_page(page);
+			} else
+				put_page(page);
+		}
+
+		/* Only reclaim from the older half of the shrinklist */
+		double_depth += 2;
+		if (double_depth >= min(shmem_shrinklist_depth, 2000UL))
+			break;
+	}
+
+	if (!topage)
+		goto unlock;
+	preempt_disable();
+	toused = shmem_disband_hugehead(topage);
+	spin_unlock(&shmem_shrinklist_lock);
+	if (toused > 0) {
+		if (HPAGE_PMD_NR - toused >= fromused)
+			shmem_disband_hugetails(topage, tolist, fromused);
+		else
+			shmem_disband_hugetails(topage, NULL, 0);
+		freed += HPAGE_PMD_NR - toused;
+	}
+	preempt_enable();
+	put_page(topage);
+	return freed;
+unlock:
+	spin_unlock(&shmem_shrinklist_lock);
+	return freed;
+}
+
+static struct page *shmem_get_migrate_page(struct page *frompage,
+					   unsigned long private, int **result)
+{
+	struct list_head *tolist = (struct list_head *)private;
+	struct page *topage;
+
+	VM_BUG_ON(list_empty(tolist));
+	topage = list_first_entry(tolist, struct page, lru);
+	list_del(&topage->lru);
+	return topage;
+}
+
+static void shmem_put_migrate_page(struct page *topage, unsigned long private)
+{
+	struct list_head *tolist = (struct list_head *)private;
+
+	list_add(&topage->lru, tolist);
+}
+
+static void shmem_putback_migrate_pages(struct list_head *tolist)
+{
+	struct page *topage;
+	struct page *next;
+
+	/*
+	 * The tolist pages were not counted in NR_ISOLATED, so stats
+	 * would go wrong if putback_movable_pages() were used on them.
+	 * Indeed, even putback_lru_page() is wrong for these pages.
+	 */
+	list_for_each_entry_safe(topage, next, tolist, lru) {
+		list_del(&topage->lru);
+		if (put_page_testzero(topage))
+			free_hot_cold_page(topage, 1);
+	}
+}
+
+static unsigned long shmem_shrink_hugehole(struct shrinker *shrink,
+					   struct shrink_control *sc)
+{
+	unsigned long freed;
+	LIST_HEAD(fromlist);
+	LIST_HEAD(tolist);
+
+	if (list_empty(&shmem_shrinklist))
+		return SHRINK_STOP;
+	freed = shmem_choose_hugehole(&fromlist, &tolist);
+	if (list_empty(&fromlist))
+		return SHRINK_STOP;
+	if (!list_empty(&tolist)) {
+		migrate_pages(&fromlist, shmem_get_migrate_page,
+			      shmem_put_migrate_page, (unsigned long)&tolist,
+			      MIGRATE_SYNC, MR_SHMEM_HUGEHOLE);
+		preempt_disable();
+		drain_local_pages(NULL);  /* try to preserve huge freed page */
+		preempt_enable();
+		shmem_putback_migrate_pages(&tolist);
+	}
+	putback_movable_pages(&fromlist); /* if any were left behind */
+	return freed;
+}
+
+static unsigned long shmem_count_hugehole(struct shrinker *shrink,
+					  struct shrink_control *sc)
+{
+	/*
+	 * Huge hole space is not charged to any memcg:
+	 * only shrink it for global reclaim.
+	 * But at present we're only called for global reclaim anyway.
+	 */
+	if (list_empty(&shmem_shrinklist))
+		return 0;
+	return global_page_state(NR_SHMEM_FREEHOLES);
+}
+
+static struct shrinker shmem_hugehole_shrinker = {
+	.count_objects = shmem_count_hugehole,
+	.scan_objects = shmem_shrink_hugehole,
+	.seeks = DEFAULT_SEEKS,		/* would another value work better? */
+	.batch = HPAGE_PMD_NR,		/* would another value work better? */
+};
+
 #else /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define shmem_huge SHMEM_HUGE_DENY
@@ -465,6 +837,17 @@ static inline void shmem_disband_hugetea
 {
 	BUILD_BUG();
 }
+
+static inline void shmem_added_to_hugeteam(struct page *page,
+				struct zone *zone, struct page *hugehint)
+{
+}
+
+static inline unsigned long shmem_shrink_hugehole(struct shrinker *shrink,
+						  struct shrink_control *sc)
+{
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /*
@@ -504,10 +887,10 @@ shmem_add_to_page_cache(struct page *pag
 	if (unlikely(error))
 		goto errout;
 
-	if (!PageTeam(page))
+	if (PageTeam(page))
+		shmem_added_to_hugeteam(page, zone, hugehint);
+	else
 		get_page(page);
-	else if (hugehint == SHMEM_ALLOC_HUGE_PAGE)
-		__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
 
 	mapping->nrpages++;
 	__inc_zone_state(zone, NR_FILE_PAGES);
@@ -932,6 +1315,14 @@ static void shmem_evict_inode(struct ino
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
 		shmem_truncate_range(inode, 0, (loff_t)-1);
+		if (!list_empty(&info->shrinklist)) {
+			spin_lock(&shmem_shrinklist_lock);
+			if (!list_empty(&info->shrinklist)) {
+				list_del_init(&info->shrinklist);
+				shmem_shrinklist_depth--;
+			}
+			spin_unlock(&shmem_shrinklist_lock);
+		}
 		if (!list_empty(&info->swaplist)) {
 			mutex_lock(&shmem_swaplist_mutex);
 			list_del_init(&info->swaplist);
@@ -1286,10 +1677,18 @@ static struct page *shmem_alloc_page(gfp
 			head = alloc_pages_vma(gfp|__GFP_NORETRY|__GFP_NOWARN,
 				HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(),
 				true);
+			if (!head &&
+			    shmem_shrink_hugehole(NULL, NULL) != SHRINK_STOP) {
+				head = alloc_pages_vma(
+					gfp|__GFP_NORETRY|__GFP_NOWARN,
+					HPAGE_PMD_ORDER, &pvma, 0,
+					numa_node_id(), true);
+			}
 			if (head) {
 				split_page(head, HPAGE_PMD_ORDER);
 
 				/* Prepare head page for add_to_page_cache */
+				atomic_long_set(&head->team_usage, 0);
 				__SetPageTeam(head);
 				head->mapping = mapping;
 				head->index = round_down(index, HPAGE_PMD_NR);
@@ -1613,6 +2012,21 @@ repeat:
 		alloced = true;
 
 		/*
+		 * Might we see !list_empty a moment before the shrinker
+		 * removes this inode from its list?  Unlikely, since we
+		 * already set a tag in the tree.  Some barrier required?
+		 */
+		if (alloced_huge && list_empty(&info->shrinklist)) {
+			spin_lock(&shmem_shrinklist_lock);
+			if (list_empty(&info->shrinklist)) {
+				list_add_tail(&info->shrinklist,
+					      &shmem_shrinklist);
+				shmem_shrinklist_depth++;
+			}
+			spin_unlock(&shmem_shrinklist_lock);
+		}
+
+		/*
 		 * Let SGP_FALLOC use the SGP_WRITE optimization on a new page.
 		 */
 		if (sgp == SGP_FALLOC)
@@ -1823,6 +2237,7 @@ static struct inode *shmem_get_inode(str
 		spin_lock_init(&info->lock);
 		info->seals = F_SEAL_SEAL;
 		info->flags = flags & VM_NORESERVE;
+		INIT_LIST_HEAD(&info->shrinklist);
 		INIT_LIST_HEAD(&info->swaplist);
 		simple_xattrs_init(&info->xattrs);
 		cache_no_acl(inode);
@@ -3613,9 +4028,10 @@ int __init shmem_init(void)
 	}
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	if (has_transparent_hugepage())
+	if (has_transparent_hugepage()) {
 		SHMEM_SB(shm_mnt->mnt_sb)->huge = (shmem_huge > 0);
-	else
+		register_shrinker(&shmem_hugehole_shrinker);
+	} else
 		shmem_huge = 0;	/* just in case it was patched */
 #endif
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
