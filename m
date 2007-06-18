From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618092841.7790.48917.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/7] KAMEZAWA Hiroyuki hot-remove patches
Date: Mon, 18 Jun 2007 10:28:41 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is a rollup of two patches from KAMEZAWA Hiroyuki. A slightly later
version exists but this is the one I tested with and it checks page_mapped()
with the RCU lock held.

Patch 1 is "page migration by kernel v5."
Patch 2 is "isolate lru page race fix."

Changelog V5->V6
 - removed dummy_vma and uses rcu_read_lock().

In usual, migrate_pages(page,,) is called with holoding mm->sem by systemcall.
(mm here is a mm_struct which maps the migration target page.)
This semaphore helps avoiding some race conditions.

But, if we want to migrate a page by some kernel codes, we have to avoid
some races. This patch adds check code for following race condition.

1. A page which is not mapped can be target of migration. Then, we have
   to check page_mapped() before calling try_to_unmap().

2. anon_vma can be freed while page is unmapped, but page->mapping remains as
   it was. We drop page->mapcount to be 0. Then we cannot trust page->mapping.
   So, use rcu_read_lock() to prevent anon_vma pointed by page->mapping will
   not be freed during migration.

release_pages() in mm/swap.c changes page_count() to be 0
without removing PageLRU flag...

This means isolate_lru_page() can see a page, PageLRU() && page_count(page)==0..
This is BUG. (get_page() will be called against count=0 page.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 migrate.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-clean/mm/migrate.c linux-2.6.22-rc4-mm2-005_migrationkernel/mm/migrate.c
--- linux-2.6.22-rc4-mm2-clean/mm/migrate.c	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-005_migrationkernel/mm/migrate.c	2007-06-15 16:25:31.000000000 +0100
@@ -49,9 +49,8 @@ int isolate_lru_page(struct page *page, 
 		struct zone *zone = page_zone(page);
 
 		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page)) {
+		if (PageLRU(page) && get_page_unless_zero(page)) {
 			ret = 0;
-			get_page(page);
 			ClearPageLRU(page);
 			if (PageActive(page))
 				del_page_from_active_list(zone, page);
@@ -612,6 +611,7 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	int rcu_locked = 0;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,18 +632,27 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	/* anon_vma should not be freed while migration. */
+	if (PageAnon(page)) {
+		rcu_read_lock();
+		rcu_locked = 1;
+	}
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
-	try_to_unmap(page, 1);
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page);
+		goto unlock;
+
+	try_to_unmap(page, 1);
+	rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
 
 unlock:
+	if (rcu_locked)
+		rcu_read_unlock();
+
 	unlock_page(page);
 
 	if (rc != -EAGAIN) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
