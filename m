Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 53F626B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 15:55:24 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so6113624wes.22
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:55:23 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fi1si9824708wib.89.2014.06.16.12.55.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 12:55:22 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 12/12] mm: memcontrol: rewrite uncharge API
Date: Mon, 16 Jun 2014 15:54:32 -0400
Message-Id: <1402948472-8175-13-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The memcg uncharging code that is involved towards the end of a page's
lifetime - truncation, reclaim, swapout, migration - is impressively
complicated and fragile.

Because anonymous and file pages were always charged before they had
their page->mapping established, uncharges had to happen when the page
type could still be known from the context; as in unmap for anonymous,
page cache removal for file and shmem pages, and swap cache truncation
for swap pages.  However, these operations happen well before the page
is actually freed, and so a lot of synchronization is necessary:

- Charging, uncharging, page migration, and charge migration all need
  to take a per-page bit spinlock as they could race with uncharging.

- Swap cache truncation happens during both swap-in and swap-out, and
  possibly repeatedly before the page is actually freed.  This means
  that the memcg swapout code is called from many contexts that make
  no sense and it has to figure out the direction from page state to
  make sure memory and memory+swap are always correctly charged.

- On page migration, the old page might be unmapped but then reused,
  so memcg code has to prevent untimely uncharging in that case.
  Because this code - which should be a simple charge transfer - is so
  special-cased, it is not reusable for replace_page_cache().

But now that charged pages always have a page->mapping, introduce
mem_cgroup_uncharge(), which is called after the final put_page(),
when we know for sure that nobody is looking at the page anymore.

For page migration, introduce mem_cgroup_migrate(), which is called
after the migration is successful and the new page is fully rmapped.
Because the old page is no longer uncharged after migration, prevent
double charges by decoupling the page's memcg association (PCG_USED
and pc->mem_cgroup) from the page holding an actual charge.  The new
bits PCG_MEM and PCG_MEMSW represent the respective charges and are
transferred to the new page during migration.

mem_cgroup_migrate() is suitable for replace_page_cache() as well,
which gets rid of mem_cgroup_replace_page_cache().

Swap accounting is massively simplified: because the page is no longer
uncharged as early as swap cache deletion, a new mem_cgroup_swapout()
can transfer the page's memory+swap charge (PCG_MEMSW) to the swap
entry before the final put_page() in page reclaim.

Finally, page_cgroup changes are now protected by whatever protection
the page itself offers: anonymous pages are charged under the page
table lock, whereas page cache insertions, swapin, and migration hold
the page lock.  Uncharging happens under full exclusion with no
outstanding references.  Charging and uncharging also ensure that the
page is off-LRU, which serializes against charge migration.  Remove
the very costly page_cgroup lock and set pc->flags non-atomically.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/memcg_test.txt | 128 +------
 include/linux/memcontrol.h           |  49 +--
 include/linux/page_cgroup.h          |  43 +--
 include/linux/swap.h                 |  12 +-
 mm/filemap.c                         |   4 +-
 mm/memcontrol.c                      | 684 ++++++++++++-----------------------
 mm/memory.c                          |   2 -
 mm/migrate.c                         |  44 +--
 mm/rmap.c                            |   1 -
 mm/shmem.c                           |   8 +-
 mm/swap.c                            |   6 +
 mm/swap_state.c                      |   8 +-
 mm/swapfile.c                        |   7 +-
 mm/truncate.c                        |   9 -
 mm/vmscan.c                          |  12 +-
 mm/zswap.c                           |   2 +-
 16 files changed, 297 insertions(+), 722 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index bcf750d3cecd..8870b0212150 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -29,28 +29,13 @@ Please note that implementation details can be changed.
 2. Uncharge
   a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
 
-	mem_cgroup_uncharge_page()
-	  Called when an anonymous page is fully unmapped. I.e., mapcount goes
-	  to 0. If the page is SwapCache, uncharge is delayed until
-	  mem_cgroup_uncharge_swapcache().
-
-	mem_cgroup_uncharge_cache_page()
-	  Called when a page-cache is deleted from radix-tree. If the page is
-	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache().
-
-	mem_cgroup_uncharge_swapcache()
-	  Called when SwapCache is removed from radix-tree. The charge itself
-	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
-	  charge to swap occurs.)
+	mem_cgroup_uncharge()
+	  Called when a page's refcount goes down to 0.
 
 	mem_cgroup_uncharge_swap()
 	  Called when swp_entry's refcnt goes down to 0. A charge against swap
 	  disappears.
 
-	mem_cgroup_end_migration(old, new)
-	At success of migration old is uncharged (if necessary), a charge
-	to new page is committed. At failure, charge to old page is committed.
-
 3. charge-commit-cancel
 	Memcg pages are charged in two steps:
 		mem_cgroup_try_charge()
@@ -69,18 +54,6 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	Anonymous page is newly allocated at
 		  - page fault into MAP_ANONYMOUS mapping.
 		  - Copy-On-Write.
- 	It is charged right after it's allocated before doing any page table
-	related operations. Of course, it's uncharged when another page is used
-	for the fault address.
-
-	At freeing anonymous page (by exit() or munmap()), zap_pte() is called
-	and pages for ptes are freed one by one.(see mm/memory.c). Uncharges
-	are done at page_remove_rmap() when page_mapcount() goes down to 0.
-
-	Another page freeing is by page-reclaim (vmscan.c) and anonymous
-	pages are swapped out. In this case, the page is marked as
-	PageSwapCache(). uncharge() routine doesn't uncharge the page marked
-	as SwapCache(). It's delayed until __delete_from_swap_cache().
 
 	4.1 Swap-in.
 	At swap-in, the page is taken from swap-cache. There are 2 cases.
@@ -89,41 +62,6 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	(b) If the SwapCache has been mapped by processes, it has been
 	    charged already.
 
-	This swap-in is one of the most complicated work. In do_swap_page(),
-	following events occur when pte is unchanged.
-
-	(1) the page (SwapCache) is looked up.
-	(2) lock_page()
-	(3) try_charge_swapin()
-	(4) reuse_swap_page() (may call delete_swap_cache())
-	(5) commit_charge_swapin()
-	(6) swap_free().
-
-	Considering following situation for example.
-
-	(A) The page has not been charged before (2) and reuse_swap_page()
-	    doesn't call delete_from_swap_cache().
-	(B) The page has not been charged before (2) and reuse_swap_page()
-	    calls delete_from_swap_cache().
-	(C) The page has been charged before (2) and reuse_swap_page() doesn't
-	    call delete_from_swap_cache().
-	(D) The page has been charged before (2) and reuse_swap_page() calls
-	    delete_from_swap_cache().
-
-	    memory.usage/memsw.usage changes to this page/swp_entry will be
-	 Case          (A)      (B)       (C)     (D)
-         Event
-       Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
-          ===========================================
-          (3)        +1/+1    +1/+1     +1/+1   +1/+1
-          (4)          -       0/ 0       -     -1/ 0
-          (5)         0/-1     0/ 0     -1/-1    0/ 0
-          (6)          -       0/-1       -      0/-1
-          ===========================================
-       Result         1/ 1     1/ 1      1/ 1    1/ 1
-
-       In any cases, charges to this page should be 1/ 1.
-
 	4.2 Swap-out.
 	At swap-out, typical state transition is below.
 
@@ -136,28 +74,20 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	    swp_entry's refcnt -= 1.
 
 
-	At (b), the page is marked as SwapCache and not uncharged.
-	At (d), the page is removed from SwapCache and a charge in page_cgroup
-	is moved to swap_cgroup.
-
 	Finally, at task exit,
 	(e) zap_pte() is called and swp_entry's refcnt -=1 -> 0.
-	Here, a charge in swap_cgroup disappears.
 
 5. Page Cache
    	Page Cache is charged at
 	- add_to_page_cache_locked().
 
-	uncharged at
-	- __remove_from_page_cache().
-
 	The logic is very clear. (About migration, see below)
 	Note: __remove_from_page_cache() is called by remove_from_page_cache()
 	and __remove_mapping().
 
 6. Shmem(tmpfs) Page Cache
-	Memcg's charge/uncharge have special handlers of shmem. The best way
-	to understand shmem's page state transition is to read mm/shmem.c.
+	The best way to understand shmem's page state transition is to read
+	mm/shmem.c.
 	But brief explanation of the behavior of memcg around shmem will be
 	helpful to understand the logic.
 
@@ -170,56 +100,10 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	It's charged when...
 	- A new page is added to shmem's radix-tree.
 	- A swp page is read. (move a charge from swap_cgroup to page_cgroup)
-	It's uncharged when
-	- A page is removed from radix-tree and not SwapCache.
-	- When SwapCache is removed, a charge is moved to swap_cgroup.
-	- When swp_entry's refcnt goes down to 0, a charge in swap_cgroup
-	  disappears.
 
 7. Page Migration
-   	One of the most complicated functions is page-migration-handler.
-	Memcg has 2 routines. Assume that we are migrating a page's contents
-	from OLDPAGE to NEWPAGE.
-
-	Usual migration logic is..
-	(a) remove the page from LRU.
-	(b) allocate NEWPAGE (migration target)
-	(c) lock by lock_page().
-	(d) unmap all mappings.
-	(e-1) If necessary, replace entry in radix-tree.
-	(e-2) move contents of a page.
-	(f) map all mappings again.
-	(g) pushback the page to LRU.
-	(-) OLDPAGE will be freed.
-
-	Before (g), memcg should complete all necessary charge/uncharge to
-	NEWPAGE/OLDPAGE.
-
-	The point is....
-	- If OLDPAGE is anonymous, all charges will be dropped at (d) because
-          try_to_unmap() drops all mapcount and the page will not be
-	  SwapCache.
-
-	- If OLDPAGE is SwapCache, charges will be kept at (g) because
-	  __delete_from_swap_cache() isn't called at (e-1)
-
-	- If OLDPAGE is page-cache, charges will be kept at (g) because
-	  remove_from_swap_cache() isn't called at (e-1)
-
-	memcg provides following hooks.
-
-	- mem_cgroup_prepare_migration(OLDPAGE)
-	  Called after (b) to account a charge (usage += PAGE_SIZE) against
-	  memcg which OLDPAGE belongs to.
-
-        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
-	  Called after (f) before (g).
-	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
-	  charged, a charge by prepare_migration() is automatically canceled.
-	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
-
-	  But zap_pte() (by exit or munmap) can be called while migration,
-	  we have to check if OLDPAGE/NEWPAGE is a valid page after commit().
+
+	mem_cgroup_migrate()
 
 8. LRU
         Each memcg has its own private LRU. Now, its handling is under global
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1a9a096858e0..806b8fa15c5f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -60,15 +60,17 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 			      bool lrucare);
 void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg);
 
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
+void mem_cgroup_uncharge(struct page *page);
+
+/* Batched uncharging */
+void mem_cgroup_uncharge_start(void);
+void mem_cgroup_uncharge_end(void);
 
-/* For coalescing uncharge for reducing memcg' overhead*/
-extern void mem_cgroup_uncharge_start(void);
-extern void mem_cgroup_uncharge_end(void);
+void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
+			bool lrucare);
 
-extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_uncharge_cache_page(struct page *page);
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
 bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 				  struct mem_cgroup *memcg);
@@ -96,12 +98,6 @@ bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
 
 extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 
-extern void
-mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
-			     struct mem_cgroup **memcgp);
-extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
-	struct page *oldpage, struct page *newpage, bool migration_ok);
-
 struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
@@ -116,8 +112,6 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
-extern void mem_cgroup_replace_page_cache(struct page *oldpage,
-					struct page *newpage);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -235,19 +229,21 @@ static inline void mem_cgroup_cancel_charge(struct page *page,
 {
 }
 
-static inline void mem_cgroup_uncharge_start(void)
+static inline void mem_cgroup_uncharge(struct page *page)
 {
 }
 
-static inline void mem_cgroup_uncharge_end(void)
+static inline void mem_cgroup_uncharge_start(void)
 {
 }
 
-static inline void mem_cgroup_uncharge_page(struct page *page)
+static inline void mem_cgroup_uncharge_end(void)
 {
 }
 
-static inline void mem_cgroup_uncharge_cache_page(struct page *page)
+static inline void mem_cgroup_migrate(struct page *oldpage,
+				      struct page *newpage,
+				      bool lrucare)
 {
 }
 
@@ -286,17 +282,6 @@ static inline struct cgroup_subsys_state
 	return NULL;
 }
 
-static inline void
-mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
-			     struct mem_cgroup **memcgp)
-{
-}
-
-static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
-		struct page *oldpage, struct page *newpage, bool migration_ok)
-{
-}
-
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
@@ -392,10 +377,6 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
-static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
-				struct page *newpage)
-{
-}
 #endif /* CONFIG_MEMCG */
 
 #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 777a524716db..97b5c39a31c8 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -3,9 +3,9 @@
 
 enum {
 	/* flags for mem_cgroup */
-	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
-	PCG_USED, /* this object is in use. */
-	PCG_MIGRATION, /* under page migration */
+	PCG_USED,	/* This page is charged to a memcg */
+	PCG_MEM,	/* This page holds a memory charge */
+	PCG_MEMSW,	/* This page holds a memory+swap charge */
 	__NR_PCG_FLAGS,
 };
 
@@ -44,42 +44,9 @@ static inline void __init page_cgroup_init(void)
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 struct page *lookup_cgroup_page(struct page_cgroup *pc);
 
-#define TESTPCGFLAG(uname, lname)			\
-static inline int PageCgroup##uname(struct page_cgroup *pc)	\
-	{ return test_bit(PCG_##lname, &pc->flags); }
-
-#define SETPCGFLAG(uname, lname)			\
-static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
-	{ set_bit(PCG_##lname, &pc->flags);  }
-
-#define CLEARPCGFLAG(uname, lname)			\
-static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
-	{ clear_bit(PCG_##lname, &pc->flags);  }
-
-#define TESTCLEARPCGFLAG(uname, lname)			\
-static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
-	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
-
-TESTPCGFLAG(Used, USED)
-CLEARPCGFLAG(Used, USED)
-SETPCGFLAG(Used, USED)
-
-SETPCGFLAG(Migration, MIGRATION)
-CLEARPCGFLAG(Migration, MIGRATION)
-TESTPCGFLAG(Migration, MIGRATION)
-
-static inline void lock_page_cgroup(struct page_cgroup *pc)
-{
-	/*
-	 * Don't take this lock in IRQ context.
-	 * This lock is for pc->mem_cgroup, USED, MIGRATION
-	 */
-	bit_spin_lock(PCG_LOCK, &pc->flags);
-}
-
-static inline void unlock_page_cgroup(struct page_cgroup *pc)
+static inline int PageCgroupUsed(struct page_cgroup *pc)
 {
-	bit_spin_unlock(PCG_LOCK, &pc->flags);
+	return test_bit(PCG_USED, &pc->flags);
 }
 
 #else /* CONFIG_MEMCG */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 290905133078..94fd0b23f3f9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -382,9 +382,13 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 }
 #endif
 #ifdef CONFIG_MEMCG_SWAP
-extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
+extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
+extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
 #else
-static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
+static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
+{
+}
+static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
 }
 #endif
@@ -444,7 +448,7 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t, struct page *page);
+extern void swapcache_free(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -508,7 +512,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp, struct page *page)
+static inline void swapcache_free(swp_entry_t swp)
 {
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 114cd89c1cc2..c2f30ed8e95f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -233,7 +233,6 @@ void delete_from_page_cache(struct page *page)
 	spin_lock_irq(&mapping->tree_lock);
 	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_uncharge_cache_page(page);
 
 	if (freepage)
 		freepage(page);
@@ -501,8 +500,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
-		/* mem_cgroup codes must not be called under tree_lock */
-		mem_cgroup_replace_page_cache(old, new);
+		mem_cgroup_migrate(old, new, true);
 		radix_tree_preload_end();
 		if (freepage)
 			freepage(old);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5e2129ceca07..cb3055a835cf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -882,13 +882,6 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	return val;
 }
 
-static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
-					 bool charge)
-{
-	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
-}
-
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 					    enum mem_cgroup_events_index idx)
 {
@@ -909,13 +902,13 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 struct page *page,
-					 bool anon, int nr_pages)
+					 int nr_pages)
 {
 	/*
 	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
 	 * counted as CACHE even if it's on ANON LRU.
 	 */
-	if (anon)
+	if (PageAnon(page))
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
 				nr_pages);
 	else
@@ -1347,20 +1340,6 @@ out:
 	return lruvec;
 }
 
-/*
- * Following LRU functions are allowed to be used without PCG_LOCK.
- * Operations are called by routine of global LRU independently from memcg.
- * What we have to take care of here is validness of pc->mem_cgroup.
- *
- * Changes to pc->mem_cgroup happens when
- * 1. charge
- * 2. moving account
- * In typical case, "charge" is done before add-to-lru. Exception is SwapCache.
- * It is added to LRU before charge.
- * If PCG_USED bit is not set, page_cgroup is not added to this private LRU.
- * When moving account, the page is not on LRU. It's isolated.
- */
-
 /**
  * mem_cgroup_page_lruvec - return lruvec for adding an lru page
  * @page: the page
@@ -2261,22 +2240,14 @@ cleanup:
  *
  * Notes: Race condition
  *
- * We usually use lock_page_cgroup() for accessing page_cgroup member but
- * it tends to be costly. But considering some conditions, we doesn't need
- * to do so _always_.
+ * Charging occurs during page instantiation, while the page is
+ * unmapped and locked in page migration, or while the page table is
+ * locked in THP migration.  No race is possible.
  *
- * Considering "charge", lock_page_cgroup() is not required because all
- * file-stat operations happen after a page is attached to radix-tree. There
- * are no race with "charge".
+ * Uncharge happens to pages with zero references, no race possible.
  *
- * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
- * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
- * if there are race with "uncharge". Statistics itself is properly handled
- * by flags.
- *
- * Considering "move", this is an only case we see a race. To make the race
- * small, we check memcg->moving_account and detect there are possibility
- * of race or not. If there is, we take a lock.
+ * Charge moving between groups is protected by checking mm->moving
+ * account and taking the move_lock in the slowpath.
  */
 
 void __mem_cgroup_begin_update_page_stat(struct page *page,
@@ -2692,6 +2663,16 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 	return mem_cgroup_from_id(id);
 }
 
+/*
+ * try_get_mem_cgroup_from_page - look up page's memcg association
+ * @page: the page
+ *
+ * Look up, get a css reference, and return the memcg that owns @page.
+ *
+ * The page must be locked to prevent racing with swap-in and page
+ * cache charges.  If coming from an unlocked page table, the caller
+ * must ensure the page is on the LRU or this can race with charging.
+ */
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	struct mem_cgroup *memcg = NULL;
@@ -2702,7 +2683,6 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		memcg = pc->mem_cgroup;
 		if (memcg && !css_tryget_online(&memcg->css))
@@ -2716,19 +2696,17 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 			memcg = NULL;
 		rcu_read_unlock();
 	}
-	unlock_page_cgroup(pc);
 	return memcg;
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
-			  unsigned int nr_pages, bool anon, bool lrucare)
+			  unsigned int nr_pages, bool lrucare)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	struct zone *uninitialized_var(zone);
 	struct lruvec *lruvec;
 	bool was_on_lru = false;
 
-	lock_page_cgroup(pc);
 	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
 	/*
 	 * we don't need page_cgroup_lock about tail pages, becase they are not
@@ -2750,8 +2728,22 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		}
 	}
 
+	/*
+	 * Nobody should be changing or seriously looking at
+	 * pc->mem_cgroup and pc->flags at this point:
+	 *
+	 * - the page is uncharged
+	 *
+	 * - the page is off-LRU
+	 *
+	 * - an anonymous fault has exclusive page access, except for
+	 *   a locked page table
+	 *
+	 * - a page cache insertion, a swapin fault, or a migration
+	 *   have the page locked
+	 */
 	pc->mem_cgroup = memcg;
-	SetPageCgroupUsed(pc);
+	pc->flags = PCG_USED | PCG_MEM | PCG_MEMSW;
 
 	if (lrucare) {
 		if (was_on_lru) {
@@ -2763,9 +2755,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
-	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
-	unlock_page_cgroup(pc);
-
+	mem_cgroup_charge_statistics(memcg, page, nr_pages);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
@@ -3398,7 +3388,6 @@ static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT (1 << PCG_LOCK | 1 << PCG_MIGRATION)
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
@@ -3419,7 +3408,7 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
 		pc->mem_cgroup = memcg;
-		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+		pc->flags = head_pc->flags;
 	}
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
 		       HPAGE_PMD_NR);
@@ -3449,7 +3438,6 @@ static int mem_cgroup_move_account(struct page *page,
 {
 	unsigned long flags;
 	int ret;
-	bool anon = PageAnon(page);
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -3463,15 +3451,13 @@ static int mem_cgroup_move_account(struct page *page,
 	if (nr_pages > 1 && !PageTransHuge(page))
 		goto out;
 
-	lock_page_cgroup(pc);
-
 	ret = -EINVAL;
 	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
-		goto unlock;
+		goto out;
 
 	move_lock_mem_cgroup(from, &flags);
 
-	if (!anon && page_mapped(page)) {
+	if (!PageAnon(page) && page_mapped(page)) {
 		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
 			       nr_pages);
 		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
@@ -3485,15 +3471,19 @@ static int mem_cgroup_move_account(struct page *page,
 			       nr_pages);
 	}
 
-	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
+	mem_cgroup_charge_statistics(from, page, -nr_pages);
+
+	/*
+	 * It is safe to change pc->mem_cgroup here because the page
+	 * is referenced, charged, and isolated - we can't race with
+	 * uncharging, charging, migration, or LRU putback.
+	 */
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, page, anon, nr_pages);
+	mem_cgroup_charge_statistics(to, page, nr_pages);
 	move_unlock_mem_cgroup(from, &flags);
 	ret = 0;
-unlock:
-	unlock_page_cgroup(pc);
 	/*
 	 * check events
 	 */
@@ -3569,193 +3559,6 @@ out:
 	return ret;
 }
 
-static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
-				   unsigned int nr_pages,
-				   const enum charge_type ctype)
-{
-	struct memcg_batch_info *batch = NULL;
-	bool uncharge_memsw = true;
-
-	/* If swapout, usage of swap doesn't decrease */
-	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		uncharge_memsw = false;
-
-	batch = &current->memcg_batch;
-	/*
-	 * In usual, we do css_get() when we remember memcg pointer.
-	 * But in this case, we keep res->usage until end of a series of
-	 * uncharges. Then, it's ok to ignore memcg's refcnt.
-	 */
-	if (!batch->memcg)
-		batch->memcg = memcg;
-	/*
-	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
-	 * In those cases, all pages freed continuously can be expected to be in
-	 * the same cgroup and we have chance to coalesce uncharges.
-	 * But we do uncharge one by one if this is killed by OOM(TIF_MEMDIE)
-	 * because we want to do uncharge as soon as possible.
-	 */
-
-	if (!batch->do_batch || test_thread_flag(TIF_MEMDIE))
-		goto direct_uncharge;
-
-	if (nr_pages > 1)
-		goto direct_uncharge;
-
-	/*
-	 * In typical case, batch->memcg == mem. This means we can
-	 * merge a series of uncharges to an uncharge of res_counter.
-	 * If not, we uncharge res_counter ony by one.
-	 */
-	if (batch->memcg != memcg)
-		goto direct_uncharge;
-	/* remember freed charge and uncharge it later */
-	batch->nr_pages++;
-	if (uncharge_memsw)
-		batch->memsw_nr_pages++;
-	return;
-direct_uncharge:
-	res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
-	if (uncharge_memsw)
-		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
-	if (unlikely(batch->memcg != memcg))
-		memcg_oom_recover(memcg);
-}
-
-/*
- * uncharge if !page_mapped(page)
- */
-static struct mem_cgroup *
-__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
-			     bool end_migration)
-{
-	struct mem_cgroup *memcg = NULL;
-	unsigned int nr_pages = 1;
-	struct page_cgroup *pc;
-	bool anon;
-
-	if (mem_cgroup_disabled())
-		return NULL;
-
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-	}
-	/*
-	 * Check if our page_cgroup is valid
-	 */
-	pc = lookup_page_cgroup(page);
-	if (unlikely(!PageCgroupUsed(pc)))
-		return NULL;
-
-	lock_page_cgroup(pc);
-
-	memcg = pc->mem_cgroup;
-
-	if (!PageCgroupUsed(pc))
-		goto unlock_out;
-
-	anon = PageAnon(page);
-
-	switch (ctype) {
-	case MEM_CGROUP_CHARGE_TYPE_ANON:
-		/*
-		 * Generally PageAnon tells if it's the anon statistics to be
-		 * updated; but sometimes e.g. mem_cgroup_uncharge_page() is
-		 * used before page reached the stage of being marked PageAnon.
-		 */
-		anon = true;
-		/* fallthrough */
-	case MEM_CGROUP_CHARGE_TYPE_DROP:
-		/* See mem_cgroup_prepare_migration() */
-		if (page_mapped(page))
-			goto unlock_out;
-		/*
-		 * Pages under migration may not be uncharged.  But
-		 * end_migration() /must/ be the one uncharging the
-		 * unused post-migration page and so it has to call
-		 * here with the migration bit still set.  See the
-		 * res_counter handling below.
-		 */
-		if (!end_migration && PageCgroupMigration(pc))
-			goto unlock_out;
-		break;
-	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
-		if (!PageAnon(page)) {	/* Shared memory */
-			if (page->mapping && !page_is_file_cache(page))
-				goto unlock_out;
-		} else if (page_mapped(page)) /* Anon */
-				goto unlock_out;
-		break;
-	default:
-		break;
-	}
-
-	mem_cgroup_charge_statistics(memcg, page, anon, -nr_pages);
-
-	ClearPageCgroupUsed(pc);
-	/*
-	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
-	 * freed from LRU. This is safe because uncharged page is expected not
-	 * to be reused (freed soon). Exception is SwapCache, it's handled by
-	 * special functions.
-	 */
-
-	unlock_page_cgroup(pc);
-	/*
-	 * even after unlock, we have memcg->res.usage here and this memcg
-	 * will never be freed, so it's safe to call css_get().
-	 */
-	memcg_check_events(memcg, page);
-	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
-		mem_cgroup_swap_statistics(memcg, true);
-		css_get(&memcg->css);
-	}
-	/*
-	 * Migration does not charge the res_counter for the
-	 * replacement page, so leave it alone when phasing out the
-	 * page that is unused after the migration.
-	 */
-	if (!end_migration)
-		mem_cgroup_do_uncharge(memcg, nr_pages, ctype);
-
-	return memcg;
-
-unlock_out:
-	unlock_page_cgroup(pc);
-	return NULL;
-}
-
-void mem_cgroup_uncharge_page(struct page *page)
-{
-	/* early check. */
-	if (page_mapped(page))
-		return;
-	VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
-	/*
-	 * If the page is in swap cache, uncharge should be deferred
-	 * to the swap path, which also properly accounts swap usage
-	 * and handles memcg lifetime.
-	 *
-	 * Note that this check is not stable and reclaim may add the
-	 * page to swap cache at any time after this.  However, if the
-	 * page is not in swap cache by the time page->mapcount hits
-	 * 0, there won't be any page table references to the swap
-	 * slot, and reclaim will free it and not actually write the
-	 * page to disk.
-	 */
-	if (PageSwapCache(page))
-		return;
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
-}
-
-void mem_cgroup_uncharge_cache_page(struct page *page)
-{
-	VM_BUG_ON_PAGE(page_mapped(page), page);
-	VM_BUG_ON_PAGE(page->mapping, page);
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
-}
-
 /*
  * Batch_start/batch_end is called in unmap_page_range/invlidate/trucate.
  * In that cases, pages are freed continuously and we can expect pages
@@ -3803,57 +3606,12 @@ void mem_cgroup_uncharge_end(void)
 	batch->memcg = NULL;
 }
 
-#ifdef CONFIG_SWAP
-/*
- * called after __delete_from_swap_cache() and drop "page" account.
- * memcg information is recorded to swap_cgroup of "ent"
- */
-void
-mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
-{
-	struct mem_cgroup *memcg;
-	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
-
-	if (!swapout) /* this was a swap cache but the swap is unused ! */
-		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
-
-	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
-
-	/*
-	 * record memcg information,  if swapout && memcg != NULL,
-	 * css_get() was called in uncharge().
-	 */
-	if (do_swap_account && swapout && memcg)
-		swap_cgroup_record(ent, mem_cgroup_id(memcg));
-}
-#endif
-
 #ifdef CONFIG_MEMCG_SWAP
-/*
- * called from swap_entry_free(). remove record in swap_cgroup and
- * uncharge "memsw" account.
- */
-void mem_cgroup_uncharge_swap(swp_entry_t ent)
+static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
+					 bool charge)
 {
-	struct mem_cgroup *memcg;
-	unsigned short id;
-
-	if (!do_swap_account)
-		return;
-
-	id = swap_cgroup_record(ent, 0);
-	rcu_read_lock();
-	memcg = mem_cgroup_lookup(id);
-	if (memcg) {
-		/*
-		 * We uncharge this because swap is freed.  This memcg can
-		 * be obsolete one. We avoid calling css_tryget_online().
-		 */
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
-		mem_cgroup_swap_statistics(memcg, false);
-		css_put(&memcg->css);
-	}
-	rcu_read_unlock();
+	int val = (charge) ? 1 : -1;
+	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
 }
 
 /**
@@ -3905,169 +3663,6 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
-/*
- * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
- * page belongs to.
- */
-void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
-				  struct mem_cgroup **memcgp)
-{
-	struct mem_cgroup *memcg = NULL;
-	unsigned int nr_pages = 1;
-	struct page_cgroup *pc;
-
-	*memcgp = NULL;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	if (PageTransHuge(page))
-		nr_pages <<= compound_order(page);
-
-	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
-		css_get(&memcg->css);
-		/*
-		 * At migrating an anonymous page, its mapcount goes down
-		 * to 0 and uncharge() will be called. But, even if it's fully
-		 * unmapped, migration may fail and this page has to be
-		 * charged again. We set MIGRATION flag here and delay uncharge
-		 * until end_migration() is called
-		 *
-		 * Corner Case Thinking
-		 * A)
-		 * When the old page was mapped as Anon and it's unmap-and-freed
-		 * while migration was ongoing.
-		 * If unmap finds the old page, uncharge() of it will be delayed
-		 * until end_migration(). If unmap finds a new page, it's
-		 * uncharged when it make mapcount to be 1->0. If unmap code
-		 * finds swap_migration_entry, the new page will not be mapped
-		 * and end_migration() will find it(mapcount==0).
-		 *
-		 * B)
-		 * When the old page was mapped but migraion fails, the kernel
-		 * remaps it. A charge for it is kept by MIGRATION flag even
-		 * if mapcount goes down to 0. We can do remap successfully
-		 * without charging it again.
-		 *
-		 * C)
-		 * The "old" page is under lock_page() until the end of
-		 * migration, so, the old page itself will not be swapped-out.
-		 * If the new page is swapped out before end_migraton, our
-		 * hook to usual swap-out path will catch the event.
-		 */
-		if (PageAnon(page))
-			SetPageCgroupMigration(pc);
-	}
-	unlock_page_cgroup(pc);
-	/*
-	 * If the page is not charged at this point,
-	 * we return here.
-	 */
-	if (!memcg)
-		return;
-
-	*memcgp = memcg;
-	/*
-	 * We charge new page before it's used/mapped. So, even if unlock_page()
-	 * is called before end_migration, we can catch all events on this new
-	 * page. In the case new page is migrated but not remapped, new page's
-	 * mapcount will be finally 0 and we call uncharge in end_migration().
-	 */
-	/*
-	 * The page is committed to the memcg, but it's not actually
-	 * charged to the res_counter since we plan on replacing the
-	 * old one and only one page is going to be left afterwards.
-	 */
-	commit_charge(newpage, memcg, nr_pages, PageAnon(page), false);
-}
-
-/* remove redundant charge if migration failed*/
-void mem_cgroup_end_migration(struct mem_cgroup *memcg,
-	struct page *oldpage, struct page *newpage, bool migration_ok)
-{
-	struct page *used, *unused;
-	struct page_cgroup *pc;
-	bool anon;
-
-	if (!memcg)
-		return;
-
-	if (!migration_ok) {
-		used = oldpage;
-		unused = newpage;
-	} else {
-		used = newpage;
-		unused = oldpage;
-	}
-	anon = PageAnon(used);
-	__mem_cgroup_uncharge_common(unused,
-				     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
-				     : MEM_CGROUP_CHARGE_TYPE_CACHE,
-				     true);
-	css_put(&memcg->css);
-	/*
-	 * We disallowed uncharge of pages under migration because mapcount
-	 * of the page goes down to zero, temporarly.
-	 * Clear the flag and check the page should be charged.
-	 */
-	pc = lookup_page_cgroup(oldpage);
-	lock_page_cgroup(pc);
-	ClearPageCgroupMigration(pc);
-	unlock_page_cgroup(pc);
-
-	/*
-	 * If a page is a file cache, radix-tree replacement is very atomic
-	 * and we can skip this check. When it was an Anon page, its mapcount
-	 * goes down to 0. But because we added MIGRATION flage, it's not
-	 * uncharged yet. There are several case but page->mapcount check
-	 * and USED bit check in mem_cgroup_uncharge_page() will do enough
-	 * check. (see prepare_charge() also)
-	 */
-	if (anon)
-		mem_cgroup_uncharge_page(used);
-}
-
-/*
- * At replace page cache, newpage is not under any memcg but it's on
- * LRU. So, this function doesn't touch res_counter but handles LRU
- * in correct way. Both pages are locked so we cannot race with uncharge.
- */
-void mem_cgroup_replace_page_cache(struct page *oldpage,
-				  struct page *newpage)
-{
-	struct mem_cgroup *memcg = NULL;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(oldpage);
-	/* fix accounting on old pages */
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
-		mem_cgroup_charge_statistics(memcg, oldpage, false, -1);
-		ClearPageCgroupUsed(pc);
-	}
-	unlock_page_cgroup(pc);
-
-	/*
-	 * When called from shmem_replace_page(), in some cases the
-	 * oldpage has already been charged, and in some cases not.
-	 */
-	if (!memcg)
-		return;
-	/*
-	 * Even if newpage->mapping was NULL before starting replacement,
-	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
-	 * LRU while we overwrite pc->mem_cgroup.
-	 */
-	commit_charge(newpage, memcg, 1, false, true);
-}
-
 #ifdef CONFIG_DEBUG_VM
 static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
 {
@@ -6242,9 +5837,9 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 	if (page) {
 		pc = lookup_page_cgroup(page);
 		/*
-		 * Do only loose check w/o page_cgroup lock.
-		 * mem_cgroup_move_account() checks the pc is valid or not under
-		 * the lock.
+		 * Do only loose check w/o serialization.
+		 * mem_cgroup_move_account() checks the pc is valid or
+		 * not under LRU exclusion.
 		 */
 		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
@@ -6703,6 +6298,67 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+#ifdef CONFIG_MEMCG_SWAP
+/**
+ * mem_cgroup_swapout - transfer a memsw charge to swap
+ * @page: page whose memsw charge to transfer
+ * @entry: swap entry to move the charge to
+ *
+ * Transfer the memsw charge of @page to @entry.
+ */
+void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
+{
+	struct page_cgroup *pc;
+	unsigned short oldid;
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON_PAGE(page_count(page), page);
+
+	if (!do_swap_account)
+		return;
+
+	pc = lookup_page_cgroup(page);
+
+	/* Readahead page, never charged */
+	if (!PageCgroupUsed(pc))
+		return;
+
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
+
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
+	VM_BUG_ON_PAGE(oldid, page);
+
+	pc->flags &= ~PCG_MEMSW;
+	css_get(&pc->mem_cgroup->css);
+	mem_cgroup_swap_statistics(pc->mem_cgroup, true);
+}
+
+/**
+ * mem_cgroup_uncharge_swap - uncharge a swap entry
+ * @entry: swap entry to uncharge
+ *
+ * Drop the memsw charge associated with @entry.
+ */
+void mem_cgroup_uncharge_swap(swp_entry_t entry)
+{
+	struct mem_cgroup *memcg;
+	unsigned short id;
+
+	if (!do_swap_account)
+		return;
+
+	id = swap_cgroup_record(entry, 0);
+	rcu_read_lock();
+	memcg = mem_cgroup_lookup(id);
+	if (memcg) {
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		mem_cgroup_swap_statistics(memcg, false);
+		css_put(&memcg->css);
+	}
+	rcu_read_unlock();
+}
+#endif
+
 /**
  * mem_cgroup_try_charge - try charging a page
  * @page: page to charge
@@ -6811,7 +6467,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 	}
 
-	commit_charge(page, memcg, nr_pages, PageAnon(page), lrucare);
+	commit_charge(page, memcg, nr_pages, lrucare);
 
 	if (do_swap_account && PageSwapCache(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
@@ -6853,6 +6509,116 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 	cancel_charge(memcg, nr_pages);
 }
 
+/**
+ * mem_cgroup_uncharge - uncharge a page
+ * @page: page to uncharge
+ *
+ * Uncharge a page previously charged with mem_cgroup_try_charge() and
+ * mem_cgroup_commit_charge().
+ */
+void mem_cgroup_uncharge(struct page *page)
+{
+	struct memcg_batch_info *batch;
+	unsigned int nr_pages = 1;
+	struct mem_cgroup *memcg;
+	struct page_cgroup *pc;
+	unsigned long flags;
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON_PAGE(page_count(page), page);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(page);
+
+	/* Every final put_page() ends up here */
+	if (!PageCgroupUsed(pc))
+		return;
+
+	if (PageTransHuge(page)) {
+		nr_pages <<= compound_order(page);
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+	}
+	/*
+	 * Nobody should be changing or seriously looking at
+	 * pc->mem_cgroup and pc->flags at this point, we have fully
+	 * exclusive access to the page.
+	 */
+	memcg = pc->mem_cgroup;
+	flags = pc->flags;
+	pc->flags = 0;
+
+	mem_cgroup_charge_statistics(memcg, page, -nr_pages);
+	memcg_check_events(memcg, page);
+
+	batch = &current->memcg_batch;
+	if (!batch->memcg)
+		batch->memcg = memcg;
+	else if (batch->memcg != memcg)
+		goto uncharge;
+	if (nr_pages > 1)
+		goto uncharge;
+	if (!batch->do_batch)
+		goto uncharge;
+	if (test_thread_flag(TIF_MEMDIE))
+		goto uncharge;
+	if (flags & PCG_MEM)
+		batch->nr_pages++;
+	if (flags & PCG_MEMSW)
+		batch->memsw_nr_pages++;
+	return;
+uncharge:
+	if (flags & PCG_MEM)
+		res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
+	if (flags & PCG_MEMSW)
+		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
+	if (batch->memcg != memcg)
+		memcg_oom_recover(memcg);
+}
+
+/**
+ * mem_cgroup_migrate - migrate a charge to another page
+ * @oldpage: currently charged page
+ * @newpage: page to transfer the charge to
+ * @lrucare: page might be on LRU already
+ *
+ * Migrate the charge from @oldpage to @newpage.
+ *
+ * Both pages must be locked, @newpage->mapping must be set up.
+ */
+void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
+			bool lrucare)
+{
+	unsigned int nr_pages = 1;
+	struct page_cgroup *pc;
+
+	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
+	VM_BUG_ON_PAGE(PageLRU(oldpage), oldpage);
+	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);
+	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(oldpage);
+	if (!PageCgroupUsed(pc))
+		return;
+
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), oldpage);
+	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
+
+	if (PageTransHuge(oldpage)) {
+		nr_pages <<= compound_order(oldpage);
+		VM_BUG_ON_PAGE(!PageTransHuge(oldpage), oldpage);
+		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
+	}
+
+	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
+}
+
 /*
  * subsys_initcall() for memory controller.
  *
diff --git a/mm/memory.c b/mm/memory.c
index d66988d56caf..a4b5b17b54c9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1292,7 +1292,6 @@ static void unmap_page_range(struct mmu_gather *tlb,
 		details = NULL;
 
 	BUG_ON(addr >= end);
-	mem_cgroup_uncharge_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1302,7 +1301,6 @@ static void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_pud_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
-	mem_cgroup_uncharge_end();
 }
 
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 63f0cd559999..4a9991aeebe9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -780,11 +780,14 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
 	if (rc != MIGRATEPAGE_SUCCESS) {
-		newpage->mapping = NULL;
+		if (!PageAnon(newpage))
+			newpage->mapping = NULL;
 	} else {
 		if (remap_swapcache)
 			remove_migration_ptes(page, newpage);
-		page->mapping = NULL;
+		if (!PageAnon(page))
+			page->mapping = NULL;
+		mem_cgroup_migrate(page, newpage, false);
 	}
 
 	unlock_page(newpage);
@@ -797,7 +800,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
-	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
 	if (!trylock_page(page)) {
@@ -823,9 +825,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		lock_page(page);
 	}
 
-	/* charge against new page */
-	mem_cgroup_prepare_migration(page, newpage, &mem);
-
 	if (PageWriteback(page)) {
 		/*
 		 * Only in the case of a full synchronous migration is it
@@ -835,10 +834,10 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 */
 		if (mode != MIGRATE_SYNC) {
 			rc = -EBUSY;
-			goto uncharge;
+			goto out_unlock;
 		}
 		if (!force)
-			goto uncharge;
+			goto out_unlock;
 		wait_on_page_writeback(page);
 	}
 	/*
@@ -874,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 			 */
 			remap_swapcache = 0;
 		} else {
-			goto uncharge;
+			goto out_unlock;
 		}
 	}
 
@@ -887,7 +886,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the page migration right away (proteced by page lock).
 		 */
 		rc = balloon_page_migrate(newpage, page, mode);
-		goto uncharge;
+		goto out_unlock;
 	}
 
 	/*
@@ -906,7 +905,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		VM_BUG_ON_PAGE(PageAnon(page), page);
 		if (page_has_private(page)) {
 			try_to_free_buffers(page);
-			goto uncharge;
+			goto out_unlock;
 		}
 		goto skip_unmap;
 	}
@@ -925,10 +924,7 @@ skip_unmap:
 	if (anon_vma)
 		put_anon_vma(anon_vma);
 
-uncharge:
-	mem_cgroup_end_migration(mem, page, newpage,
-				 (rc == MIGRATEPAGE_SUCCESS ||
-				  rc == MIGRATEPAGE_BALLOON_SUCCESS));
+out_unlock:
 	unlock_page(page);
 out:
 	return rc;
@@ -1787,7 +1783,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	struct mem_cgroup *memcg = NULL;
 	int page_lru = page_is_file_cache(page);
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
@@ -1853,15 +1848,6 @@ fail_putback:
 		goto out_unlock;
 	}
 
-	/*
-	 * Traditional migration needs to prepare the memcg charge
-	 * transaction early to prevent the old page from being
-	 * uncharged when installing migration entries.  Here we can
-	 * save the potential rollback and start the charge transfer
-	 * only when migration is already known to end successfully.
-	 */
-	mem_cgroup_prepare_migration(page, new_page, &memcg);
-
 	orig_entry = *pmd;
 	entry = mk_pmd(new_page, vma->vm_page_prot);
 	entry = pmd_mkhuge(entry);
@@ -1889,14 +1875,10 @@ fail_putback:
 		goto fail_putback;
 	}
 
+	mem_cgroup_migrate(page, new_page, false);
+
 	page_remove_rmap(page);
 
-	/*
-	 * Finish the charge transaction under the page table lock to
-	 * prevent split_huge_page() from dividing up the charge
-	 * before it's fully transferred to the new page.
-	 */
-	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 07576e0b92ef..e10d60543e9b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1089,7 +1089,6 @@ void page_remove_rmap(struct page *page)
 	if (unlikely(PageHuge(page)))
 		goto out;
 	if (anon) {
-		mem_cgroup_uncharge_page(page);
 		if (PageTransHuge(page))
 			__dec_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
diff --git a/mm/shmem.c b/mm/shmem.c
index ea968bf84942..dc9eb434ea8e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -405,7 +405,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			pvec.pages, indices);
 		if (!pvec.nr)
 			break;
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -433,7 +432,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		cond_resched();
 		index++;
 	}
@@ -484,7 +482,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			pagevec_release(&pvec);
 			break;
 		}
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -511,7 +508,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		index++;
 	}
 
@@ -809,7 +805,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
-	swapcache_free(swap, NULL);
+	swapcache_free(swap);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
@@ -982,7 +978,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 		 */
 		oldpage = newpage;
 	} else {
-		mem_cgroup_replace_page_cache(oldpage, newpage);
+		mem_cgroup_migrate(oldpage, newpage, false);
 		lru_cache_add_anon(newpage);
 		*pagep = newpage;
 	}
diff --git a/mm/swap.c b/mm/swap.c
index a98f48626359..3074210f245d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
+	mem_cgroup_uncharge(page);
 }
 
 static void __put_single_page(struct page *page)
@@ -915,6 +916,8 @@ void release_pages(struct page **pages, int nr, bool cold)
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
 
+	mem_cgroup_uncharge_start();
+
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
@@ -946,6 +949,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
+		mem_cgroup_uncharge(page);
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
@@ -955,6 +959,8 @@ void release_pages(struct page **pages, int nr, bool cold)
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	mem_cgroup_uncharge_end();
+
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
 EXPORT_SYMBOL(release_pages);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 2972eee184a4..e160151da6b8 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -176,7 +176,7 @@ int add_to_swap(struct page *page, struct list_head *list)
 
 	if (unlikely(PageTransHuge(page)))
 		if (unlikely(split_huge_page_to_list(page, list))) {
-			swapcache_free(entry, NULL);
+			swapcache_free(entry);
 			return 0;
 		}
 
@@ -202,7 +202,7 @@ int add_to_swap(struct page *page, struct list_head *list)
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry, NULL);
+		swapcache_free(entry);
 		return 0;
 	}
 }
@@ -225,7 +225,7 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	swapcache_free(entry, page);
+	swapcache_free(entry);
 	page_cache_release(page);
 }
 
@@ -386,7 +386,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry, NULL);
+		swapcache_free(entry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0883b4912ff7..8798b2e0ac59 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -843,16 +843,13 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry, struct page *page)
+void swapcache_free(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
-	unsigned char count;
 
 	p = swap_info_get(entry);
 	if (p) {
-		count = swap_entry_free(p, entry, SWAP_HAS_CACHE);
-		if (page)
-			mem_cgroup_uncharge_swapcache(page, entry, count != 0);
+		swap_entry_free(p, entry, SWAP_HAS_CACHE);
 		spin_unlock(&p->lock);
 	}
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index 6a78c814bebf..b352481c276d 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -281,7 +281,6 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -307,7 +306,6 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		cond_resched();
 		index++;
 	}
@@ -367,7 +365,6 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			pagevec_release(&pvec);
 			break;
 		}
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -389,7 +386,6 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		index++;
 	}
 	cleancache_invalidate_inode(mapping);
@@ -488,7 +484,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -517,7 +512,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		cond_resched();
 		index++;
 	}
@@ -548,7 +542,6 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	BUG_ON(page_has_private(page));
 	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_uncharge_cache_page(page);
 
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
@@ -597,7 +590,6 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
-		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -650,7 +642,6 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
 		cond_resched();
 		index++;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe8eb67..521f7eab1798 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -571,9 +571,10 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
+		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
-		swapcache_free(swap, page);
+		swapcache_free(swap);
 	} else {
 		void (*freepage)(struct page *);
 		void *shadow = NULL;
@@ -594,7 +595,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			shadow = workingset_eviction(mapping, page);
 		__delete_from_page_cache(page, shadow);
 		spin_unlock_irq(&mapping->tree_lock);
-		mem_cgroup_uncharge_cache_page(page);
 
 		if (freepage != NULL)
 			freepage(page);
@@ -1097,6 +1097,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		__clear_page_locked(page);
 free_it:
+		mem_cgroup_uncharge(page);
 		nr_reclaimed++;
 
 		/*
@@ -1126,12 +1127,13 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
+	mem_cgroup_uncharge_end();
 
 	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
-	mem_cgroup_uncharge_end();
+
 	*ret_nr_dirty += nr_dirty;
 	*ret_nr_congested += nr_congested;
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
@@ -1429,6 +1431,8 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			__ClearPageActive(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
+			mem_cgroup_uncharge(page);
+
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
 				(*get_compound_page_dtor(page))(page);
@@ -1650,6 +1654,8 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 			__ClearPageActive(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
+			mem_cgroup_uncharge(page);
+
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
 				(*get_compound_page_dtor(page))(page);
diff --git a/mm/zswap.c b/mm/zswap.c
index 008388fe7b0f..333d70c66093 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -502,7 +502,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry, NULL);
+		swapcache_free(entry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
