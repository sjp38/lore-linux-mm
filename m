Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 549A66B0022
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:14:34 -0400 (EDT)
Received: by mail-px0-f177.google.com with SMTP id 10so2040762pxi.8
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:14:32 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 08/10] migration: make in-order-putback aware
Date: Mon, 30 May 2011 03:13:47 +0900
Message-Id: <1bffff5c891b174e1296a5182f09a8b46311b326.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

This patch makes migrate_pages_inorder_lru which is aware of in-order putback.
So newpage is located at old page's LRU position.

The logic is following as.

This patch creates new API migrate_pages_inorder_lru for compaction.
We need it because

1. inorder_lru uses singly linked list but migrate_pages doesn't support it
2. I need defer old page's putback.(see below)
3. I don't want to bother generic migrate_pages. Maybe there are some points
   we can unify but I want to defer it after review/merge/stable this series.

For in-order-putback of migration, we need some tweak.
First of all, we need defer old page's putback.
At present, during migration, old page would be freed through unmap_and_move's putback_lru_page.
It has a problem in inorder-putback's keep_lru_order logic.
It does check PageLRU and so on. If old page would be freed, it doesn't have PageLRU any more
so keep_lru_order returns false so inorder putback would become nop.

Second, we need adjust prev_page of inorder_lru pages when we putback newpage and
free old page.
For example,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4 - P3 - P2 - P1 - T
inorder_lru : 0

We isolate P2,P3,P4 so inorder_lru has following list

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P1 - T
inorder_lru : (P4,P5) - (P3,P4) - (P2,P3)

After 1st putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
inorder_lru : (P3,P4) - (P2,P3)
P4' is newpage and P4(ie, old page) would freed

In 2nd putback, P3 would find P4 in keep_order_lru but P4 is in buddy
so it returns false then inorder_lru doesn't work any more.
The bad effect continues until P2. That's too bad.
For fixing, this patch defines adjust_inorder_prev_page.
It works following as.

After 1st putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
inorder_lru : (P3,P4') - (P2,P3)

It replaces old page's pointer with new one's so

In 2nd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P1 -  T
inorder_lru : (P2,P3')

In 3rd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P2' - P1 - T
inorder_lru : 0

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 o Actually, I don't like new version of migration. We already had it on hugepage
   so I don't want to add another new version. But this patch might make many trouble
   of handling page list so I want to not propagate it into another stable thing.
   So my final descision is a complete separation but if you guys don't like it,
   I can unify it with some flag parameter. Maybe it could make code very ugly, I think.
   I want to unify all of migrate functions(ie, normal, inorder, huge_page) later.

 include/linux/migrate.h |    5 +
 mm/migrate.c            |  294 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 299 insertions(+), 0 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ca20500..8e96d92 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -50,6 +50,11 @@ extern int migrate_page(struct address_space *,
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
+
+extern int migrate_inorder_lru_pages(struct inorder_lru *l, new_page_t x,
+			unsigned long private, bool offlining,
+			bool sync);
+
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
diff --git a/mm/migrate.c b/mm/migrate.c
index d5a1194..bc614d3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -843,6 +843,250 @@ move_newpage:
 	return rc;
 }
 
+static inline void adjust_inorder_prev_page(struct inorder_lru *head,
+			struct page *prev_page, struct page *new_page)
+{
+	struct page *page;
+	list_for_each_migrate_entry(page, head, ilru)
+		if (page->ilru.prev_page == prev_page)
+			page->ilru.prev_page = new_page;
+}
+
+/*
+ * Counterpart of unmap_and_move() for compaction.
+ * The logic is almost same with unmap_and_move. The difference is
+ * this function handles prev_lru. For inorder-lru compaction, we use
+ * singly linked list so we need prev pointer handling to delete entry.
+ */
+static int unmap_and_move_inorder_lru(new_page_t get_new_page, unsigned long private,
+		struct page *page, int force, bool offlining, bool sync,
+		struct inorder_lru **prev_lru, struct inorder_lru *head)
+{
+	int rc = 0;
+	int *result = NULL;
+	struct page *newpage = get_new_page(page, private, &result);
+	int remap_swapcache = 1;
+	int charge = 0;
+	struct mem_cgroup *mem;
+	struct anon_vma *anon_vma = NULL;
+	struct page *prev_page;
+	struct zone *zone;
+	bool del = false;
+
+	VM_BUG_ON(!prev_lru);
+
+	if (!newpage)
+		return -ENOMEM;
+
+	prev_page = page->ilru.prev_page;
+	if (page_count(page) == 1) {
+		/* page was freed from under us. So we are done. */
+		goto move_newpage;
+	}
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page)))
+			goto move_newpage;
+
+	/* prepare cgroup just returns 0 or -ENOMEM */
+	rc = -EAGAIN;
+
+	if (!trylock_page(page)) {
+		if (!force || !sync)
+			goto move_newpage;
+
+		/*
+		 * It's not safe for direct compaction to call lock_page.
+		 * For example, during page readahead pages are added locked
+		 * to the LRU. Later, when the IO completes the pages are
+		 * marked uptodate and unlocked. However, the queueing
+		 * could be merging multiple pages for one bio (e.g.
+		 * mpage_readpages). If an allocation happens for the
+		 * second or third page, the process can end up locking
+		 * the same page twice and deadlocking. Rather than
+		 * trying to be clever about what pages can be locked,
+		 * avoid the use of lock_page for direct compaction
+		 * altogether.
+		 */
+		if (current->flags & PF_MEMALLOC)
+			goto move_newpage;
+		lock_page(page);
+	}
+
+	/*
+	 * Only memory hotplug's offline_pages() caller has locked out KSM,
+	 * and can safely migrate a KSM page.  The other cases have skipped
+	 * PageKsm along with PageReserved - but it is only now when we have
+	 * the page lock that we can be certain it will not go KSM beneath us
+	 * (KSM will not upgrade a page from PageAnon to PageKsm when it sees
+	 * its pagecount raised, but only here do we take the page lock which
+	 * serializes that).
+	 */
+	if (PageKsm(page) && !offlining) {
+		rc = -EBUSY;
+		goto unlock;
+	}
+
+	/* charge against new page */
+	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
+	if (charge == -ENOMEM) {
+		rc = -ENOMEM;
+		goto unlock;
+	}
+	BUG_ON(charge);
+
+	if (PageWriteback(page)) {
+		/*
+		 * For !sync, there is no point retrying as the retry loop
+		 * is expected to be too short for PageWriteback to be cleared
+		 */
+		if (!sync) {
+			rc = -EBUSY;
+			goto uncharge;
+		}
+		if (!force)
+			goto uncharge;
+		wait_on_page_writeback(page);
+	}
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 */
+	if (PageAnon(page)) {
+                /*
+                 * Only page_lock_anon_vma() understands the subtleties of
+                 * getting a hold on an anon_vma from outside one of its mms.
+                 */
+                anon_vma = page_lock_anon_vma(page);
+                if (anon_vma) {
+                        /*
+                         * Take a reference count on the anon_vma if the
+                         * page is mapped so that it is guaranteed to
+                         * exist when the page is remapped later
+                         */
+                        get_anon_vma(anon_vma);
+                        page_unlock_anon_vma(anon_vma);
+		} else if (PageSwapCache(page)) {
+			/*
+			 * We cannot be sure that the anon_vma of an unmapped
+			 * swapcache page is safe to use because we don't
+			 * know in advance if the VMA that this page belonged
+			 * to still exists. If the VMA and others sharing the
+			 * data have been freed, then the anon_vma could
+			 * already be invalid.
+			 *
+			 * To avoid this possibility, swapcache pages get
+			 * migrated but are not remapped when migration
+			 * completes
+			 */
+			remap_swapcache = 0;
+		} else {
+			goto uncharge;
+		}
+	}
+
+	/*
+	 * Corner case handling:
+	 * 1. When a new swap-cache page is read into, it is added to the LRU
+	 * and treated as swapcache but it has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page will
+	 * trigger a BUG.  So handle it here.
+	 * 2. An orphaned page (see truncate_complete_page) might have
+	 * fs-private metadata. The page can be picked up due to memory
+	 * offlining.  Everywhere else except page reclaim, the page is
+	 * invisible to the vm, so the page can not be migrated.  So try to
+	 * free the metadata, so the page can be freed.
+	 */
+	if (!page->mapping) {
+		VM_BUG_ON(PageAnon(page));
+		if (page_has_private(page)) {
+			try_to_free_buffers(page);
+			goto uncharge;
+		}
+		goto skip_unmap;
+	}
+
+	/* Establish migration ptes or remove ptes */
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+
+skip_unmap:
+	if (!page_mapped(page))
+		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
+
+	if (rc && remap_swapcache)
+		remove_migration_ptes(page, page);
+
+	/* Drop an anon_vma reference if we took one */
+	if (anon_vma)
+		put_anon_vma(anon_vma);
+
+uncharge:
+	if (!charge)
+		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+unlock:
+	unlock_page(page);
+
+move_newpage:
+	if (rc != -EAGAIN) {
+		/*
+		 * A page that has been migrated has all references
+		 * removed and will be freed. A page that has not been
+		 * migrated will have kepts its references and be
+		 * restored.
+		 */
+		migratelist_del(page, *prev_lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		/*
+		 * Unlike unmap_and_move, we defer putback page
+		 * after inorder handling. Because the page would
+		 * be freed so it doesn't have PG_lru. Then,
+		 * keep_lru_order doesn't work correctly.
+		 */
+		del = true;
+	}
+	else
+		*prev_lru = &page->ilru;
+
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lru_lock);
+	if (keep_lru_order(page, prev_page)) {
+		putback_page_to_lru(newpage, prev_page);
+		spin_unlock_irq(&zone->lru_lock);
+		/*
+		 * The newpage will replace LRU position of old page and
+		 * old one would be freed. So let's adjust prev_page of pages
+		 * remained in migratelist for keep_lru_order.
+		 */
+		adjust_inorder_prev_page(head, page, newpage);
+		put_page(newpage); /* drop ref from isolate */
+	}
+	else {
+
+		spin_unlock_irq(&zone->lru_lock);
+		putback_lru_page(newpage);
+	}
+
+	if (del)
+		putback_lru_page(page);
+
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(newpage);
+	}
+	return rc;
+}
+
+
 /*
  * Counterpart of unmap_and_move_page() for hugepage migration.
  *
@@ -984,6 +1228,56 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_inorder_lru_pages(struct inorder_lru *head, new_page_t get_new_page,
+		unsigned long private, bool offlining, bool sync)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int pass = 0;
+	struct page *page, *page2;
+	struct inorder_lru *prev;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	for(pass = 0; pass < 10 && retry; pass++) {
+		retry = 0;
+		list_for_each_migrate_entry_safe(page, page2, head, ilru) {
+			cond_resched();
+
+			prev = head;
+			rc = unmap_and_move_inorder_lru(get_new_page, private,
+					page, pass > 2, offlining,
+					sync, &prev, head);
+
+			switch(rc) {
+				case -ENOMEM:
+					goto out;
+				case -EAGAIN:
+					retry++;
+					break;
+				case 0:
+					break;
+				default:
+					/* Permanent failure */
+					nr_failed++;
+					break;
+			}
+		}
+	}
+	rc = 0;
+out:
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	if (rc)
+		return rc;
+
+	return nr_failed + retry;
+}
+
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
 		bool sync)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
