Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1024E6B0022
	for <linux-mm@kvack.org>; Sat,  7 May 2011 01:33:31 -0400 (EDT)
Message-ID: <4DC4D9A6.9070103@parallels.com>
Date: Sat, 7 May 2011 09:33:26 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105031223120.9845@sister.anvils>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:

<cut>

>
> Here's the patch I was testing last night, but I do want to test it
> some more (I've not even tried your unmounting case yet), and I do want
> to make some changes to it (some comments, and see if I can move the
> mem_cgroup_cache_charge outside of the mutex, making it GFP_KERNEL
> rather than GFP_NOFS - at the time that mem_cgroup charging went in,
> we did not know here if it was actually a shmem swap page, whereas
> nowadays we can be sure, since that's noted in the swap_map).
>
> In shmem_unuse_inode I'm widening the shmem_swaplist_mutex to protect
> against shmem_evict_inode; and in shmem_writepage adding to the list
> earlier, while holding lock on page still in pagecache to protect it.
>
> But testing last night showed corruption on this laptop (no problem
> on other machines): I'm guessing it's unrelated, but I can't be sure
> of that without more extended testing.
>
> Hugh

This patch fixed my problem, I didn't catch any crashes on my test-case: swapout-unmount.

>
> --- 2.6.39-rc5/mm/shmem.c	2011-04-28 09:52:49.066135001 -0700
> +++ linux/mm/shmem.c	2011-05-02 21:02:21.745633214 -0700
> @@ -852,7 +852,7 @@ static inline int shmem_find_swp(swp_ent
>
>   static int shmem_unuse_inode(struct shmem_inode_info *info, swp_entry_t entry, struct page *page)
>   {
> -	struct inode *inode;
> +	struct address_space *mapping;
>   	unsigned long idx;
>   	unsigned long size;
>   	unsigned long limit;
> @@ -928,7 +928,7 @@ lost2:
>   	return 0;
>   found:
>   	idx += offset;
> -	inode = igrab(&info->vfs_inode);
> +	mapping = info->vfs_inode.i_mapping;
>   	spin_unlock(&info->lock);
>
>   	/*
> @@ -940,20 +940,16 @@ found:
>   	 */
>   	if (shmem_swaplist.next !=&info->swaplist)
>   		list_move_tail(&shmem_swaplist,&info->swaplist);
> -	mutex_unlock(&shmem_swaplist_mutex);
>
> -	error = 1;
> -	if (!inode)
> -		goto out;
>   	/*
> -	 * Charge page using GFP_KERNEL while we can wait.
> +	 * Charge page using GFP_NOFS while we can wait.
>   	 * Charged back to the user(not to caller) when swap account is used.
>   	 * add_to_page_cache() will be called with GFP_NOWAIT.
>   	 */
> -	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
> +	error = mem_cgroup_cache_charge(page, current->mm, GFP_NOFS);
>   	if (error)
>   		goto out;
> -	error = radix_tree_preload(GFP_KERNEL);
> +	error = radix_tree_preload(GFP_NOFS);
>   	if (error) {
>   		mem_cgroup_uncharge_cache_page(page);
>   		goto out;
> @@ -963,14 +959,14 @@ found:
>   	spin_lock(&info->lock);
>   	ptr = shmem_swp_entry(info, idx, NULL);
>   	if (ptr&&  ptr->val == entry.val) {
> -		error = add_to_page_cache_locked(page, inode->i_mapping,
> +		error = add_to_page_cache_locked(page, mapping,
>   						idx, GFP_NOWAIT);
>   		/* does mem_cgroup_uncharge_cache_page on error */
>   	} else	/* we must compensate for our precharge above */
>   		mem_cgroup_uncharge_cache_page(page);
>
>   	if (error == -EEXIST) {
> -		struct page *filepage = find_get_page(inode->i_mapping, idx);
> +		struct page *filepage = find_get_page(mapping, idx);
>   		error = 1;
>   		if (filepage) {
>   			/*
> @@ -995,9 +991,6 @@ found:
>   	spin_unlock(&info->lock);
>   	radix_tree_preload_end();
>   out:
> -	unlock_page(page);
> -	page_cache_release(page);
> -	iput(inode);		/* allows for NULL */
>   	return error;
>   }
>
> @@ -1016,7 +1009,7 @@ int shmem_unuse(swp_entry_t entry, struc
>   		found = shmem_unuse_inode(info, entry, page);
>   		cond_resched();
>   		if (found)
> -			goto out;
> +			break;
>   	}
>   	mutex_unlock(&shmem_swaplist_mutex);
>   	/*
> @@ -1025,7 +1018,6 @@ int shmem_unuse(swp_entry_t entry, struc
>   	 */
>   	unlock_page(page);
>   	page_cache_release(page);
> -out:
>   	return (found<  0) ? found : 0;
>   }
>
> @@ -1039,6 +1031,7 @@ static int shmem_writepage(struct page *
>   	struct address_space *mapping;
>   	unsigned long index;
>   	struct inode *inode;
> +	bool unlock_mutex = false;
>
>   	BUG_ON(!PageLocked(page));
>   	mapping = page->mapping;
> @@ -1064,7 +1057,17 @@ static int shmem_writepage(struct page *
>   	else
>   		swap.val = 0;
>
> +	if (swap.val&&  list_empty(&info->swaplist)) {
> +		mutex_lock(&shmem_swaplist_mutex);
> +		/* move instead of add in case we're racing */
> +		list_move_tail(&info->swaplist,&shmem_swaplist);
> +		unlock_mutex = true;
> +	}
> +
>   	spin_lock(&info->lock);
> +	if (unlock_mutex)
> +		mutex_unlock(&shmem_swaplist_mutex);
> +
>   	if (index>= info->next_index) {
>   		BUG_ON(!(info->flags&  SHMEM_TRUNCATE));
>   		goto unlock;
> @@ -1084,21 +1087,10 @@ static int shmem_writepage(struct page *
>   		delete_from_page_cache(page);
>   		shmem_swp_set(info, entry, swap.val);
>   		shmem_swp_unmap(entry);
> -		if (list_empty(&info->swaplist))
> -			inode = igrab(inode);
> -		else
> -			inode = NULL;
>   		spin_unlock(&info->lock);
>   		swap_shmem_alloc(swap);
>   		BUG_ON(page_mapped(page));
>   		swap_writepage(page, wbc);
> -		if (inode) {
> -			mutex_lock(&shmem_swaplist_mutex);
> -			/* move instead of add in case we're racing */
> -			list_move_tail(&info->swaplist,&shmem_swaplist);
> -			mutex_unlock(&shmem_swaplist_mutex);
> -			iput(inode);
> -		}
>   		return 0;
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
