Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 04D146B0038
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:12:34 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ty20so6382971lab.39
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:12:34 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id j6si12832744laf.89.2014.07.01.17.12.31
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:12:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 2/3] mm: Introduce atomic_remove_mapping
Date: Wed,  2 Jul 2014 09:13:48 +0900
Message-Id: <1404260029-11525-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1404260029-11525-1-git-send-email-minchan@kernel.org>
References: <1404260029-11525-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org

For release page from atomic context(ie, softirq), locks
related to the work should be aware of that.

There are two locks.

One is mapping->tree_lock and the other is swap_info_struct->lock.
The mapping->tree_lock is alreay aware of irq so it's no problem
but swap_info_struct->lock isn't so atomic_remove_mapping uses just
try_spinlock and if it fails to hold a lock, it just depends on
a fallback plan which moves the page into LRU's tail and expect page
freeing in next.

A change I know is mapping->a_ops->free is called on atomic context
by this patch. Only user is nfs_readdir_clear_array which is no
problem when I look at.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  4 ++++
 mm/swapfile.c        | 11 ++++++++-
 mm/vmscan.c          | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 94fd0b23f3f9..5df540205bda 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -336,6 +336,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
+extern int atomic_remove_mapping(struct address_space *mapping,
+					struct page *page);
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
@@ -441,6 +443,7 @@ static inline long get_nr_swap_pages(void)
 }
 
 extern void si_swapinfo(struct sysinfo *);
+extern struct swap_info_struct *swap_info_get(swp_entry_t entry);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
@@ -449,6 +452,7 @@ extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t);
+extern void __swapcache_free(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index ec2ce926ea5f..d76496a8a104 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -722,7 +722,7 @@ swp_entry_t get_swap_page_of_type(int type)
 	return (swp_entry_t) {0};
 }
 
-static struct swap_info_struct *swap_info_get(swp_entry_t entry)
+struct swap_info_struct *swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 	unsigned long offset, type;
@@ -855,6 +855,15 @@ void swapcache_free(swp_entry_t entry)
 	}
 }
 
+void __swapcache_free(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+
+	p = swap_info_get(entry);
+	if (p)
+		swap_entry_free(p, entry, SWAP_HAS_CACHE);
+}
+
 /*
  * How many references to page are currently swapped out?
  * This does not give an exact answer when swap count is continued,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d24fd63b209..31af369eef24 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -526,6 +526,69 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 }
 
 /*
+ * Attempt to detach a locked page from its ->mapping in atomic context.
+ * If it is dirty or if someone else has a ref on the page or couldn't
+ * get necessary locks, abort and return 0.
+ * If it was successfully detached, return 1.
+ * Assumes the caller has a single ref on this page.
+ */
+int atomic_remove_mapping(struct address_space *mapping,
+				struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+	BUG_ON(mapping != page_mapping(page));
+	BUG_ON(!irqs_disabled());
+
+	spin_lock(&mapping->tree_lock);
+
+	/* Look at comment in __remove_mapping */
+	if (!page_freeze_refs(page, 2))
+		goto cannot_free;
+	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
+	if (unlikely(PageDirty(page))) {
+		page_unfreeze_refs(page, 2);
+		goto cannot_free;
+	}
+
+	if (PageSwapCache(page)) {
+		swp_entry_t swap = { .val = page_private(page) };
+		struct swap_info_struct *p = swap_info_get(swap);
+
+		if (!p || !spin_trylock(&p->lock)) {
+			page_unfreeze_refs(page, 2);
+			goto cannot_free;
+		}
+
+		mem_cgroup_swapout(page, swap);
+		__delete_from_swap_cache(page);
+		spin_unlock(&mapping->tree_lock);
+		__swapcache_free(swap);
+		spin_unlock(&p->lock);
+	} else {
+		void (*freepage)(struct page *);
+
+		freepage = mapping->a_ops->freepage;
+		__delete_from_page_cache(page, NULL);
+		spin_unlock(&mapping->tree_lock);
+
+		if (freepage != NULL)
+			freepage(page);
+	}
+
+	/*
+	 * Unfreezing the refcount with 1 rather than 2 effectively
+	 * drops the pagecache ref for us without requiring another
+	 * atomic operation.
+	 */
+	page_unfreeze_refs(page, 1);
+	return 1;
+
+cannot_free:
+	spin_unlock(&mapping->tree_lock);
+	return 0;
+}
+
+/*
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
