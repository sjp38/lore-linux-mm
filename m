Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 24C5E6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 21:44:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6920587pbb.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 18:44:33 -0700 (PDT)
Date: Fri, 18 May 2012 18:44:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH v2 1/10] shmem: substitute page if mapping excludes its
 zone
In-Reply-To: <alpine.LSU.2.00.1205181753310.9617@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205181841540.9617@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils> <20120514161330.def0ac52.akpm@linux-foundation.org> <alpine.LSU.2.00.1205142101420.2196@eggly.anvils>
 <alpine.LSU.2.00.1205181753310.9617@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The GMA500 GPU driver uses GEM shmem objects, but with a new twist:
the backing RAM has to be below 4GB.  Not a problem while the boards
supported only 4GB: but now Intel's D2700MUD boards support 8GB, and
their GMA3600 is managed by the GMA500 driver.

shmem/tmpfs has never pretended to support hardware restrictions on
the backing memory, but it might have appeared to do so before v3.1,
and even now it works fine until a page is swapped out then back in.
When read_cache_page_gfp() supplied a freshly allocated page for copy,
that compensated for whatever choice might have been made by earlier
swapin readahead; but swapoff was likely to destroy the illusion.

We would like to continue to support GMA500, so now add a new
shmem_should_substitute_page() check on the zone when about to move a
page from swapcache to filecache (in swapin and swapoff cases), with
shmem_substitute_page() to allocate and substitute a suitable page
(given gma500/gem.c's mapping_set_gfp_mask GFP_KERNEL | __GFP_DMA32).

This does involve a minor extension to mem_cgroup_replace_page_cache()
(the page may or may not have already been charged); and I've removed
a comment and call to mem_cgroup_uncharge_cache_page(), which in fact
is always a no-op while PageSwapCache.

Also removed optimization of an unlikely path in shmem_getpage_gfp(),
now that we need to check PageSwapCache more carefully (a racing caller
might already have made the copy).  And at one point shmem_unuse_inode()
needs to use the hitherto private page_swapcount(), to guard against
racing with inode eviction.

It would make sense to extend shmem_should_substitute_page(), to cover
cpuset and NUMA mempolicy restrictions too, but set that aside for
now: needs a cleanup of shmem mempolicy handling, and more testing,
and ought to handle swap faults in do_swap_page() as well as shmem.

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
I've Cc'ed Stephane, Andi, Dave, Daniel and Rob because of their interest
in the i915 Sandybridge issue; but reiterate that this patch does nothing
for that case.

 include/linux/swap.h |    6 +
 mm/memcontrol.c      |   17 +++-
 mm/shmem.c           |  158 ++++++++++++++++++++++++++++++++++++-----
 mm/swapfile.c        |    2 
 4 files changed, 159 insertions(+), 24 deletions(-)

--- 3045N.orig/include/linux/swap.h	2012-05-17 16:30:20.222078994 -0700
+++ 3045N/include/linux/swap.h	2012-05-17 16:30:29.786078930 -0700
@@ -355,6 +355,7 @@ extern int swap_type_of(dev_t, sector_t,
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
+extern int page_swapcount(struct page *);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
@@ -448,6 +449,11 @@ static inline void delete_from_swap_cach
 {
 }
 
+static inline int page_swapcount(struct page *page)
+{
+	return 0;
+}
+
 #define reuse_swap_page(page)	(page_mapcount(page) == 1)
 
 static inline int try_to_free_swap(struct page *page)
--- 3045N.orig/mm/memcontrol.c	2012-05-17 16:30:20.226078835 -0700
+++ 3045N/mm/memcontrol.c	2012-05-17 16:30:29.786078930 -0700
@@ -3548,7 +3548,7 @@ void mem_cgroup_end_migration(struct mem
 void mem_cgroup_replace_page_cache(struct page *oldpage,
 				  struct page *newpage)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
 	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
 
@@ -3558,11 +3558,20 @@ void mem_cgroup_replace_page_cache(struc
 	pc = lookup_page_cgroup(oldpage);
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
-	memcg = pc->mem_cgroup;
-	mem_cgroup_charge_statistics(memcg, false, -1);
-	ClearPageCgroupUsed(pc);
+	if (PageCgroupUsed(pc)) {
+		memcg = pc->mem_cgroup;
+		mem_cgroup_charge_statistics(memcg, false, -1);
+		ClearPageCgroupUsed(pc);
+	}
 	unlock_page_cgroup(pc);
 
+	/*
+	 * When called from shmem_substitute_page(), in some cases the
+	 * oldpage has already been charged, and in some cases not.
+	 */
+	if (!memcg)
+		return;
+
 	if (PageSwapBacked(oldpage))
 		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 
--- 3045N.orig/mm/shmem.c	2012-05-17 16:30:20.226078835 -0700
+++ 3045N/mm/shmem.c	2012-05-18 16:28:33.642198028 -0700
@@ -103,6 +103,9 @@ static unsigned long shmem_default_max_i
 }
 #endif
 
+static bool shmem_should_substitute_page(struct page *page, gfp_t gfp);
+static int shmem_substitute_page(struct page **pagep, gfp_t gfp,
+				struct shmem_inode_info *info, pgoff_t index);
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type);
 
@@ -604,12 +607,13 @@ static void shmem_evict_inode(struct ino
  * If swap found in inode, free it and move page from swapcache to filecache.
  */
 static int shmem_unuse_inode(struct shmem_inode_info *info,
-			     swp_entry_t swap, struct page *page)
+			     swp_entry_t swap, struct page **pagep)
 {
 	struct address_space *mapping = info->vfs_inode.i_mapping;
 	void *radswap;
 	pgoff_t index;
-	int error;
+	gfp_t gfp;
+	int error = 0;
 
 	radswap = swp_to_radix_entry(swap);
 	index = radix_tree_locate_item(&mapping->page_tree, radswap);
@@ -625,22 +629,48 @@ static int shmem_unuse_inode(struct shme
 	if (shmem_swaplist.next != &info->swaplist)
 		list_move_tail(&shmem_swaplist, &info->swaplist);
 
+	gfp = mapping_gfp_mask(mapping);
+	if (shmem_should_substitute_page(*pagep, gfp)) {
+		mutex_unlock(&shmem_swaplist_mutex);
+		error = shmem_substitute_page(pagep, gfp, info, index);
+		mutex_lock(&shmem_swaplist_mutex);
+		/*
+		 * We needed to drop mutex to make that restrictive page
+		 * allocation, but the inode might have been freed while we
+		 * dropped it: although a racing shmem_evict_inode() cannot
+		 * complete without emptying the radix_tree, our page lock
+		 * on this swapcache page is not enough to prevent that -
+		 * free_swap_and_cache() of our swap entry will only
+		 * trylock_page(), removing swap from radix_tree whatever.
+		 *
+		 * We must not proceed to shmem_add_to_page_cache() if the
+		 * inode has been freed, but of course we cannot rely on
+		 * inode or mapping or info to check that.  However, we can
+		 * safely check if our swap entry is still in use (and here
+		 * it can't have got reused for another page): if it's still
+		 * in use, then the inode cannot have been freed yet, and we
+		 * can safely proceed (if it's no longer in use, that tells
+		 * nothing about the inode, but we don't need to unuse swap).
+		 */
+		if (!page_swapcount(*pagep))
+			error = -ENOENT;
+	}
+
 	/*
 	 * We rely on shmem_swaplist_mutex, not only to protect the swaplist,
 	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
 	 * beneath us (pagelock doesn't help until the page is in pagecache).
 	 */
-	error = shmem_add_to_page_cache(page, mapping, index,
+	if (!error)
+		error = shmem_add_to_page_cache(*pagep, mapping, index,
 						GFP_NOWAIT, radswap);
-	/* which does mem_cgroup_uncharge_cache_page on error */
-
 	if (error != -ENOMEM) {
 		/*
 		 * Truncation and eviction use free_swap_and_cache(), which
 		 * only does trylock page: if we raced, best clean up here.
 		 */
-		delete_from_swap_cache(page);
-		set_page_dirty(page);
+		delete_from_swap_cache(*pagep);
+		set_page_dirty(*pagep);
 		if (!error) {
 			spin_lock(&info->lock);
 			info->swapped--;
@@ -660,7 +690,14 @@ int shmem_unuse(swp_entry_t swap, struct
 	struct list_head *this, *next;
 	struct shmem_inode_info *info;
 	int found = 0;
-	int error;
+	int error = 0;
+
+	/*
+	 * There's a faint possibility that swap page was substituted before
+	 * caller locked it: caller will come back later with the right page.
+	 */
+	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
+		goto out;
 
 	/*
 	 * Charge page using GFP_KERNEL while we can wait, before taking
@@ -676,7 +713,7 @@ int shmem_unuse(swp_entry_t swap, struct
 	list_for_each_safe(this, next, &shmem_swaplist) {
 		info = list_entry(this, struct shmem_inode_info, swaplist);
 		if (info->swapped)
-			found = shmem_unuse_inode(info, swap, page);
+			found = shmem_unuse_inode(info, swap, &page);
 		else
 			list_del_init(&info->swaplist);
 		cond_resched();
@@ -685,8 +722,6 @@ int shmem_unuse(swp_entry_t swap, struct
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (!found)
-		mem_cgroup_uncharge_cache_page(page);
 	if (found < 0)
 		error = found;
 out:
@@ -856,6 +891,89 @@ static inline struct mempolicy *shmem_ge
 #endif
 
 /*
+ * When a page is moved from swapcache to shmem filecache (either by the
+ * usual swapin of shmem_getpage_gfp(), or by the less common swapoff of
+ * shmem_unuse_inode()), it may have been read in earlier from swap, in
+ * ignorance of the mapping it belongs to.  If that mapping has special
+ * constraints (like the gma500 GEM driver, which requires RAM below 4GB),
+ * we may need to copy to a suitable page before moving to filecache.
+ *
+ * In a future release, this may well be extended to respect cpuset and
+ * NUMA mempolicy, and applied also to anonymous pages in do_swap_page();
+ * but for now it is a simple matter of zone.
+ */
+static bool shmem_should_substitute_page(struct page *page, gfp_t gfp)
+{
+	return page_zonenum(page) > gfp_zone(gfp);
+}
+
+static int shmem_substitute_page(struct page **pagep, gfp_t gfp,
+				   struct shmem_inode_info *info, pgoff_t index)
+{
+	struct page *oldpage, *newpage;
+	struct address_space *swap_mapping;
+	pgoff_t swap_index;
+	int error;
+
+	oldpage = *pagep;
+	swap_index = page_private(oldpage);
+	swap_mapping = page_mapping(oldpage);
+
+	/*
+	 * We have arrived here because our zones are constrained, so don't
+	 * limit chance of success by further cpuset and node constraints.
+	 */
+	gfp &= ~GFP_CONSTRAINT_MASK;
+	newpage = shmem_alloc_page(gfp, info, index);
+	if (!newpage)
+		return -ENOMEM;
+
+	page_cache_get(newpage);
+	copy_highpage(newpage, oldpage);
+	flush_dcache_page(newpage);
+
+	__set_page_locked(newpage);
+	SetPageUptodate(newpage);
+	SetPageSwapBacked(newpage);
+	set_page_private(newpage, swap_index);
+	SetPageSwapCache(newpage);
+
+	/*
+	 * Our caller will very soon move newpage out of swapcache, but it's a
+	 * nice clean interface for us to substitute newpage for oldpage there.
+	 */
+	spin_lock_irq(&swap_mapping->tree_lock);
+	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
+								   newpage);
+	if (!error) {
+		__inc_zone_page_state(newpage, NR_FILE_PAGES);
+		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	}
+	spin_unlock_irq(&swap_mapping->tree_lock);
+
+	if (unlikely(error)) {
+		/*
+		 * Is this possible?  I think not, now that our callers check
+		 * both PageSwapCache and page_private after getting page lock;
+		 * but be defensive.  Reverse old to newpage for clear and free.
+		 */
+		oldpage = newpage;
+	} else {
+		mem_cgroup_replace_page_cache(oldpage, newpage);
+		lru_cache_add_anon(newpage);
+		*pagep = newpage;
+	}
+
+	ClearPageSwapCache(oldpage);
+	set_page_private(oldpage, 0);
+
+	unlock_page(oldpage);
+	page_cache_release(oldpage);
+	page_cache_release(oldpage);
+	return error;
+}
+
+/*
  * shmem_getpage_gfp - find page in cache, or get from swap, or allocate
  *
  * If we allocate a new one we do not mark it dirty. That's up to the
@@ -923,19 +1041,21 @@ repeat:
 
 		/* We have to do this with page locked to prevent races */
 		lock_page(page);
+		if (!PageSwapCache(page) || page_private(page) != swap.val ||
+		    page->mapping) {
+			error = -EEXIST;	/* try again */
+			goto failed;
+		}
 		if (!PageUptodate(page)) {
 			error = -EIO;
 			goto failed;
 		}
 		wait_on_page_writeback(page);
 
-		/* Someone may have already done it for us */
-		if (page->mapping) {
-			if (page->mapping == mapping &&
-			    page->index == index)
-				goto done;
-			error = -EEXIST;
-			goto failed;
+		if (shmem_should_substitute_page(page, gfp)) {
+			error = shmem_substitute_page(&page, gfp, info, index);
+			if (error)
+				goto failed;
 		}
 
 		error = mem_cgroup_cache_charge(page, current->mm,
@@ -998,7 +1118,7 @@ repeat:
 		if (sgp == SGP_DIRTY)
 			set_page_dirty(page);
 	}
-done:
+
 	/* Perhaps the file has been truncated since we checked */
 	if (sgp != SGP_WRITE &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
--- 3045N.orig/mm/swapfile.c	2012-05-17 16:30:20.226078835 -0700
+++ 3045N/mm/swapfile.c	2012-05-17 16:30:29.790078925 -0700
@@ -604,7 +604,7 @@ void swapcache_free(swp_entry_t entry, s
  * This does not give an exact answer when swap count is continued,
  * but does include the high COUNT_CONTINUED flag to allow for that.
  */
-static inline int page_swapcount(struct page *page)
+int page_swapcount(struct page *page)
 {
 	int count = 0;
 	struct swap_info_struct *p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
