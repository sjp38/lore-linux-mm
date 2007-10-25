Date: Thu, 25 Oct 2007 16:36:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0710251556300.1521@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
 <84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org, neilb@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 22 Oct 2007, Pekka Enberg wrote:
> On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
> > Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
> > Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
> > if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
> > a special code to get the LRU rotation right, not useful elsewhere.
> > Though Documentation/filesystems/vfs.txt does imply wider use.
> >
> > I think this is where people use the phrase "go figure" ;)
> 
> Heh. As far as I can tell, the implication of "wider use" was added by
> Neil in commit "341546f5ad6fce584531f744853a5807a140f2a9 Update some
> VFS documentation", so perhaps he might know? Neil?

I take as gospel this extract from Andrew's original 2.5.52 comment:

  So the locking rules for writepage() are unchanged.  They are:
  
  - Called with the page locked
  - Returns with the page unlocked
  - Must redirty the page itself if it wasn't all written.
  
  But there is a new, special, hidden, undocumented, secret hack for
  tmpfs: writepage may return WRITEPAGE_ACTIVATE to tell the VM to move
  the page to the active list.  The page must be kept locked in this one
  case.

Special, hidden, undocumented, secret hack!  Then in 2.6.7 Andrew
stole his own secret and used it when concocting ramdisk_writepage.
Oh, and NFS made some kind of use of it in 2.6.6 only.  Then Neil
revealed the secret to the uninitiated in 2.6.17: now, what's the
appropriate punishment for that?

In the full 2.5.52 comment, Andrew explains how prior to this secret
code, we used fail_writepage, which in the memory pressure case did
an activate_page, with the intention of moving the page to the active
list - but that didn't actually work, because the page is off the
LRUs at this point, being passed around between pagevecs.

I've always preferred the way it was originally trying to do it, which
seems clearer and less error-prone than having a special code which
people then have to worry about.  Here's the patch I'd like to present
in due course (against 2.6.24-rc1, so unionfs absent): tmpfs and ramdisk
simply SetPageActive for this case (and go back to obeying the usual
unlocking rule for writepage), vmscan.c observe and act accordingly.

But I've not tested it at all (well, I've run with it in, but not
actually going down the paths in question): it may suffer from
something silly like the original fail_writepage.  Plus I might be
persuaded into making inc_zone_page_state(page, NR_VMSCAN_WRITE)
conditional on !PageActive(page), just to produce the same stats
as before (though they don't make a lot of sense, counting other
non-writes as writes).  And would it need a deprecation phase?

Hugh

 Documentation/filesystems/Locking |    6 +-----
 Documentation/filesystems/vfs.txt |    4 +---
 drivers/block/rd.c                |    5 ++---
 include/linux/fs.h                |   10 ----------
 mm/migrate.c                      |    5 ++---
 mm/page-writeback.c               |    4 ----
 mm/shmem.c                        |   11 ++++++++---
 mm/vmscan.c                       |   17 ++++++-----------
 8 files changed, 20 insertions(+), 42 deletions(-)

--- 2.6.24-rc1/Documentation/filesystems/Locking	2007-10-24 07:15:11.000000000 +0100
+++ linux/Documentation/filesystems/Locking	2007-10-24 08:42:07.000000000 +0100
@@ -228,11 +228,7 @@ If the filesystem is called for sync the
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
--- 2.6.24-rc1/Documentation/filesystems/vfs.txt	2007-10-24 07:15:11.000000000 +0100
+++ linux/Documentation/filesystems/vfs.txt	2007-10-24 08:42:07.000000000 +0100
@@ -567,9 +567,7 @@ struct address_space_operations {
       If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
       try too hard if there are problems, and may choose to write out
       other pages from the mapping if that is easier (e.g. due to
-      internal dependencies).  If it chooses not to start writeout, it
-      should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
-      calling ->writepage on that page.
+      internal dependencies).
 
       See the file "Locking" for more details.
 
--- 2.6.24-rc1/drivers/block/rd.c	2007-10-24 07:15:23.000000000 +0100
+++ linux/drivers/block/rd.c	2007-10-24 08:42:07.000000000 +0100
@@ -152,8 +152,7 @@ static int ramdisk_commit_write(struct f
 
 /*
  * ->writepage to the blockdev's mapping has to redirty the page so that the
- * VM doesn't go and steal it.  We return AOP_WRITEPAGE_ACTIVATE so that the VM
- * won't try to (pointlessly) write the page again for a while.
+ * VM doesn't go and steal it.
  *
  * Really, these pages should not be on the LRU at all.
  */
@@ -163,7 +162,7 @@ static int ramdisk_writepage(struct page
 		make_page_uptodate(page);
 	SetPageDirty(page);
 	if (wbc->for_reclaim)
-		return AOP_WRITEPAGE_ACTIVATE;
+		SetPageActive(page);
 	unlock_page(page);
 	return 0;
 }
--- 2.6.24-rc1/include/linux/fs.h	2007-10-24 07:16:01.000000000 +0100
+++ linux/include/linux/fs.h	2007-10-24 08:42:07.000000000 +0100
@@ -368,15 +368,6 @@ struct iattr {
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
@@ -392,7 +383,6 @@ struct iattr {
  */
 
 enum positive_aop_returns {
-	AOP_WRITEPAGE_ACTIVATE	= 0x80000,
 	AOP_TRUNCATED_PAGE	= 0x80001,
 };
 
--- 2.6.24-rc1/mm/migrate.c	2007-10-24 07:16:04.000000000 +0100
+++ linux/mm/migrate.c	2007-10-24 08:42:07.000000000 +0100
@@ -525,9 +525,8 @@ static int writeout(struct address_space
 		/* I/O Error writing */
 		return -EIO;
 
-	if (rc != AOP_WRITEPAGE_ACTIVATE)
-		/* unlocked. Relock */
-		lock_page(page);
+	/* Unlocked: relock */
+	lock_page(page);
 
 	return -EAGAIN;
 }
--- 2.6.24-rc1/mm/page-writeback.c	2007-10-24 07:16:04.000000000 +0100
+++ linux/mm/page-writeback.c	2007-10-24 08:42:07.000000000 +0100
@@ -850,10 +850,6 @@ retry:
 
 			ret = (*writepage)(page, wbc, data);
 
-			if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
-				unlock_page(page);
-				ret = 0;
-			}
 			if (ret || (--(wbc->nr_to_write) <= 0))
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
--- 2.6.24-rc1/mm/shmem.c	2007-10-24 07:16:04.000000000 +0100
+++ linux/mm/shmem.c	2007-10-24 08:42:07.000000000 +0100
@@ -915,6 +915,8 @@ static int shmem_writepage(struct page *
 	struct inode *inode;
 
 	BUG_ON(!PageLocked(page));
+	if (!wbc->for_reclaim)
+		goto redirty;
 	BUG_ON(page_mapped(page));
 
 	mapping = page->mapping;
@@ -922,10 +924,10 @@ static int shmem_writepage(struct page *
 	inode = mapping->host;
 	info = SHMEM_I(inode);
 	if (info->flags & VM_LOCKED)
-		goto redirty;
+		goto reactivate;
 	swap = get_swap_page();
 	if (!swap.val)
-		goto redirty;
+		goto reactivate;
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
@@ -955,9 +957,12 @@ static int shmem_writepage(struct page *
 unlock:
 	spin_unlock(&info->lock);
 	swap_free(swap);
+reactivate:
+	SetPageActive(page);
 redirty:
 	set_page_dirty(page);
-	return AOP_WRITEPAGE_ACTIVATE;	/* Return with the page locked */
+	unlock_page(page);
+	return 0;
 }
 
 #ifdef CONFIG_NUMA
--- 2.6.24-rc1/mm/vmscan.c	2007-10-24 07:16:04.000000000 +0100
+++ linux/mm/vmscan.c	2007-10-24 08:42:07.000000000 +0100
@@ -281,8 +281,6 @@ enum pageout_io {
 typedef enum {
 	/* failed to write page out, page is locked */
 	PAGE_KEEP,
-	/* move page to the active list, page is locked */
-	PAGE_ACTIVATE,
 	/* page has been sent to the disk successfully, page is unlocked */
 	PAGE_SUCCESS,
 	/* page is clean and locked */
@@ -329,8 +327,10 @@ static pageout_t pageout(struct page *pa
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
 
@@ -349,10 +349,6 @@ static pageout_t pageout(struct page *pa
 		res = mapping->a_ops->writepage(page, &wbc);
 		if (res < 0)
 			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
-			return PAGE_ACTIVATE;
-		}
 
 		/*
 		 * Wait on writeback if requested to. This happens when
@@ -538,8 +534,6 @@ static unsigned long shrink_page_list(st
 			switch (pageout(page, mapping, sync_writeback)) {
 			case PAGE_KEEP:
 				goto keep_locked;
-			case PAGE_ACTIVATE:
-				goto activate_locked;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page) || PageDirty(page))
 					goto keep;
@@ -597,10 +591,11 @@ free_it:
 
 activate_locked:
 		SetPageActive(page);
-		pgactivate++;
 keep_locked:
 		unlock_page(page);
 keep:
+		if (PageActive(page))
+			pgactivate++;
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page));
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
