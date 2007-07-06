Date: Fri, 6 Jul 2007 18:23:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory unplug v7 - migration by kernel
Message-Id: <20070706182324.e18338d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

page migration by kernel v6.

Changelog V6->V7
 - moved rcu_read_lock/rcu_read_unlock to correct place.
 - fixed text.

Changelog V5->V6
 - removed dummy_vma and uses rcu_read_lock().
 - removed page_mapped() check and uses !page->mapping check.

In usual, migrate_pages(page,,) is called with holding mm->sem by system call.
(mm here is a mm_struct which maps the migration target page.)
This semaphore helps avoiding some race conditions.

But, if we want to migrate a page by some kernel codes, we have to avoid
some races. This patch adds check code for following race condition.

1. A page which page->mapping==NULL can be target of migration. Then, we have
   to check page->mapping before calling try_to_unmap().

2. anon_vma can be freed while page is unmapped, but page->mapping remains as
   it was. We drop page->mapcount to be 0. Then we cannot trust page->mapping.
   So, use rcu_read_lock() to prevent anon_vma pointed by page->mapping from
   being freed during migration.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/migrate.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/migrate.c
+++ linux-2.6.22-rc6-mm1/mm/migrate.c
@@ -632,18 +632,35 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
 	/*
-	 * Establish migration ptes or remove ptes
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This rcu_read_lock() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
 	 */
+	rcu_read_lock();
+	/*
+	 * This is a corner case handling.
+	 * When a new swap-cache is read into, it is linked to LRU
+	 * and treated as swapcache but has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page is
+	 * BUG. So handle it here.
+	 */
+	if (!page->mapping)
+		goto rcu_unlock;
+	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
+
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
+rcu_unlock:
+	rcu_read_unlock();
 
 unlock:
+
 	unlock_page(page);
 
 	if (rc != -EAGAIN) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
