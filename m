Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFC46B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:21:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r2-v6so3227240pgp.3
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:21:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d129-v6sor1231247pfc.144.2018.07.27.09.21.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 09:21:52 -0700 (PDT)
From: Daniel Drake <drake@endlessm.com>
Subject: Making direct reclaim fail when thrashing
Date: Fri, 27 Jul 2018 11:21:43 -0500
Message-Id: <20180727162143.26466-1-drake@endlessm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux@endlessm.com, linux-kernel@vger.kernel.org

Split from the thread
  [PATCH 0/10] psi: pressure stall information for CPU, memory, and IO v2
where we were discussing if/how to make the direct reclaim codepath
fail if we're excessively thrashing, so that the OOM killer might
step in. This is potentially desirable when the thrashing is so bad
that the UI stops responding, causing the user to pull the plug.

On Tue, Jul 17, 2018 at 7:23 AM, Michal Hocko <mhocko@kernel.org> wrote:
> mm/workingset.c allows for tracking when an actual page got evicted.
> workingset_refault tells us whether a give filemap fault is a recent
> refault and activates the page if that is the case. So what you need is
> to note how many refaulted pages we have on the active LRU list. If that
> is a large part of the list and if the inactive list is really small
> then we know we are trashing. This all sounds much easier than it will
> eventually turn out to be of course but I didn't really get to play with
> this much.

Apologies in advance for any silly mistakes or terrible code that
follows, as I am not familiar in this part of the kernel.

As mentioned in my last mail, knowing if a page on the active list was
refaulted into place appears not trivial, because the eviction information
was lost upon refault (it was stored in the page cache shadow entry).

Here I'm experimenting by adding another tag to the page cache radix tree,
tagging pages that were activated in the refault path.

And then in get_scan_count I'm checking how many active pages have that
tag, and also looking at the size of the active and inactive lists.

It has a performance blow (probably due to looping over the whole
active list and doing lots of locking?) but I figured it might serve
as one step forward.

The results are not exactly as I would expect. Upon launching 20
processes that allocate and memset 100mb RAM each, exhausting all RAM
(and no swap available), the kernel starts thrashing and I get numbers
like:

 get_scan_count lru1 active=422714 inactive=19595 refaulted=0
 get_scan_count lru3 active=832 inactive=757 refaulted=21

Lots of active anonymous pages (lru1), and none refaulted, perhaps
not surprising because it can't swap them out, no swap available.

But only few file pages on the lists (lru3), and only a tiny number
of refaulted ones, which doesn't line up with your suggestion of
detecting when a large part of the active list is made up of refaulted
pages.

Any further suggestions appreciated.

Thanks
Daniel
---
 include/linux/fs.h         |  1 +
 include/linux/radix-tree.h |  2 +-
 mm/filemap.c               |  2 ++
 mm/vmscan.c                | 37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index d85ac9d24bb3..45f94ffd1c67 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -462,6 +462,7 @@ struct block_device {
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
 #define PAGECACHE_TAG_TOWRITE	2
+#define PAGECACHE_TAG_REFAULTED	3
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 34149e8b5f73..86eccb71ef7e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -65,7 +65,7 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 3
+#define RADIX_TREE_MAX_TAGS 4
 
 #ifndef RADIX_TREE_MAP_SHIFT
 #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
diff --git a/mm/filemap.c b/mm/filemap.c
index 250f675dcfb2..9a686570dc75 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -917,6 +917,8 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		 */
 		if (!(gfp_mask & __GFP_WRITE) &&
 		    shadow && workingset_refault(shadow)) {
+			radix_tree_tag_set(&mapping->i_pages, page_index(page),
+					   PAGECACHE_TAG_REFAULTED);
 			SetPageActive(page);
 			workingset_activation(page);
 		} else
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f86f288..79bc810b43bb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2102,6 +2102,30 @@ enum scan_balance {
 	SCAN_FILE,
 };
 
+
+static int count_refaulted(struct lruvec *lruvec, enum lru_list lru) {
+	int nr_refaulted = 0;
+	struct page *page;
+
+	list_for_each_entry(page, &lruvec->lists[lru], lru) {
+		/* Lookup page cache entry from page following the approach
+		 * taken in __set_page_dirty_nobuffers */
+		unsigned long flags;
+		struct address_space *mapping = page_mapping(page);
+		if (!mapping)
+			continue;
+
+		xa_lock_irqsave(&mapping->i_pages, flags);
+		BUG_ON(page_mapping(page) != mapping);
+		nr_refaulted += radix_tree_tag_get(&mapping->i_pages,
+						   page_index(page),
+						   PAGECACHE_TAG_REFAULTED);
+		xa_unlock_irqrestore(&mapping->i_pages, flags);
+	}
+
+	return nr_refaulted;
+}
+
 /*
  * Determine how aggressively the anon and file LRU lists should be
  * scanned.  The relative value of each set of LRU lists is determined
@@ -2270,6 +2294,19 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		unsigned long size;
 		unsigned long scan;
 
+		if (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE) {
+			int nr_refaulted;
+			unsigned long inactive, active;
+
+			nr_refaulted  = count_refaulted(lruvec, lru);
+			active = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
+			inactive = lruvec_lru_size(lruvec, lru - 1,
+						   sc->reclaim_idx);
+			pr_err("get_scan_count lru%d active=%ld inactive=%ld "
+			      "refaulted=%d\n",
+			       lru, active, inactive, nr_refaulted);
+		}
+
 		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
 		scan = size >> sc->priority;
 		/*
-- 
2.17.1
