Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2F182F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:54:33 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so103833413obb.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:54:33 -0700 (PDT)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id w4si16212569obp.92.2015.10.18.21.54.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:54:32 -0700 (PDT)
Received: by obcqt19 with SMTP id qt19so51817462obc.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:54:32 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:54:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/12] mm: rename mem_cgroup_migrate to
 mem_cgroup_replace_page
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

After v4.3's commit 0610c25daa3e ("memcg: fix dirty page migration")
mem_cgroup_migrate() doesn't have much to offer in page migration:
convert migrate_misplaced_transhuge_page() to set_page_memcg() instead.

Then rename mem_cgroup_migrate() to mem_cgroup_replace_page(), since its
remaining callers are replace_page_cache_page() and shmem_replace_page():
both of whom passed lrucare true, so just eliminate that argument.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    7 ++-----
 mm/filemap.c               |    2 +-
 mm/memcontrol.c            |   29 ++++++++---------------------
 mm/migrate.c               |    5 ++---
 mm/shmem.c                 |    2 +-
 5 files changed, 14 insertions(+), 31 deletions(-)

--- migrat.orig/include/linux/memcontrol.h	2015-10-04 10:47:52.429445705 -0700
+++ migrat/include/linux/memcontrol.h	2015-10-18 17:53:14.323325727 -0700
@@ -297,8 +297,7 @@ void mem_cgroup_cancel_charge(struct pag
 void mem_cgroup_uncharge(struct page *page);
 void mem_cgroup_uncharge_list(struct list_head *page_list);
 
-void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
-			bool lrucare);
+void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
@@ -535,9 +534,7 @@ static inline void mem_cgroup_uncharge_l
 {
 }
 
-static inline void mem_cgroup_migrate(struct page *oldpage,
-				      struct page *newpage,
-				      bool lrucare)
+static inline void mem_cgroup_replace_page(struct page *old, struct page *new)
 {
 }
 
--- migrat.orig/mm/filemap.c	2015-10-11 14:55:52.800038322 -0700
+++ migrat/mm/filemap.c	2015-10-18 17:53:14.324325728 -0700
@@ -510,7 +510,7 @@ int replace_page_cache_page(struct page
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		mem_cgroup_end_page_stat(memcg);
-		mem_cgroup_migrate(old, new, true);
+		mem_cgroup_replace_page(old, new);
 		radix_tree_preload_end();
 		if (freepage)
 			freepage(old);
--- migrat.orig/mm/memcontrol.c	2015-10-18 17:37:59.336284038 -0700
+++ migrat/mm/memcontrol.c	2015-10-18 17:53:14.326325730 -0700
@@ -4578,9 +4578,8 @@ static int mem_cgroup_move_account(struc
 		goto out;
 
 	/*
-	 * Prevent mem_cgroup_migrate() from looking at page->mem_cgroup
-	 * of its source page while we change it: page migration takes
-	 * both pages off the LRU, but page cache replacement doesn't.
+	 * Prevent mem_cgroup_replace_page() from looking at
+	 * page->mem_cgroup of its source page while we change it.
 	 */
 	if (!trylock_page(page))
 		goto out;
@@ -5547,7 +5546,7 @@ void mem_cgroup_uncharge_list(struct lis
 }
 
 /**
- * mem_cgroup_migrate - migrate a charge to another page
+ * mem_cgroup_replace_page - migrate a charge to another page
  * @oldpage: currently charged page
  * @newpage: page to transfer the charge to
  * @lrucare: either or both pages might be on the LRU already
@@ -5556,16 +5555,13 @@ void mem_cgroup_uncharge_list(struct lis
  *
  * Both pages must be locked, @newpage->mapping must be set up.
  */
-void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
-			bool lrucare)
+void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 {
 	struct mem_cgroup *memcg;
 	int isolated;
 
 	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(newpage), newpage);
 	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
 	VM_BUG_ON_PAGE(PageTransHuge(oldpage) != PageTransHuge(newpage),
 		       newpage);
@@ -5577,25 +5573,16 @@ void mem_cgroup_migrate(struct page *old
 	if (newpage->mem_cgroup)
 		return;
 
-	/*
-	 * Swapcache readahead pages can get migrated before being
-	 * charged, and migration from compaction can happen to an
-	 * uncharged page when the PFN walker finds a page that
-	 * reclaim just put back on the LRU but has not released yet.
-	 */
+	/* Swapcache readahead pages can get replaced before being charged */
 	memcg = oldpage->mem_cgroup;
 	if (!memcg)
 		return;
 
-	if (lrucare)
-		lock_page_lru(oldpage, &isolated);
-
+	lock_page_lru(oldpage, &isolated);
 	oldpage->mem_cgroup = NULL;
+	unlock_page_lru(oldpage, isolated);
 
-	if (lrucare)
-		unlock_page_lru(oldpage, isolated);
-
-	commit_charge(newpage, memcg, lrucare);
+	commit_charge(newpage, memcg, true);
 }
 
 /*
--- migrat.orig/mm/migrate.c	2015-10-18 17:53:11.062322014 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:14.326325730 -0700
@@ -30,7 +30,6 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
-#include <linux/memcontrol.h>
 #include <linux/syscalls.h>
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
@@ -1830,8 +1829,8 @@ fail_putback:
 	}
 
 	mlock_migrate_page(new_page, page);
-	mem_cgroup_migrate(page, new_page, false);
-
+	set_page_memcg(new_page, page_memcg(page));
+	set_page_memcg(page, NULL);
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
--- migrat.orig/mm/shmem.c	2015-09-12 18:30:20.857039763 -0700
+++ migrat/mm/shmem.c	2015-10-18 17:53:14.327325731 -0700
@@ -1023,7 +1023,7 @@ static int shmem_replace_page(struct pag
 		 */
 		oldpage = newpage;
 	} else {
-		mem_cgroup_migrate(oldpage, newpage, true);
+		mem_cgroup_replace_page(oldpage, newpage);
 		lru_cache_add_anon(newpage);
 		*pagep = newpage;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
