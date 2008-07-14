Date: Tue, 15 Jul 2008 04:12:22 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 3/9] revert migration change of unevictable lru infrastructure
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715041051.F6F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: unevictable-lru-infrastructure-revert-migration-change.patch
Against:  mmotm Jul 14
Applies after: unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch


Unevictable LRU Infrastructure patch changed several migration code because
Old version putback_lru_page() had needed to page lock.

it has little performance degression and isn't necessary now.
So, reverting is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/migrate.c |   38 +++++++++++---------------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -67,11 +67,7 @@ int putback_lru_pages(struct list_head *
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
-		get_page(page);
-		lock_page(page);
 		putback_lru_page(page);
-		unlock_page(page);
-		put_page(page);
 		count++;
 	}
 	return count;
@@ -583,8 +579,6 @@ static int move_to_new_page(struct page 
 	struct address_space *mapping;
 	int rc;
 
-	get_page(newpage); /* for prevent page release under lock_page() */
-
 	/*
 	 * Block others from accessing the page when we get around to
 	 * establishing additional references. We are the only one
@@ -617,12 +611,10 @@ static int move_to_new_page(struct page 
 
 	if (!rc) {
 		remove_migration_ptes(page, newpage);
-		putback_lru_page(newpage);
 	} else
 		newpage->mapping = NULL;
 
 	unlock_page(newpage);
-	put_page(newpage);
 
 	return rc;
 }
@@ -645,16 +637,13 @@ static int unmap_and_move(new_page_t get
 
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
-		get_page(page);
-		goto end_migration;
+		goto move_newpage;
 	}
 
-	get_page(page);
-
 	charge = mem_cgroup_prepare_migration(page, newpage);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
-		goto end_migration;
+		goto move_newpage;
 	}
 	/* prepare cgroup just returns 0 or -ENOMEM */
 	BUG_ON(charge);
@@ -662,7 +651,7 @@ static int unmap_and_move(new_page_t get
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
-			goto end_migration;
+			goto move_newpage;
 		lock_page(page);
 	}
 
@@ -723,6 +712,7 @@ rcu_unlock:
 		rcu_read_unlock();
 
 unlock:
+	unlock_page(page);
 
 	if (rc != -EAGAIN) {
  		/*
@@ -735,22 +725,16 @@ unlock:
 		putback_lru_page(page);
 	}
 
-	unlock_page(page);
-
-end_migration:
-	put_page(page);
-
+move_newpage:
 	if (!charge)
 		mem_cgroup_end_migration(newpage);
 
-	if (!newpage->mapping) {
-		/*
-		 * Migration failed or was never attempted.
-		 * Free the newpage.
-		 */
-		VM_BUG_ON(page_count(newpage) != 1);
-		put_page(newpage);
-	}
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	putback_lru_page(newpage);
+
 	if (result) {
 		if (rc)
 			*result = rc;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
