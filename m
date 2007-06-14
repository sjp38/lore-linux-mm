Date: Thu, 14 Jun 2007 17:29:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
	<20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
	<20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 00:47:46 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:
> 
> > In my understanding:
> > 
> > PageAnon(page) checks (page->mapping & 0x1). And, as you know, page->mapping
> > is not cleared even if the page is removed from rmap.
> 
> But in that case the refcount is zero. We will not migrate the page.
> 
yes. why we add dummy_vma to page here is 
==
0. page_count(page) check.
1. does try_to_unmap() and page->mapcount goes down to 0. page->count goes down to 1.
2. page->mapping is copied to newpage.
3. remove_migration_ptes is called against newpage->mapping.
==

If page is zapped while 0->1, newpage->mapping can be untrustable value.
My point is that if page->mapcount goes down to 0, we should be careful to
access page->mapping value.

But...during discussion with you, I found anon_vma is now freed by RCU...

Ugh, then, what I have to do is  rcu_read_lock() -> rcu_read_unlock() while
migrating anon ptes. If we can rcu read lock here, we don't need dummy_vma.
How about this ?

-Kame
p.s page_lock_anon_vma() locks anon_vma, not page.

==
page migratio by kernel v5.

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

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/migrate.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

Index: devel-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/migrate.c
+++ devel-2.6.22-rc4-mm2/mm/migrate.c
@@ -612,6 +612,7 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	int rcu_locked = 0;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,16 +633,24 @@ static int unmap_and_move(new_page_t get
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
+	if (page_mapped(page))
+		try_to_unmap(page, 1);
+
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
+	if (rcu_locked)
+		rcu_read_unlock();
 
 unlock:
 	unlock_page(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
