Date: Thu, 20 Nov 2008 01:14:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/7] mm: remove AOP_WRITEPAGE_ACTIVATE
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200111510.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Neil Brown <neilb@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Erez Zadok <ezk@cs.sunysb.edu>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

AOP_WRITEPAGE_ACTIVATE is a special return value from a_ops->writepage(),
for the filesystem to tell reclaim that it didn't write the page, and
there's little chance of being able to write it soon, so please defer
its reclaim as long as possible by recycling to head of active list.

(The Unevictable LRU has replaced this functionality to some extent;
but not entirely, and CONFIG_UNEVICTABLE_LRU may anyway not be set.)

It has only one user in tree, shmem_writepage(), and it only makes
sense in reclaim; but it has the confusing peculiarity of returning
with the page still locked, unlike both success and error cases.

It would be more intuitive if shmem_writepage() were to return the
page unlocked with PageActive set, and vmscan observe that to activate
the page: then nowhere else need worry about this peculiar return value.

(We already have the case of an unlocked page marked PageActive
but not yet PageLRU, that's not new.)

One anomaly - NR_VMSCAN_WRITE stats were not updated when AOP_WRITEPAGE
_ACTIVATE, but were updated when the filesystem just redirtied the page
and feigned success: NR_VMSCAN_WRITE stats now updated in neither case.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
This has only taken me one year!

Google codesearch shows just one out-of-tree project actually using it:
openafs (in osi_vnodeops.c).  unionfs no longer refers to it; btrfs
refers to it only in #if code for kernel versions before 2.6.22.

Would it be okay for me to advise the OpenAFS people, and we remove the
definition in 2.6.29; or do we need to go through a deprecation process?

 Documentation/filesystems/Locking |    6 +-----
 Documentation/filesystems/vfs.txt |   13 ++++++++++---
 fs/buffer.c                       |   12 +++++-------
 include/linux/fs.h                |   10 ----------
 mm/migrate.c                      |    5 ++---
 mm/page-writeback.c               |   27 +++++++++++----------------
 mm/shmem.c                        |    2 +-
 mm/vmscan.c                       |   24 +++++++++++-------------
 8 files changed, 41 insertions(+), 58 deletions(-)

--- mmclean1/Documentation/filesystems/Locking	2008-11-02 23:17:53.000000000 +0000
+++ mmclean2/Documentation/filesystems/Locking	2008-11-19 15:26:13.000000000 +0000
@@ -225,11 +225,7 @@ If the filesystem is called for sync the
 in-progress I/O and then start new I/O.
 
 The filesystem should unlock the page synchronously, before returning to the
-caller, unless ->writepage() returns special WRITEPAGE_ACTIVATE
-value. WRITEPAGE_ACTIVATE means that page cannot really be written out
-currently, and VM should stop calling ->writepage() on this page for some
-time. VM does this by moving page to the head of the active list, hence the
-name.
+caller.
 
 Unless the filesystem is going to redirty_page_for_writepage(), unlock the page
 and return zero, writepage *must* run set_page_writeback() against the page,
--- mmclean1/Documentation/filesystems/vfs.txt	2008-11-19 15:24:49.000000000 +0000
+++ mmclean2/Documentation/filesystems/vfs.txt	2008-11-19 15:26:13.000000000 +0000
@@ -551,9 +551,16 @@ struct address_space_operations {
       If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
       try too hard if there are problems, and may choose to write out
       other pages from the mapping if that is easier (e.g. due to
-      internal dependencies).  If it chooses not to start writeout, it
-      should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
-      calling ->writepage on that page.
+      internal dependencies); then redirty_page_for_writepage() on the
+      given page, before unlocking it and returning 0 for success.
+
+      If wbc->for_reclaim, but the filesystem will be unable to write
+      out the page for the foreseeable future (perhaps it cannot even
+      implement writepage in reclaim), it may redirty_page_for_writepage()
+      then SetPageActive(), before unlocking the page and returning 0: to
+      delay page reclaim from reconsidering this page for a little longer.
+      But this is unusual: SetPageActive() should never be used unless
+      wbc->for_reclaim, and only shmem_writepage() actually does this.
 
       See the file "Locking" for more details.
 
--- mmclean1/fs/buffer.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/fs/buffer.c	2008-11-19 15:26:13.000000000 +0000
@@ -3324,7 +3324,6 @@ EXPORT_SYMBOL(bh_submit_read);
 static void trigger_write(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	int rc;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_NONE,
 		.nr_to_write = 1,
@@ -3345,13 +3344,12 @@ static void trigger_write(struct page *p
 		/* Someone else already triggered a write */
 		goto unlock;
 
-	rc = mapping->a_ops->writepage(page, &wbc);
-	if (rc < 0)
-		/* I/O Error writing */
-		return;
+	mapping->a_ops->writepage(page, &wbc);
+	/* Ignore any error in writing */
+	return;
 
-	if (rc == AOP_WRITEPAGE_ACTIVATE)
-unlock:		unlock_page(page);
+unlock:
+	unlock_page(page);
 }
 
 /*
--- mmclean1/include/linux/fs.h	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/include/linux/fs.h	2008-11-19 15:26:13.000000000 +0000
@@ -385,15 +385,6 @@ struct iattr {
 /** 
  * enum positive_aop_returns - aop return codes with specific semantics
  *
- * @AOP_WRITEPAGE_ACTIVATE: Informs the caller that page writeback has
- * 			    completed, that the page is still locked, and
- * 			    should be considered active.  The VM uses this hint
- * 			    to return the page to the active list -- it won't
- * 			    be a candidate for writeback again in the near
- * 			    future.  Other callers must be careful to unlock
- * 			    the page if they get this return.  Returned by
- * 			    writepage(); 
- *
  * @AOP_TRUNCATED_PAGE: The AOP method that was handed a locked page has
  *  			unlocked it and the page might have been truncated.
  *  			The caller should back up to acquiring a new page and
@@ -409,7 +400,6 @@ struct iattr {
  */
 
 enum positive_aop_returns {
-	AOP_WRITEPAGE_ACTIVATE	= 0x80000,
 	AOP_TRUNCATED_PAGE	= 0x80001,
 };
 
--- mmclean1/mm/migrate.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/mm/migrate.c	2008-11-19 15:26:13.000000000 +0000
@@ -523,9 +523,8 @@ static int writeout(struct address_space
 
 	rc = mapping->a_ops->writepage(page, &wbc);
 
-	if (rc != AOP_WRITEPAGE_ACTIVATE)
-		/* unlocked. Relock */
-		lock_page(page);
+	/* Unlocked: relock */
+	lock_page(page);
 
 	return (rc < 0) ? -EIO : -EAGAIN;
 }
--- mmclean1/mm/page-writeback.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/mm/page-writeback.c	2008-11-19 15:26:13.000000000 +0000
@@ -963,22 +963,17 @@ continue_unlock:
 
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
-				if (ret == AOP_WRITEPAGE_ACTIVATE) {
-					unlock_page(page);
-					ret = 0;
-				} else {
-					/*
-					 * done_index is set past this page,
-					 * so media errors will not choke
-					 * background writeout for the entire
-					 * file. This has consequences for
-					 * range_cyclic semantics (ie. it may
-					 * not be suitable for data integrity
-					 * writeout).
-					 */
-					done = 1;
-					break;
-				}
+				/*
+				 * done_index is set past this page,
+				 * so media errors will not choke
+				 * background writeout for the entire
+				 * file. This has consequences for
+				 * range_cyclic semantics (ie. it may
+				 * not be suitable for data integrity
+				 * writeout).
+				 */
+				done = 1;
+				break;
  			}
 
 			if (wbc->sync_mode == WB_SYNC_NONE) {
--- mmclean1/mm/shmem.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/mm/shmem.c	2008-11-19 15:26:13.000000000 +0000
@@ -1074,7 +1074,7 @@ unlock:
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
-		return AOP_WRITEPAGE_ACTIVATE;	/* Return with page locked */
+		SetPageActive(page);
 	unlock_page(page);
 	return 0;
 }
--- mmclean1/mm/vmscan.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean2/mm/vmscan.c	2008-11-19 15:26:13.000000000 +0000
@@ -349,8 +349,6 @@ typedef enum {
 	/* failed to write page out, page is locked */
 	PAGE_KEEP,
 	/* move page to the active list, page is locked */
-	PAGE_ACTIVATE,
-	/* page has been sent to the disk successfully, page is unlocked */
 	PAGE_SUCCESS,
 	/* page is clean and locked */
 	PAGE_CLEAN,
@@ -396,8 +394,10 @@ static pageout_t pageout(struct page *pa
 		}
 		return PAGE_KEEP;
 	}
-	if (mapping->a_ops->writepage == NULL)
-		return PAGE_ACTIVATE;
+	if (mapping->a_ops->writepage == NULL) {
+		SetPageActive(page);
+		return PAGE_KEEP;
+	}
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
@@ -416,10 +416,6 @@ static pageout_t pageout(struct page *pa
 		res = mapping->a_ops->writepage(page, &wbc);
 		if (res < 0)
 			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
-			return PAGE_ACTIVATE;
-		}
 
 		/*
 		 * Wait on writeback if requested to. This happens when
@@ -430,10 +426,13 @@ static pageout_t pageout(struct page *pa
 			wait_on_page_writeback(page);
 
 		if (!PageWriteback(page)) {
-			/* synchronous write or broken a_ops? */
+			/* synchronous write, or writepage passed over it */
 			ClearPageReclaim(page);
 		}
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		if (!PageDirty(page)) {
+			/* writepage did not pass over this write */
+			inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		}
 		return PAGE_SUCCESS;
 	}
 
@@ -720,8 +719,6 @@ static unsigned long shrink_page_list(st
 			switch (pageout(page, mapping, sync_writeback)) {
 			case PAGE_KEEP:
 				goto keep_locked;
-			case PAGE_ACTIVATE:
-				goto activate_locked;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page) || PageDirty(page))
 					goto keep;
@@ -811,10 +808,11 @@ activate_locked:
 			remove_exclusive_swap_page_ref(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-		pgactivate++;
 keep_locked:
 		unlock_page(page);
 keep:
+		if (PageActive(page))
+			pgactivate++;
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
