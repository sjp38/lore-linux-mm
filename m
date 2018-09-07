Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72E716B7D68
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 04:39:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g9-v6so6904041pgc.16
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 01:39:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n22-v6si7784668pgd.375.2018.09.07.01.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 01:39:29 -0700 (PDT)
Subject: Re: [PATCH v6 6/6] Btrfs: support swap files
References: <cover.1536305017.git.osandov@fb.com>
 <77442bbbad9ebc37f3b72a47ca983a3a805e0718.1536305017.git.osandov@fb.com>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <401845b3-f7b9-7dfb-dc9b-42350daff44e@suse.com>
Date: Fri, 7 Sep 2018 11:39:25 +0300
MIME-Version: 1.0
In-Reply-To: <77442bbbad9ebc37f3b72a47ca983a3a805e0718.1536305017.git.osandov@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>, linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org



On  7.09.2018 10:39, Omar Sandoval wrote:
> From: Omar Sandoval <osandov@fb.com>
> 
> Implement the swap file a_ops on Btrfs. Activation needs to make sure
> that the file can be used as a swap file, which currently means it must
> be fully allocated as nocow with no compression on one device. It must
> also do the proper tracking so that ioctls will not interfere with the
> swap file. Deactivation clears this tracking.
> 
> Signed-off-by: Omar Sandoval <osandov@fb.com>
> ---
>  fs/btrfs/inode.c | 316 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 316 insertions(+)
> 
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 9357a19d2bff..55aba2d7074c 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -27,6 +27,7 @@
>  #include <linux/uio.h>
>  #include <linux/magic.h>
>  #include <linux/iversion.h>
> +#include <linux/swap.h>
>  #include <asm/unaligned.h>
>  #include "ctree.h"
>  #include "disk-io.h"
> @@ -10437,6 +10438,319 @@ void btrfs_set_range_writeback(struct extent_io_tree *tree, u64 start, u64 end)
>  	}
>  }
>  
> +/*
> + * Add an entry indicating a block group or device which is pinned by a
> + * swapfile. Returns 0 on success, 1 if there is already an entry for it, or a
> + * negative errno on failure.
> + */
> +static int btrfs_add_swapfile_pin(struct inode *inode, void *ptr,
> +				  bool is_block_group)
> +{
> +	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
> +	struct btrfs_swapfile_pin *sp, *entry;
> +	struct rb_node **p;
> +	struct rb_node *parent = NULL;
> +
> +	sp = kmalloc(sizeof(*sp), GFP_NOFS);
> +	if (!sp)
> +		return -ENOMEM;
> +	sp->ptr = ptr;
> +	sp->inode = inode;
> +	sp->is_block_group = is_block_group;
> +
> +	spin_lock(&fs_info->swapfile_pins_lock);
> +	p = &fs_info->swapfile_pins.rb_node;
> +	while (*p) {
> +		parent = *p;
> +		entry = rb_entry(parent, struct btrfs_swapfile_pin, node);
> +		if (sp->ptr < entry->ptr ||
> +		    (sp->ptr == entry->ptr && sp->inode < entry->inode)) {
> +			p = &(*p)->rb_left;
> +		} else if (sp->ptr > entry->ptr ||
> +			   (sp->ptr == entry->ptr && sp->inode > entry->inode)) {
> +			p = &(*p)->rb_right;
> +		} else {
> +			spin_unlock(&fs_info->swapfile_pins_lock);
> +			kfree(sp);
> +			return 1;
> +		}


I have to admit this is creative use of pointers but I dislike it:

1. You are not really doing an interval tree of any sorts so rb seems a
bit of an overkill. How many block groups/devices do you expect to have
in the rb tree i.e how many swap files per file system so that the logn
search behavior really matter? Why not a simple linked list and just an
equality comparison of pointers?

2. The code self-admits that using pointers for lt/gr comparison is a
hack since in case pointers match you fall back to checking the inode
pointer

3. There is a discrepancy between the keys used for adding (ptr + inode)
and deletion (just inode)


At the very  least this hack needs to be at least mentioned in the
changelog.

> +	}
> +	rb_link_node(&sp->node, parent, p);
> +	rb_insert_color(&sp->node, &fs_info->swapfile_pins);
> +	spin_unlock(&fs_info->swapfile_pins_lock);
> +	return 0;
> +}
> +
> +static void btrfs_free_swapfile_pins(struct inode *inode)
> +{
> +	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
> +	struct btrfs_swapfile_pin *sp;
> +	struct rb_node *node, *next;
> +
> +	spin_lock(&fs_info->swapfile_pins_lock);
> +	node = rb_first(&fs_info->swapfile_pins);
> +	while (node) {
> +		next = rb_next(node);
> +		sp = rb_entry(node, struct btrfs_swapfile_pin, node);
> +		if (sp->inode == inode) {
> +			rb_erase(&sp->node, &fs_info->swapfile_pins);
> +			if (sp->is_block_group)
> +				btrfs_put_block_group(sp->ptr);
> +			kfree(sp);
> +		}
> +		node = next;
> +	}
> +	spin_unlock(&fs_info->swapfile_pins_lock);
> +}
> +
> +struct btrfs_swap_info {
> +	u64 start;
> +	u64 block_start;
> +	u64 block_len;
> +	u64 lowest_ppage;
> +	u64 highest_ppage;
> +	unsigned long nr_pages;
> +	int nr_extents;
> +};
> +
> +static int btrfs_add_swap_extent(struct swap_info_struct *sis,
> +				 struct btrfs_swap_info *bsi)
> +{
> +	unsigned long nr_pages;
> +	u64 first_ppage, first_ppage_reported, next_ppage;

what the does extra p stand for - physical?

> +	int ret;
> +
> +	first_ppage = ALIGN(bsi->block_start, PAGE_SIZE) >> PAGE_SHIFT;
> +	next_ppage = ALIGN_DOWN(bsi->block_start + bsi->block_len,
> +				PAGE_SIZE) >> PAGE_SHIFT;
> +
> +	if (first_ppage >= next_ppage)
> +		return 0;
> +	nr_pages = next_ppage - first_ppage;
> +
> +	first_ppage_reported = first_ppage;
> +	if (bsi->start == 0)
> +		first_ppage_reported++;
> +	if (bsi->lowest_ppage > first_ppage_reported)
> +		bsi->lowest_ppage = first_ppage_reported;
> +	if (bsi->highest_ppage < (next_ppage - 1))
> +		bsi->highest_ppage = next_ppage - 1;
> +
> +	ret = add_swap_extent(sis, bsi->nr_pages, nr_pages, first_ppage);
> +	if (ret < 0)
> +		return ret;
> +	bsi->nr_extents += ret;
> +	bsi->nr_pages += nr_pages;
> +	return 0;
> +}
> +
> +static void btrfs_swap_deactivate(struct file *file)
> +{
> +	struct inode *inode = file_inode(file);
> +
> +	btrfs_free_swapfile_pins(inode);
> +	atomic_dec(&BTRFS_I(inode)->root->nr_swapfiles);
> +}
> +
> +static int btrfs_swap_activate(struct swap_info_struct *sis, struct file *file,
> +			       sector_t *span)
> +{
> +	struct inode *inode = file_inode(file);
> +	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
> +	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
> +	struct extent_state *cached_state = NULL;
> +	struct extent_map *em = NULL;
> +	struct btrfs_device *device = NULL;
> +	struct btrfs_swap_info bsi = {
> +		.lowest_ppage = (sector_t)-1ULL,
> +	};
> +	int ret = 0;
> +	u64 isize = inode->i_size;
> +	u64 start;
> +
> +	/*
> +	 * If the swap file was just created, make sure delalloc is done. If the
> +	 * file changes again after this, the user is doing something stupid and
> +	 * we don't really care.
> +	 */
> +	ret = btrfs_wait_ordered_range(inode, 0, (u64)-1);
> +	if (ret)
> +		return ret;
> +
> +	/*
> +	 * The inode is locked, so these flags won't change after we check them.
> +	 */
> +	if (BTRFS_I(inode)->flags & BTRFS_INODE_COMPRESS) {
> +		btrfs_info(fs_info, "swapfile must not be compressed");
> +		return -EINVAL;
> +	}
> +	if (!(BTRFS_I(inode)->flags & BTRFS_INODE_NODATACOW)) {
> +		btrfs_info(fs_info, "swapfile must not be copy-on-write");
> +		return -EINVAL;
> +	}
> +
> +	/*
> +	 * Balance or device remove/replace/resize can move stuff around from
> +	 * under us. The EXCL_OP flag makes sure they aren't running/won't run
> +	 * concurrently while we are mapping the swap extents, and
> +	 * fs_info->swapfile_pins prevents them from running while the swap file
> +	 * is active and moving the extents. Note that this also prevents a
> +	 * concurrent device add which isn't actually necessary, but it's not
> +	 * really worth the trouble to allow it.
> +	 */
> +	if (test_and_set_bit(BTRFS_FS_EXCL_OP, &fs_info->flags))
> +		return -EBUSY;
> +	/*
> +	 * Snapshots can create extents which require COW even if NODATACOW is
> +	 * set. We use this counter to prevent snapshots. We must increment it
> +	 * before walking the extents because we don't want a concurrent
> +	 * snapshot to run after we've already checked the extents.
> +	 */
> +	atomic_inc(&BTRFS_I(inode)->root->nr_swapfiles);
> +
> +	lock_extent_bits(io_tree, 0, isize - 1, &cached_state);
> +	start = 0;
> +	while (start < isize) {
> +		u64 end, logical_block_start, physical_block_start;
> +		struct btrfs_block_group_cache *bg;
> +		u64 len = isize - start;
> +
> +		em = btrfs_get_extent(BTRFS_I(inode), NULL, 0, start, len, 0);
> +		if (IS_ERR(em)) {
> +			ret = PTR_ERR(em);
> +			goto out;
> +		}
> +		end = extent_map_end(em);
> +
> +		if (em->block_start == EXTENT_MAP_HOLE) {
> +			btrfs_info(fs_info, "swapfile must not have holes");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +		if (em->block_start == EXTENT_MAP_INLINE) {
> +			/*
> +			 * It's unlikely we'll ever actually find ourselves
> +			 * here, as a file small enough to fit inline won't be
> +			 * big enough to store more than the swap header, but in
> +			 * case something changes in the future, let's catch it
> +			 * here rather than later.
> +			 */
> +			btrfs_info(fs_info, "swapfile must not be inline");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
> +			btrfs_info(fs_info, "swapfile must not be compressed");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		logical_block_start = em->block_start + (start - em->start);
> +		len = min(len, em->len - (start - em->start));
> +		free_extent_map(em);
> +		em = NULL;
> +
> +		ret = can_nocow_extent(inode, start, &len, NULL, NULL, NULL);
> +		if (ret < 0) {
> +			goto out;
> +		} else if (ret) {
> +			ret = 0;
> +		} else {
> +			btrfs_info(fs_info, "swapfile must not be copy-on-write");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		em = btrfs_get_chunk_map(fs_info, logical_block_start, len);
> +		if (IS_ERR(em)) {
> +			ret = PTR_ERR(em);
> +			goto out;
> +		}
> +
> +		if (em->map_lookup->type & BTRFS_BLOCK_GROUP_PROFILE_MASK) {
> +			btrfs_info(fs_info, "swapfile must have single data profile");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		if (device == NULL) {
> +			device = em->map_lookup->stripes[0].dev;
> +			ret = btrfs_add_swapfile_pin(inode, device, false);
> +			if (ret == 1)
> +				ret = 0;
> +			else if (ret)
> +				goto out;
> +		} else if (device != em->map_lookup->stripes[0].dev) {
> +			btrfs_info(fs_info, "swapfile must be on one device");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		physical_block_start = (em->map_lookup->stripes[0].physical +
> +					(logical_block_start - em->start));
> +		len = min(len, em->len - (logical_block_start - em->start));
> +		free_extent_map(em);
> +		em = NULL;
> +
> +		bg = btrfs_lookup_block_group(fs_info, logical_block_start);
> +		if (!bg) {
> +			btrfs_info(fs_info, "could not find block group containing swapfile");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		ret = btrfs_add_swapfile_pin(inode, bg, true);
> +		if (ret) {
> +			btrfs_put_block_group(bg);
> +			if (ret == 1)
> +				ret = 0;
> +			else
> +				goto out;
> +		}
> +
> +		if (bsi.block_len &&
> +		    bsi.block_start + bsi.block_len == physical_block_start) {
> +			bsi.block_len += len;
> +		} else {
> +			if (bsi.block_len) {
> +				ret = btrfs_add_swap_extent(sis, &bsi);
> +				if (ret)
> +					goto out;
> +			}
> +			bsi.start = start;
> +			bsi.block_start = physical_block_start;
> +			bsi.block_len = len;
> +		}
> +
> +		start = end;
> +	}
> +
> +	if (bsi.block_len)
> +		ret = btrfs_add_swap_extent(sis, &bsi);
> +
> +out:
> +	if (!IS_ERR_OR_NULL(em))
> +		free_extent_map(em);
> +
> +	unlock_extent_cached(io_tree, 0, isize - 1, &cached_state);
> +
> +	if (ret)
> +		btrfs_swap_deactivate(file);
> +
> +	clear_bit(BTRFS_FS_EXCL_OP, &fs_info->flags);
> +
> +	if (ret)
> +		return ret;
> +
> +	if (device)
> +		sis->bdev = device->bdev;
> +	*span = bsi.highest_ppage - bsi.lowest_ppage + 1;
> +	sis->max = bsi.nr_pages;
> +	sis->pages = bsi.nr_pages - 1;
> +	sis->highest_bit = bsi.nr_pages - 1;
> +	return bsi.nr_extents;
> +}
> +
>  static const struct inode_operations btrfs_dir_inode_operations = {
>  	.getattr	= btrfs_getattr,
>  	.lookup		= btrfs_lookup,
> @@ -10514,6 +10828,8 @@ static const struct address_space_operations btrfs_aops = {
>  	.releasepage	= btrfs_releasepage,
>  	.set_page_dirty	= btrfs_set_page_dirty,
>  	.error_remove_page = generic_error_remove_page,
> +	.swap_activate	= btrfs_swap_activate,
> +	.swap_deactivate = btrfs_swap_deactivate,
>  };
>  
>  static const struct address_space_operations btrfs_symlink_aops = {
> 
