Date: Fri, 15 Jun 2007 18:43:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070615184308.d59a9c11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070615073125.f5e4d6e2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
	<20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
	<20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
	<20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
	<20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
	<20070615011536.beaa79c1.kamezawa.hiroyu@jp.fujitsu.com>
	<46718320.1010500@csn.ul.ie>
	<20070615073125.f5e4d6e2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

This is updated version.

-Kame

page migration by kernel v6.

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

Index: devel-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/migrate.c
+++ devel-2.6.22-rc4-mm2/mm/migrate.c
@@ -632,16 +632,30 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
 	/*
-	 * Establish migration ptes or remove ptes
+	 * This is a corner case handling.
+	 * When a new swap-ache is read into, it is linked to LRU
+	 * and treated as swapcache but has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page is
+	 * BUG. So handle it here.
+	 */
+	if (!page->mapping)
+		goto unlock;
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a pages
+	 * This rcu_read_lock() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
 	 */
+	rcu_read_lock();
 	try_to_unmap(page, 1);
+
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
+	rcu_read_unlock();
 
 unlock:
 	unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
