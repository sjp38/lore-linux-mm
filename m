Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id F3F236B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 05:53:17 -0400 (EDT)
Date: Thu, 23 May 2013 11:53:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: vmscan: Take page buffers dirty and locked state
 into account
Message-ID: <20130523095315.GC22466@quack.suse.cz>
References: <1369301187-24934-1-git-send-email-mgorman@suse.de>
 <1369301187-24934-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369301187-24934-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 23-05-13 10:26:27, Mel Gorman wrote:
> Page reclaim keeps track of dirty and under writeback pages and uses it to
> determine if wait_iff_congested() should stall or if kswapd should begin
> writing back pages. This fails to account for buffer pages that can be
> under writeback but not PageWriteback which is the case for filesystems
> like ext3. Furthermore, PageDirty buffer pages can have all the buffers
> clean and writepage does no IO so it should not be accounted as congested.
> 
> This patch adds an address_space operation that filesystems may
> optionally use to check if a page is really dirty or really under
> writeback. An implementation is provided for filesystems that use
> buffer_heads. By default, the page flags are obeyed.
> 
> Credit goes to Jan Kara for identifying that the page flags alone are
> not sufficient for ext3 and sanity checking a number of ideas on how
> the problem could be addressed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/buffer.c                 | 34 ++++++++++++++++++++++++++++++++++
>  fs/ext2/inode.c             |  1 +
>  fs/ext3/inode.c             |  3 +++
>  fs/ext4/inode.c             |  2 ++
>  fs/gfs2/aops.c              |  2 ++
>  fs/ntfs/aops.c              |  1 +
>  fs/ocfs2/aops.c             |  1 +
>  fs/xfs/xfs_aops.c           |  1 +
>  include/linux/buffer_head.h |  3 +++
>  include/linux/fs.h          |  1 +
>  mm/vmscan.c                 | 33 +++++++++++++++++++++++++++++++--
>  11 files changed, 80 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 1aa0836..4247aa9 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -91,6 +91,40 @@ void unlock_buffer(struct buffer_head *bh)
>  EXPORT_SYMBOL(unlock_buffer);
>  
>  /*
> + * Returns if the page has dirty or writeback buffers. If all the buffers
> + * are unlocked and clean then the PageDirty information is stale. If
> + * any of the pages are locked, it is assumed they are locked for IO.
> + */
> +void buffer_check_dirty_writeback(struct page *page,
> +				     bool *dirty, bool *writeback)
> +{
> +	struct buffer_head *head, *bh;
> +	*dirty = false;
> +	*writeback = false;
> +
> +	BUG_ON(!PageLocked(page));
> +
> +	if (!page_has_buffers(page))
> +		return;
> +
> +	if (PageWriteback(page))
> +		*writeback = true;
> +
> +	head = page_buffers(page);
> +	bh = head;
> +	do {
> +		if (buffer_locked(bh))
> +			*writeback = true;
> +
> +		if (buffer_dirty(bh))
> +			*dirty = true;
> +
> +		bh = bh->b_this_page;
> +	} while (bh != head);
> +}
> +EXPORT_SYMBOL(buffer_check_dirty_writeback);
> +
> +/*
>   * Block until a buffer comes unlocked.  This doesn't stop it
>   * from becoming locked again - you have to lock it yourself
>   * if you want to preserve its state.
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 0a87bb1..2fc3593 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -880,6 +880,7 @@ const struct address_space_operations ext2_aops = {
>  	.writepages		= ext2_writepages,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate	= block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
  Hum, actually from what I know, it should be enough to set
.is_dirty_writeback to buffer_check_dirty_writeback() only for
ext3_ordered_aops and maybe def_blk_aops (fs/block_dev.c). I also realized
that data=journal mode of ext3 & ext4 also needs a special treatment but
there we have to have a special function (likely provided by jbd/jbd2). But
this mode isn't used very much so it's not pressing to fix that.

Also I was thinking about how does this work NFS? It's page state logic is
more complex with page going from PageDirty -> PageWriteback -> Unstable ->
Clean. Unstable is a state where the page appears as clean to MM but it
still cannot be reclaimed (we are waiting for the server to write the
page). You need an inode wide commit operation to transform pages from
Unstable to Clean state.
  
I guess it would be worth testing this - something like your largedd test
but over NFS.

								Honza

> diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
> index 23c7128..14494fc 100644
> --- a/fs/ext3/inode.c
> +++ b/fs/ext3/inode.c
> @@ -1984,6 +1984,7 @@ static const struct address_space_operations ext3_ordered_aops = {
>  	.direct_IO		= ext3_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> @@ -1999,6 +2000,7 @@ static const struct address_space_operations ext3_writeback_aops = {
>  	.direct_IO		= ext3_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> @@ -2013,6 +2015,7 @@ static const struct address_space_operations ext3_journalled_aops = {
>  	.invalidatepage		= ext3_invalidatepage,
>  	.releasepage		= ext3_releasepage,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 0723774..7af746a 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3309,6 +3309,7 @@ static const struct address_space_operations ext4_aops = {
>  	.direct_IO		= ext4_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> @@ -3340,6 +3341,7 @@ static const struct address_space_operations ext4_da_aops = {
>  	.direct_IO		= ext4_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
> index 0bad69e..027b8ea 100644
> --- a/fs/gfs2/aops.c
> +++ b/fs/gfs2/aops.c
> @@ -1112,6 +1112,7 @@ static const struct address_space_operations gfs2_writeback_aops = {
>  	.direct_IO = gfs2_direct_IO,
>  	.migratepage = buffer_migrate_page,
>  	.is_partially_uptodate = block_is_partially_uptodate,
> +	.is_dirty_writeback = buffer_check_dirty_writeback,
>  	.error_remove_page = generic_error_remove_page,
>  };
>  
> @@ -1129,6 +1130,7 @@ static const struct address_space_operations gfs2_ordered_aops = {
>  	.direct_IO = gfs2_direct_IO,
>  	.migratepage = buffer_migrate_page,
>  	.is_partially_uptodate = block_is_partially_uptodate,
> +	.is_dirty_writeback = buffer_check_dirty_writeback,
>  	.error_remove_page = generic_error_remove_page,
>  };
>  
> diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
> index fa9c05f..eb85ac1 100644
> --- a/fs/ntfs/aops.c
> +++ b/fs/ntfs/aops.c
> @@ -1549,6 +1549,7 @@ const struct address_space_operations ntfs_aops = {
>  	.migratepage	= buffer_migrate_page,	/* Move a page cache page from
>  						   one physical page to an
>  						   other. */
> +	.is_dirty_writeback = buffer_check_dirty_writeback,
>  	.error_remove_page = generic_error_remove_page,
>  };
>  
> diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
> index 20dfec7..191af11 100644
> --- a/fs/ocfs2/aops.c
> +++ b/fs/ocfs2/aops.c
> @@ -2096,5 +2096,6 @@ const struct address_space_operations ocfs2_aops = {
>  	.releasepage		= ocfs2_releasepage,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate	= block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index f64ee71..1aada1c 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1656,5 +1656,6 @@ const struct address_space_operations xfs_address_space_operations = {
>  	.direct_IO		= xfs_vm_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.is_dirty_writeback	= buffer_check_dirty_writeback,
>  	.error_remove_page	= generic_error_remove_page,
>  };
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index 6d9f5a2..d458880 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -139,6 +139,9 @@ BUFFER_FNS(Prio, prio)
>  	})
>  #define page_has_buffers(page)	PagePrivate(page)
>  
> +void buffer_check_dirty_writeback(struct page *page,
> +				     bool *dirty, bool *writeback);
> +
>  /*
>   * Declarations
>   */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 0a9a6766..96f857f 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -380,6 +380,7 @@ struct address_space_operations {
>  	int (*launder_page) (struct page *);
>  	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
>  					unsigned long);
> +	void (*is_dirty_writeback) (struct page *, bool *, bool *);
>  	int (*error_remove_page)(struct address_space *, struct page *);
>  
>  	/* swapfile support */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f3315c6..d9213d8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -669,6 +669,25 @@ static enum page_references page_check_references(struct page *page,
>  	return PAGEREF_RECLAIM;
>  }
>  
> +/* Check if a page is dirty or under writeback */
> +static void page_check_dirty_writeback(struct page *page,
> +				       bool *dirty, bool *writeback)
> +{
> +	struct address_space *mapping;
> +
> +	/* By default assume that the page flags are accurate */
> +	*dirty = PageDirty(page);
> +	*writeback = PageWriteback(page);
> +
> +	/* Verify dirty/writeback state if the filesystem supports it */
> +	if (!page_has_private(page))
> +		return;
> +
> +	mapping = page_mapping(page);
> +	if (mapping && mapping->a_ops->is_dirty_writeback)
> +		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
> +}
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
> @@ -839,9 +858,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		}
>  
>  		if (PageDirty(page)) {
> -			nr_dirty++;
> +			bool dirty, writeback;
> +
> +			/*
> +			 * The number of dirty pages determines if a zone is
> +			 * marked zone_is_reclaim_congested which affects
> +			 * wait_iff_congested. The number of unqueued dirty
> +			 * pages affects if kswapd will start writing pages.
> +			 */
> +			page_check_dirty_writeback(page, &dirty, &writeback);
> +			if (dirty || writeback)
> +				nr_dirty++;
>  
> -			if (!PageWriteback(page))
> +			if (dirty && !writeback)
>  				nr_unqueued_dirty++;
>  
>  			/*
> -- 
> 1.8.1.4
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
