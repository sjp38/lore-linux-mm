Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 94EEE900001
	for <linux-mm@kvack.org>; Tue,  3 May 2011 16:06:42 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p43K6dl9008680
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:06:39 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by hpaq13.eem.corp.google.com with ESMTP id p43K5pZ6002414
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:06:37 -0700
Received: by pvg11 with SMTP id 11so244896pvg.41
        for <linux-mm@kvack.org>; Tue, 03 May 2011 13:06:37 -0700 (PDT)
Date: Tue, 3 May 2011 13:06:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
In-Reply-To: <4DB0FE8F.9070407@parallels.com>
Message-ID: <alpine.LSU.2.00.1105031223120.9845@sister.anvils>
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 22 Apr 2011, Konstantin Khlebnikov wrote:
> Andrew Morton wrote:
> > On Thu, 21 Apr 2011 10:41:50 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> > 
> > > shmem_writepage() call igrab() on the inode for the page which is came
> > > from
> > > reclaimer to add it later into shmem_swaplist for swap-unuse operation.
> > > 
> > > This igrab() can race with super-block deactivating process:
> > > 
> > > shrink_inactive_list()		deactivate_super()
> > > pageout()			tmpfs_fs_type->kill_sb()
> > > shmem_writepage()		kill_litter_super()
> > > 				generic_shutdown_super()
> > > 				 evict_inodes()
> > >   igrab()
> > > 				  atomic_read(&inode->i_count)
> > > 				   skip-inode
> > >   iput()
> > > 				 if (!list_empty(&sb->s_inodes))
> > > 					printk("VFS: Busy inodes after...
> > > 
> > > This igrap-iput pair was added in commit 1b1b32f2c6f6bb3253
> > > based on incorrect assumptions:

Konstantin, many thanks for discovering this issue, and please accept
my apology for being so slow to respond.  I have to find enough "cool"
time to think my way back into all the races which may occur here.

I am disappointed with igrab!  It appeared to be the tool I needed
when I added that in, when I was concerned with deletion racing with
writepage and swapoff.  Clearly I didn't research igrab enough: its
interface seemed right, and I never imagined it gave no equivalent
protection against unmount - well, it does protect the inode, but
you have to pay for that with a "Self-destruct in 5 seconds" message.

I'm surprised that nothing else has such a problem with igrab, but
must accept I got it wrong, and I'm using it where it's not usable.
And it got more obviously unusable with 2.6.37's 63997e98a3be which
removed the second "safety" call to invalidate/evict_inodes() from
generic_shutdown_super().

> > > 
> > > : Ah, I'd never suspected it, but shmem_writepage's swaplist
> > > manipulation
> > > : is unsafe: though still hold page lock, which would hold off inode
> > > : deletion if the page were i pagecache, it doesn't hold off once it's
> > > in
> > > : swapcache (free_swap_and_cache doesn't wait on locked pages).  Hmm: we
> > > : could put the the inode on swaplist earlier, but then
> > > shmem_unuse_inode
> > > : could never prune unswapped inodes.
> > > 
> > > Attached locked page actually protect inode from deletion because
> > > truncate_inode_pages_range() will sleep on this, so igrab not required.
> > > This patch actually revert last hunk from that commit.
> > > 
> > 
> > hm, is that last paragraph true?  Let's look at the resulting code.
> > 
> > 
> > : 	if (swap.val&&  add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
> > : 		delete_from_page_cache(page);
> > 
> > Here, the page is removed from inode->i_mapping.  So
> > truncate_inode_pages() won't see that page and will not block on its
> > lock.
> 
> Oops, right. Sorry. It produce use-after-free race, but it is quiet and
> small.
> My test is using too few files to catch it in a reasonable time,
> and I ran it without slab poisoning.
> 
> So, v1 patch is correct but little ugly, while v2 -- broken.

Yes.  But even if the v1 patch is correct so far as it goes (and I've
not spent much time considering it, being disapppointed enough with
igrab that I'd rather get away from it and solve the races internally
than rely further upon VFS constructs here), it must be incomplete
since the same problem will apply to the igrab in shmem_unuse_inode too.

> 
> > 
> > : 		shmem_swp_set(info, entry, swap.val);
> > : 		shmem_swp_unmap(entry);
> > : 		spin_unlock(&info->lock);
> > : 		if (list_empty(&info->swaplist)) {
> > : 			mutex_lock(&shmem_swaplist_mutex);
> > : 			/* move instead of add in case we're racing */
> > : 			list_move_tail(&info->swaplist,&shmem_swaplist);
> > : 			mutex_unlock(&shmem_swaplist_mutex);
> > : 		}
> > 
> > Here, the code plays with `info', which points at storage which is
> > embedded within the inode's filesystem-private part.
> > 
> > But because the inode now has no attached locked page, a concurrent
> > umount can free the inode while this code is using it.
> 
> I guess we can try to put delete_from_page_cache(page); right before
> swap_writepage
> but it move it outside info->lock...

You're right to be wary, we do need to do all the swizzling within
info->lock.

> 
> > 
> > : 		swap_shmem_alloc(swap);
> > : 		BUG_ON(page_mapped(page));
> > : 		swap_writepage(page, wbc);
> > : 		return 0;
> > : 	}
> > 
> > However, I assume that you reran your testcase with the v2 patch and
> > that things ran OK.  How come?  Either my analysis is wrong or the
> > testcase doesn't trigger races in this code path?

Here's the patch I was testing last night, but I do want to test it
some more (I've not even tried your unmounting case yet), and I do want
to make some changes to it (some comments, and see if I can move the
mem_cgroup_cache_charge outside of the mutex, making it GFP_KERNEL
rather than GFP_NOFS - at the time that mem_cgroup charging went in,
we did not know here if it was actually a shmem swap page, whereas
nowadays we can be sure, since that's noted in the swap_map).

In shmem_unuse_inode I'm widening the shmem_swaplist_mutex to protect
against shmem_evict_inode; and in shmem_writepage adding to the list
earlier, while holding lock on page still in pagecache to protect it.

But testing last night showed corruption on this laptop (no problem
on other machines): I'm guessing it's unrelated, but I can't be sure
of that without more extended testing.

Hugh

--- 2.6.39-rc5/mm/shmem.c	2011-04-28 09:52:49.066135001 -0700
+++ linux/mm/shmem.c	2011-05-02 21:02:21.745633214 -0700
@@ -852,7 +852,7 @@ static inline int shmem_find_swp(swp_ent
 
 static int shmem_unuse_inode(struct shmem_inode_info *info, swp_entry_t entry, struct page *page)
 {
-	struct inode *inode;
+	struct address_space *mapping;
 	unsigned long idx;
 	unsigned long size;
 	unsigned long limit;
@@ -928,7 +928,7 @@ lost2:
 	return 0;
 found:
 	idx += offset;
-	inode = igrab(&info->vfs_inode);
+	mapping = info->vfs_inode.i_mapping;
 	spin_unlock(&info->lock);
 
 	/*
@@ -940,20 +940,16 @@ found:
 	 */
 	if (shmem_swaplist.next != &info->swaplist)
 		list_move_tail(&shmem_swaplist, &info->swaplist);
-	mutex_unlock(&shmem_swaplist_mutex);
 
-	error = 1;
-	if (!inode)
-		goto out;
 	/*
-	 * Charge page using GFP_KERNEL while we can wait.
+	 * Charge page using GFP_NOFS while we can wait.
 	 * Charged back to the user(not to caller) when swap account is used.
 	 * add_to_page_cache() will be called with GFP_NOWAIT.
 	 */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
+	error = mem_cgroup_cache_charge(page, current->mm, GFP_NOFS);
 	if (error)
 		goto out;
-	error = radix_tree_preload(GFP_KERNEL);
+	error = radix_tree_preload(GFP_NOFS);
 	if (error) {
 		mem_cgroup_uncharge_cache_page(page);
 		goto out;
@@ -963,14 +959,14 @@ found:
 	spin_lock(&info->lock);
 	ptr = shmem_swp_entry(info, idx, NULL);
 	if (ptr && ptr->val == entry.val) {
-		error = add_to_page_cache_locked(page, inode->i_mapping,
+		error = add_to_page_cache_locked(page, mapping,
 						idx, GFP_NOWAIT);
 		/* does mem_cgroup_uncharge_cache_page on error */
 	} else	/* we must compensate for our precharge above */
 		mem_cgroup_uncharge_cache_page(page);
 
 	if (error == -EEXIST) {
-		struct page *filepage = find_get_page(inode->i_mapping, idx);
+		struct page *filepage = find_get_page(mapping, idx);
 		error = 1;
 		if (filepage) {
 			/*
@@ -995,9 +991,6 @@ found:
 	spin_unlock(&info->lock);
 	radix_tree_preload_end();
 out:
-	unlock_page(page);
-	page_cache_release(page);
-	iput(inode);		/* allows for NULL */
 	return error;
 }
 
@@ -1016,7 +1009,7 @@ int shmem_unuse(swp_entry_t entry, struc
 		found = shmem_unuse_inode(info, entry, page);
 		cond_resched();
 		if (found)
-			goto out;
+			break;
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 	/*
@@ -1025,7 +1018,6 @@ int shmem_unuse(swp_entry_t entry, struc
 	 */
 	unlock_page(page);
 	page_cache_release(page);
-out:
 	return (found < 0) ? found : 0;
 }
 
@@ -1039,6 +1031,7 @@ static int shmem_writepage(struct page *
 	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
+	bool unlock_mutex = false;
 
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
@@ -1064,7 +1057,17 @@ static int shmem_writepage(struct page *
 	else
 		swap.val = 0;
 
+	if (swap.val && list_empty(&info->swaplist)) {
+		mutex_lock(&shmem_swaplist_mutex);
+		/* move instead of add in case we're racing */
+		list_move_tail(&info->swaplist, &shmem_swaplist);
+		unlock_mutex = true;
+	}
+
 	spin_lock(&info->lock);
+	if (unlock_mutex)
+		mutex_unlock(&shmem_swaplist_mutex);
+
 	if (index >= info->next_index) {
 		BUG_ON(!(info->flags & SHMEM_TRUNCATE));
 		goto unlock;
@@ -1084,21 +1087,10 @@ static int shmem_writepage(struct page *
 		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
-		if (list_empty(&info->swaplist))
-			inode = igrab(inode);
-		else
-			inode = NULL;
 		spin_unlock(&info->lock);
 		swap_shmem_alloc(swap);
 		BUG_ON(page_mapped(page));
 		swap_writepage(page, wbc);
-		if (inode) {
-			mutex_lock(&shmem_swaplist_mutex);
-			/* move instead of add in case we're racing */
-			list_move_tail(&info->swaplist, &shmem_swaplist);
-			mutex_unlock(&shmem_swaplist_mutex);
-			iput(inode);
-		}
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
