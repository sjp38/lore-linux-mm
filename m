Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 732696B0282
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:22:41 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id kq3so7251065wjc.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:22:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si3697300wra.291.2017.01.19.01.22.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 01:22:39 -0800 (PST)
Date: Thu, 19 Jan 2017 10:22:36 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170119092236.GC2565@quack2.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
 <20170117082425.GD19699@dhcp22.suse.cz>
 <20170117151817.GR19699@dhcp22.suse.cz>
 <20170117155916.dcizr65bwa6behe7@thunk.org>
 <20170117161618.GT19699@dhcp22.suse.cz>
 <20170117172925.GA2486@quack2.suse.cz>
 <20170119083956.GE30786@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119083956.GE30786@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-01-17 09:39:56, Michal Hocko wrote:
> On Tue 17-01-17 18:29:25, Jan Kara wrote:
> > On Tue 17-01-17 17:16:19, Michal Hocko wrote:
> > > > > But before going to play with that I am really wondering whether we need
> > > > > all this with no journal at all. AFAIU what Jack told me it is the
> > > > > journal lock(s) which is the biggest problem from the reclaim recursion
> > > > > point of view. What would cause a deadlock in no journal mode?
> > > > 
> > > > We still have the original problem for why we need GFP_NOFS even in
> > > > ext2.  If we are in a writeback path, and we need to allocate memory,
> > > > we don't want to recurse back into the file system's writeback path.
> > > 
> > > But we do not enter the writeback path from the direct reclaim. Or do
> > > you mean something other than pageout()'s mapping->a_ops->writepage?
> > > There is only try_to_release_page where we get back to the filesystems
> > > but I do not see any NOFS protection in ext4_releasepage.
> > 
> > Maybe to expand a bit: These days, direct reclaim can call ->releasepage()
> > callback, ->evict_inode() callback (and only for inodes with i_nlink > 0),
> > shrinkers. That's it. So the recursion possibilities are rather more limited
> > than they used to be several years ago and we likely do not need as much
> > GFP_NOFS protection as we used to.
> 
> Thanks for making my remark more clear Jack! I would just want to add
> that I was playing with the patch below (it is basically
> GFP_NOFS->GFP_KERNEL for all allocations which trigger warning from the
> debugging patch which means they are called from within transaction) and
> it didn't hit the lockdep when running xfstests both with or without the
> enabled journal.
> 
> So am I still missing something or the nojournal mode is safe and the
> current series is OK wrt. ext*?

I'm convinced the current series is OK, only real life will tell us whether
we missed something or not ;)

> The following patch in its current form is WIP and needs a proper review
> before I post it.

So jbd2 changes look confusing (although technically correct) to me - we
*always* should run in NOFS context in those place so having GFP_KERNEL
there looks like it is unnecessarily hiding what is going on. So in those
places I'd prefer to keep GFP_NOFS or somehow else make it very clear these
allocations are expected to be GFP_NOFS (and assert that). Otherwise the
changes look good to me.

								Honza

> ---
>  fs/ext4/inode.c       |  4 ++--
>  fs/ext4/mballoc.c     | 14 +++++++-------
>  fs/ext4/xattr.c       |  2 +-
>  fs/jbd2/journal.c     |  4 ++--
>  fs/jbd2/revoke.c      |  2 +-
>  fs/jbd2/transaction.c |  2 +-
>  6 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index b7d141c3b810..841cb8c4cb5e 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -2085,7 +2085,7 @@ static int ext4_writepage(struct page *page,
>  		return __ext4_journalled_writepage(page, len);
>  
>  	ext4_io_submit_init(&io_submit, wbc);
> -	io_submit.io_end = ext4_init_io_end(inode, GFP_NOFS);
> +	io_submit.io_end = ext4_init_io_end(inode, GFP_KERNEL);
>  	if (!io_submit.io_end) {
>  		redirty_page_for_writepage(wbc, page);
>  		unlock_page(page);
> @@ -3794,7 +3794,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
>  	int err = 0;
>  
>  	page = find_or_create_page(mapping, from >> PAGE_SHIFT,
> -				   mapping_gfp_constraint(mapping, ~__GFP_FS));
> +				   mapping_gfp_mask(mapping));
>  	if (!page)
>  		return -ENOMEM;
>  
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index d9fd184b049e..67b97cd6e3d6 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -1251,7 +1251,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
>  static int ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
>  			      struct ext4_buddy *e4b)
>  {
> -	return ext4_mb_load_buddy_gfp(sb, group, e4b, GFP_NOFS);
> +	return ext4_mb_load_buddy_gfp(sb, group, e4b, GFP_KERNEL);
>  }
>  
>  static void ext4_mb_unload_buddy(struct ext4_buddy *e4b)
> @@ -2054,7 +2054,7 @@ static int ext4_mb_good_group(struct ext4_allocation_context *ac,
>  
>  	/* We only do this if the grp has never been initialized */
>  	if (unlikely(EXT4_MB_GRP_NEED_INIT(grp))) {
> -		int ret = ext4_mb_init_group(ac->ac_sb, group, GFP_NOFS);
> +		int ret = ext4_mb_init_group(ac->ac_sb, group, GFP_KERNEL);
>  		if (ret)
>  			return ret;
>  	}
> @@ -3600,7 +3600,7 @@ ext4_mb_new_inode_pa(struct ext4_allocation_context *ac)
>  	BUG_ON(ac->ac_status != AC_STATUS_FOUND);
>  	BUG_ON(!S_ISREG(ac->ac_inode->i_mode));
>  
> -	pa = kmem_cache_alloc(ext4_pspace_cachep, GFP_NOFS);
> +	pa = kmem_cache_alloc(ext4_pspace_cachep, GFP_KERNEL);
>  	if (pa == NULL)
>  		return -ENOMEM;
>  
> @@ -3694,7 +3694,7 @@ ext4_mb_new_group_pa(struct ext4_allocation_context *ac)
>  	BUG_ON(!S_ISREG(ac->ac_inode->i_mode));
>  
>  	BUG_ON(ext4_pspace_cachep == NULL);
> -	pa = kmem_cache_alloc(ext4_pspace_cachep, GFP_NOFS);
> +	pa = kmem_cache_alloc(ext4_pspace_cachep, GFP_KERNEL);
>  	if (pa == NULL)
>  		return -ENOMEM;
>  
> @@ -4479,7 +4479,7 @@ ext4_fsblk_t ext4_mb_new_blocks(handle_t *handle,
>  		}
>  	}
>  
> -	ac = kmem_cache_zalloc(ext4_ac_cachep, GFP_NOFS);
> +	ac = kmem_cache_zalloc(ext4_ac_cachep, GFP_KERNEL);
>  	if (!ac) {
>  		ar->len = 0;
>  		*errp = -ENOMEM;
> @@ -4813,7 +4813,7 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
>  
>  	/* __GFP_NOFAIL: retry infinitely, ignore TIF_MEMDIE and memcg limit. */
>  	err = ext4_mb_load_buddy_gfp(sb, block_group, &e4b,
> -				     GFP_NOFS|__GFP_NOFAIL);
> +				     GFP_KERNEL|__GFP_NOFAIL);
>  	if (err)
>  		goto error_return;
>  
> @@ -4832,7 +4832,7 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
>  		 * to fail.
>  		 */
>  		new_entry = kmem_cache_alloc(ext4_free_data_cachep,
> -				GFP_NOFS|__GFP_NOFAIL);
> +				GFP_KERNEL|__GFP_NOFAIL);
>  		new_entry->efd_start_cluster = bit;
>  		new_entry->efd_group = block_group;
>  		new_entry->efd_count = count_clusters;
> diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
> index 172317462238..f68e8c87f9f2 100644
> --- a/fs/ext4/xattr.c
> +++ b/fs/ext4/xattr.c
> @@ -1650,7 +1650,7 @@ ext4_xattr_cache_insert(struct mb_cache *ext4_mb_cache, struct buffer_head *bh)
>  		       EXT4_XATTR_REFCOUNT_MAX;
>  	int error;
>  
> -	error = mb_cache_entry_create(ext4_mb_cache, GFP_NOFS, hash,
> +	error = mb_cache_entry_create(ext4_mb_cache, GFP_KERNEL, hash,
>  				      bh->b_blocknr, reusable);
>  	if (error) {
>  		if (error == -EBUSY)
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index 3a449150f834..bd29daa975a5 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -379,7 +379,7 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
>  	 */
>  	J_ASSERT_BH(bh_in, buffer_jbddirty(bh_in));
>  
> -	new_bh = alloc_buffer_head(GFP_NOFS|__GFP_NOFAIL);
> +	new_bh = alloc_buffer_head(GFP_KERNEL|__GFP_NOFAIL);
>  
>  	/* keep subsequent assertions sane */
>  	atomic_set(&new_bh->b_count, 1);
> @@ -2375,7 +2375,7 @@ static struct journal_head *journal_alloc_journal_head(void)
>  #ifdef CONFIG_JBD2_DEBUG
>  	atomic_inc(&nr_journal_heads);
>  #endif
> -	ret = kmem_cache_zalloc(jbd2_journal_head_cache, GFP_NOFS);
> +	ret = kmem_cache_zalloc(jbd2_journal_head_cache, GFP_KERNEL);
>  	if (!ret) {
>  		jbd_debug(1, "out of memory for journal_head\n");
>  		pr_notice_ratelimited("ENOMEM in %s, retrying.\n", __func__);
> diff --git a/fs/jbd2/revoke.c b/fs/jbd2/revoke.c
> index cfc38b552118..c9c347468c5b 100644
> --- a/fs/jbd2/revoke.c
> +++ b/fs/jbd2/revoke.c
> @@ -141,7 +141,7 @@ static int insert_revoke_hash(journal_t *journal, unsigned long long blocknr,
>  {
>  	struct list_head *hash_list;
>  	struct jbd2_revoke_record_s *record;
> -	gfp_t gfp_mask = GFP_NOFS;
> +	gfp_t gfp_mask = GFP_KERNEL;
>  
>  	if (journal_oom_retry)
>  		gfp_mask |= __GFP_NOFAIL;
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index 35a5d3d76182..a7e50eb330a8 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -974,7 +974,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
>  			JBUFFER_TRACE(jh, "allocate memory for buffer");
>  			jbd_unlock_bh_state(bh);
>  			frozen_buffer = jbd2_alloc(jh2bh(jh)->b_size,
> -						   GFP_NOFS | __GFP_NOFAIL);
> +						   GFP_KERNEL | __GFP_NOFAIL);
>  			goto repeat;
>  		}
>  		jh->b_frozen_data = frozen_buffer;
> -- 
> 2.11.0
> 
> -- 
> Michal Hocko
> SUSE Labs
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
