Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86EEF6B4739
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:23:26 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id q141-v6so996026ywg.5
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:23:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u132-v6sor390946ywg.507.2018.08.28.10.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 10:23:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/9] mm: workingset: tell cache transitions from workingset thrashing
Date: Tue, 28 Aug 2018 13:22:51 -0400
Message-Id: <20180828172258.3185-3-hannes@cmpxchg.org>
In-Reply-To: <20180828172258.3185-1-hannes@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Refaults happen during transitions between workingsets as well as
in-place thrashing. Knowing the difference between the two has a range
of applications, including measuring the impact of memory shortage on
the system performance, as well as the ability to smarter balance
pressure between the filesystem cache and the swap-backed workingset.

During workingset transitions, inactive cache refaults and pushes out
established active cache. When that active cache isn't stale, however,
and also ends up refaulting, that's bonafide thrashing.

Introduce a new page flag that tells on eviction whether the page has
been active or not in its lifetime. This bit is then stored in the
shadow entry, to classify refaults as transitioning or thrashing.

How many page->flags does this leave us with on 32-bit?

	20 bits are always page flags

	21 if you have an MMU

	23 with the zone bits for DMA, Normal, HighMem, Movable

	29 with the sparsemem section bits

	30 if PAE is enabled

	31 with this patch.

So on 32-bit PAE, that leaves 1 bit for distinguishing two NUMA
nodes. If that's not enough, the system can switch to discontigmem and
re-gain the 6 or 7 sparsemem section bits.

v4:
- fix a typo in the comments, as per Suren

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h         |  1 +
 include/linux/page-flags.h     |  5 +-
 include/linux/swap.h           |  2 +-
 include/trace/events/mmflags.h |  1 +
 mm/filemap.c                   |  9 ++--
 mm/huge_memory.c               |  1 +
 mm/memcontrol.c                |  2 +
 mm/migrate.c                   |  2 +
 mm/swap_state.c                |  1 +
 mm/vmscan.c                    |  1 +
 mm/vmstat.c                    |  1 +
 mm/workingset.c                | 95 ++++++++++++++++++++++------------
 12 files changed, 79 insertions(+), 42 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..6af87946d241 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -163,6 +163,7 @@ enum node_stat_item {
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
+	WORKINGSET_RESTORE,
 	WORKINGSET_NODERECLAIM,
 	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 901943e4754b..79346bc1da7a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -69,13 +69,14 @@
  */
 enum pageflags {
 	PG_locked,		/* Page is locked. Don't touch. */
-	PG_error,
 	PG_referenced,
 	PG_uptodate,
 	PG_dirty,
 	PG_lru,
 	PG_active,
+	PG_workingset,
 	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
+	PG_error,
 	PG_slab,
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
 	PG_arch_1,
@@ -280,6 +281,8 @@ PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
 PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
 PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
+PAGEFLAG(Workingset, workingset, PF_HEAD)
+	TESTCLEARFLAG(Workingset, workingset, PF_HEAD)
 __PAGEFLAG(Slab, slab, PF_NO_TAIL)
 __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c063443d8638..d8822365782b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -296,7 +296,7 @@ struct vma_swap_readahead {
 
 /* linux/mm/workingset.c */
 void *workingset_eviction(struct address_space *mapping, struct page *page);
-bool workingset_refault(void *shadow);
+void workingset_refault(struct page *page, void *shadow);
 void workingset_activation(struct page *page);
 
 /* Do not use directly, use workingset_lookup_update */
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a81cffb76d89..a1675d43777e 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -88,6 +88,7 @@
 	{1UL << PG_dirty,		"dirty"		},		\
 	{1UL << PG_lru,			"lru"		},		\
 	{1UL << PG_active,		"active"	},		\
+	{1UL << PG_workingset,		"workingset"	},		\
 	{1UL << PG_slab,		"slab"		},		\
 	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
 	{1UL << PG_arch_1,		"arch_1"	},		\
diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..5e53424d9097 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -915,12 +915,9 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		 * data from the working set, only to cache data that will
 		 * get overwritten with something else, is a waste of memory.
 		 */
-		if (!(gfp_mask & __GFP_WRITE) &&
-		    shadow && workingset_refault(shadow)) {
-			SetPageActive(page);
-			workingset_activation(page);
-		} else
-			ClearPageActive(page);
+		WARN_ON_ONCE(PageActive(page));
+		if (!(gfp_mask & __GFP_WRITE) && shadow)
+			workingset_refault(page, shadow);
 		lru_cache_add(page);
 	}
 	return ret;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 25346bd99364..04d663c58bbe 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2369,6 +2369,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
+			 (1L << PG_workingset) |
 			 (1L << PG_locked) |
 			 (1L << PG_unevictable) |
 			 (1L << PG_dirty)));
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2173f7e5164..84824b775470 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5329,6 +5329,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   stat[WORKINGSET_REFAULT]);
 	seq_printf(m, "workingset_activate %lu\n",
 		   stat[WORKINGSET_ACTIVATE]);
+	seq_printf(m, "workingset_restore %lu\n",
+		   stat[WORKINGSET_RESTORE]);
 	seq_printf(m, "workingset_nodereclaim %lu\n",
 		   stat[WORKINGSET_NODERECLAIM]);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 8c0af0f7cab1..a6a9114e62dc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -682,6 +682,8 @@ void migrate_page_states(struct page *newpage, struct page *page)
 		SetPageActive(newpage);
 	} else if (TestClearPageUnevictable(page))
 		SetPageUnevictable(newpage);
+	if (PageWorkingset(page))
+		SetPageWorkingset(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ecee9c6c4cc1..0d6a7f268d2e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -448,6 +448,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			/*
 			 * Initiate read into locked page and return.
 			 */
+			SetPageWorkingset(new_page);
 			lru_cache_add_anon(new_page);
 			*new_page_allocated = true;
 			return new_page;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f86f288..7fdbc18fea6f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1976,6 +1976,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		ClearPageActive(page);	/* we are de-activating */
+		SetPageWorkingset(page);
 		list_add(&page->lru, &l_inactive);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8ba0870ecddd..28f2faad95d4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1145,6 +1145,7 @@ const char * const vmstat_text[] = {
 	"nr_isolated_file",
 	"workingset_refault",
 	"workingset_activate",
+	"workingset_restore",
 	"workingset_nodereclaim",
 	"nr_anon_pages",
 	"nr_mapped",
diff --git a/mm/workingset.c b/mm/workingset.c
index 53759a3cf99a..f1bbce55ea60 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -121,7 +121,7 @@
  * the only thing eating into inactive list space is active pages.
  *
  *
- *		Activating refaulting pages
+ *		Refaulting inactive pages
  *
  * All that is known about the active list is that the pages have been
  * accessed more than once in the past.  This means that at any given
@@ -134,6 +134,10 @@
  * used less frequently than the refaulting page - or even not used at
  * all anymore.
  *
+ * That means if inactive cache is refaulting with a suitable refault
+ * distance, we assume the cache workingset is transitioning and put
+ * pressure on the current active list.
+ *
  * If this is wrong and demotion kicks in, the pages which are truly
  * used more frequently will be reactivated while the less frequently
  * used once will be evicted from memory.
@@ -141,6 +145,14 @@
  * But if this is right, the stale pages will be pushed out of memory
  * and the used pages get to stay in cache.
  *
+ *		Refaulting active pages
+ *
+ * If on the other hand the refaulting pages have recently been
+ * deactivated, it means that the active list is no longer protecting
+ * actively used cache from reclaim. The cache is NOT transitioning to
+ * a different workingset; the existing workingset is thrashing in the
+ * space allocated to the page cache.
+ *
  *
  *		Implementation
  *
@@ -156,8 +168,7 @@
  */
 
 #define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
-			 NODES_SHIFT +	\
-			 MEM_CGROUP_ID_SHIFT)
+			 1 + NODES_SHIFT + MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
 
 /*
@@ -170,23 +181,28 @@
  */
 static unsigned int bucket_order __read_mostly;
 
-static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
+static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction,
+			 bool workingset)
 {
 	eviction >>= bucket_order;
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
+	eviction = (eviction << 1) | workingset;
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
 
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
 static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
-			  unsigned long *evictionp)
+			  unsigned long *evictionp, bool *workingsetp)
 {
 	unsigned long entry = (unsigned long)shadow;
 	int memcgid, nid;
+	bool workingset;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
+	workingset = entry & 1;
+	entry >>= 1;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
 	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
@@ -195,6 +211,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 	*memcgidp = memcgid;
 	*pgdat = NODE_DATA(nid);
 	*evictionp = entry << bucket_order;
+	*workingsetp = workingset;
 }
 
 /**
@@ -207,8 +224,8 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
  */
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
-	struct mem_cgroup *memcg = page_memcg(page);
 	struct pglist_data *pgdat = page_pgdat(page);
+	struct mem_cgroup *memcg = page_memcg(page);
 	int memcgid = mem_cgroup_id(memcg);
 	unsigned long eviction;
 	struct lruvec *lruvec;
@@ -220,30 +237,30 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	eviction = atomic_long_inc_return(&lruvec->inactive_age);
-	return pack_shadow(memcgid, pgdat, eviction);
+	return pack_shadow(memcgid, pgdat, eviction, PageWorkingset(page));
 }
 
 /**
  * workingset_refault - evaluate the refault of a previously evicted page
+ * @page: the freshly allocated replacement page
  * @shadow: shadow entry of the evicted page
  *
  * Calculates and evaluates the refault distance of the previously
  * evicted page in the context of the node it was allocated in.
- *
- * Returns %true if the page should be activated, %false otherwise.
  */
-bool workingset_refault(void *shadow)
+void workingset_refault(struct page *page, void *shadow)
 {
 	unsigned long refault_distance;
+	struct pglist_data *pgdat;
 	unsigned long active_file;
 	struct mem_cgroup *memcg;
 	unsigned long eviction;
 	struct lruvec *lruvec;
 	unsigned long refault;
-	struct pglist_data *pgdat;
+	bool workingset;
 	int memcgid;
 
-	unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
+	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &workingset);
 
 	rcu_read_lock();
 	/*
@@ -263,41 +280,51 @@ bool workingset_refault(void *shadow)
 	 * configurations instead.
 	 */
 	memcg = mem_cgroup_from_id(memcgid);
-	if (!mem_cgroup_disabled() && !memcg) {
-		rcu_read_unlock();
-		return false;
-	}
+	if (!mem_cgroup_disabled() && !memcg)
+		goto out;
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES);
 
 	/*
-	 * The unsigned subtraction here gives an accurate distance
-	 * across inactive_age overflows in most cases.
+	 * Calculate the refault distance
 	 *
-	 * There is a special case: usually, shadow entries have a
-	 * short lifetime and are either refaulted or reclaimed along
-	 * with the inode before they get too old.  But it is not
-	 * impossible for the inactive_age to lap a shadow entry in
-	 * the field, which can then can result in a false small
-	 * refault distance, leading to a false activation should this
-	 * old entry actually refault again.  However, earlier kernels
-	 * used to deactivate unconditionally with *every* reclaim
-	 * invocation for the longest time, so the occasional
-	 * inappropriate activation leading to pressure on the active
-	 * list is not a problem.
+	 * The unsigned subtraction here gives an accurate distance
+	 * across inactive_age overflows in most cases. There is a
+	 * special case: usually, shadow entries have a short lifetime
+	 * and are either refaulted or reclaimed along with the inode
+	 * before they get too old.  But it is not impossible for the
+	 * inactive_age to lap a shadow entry in the field, which can
+	 * then result in a false small refault distance, leading to a
+	 * false activation should this old entry actually refault
+	 * again.  However, earlier kernels used to deactivate
+	 * unconditionally with *every* reclaim invocation for the
+	 * longest time, so the occasional inappropriate activation
+	 * leading to pressure on the active list is not a problem.
 	 */
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
 	inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
 
-	if (refault_distance <= active_file) {
-		inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
-		rcu_read_unlock();
-		return true;
+	/*
+	 * Compare the distance to the existing workingset size. We
+	 * don't act on pages that couldn't stay resident even if all
+	 * the memory was available to the page cache.
+	 */
+	if (refault_distance > active_file)
+		goto out;
+
+	SetPageActive(page);
+	atomic_long_inc(&lruvec->inactive_age);
+	inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+
+	/* Page was active prior to eviction */
+	if (workingset) {
+		SetPageWorkingset(page);
+		inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
 	}
+out:
 	rcu_read_unlock();
-	return false;
 }
 
 /**
-- 
2.18.0
