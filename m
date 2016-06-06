Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3117E6B0260
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:51:11 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id zc6so11088469lbb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:51:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uk6si28621673wjc.239.2016.06.06.12.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:51:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 03/10] mm: fold and remove lru_cache_add_anon() and lru_cache_add_file()
Date: Mon,  6 Jun 2016 15:48:29 -0400
Message-Id: <20160606194836.3624-4-hannes@cmpxchg.org>
In-Reply-To: <20160606194836.3624-1-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

They're the same function, and for the purpose of all callers they are
equivalent to lru_cache_add().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/cifs/file.c       | 10 +++++-----
 fs/fuse/dev.c        |  2 +-
 include/linux/swap.h |  2 --
 mm/shmem.c           |  4 ++--
 mm/swap.c            | 40 +++++++++-------------------------------
 mm/swap_state.c      |  2 +-
 6 files changed, 18 insertions(+), 42 deletions(-)

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 9793ae0bcaa2..232390879640 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3261,7 +3261,7 @@ cifs_readv_complete(struct work_struct *work)
 	for (i = 0; i < rdata->nr_pages; i++) {
 		struct page *page = rdata->pages[i];
 
-		lru_cache_add_file(page);
+		lru_cache_add(page);
 
 		if (rdata->result == 0 ||
 		    (rdata->result == -EAGAIN && got_bytes)) {
@@ -3321,7 +3321,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			 * fill them until the writes are flushed.
 			 */
 			zero_user(page, 0, PAGE_SIZE);
-			lru_cache_add_file(page);
+			lru_cache_add(page);
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 			unlock_page(page);
@@ -3331,7 +3331,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			continue;
 		} else {
 			/* no need to hold page hostage */
-			lru_cache_add_file(page);
+			lru_cache_add(page);
 			unlock_page(page);
 			put_page(page);
 			rdata->pages[i] = NULL;
@@ -3488,7 +3488,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 			/* best to give up if we're out of mem */
 			list_for_each_entry_safe(page, tpage, &tmplist, lru) {
 				list_del(&page->lru);
-				lru_cache_add_file(page);
+				lru_cache_add(page);
 				unlock_page(page);
 				put_page(page);
 			}
@@ -3518,7 +3518,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 			add_credits_and_wake_if(server, rdata->credits, 0);
 			for (i = 0; i < rdata->nr_pages; i++) {
 				page = rdata->pages[i];
-				lru_cache_add_file(page);
+				lru_cache_add(page);
 				unlock_page(page);
 				put_page(page);
 			}
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index cbece1221417..c7264d4a7f3f 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -900,7 +900,7 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 	get_page(newpage);
 
 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
-		lru_cache_add_file(newpage);
+		lru_cache_add(newpage);
 
 	err = 0;
 	spin_lock(&cs->req->waitq.lock);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0af2bb2028fd..38fe1e91ba55 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -296,8 +296,6 @@ extern unsigned long nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
 extern void lru_cache_add(struct page *);
-extern void lru_cache_add_anon(struct page *page);
-extern void lru_cache_add_file(struct page *page);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
diff --git a/mm/shmem.c b/mm/shmem.c
index e418a995427d..ff210317022d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1098,7 +1098,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 		oldpage = newpage;
 	} else {
 		mem_cgroup_migrate(oldpage, newpage);
-		lru_cache_add_anon(newpage);
+		lru_cache_add(newpage);
 		*pagep = newpage;
 	}
 
@@ -1289,7 +1289,7 @@ repeat:
 			goto decused;
 		}
 		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_anon(page);
+		lru_cache_add(page);
 
 		spin_lock(&info->lock);
 		info->alloced++;
diff --git a/mm/swap.c b/mm/swap.c
index d810c3d95c97..d2786a6308dd 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -386,36 +386,6 @@ void mark_page_accessed(struct page *page)
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
-static void __lru_cache_add(struct page *page)
-{
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
-
-	get_page(page);
-	if (!pagevec_space(pvec))
-		__pagevec_lru_add(pvec);
-	pagevec_add(pvec, page);
-	put_cpu_var(lru_add_pvec);
-}
-
-/**
- * lru_cache_add: add a page to the page lists
- * @page: the page to add
- */
-void lru_cache_add_anon(struct page *page)
-{
-	if (PageActive(page))
-		ClearPageActive(page);
-	__lru_cache_add(page);
-}
-
-void lru_cache_add_file(struct page *page)
-{
-	if (PageActive(page))
-		ClearPageActive(page);
-	__lru_cache_add(page);
-}
-EXPORT_SYMBOL(lru_cache_add_file);
-
 /**
  * lru_cache_add - add a page to a page list
  * @page: the page to be added to the LRU.
@@ -427,10 +397,18 @@ EXPORT_SYMBOL(lru_cache_add_file);
  */
 void lru_cache_add(struct page *page)
 {
+	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+
 	VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
-	__lru_cache_add(page);
+
+	get_page(page);
+	if (!pagevec_space(pvec))
+		__pagevec_lru_add(pvec);
+	pagevec_add(pvec, page);
+	put_cpu_var(lru_add_pvec);
 }
+EXPORT_SYMBOL(lru_cache_add);
 
 /**
  * add_page_to_unevictable_list - add a page to the unevictable list
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0d457e7db8d6..5400f814ae12 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -365,7 +365,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_anon(new_page);
+			lru_cache_add(new_page);
 			*new_page_allocated = true;
 			return new_page;
 		}
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
