Date: Sun, 1 Apr 2001 22:25:02 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: [PATCH-2.4.2ac26] More shared memory corruption/leak bugfixes
Message-ID: <20010401222502.B977@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uZ3hkaAS1mZxFaxD"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>, linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, arjanv@redhat.com, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The patch below fixes a number of problems in shared memory in
2.4.2ac26 (ie. it is relative to my previous set of shm patches).

The main problems fixed (hopefully!) are:

 Fix locking to avoid sleeping with spinlocks

 Fix locking to avoid races between swapin and swapout

 Fix shm size accounting to prevent a swap leak in shmem_truncate

 Avoid swapout on already-mapped pages to avoid disconnecting pages
 from their shm segment

I'm currently on a plane and will have only sporadic laptop access to
mail for the next week and a half, so I'll not be able to do much more
than the basic tmpfs testing I've already done on these patches so far
(I have checked that it runs on ac28 too, though).  Feedback welcome
but I may not be as responsive as I'd like until about the 14th of
April.

The patches will not apply to 2.4.3 kernels until Christoph's own
changes in ac* are merged in, but most of the bugs fixed here apply to
2.4.3 too.  I think that the Linus tree avoids the leak, but the
locking problems are in both trees.

Cheers,
 Stephen


--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.4.2-ac26.shm-fix2.patch2"

--- linux-2.4.2-ac26/mm/shmem.c.~1~	Tue Mar 27 18:41:50 2001
+++ linux-2.4.2-ac26/mm/shmem.c	Sun Apr  1 02:52:14 2001
@@ -226,7 +226,7 @@
  */
 static int shmem_writepage(struct page * page)
 {
-	int error;
+	int error = 0;
 	struct shmem_inode_info *info;
 	swp_entry_t *entry, swap;
 	struct inode *inode;
@@ -234,6 +234,11 @@
 	if (!PageLocked(page))
 		BUG();
 	
+	/* Only move to the swap cache if there are no other users of
+	 * the page. */
+	if (atomic_read(&page->count) > 2)
+		goto out;
+	
 	inode = page->mapping->host;
 	info = &inode->u.shmem_i;
 	swap = __get_swap_page(2);
@@ -243,16 +248,14 @@
 		return -ENOMEM;
 	}
 
+	spin_lock(&info->lock);
 	entry = shmem_swp_entry(info, page->index);
 	if (IS_ERR(entry))	/* this had been allocted on page allocation */
 		BUG();
-	spin_lock(&info->lock);
 	shmem_recalc_inode(page->mapping->host);
 	error = -EAGAIN;
-	if (entry->val) {
-		__swap_free(swap, 2);
-		goto out;
-	}
+	if (entry->val)
+		BUG();
 
 	*entry = swap;
 	error = 0;
@@ -265,8 +268,9 @@
 	page_cache_release(page);
 	set_page_dirty(page);
 	info->swapped++;
-out:
+
 	spin_unlock(&info->lock);
+out:
 	UnlockPage(page);
 	return error;
 }
@@ -307,8 +311,10 @@
 	 * cache and swap cache.  We need to recheck the page cache
 	 * under the protection of the info->lock spinlock. */
 
-	page = find_lock_page(mapping, idx);
+	page = __find_get_page(mapping, idx, page_hash(mapping, idx));
 	if (page) {
+		if (TryLockPage(page))
+			goto wait_retry;
 		spin_unlock (&info->lock);
 		return page;
 	}
@@ -317,7 +323,8 @@
 		unsigned long flags;
 
 		/* Look it up and read it in.. */
-		page = lookup_swap_cache(*entry);
+		page = __find_get_page(&swapper_space, entry->val,
+				       page_hash(&swapper_space, entry->val));
 		if (!page) {
 			spin_unlock (&info->lock);
 			lock_kernel();
@@ -326,6 +333,11 @@
 			unlock_kernel();
 			if (!page) 
 				return ERR_PTR(-ENOMEM);
+			if (!Page_Uptodate(page)) {
+				page_cache_release(page);
+				return ERR_PTR(-EIO);
+			}
+			
 			/* Too bad we can't trust this page, because we
 			 * dropped the info->lock spinlock */
 			page_cache_release(page);
@@ -333,13 +345,12 @@
 		}
 
 		/* We have to this with page locked to prevent races */
-		if (TryLockPage(page)) {
-			spin_unlock(&info->lock);
- 			wait_on_page(page);
-			page_cache_release(page);
-			goto repeat;
-		}
-			
+		if (TryLockPage(page)) 
+			goto wait_retry;
+
+		if (swap_count(page) > 2)
+			BUG();
+		
 		swap_free(*entry);
 		*entry = (swp_entry_t) {0};
 		delete_from_swap_cache_nolock(page);
@@ -371,7 +382,6 @@
 		add_to_page_cache (page, mapping, idx);
 	}
 
-	
 	/* We have the page */
 	SetPageUptodate(page);
 	if (info->locked)
@@ -380,6 +390,12 @@
 no_space:
 	spin_unlock (&inode->i_sb->u.shmem_sb.stat_lock);
 	return ERR_PTR(-ENOSPC);
+
+wait_retry:
+	spin_unlock (&info->lock);
+	wait_on_page(page);
+	page_cache_release(page);
+	goto repeat;
 }
 
 static int shmem_getpage(struct inode * inode, unsigned long idx, struct page **ptr)
@@ -640,8 +656,8 @@
 			buf += bytes;
 			if (pos > inode->i_size) 
 				inode->i_size = pos;
-			if (inode->u.shmem_i.max_index < index)
-				inode->u.shmem_i.max_index = index;
+			if (inode->u.shmem_i.max_index <= index)
+				inode->u.shmem_i.max_index = index+1;
 
 		}
 unlock:

--uZ3hkaAS1mZxFaxD--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
