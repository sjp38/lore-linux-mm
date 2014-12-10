Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEC96B0075
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:52 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so1742437pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:51 -0800 (PST)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com. [209.85.220.46])
        by mx.google.com with ESMTPS id j2si4389355pdo.128.2014.12.09.17.46.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:50 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so1116320pab.19
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:49 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 7/7] btrfs: enable swap file support
Date: Tue,  9 Dec 2014 17:45:48 -0800
Message-Id: <0f9937165d8fc1b8b6332ac97e59593022e9fa5b.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Implement the swap file a_ops on btrfs. Activation does two things:

1. Checks for a usable swap file: it must be fully allocated (no holes),
   support direct I/O (so no compressed or inline extents) and must be
   eligible for nocow in its entirety in order to avoid doing a bunch of
   allocations for a COW when we're already low on memory
2. Pins the extent maps in memory with EXTENT_FLAG_SWAPFILE

Deactivation unpins all of the extent maps.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/inode.c | 131 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 131 insertions(+)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 7c2dfb2..76b58d7 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7191,6 +7191,7 @@ static int btrfs_get_blocks_direct(struct inode *inode, sector_t iblock,
 	 * this will cow the extent, reset the len in case we changed
 	 * it above
 	 */
+	WARN_ON_ONCE(IS_SWAPFILE(inode));
 	len = bh_result->b_size;
 	free_extent_map(em);
 	em = btrfs_new_extent_direct(inode, start, len);
@@ -9443,6 +9444,134 @@ out_inode:
 
 }
 
+static void __clear_swapfile_extents(struct inode *inode)
+{
+	u64 isize = inode->i_size;
+	struct extent_map *em;
+	u64 start, len;
+
+	start = 0;
+	while (start < isize) {
+		len = isize - start;
+		em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
+		if (IS_ERR(em))
+			return;
+
+		clear_bit(EXTENT_FLAG_SWAPFILE, &em->flags);
+
+		start = extent_map_end(em);
+		free_extent_map(em);
+	}
+}
+
+static int btrfs_swap_activate(struct swap_info_struct *sis, struct file *file,
+			       sector_t *span)
+{
+	struct inode *inode = file_inode(file);
+	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
+	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
+	int ret = 0;
+	u64 isize = inode->i_size;
+	struct extent_state *cached_state = NULL;
+	struct extent_map *em;
+	u64 start, len;
+
+	if (BTRFS_I(inode)->flags & BTRFS_INODE_COMPRESS) {
+		/* Can't do direct I/O on a compressed file. */
+		btrfs_err(fs_info, "swapfile is compressed");
+		return -EINVAL;
+	}
+	if (!(BTRFS_I(inode)->flags & BTRFS_INODE_NODATACOW)) {
+		/*
+		 * Going through the copy-on-write path while swapping pages
+		 * in/out and doing a bunch of allocations could stress the
+		 * memory management code that got us there in the first place,
+		 * and that's sure to be a bad time.
+		 */
+		btrfs_err(fs_info, "swapfile is copy-on-write");
+		return -EINVAL;
+	}
+
+	lock_extent_bits(io_tree, 0, isize - 1, 0, &cached_state);
+
+	/*
+	 * All of the extents must be allocated and support direct I/O. Inline
+	 * extents and compressed extents fall back to buffered I/O, so those
+	 * are no good. Additionally, all of the extents must be safe for nocow.
+	 */
+	atomic_inc(&BTRFS_I(inode)->root->nr_swapfiles);
+	start = 0;
+	while (start < isize) {
+		len = isize - start;
+		em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
+		if (IS_ERR(em)) {
+			ret = PTR_ERR(em);
+			goto out;
+		}
+
+		if (test_bit(EXTENT_FLAG_VACANCY, &em->flags) ||
+		    em->block_start == EXTENT_MAP_HOLE) {
+			btrfs_err(fs_info, "swapfile has holes");
+			ret = -EINVAL;
+			goto out;
+		}
+		if (em->block_start == EXTENT_MAP_INLINE) {
+			/*
+			 * It's unlikely we'll ever actually find ourselves
+			 * here, as a file small enough to fit inline won't be
+			 * big enough to store more than the swap header, but in
+			 * case something changes in the future, let's catch it
+			 * here rather than later.
+			 */
+			btrfs_err(fs_info, "swapfile is inline");
+			ret = -EINVAL;
+			goto out;
+		}
+		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
+			btrfs_err(fs_info, "swapfile is compresed");
+			ret = -EINVAL;
+			goto out;
+		}
+		ret = can_nocow_extent(inode, start, &len, NULL, NULL, NULL);
+		if (ret < 0) {
+			goto out;
+		} else if (ret == 1) {
+			ret = 0;
+		} else {
+			btrfs_err(fs_info, "swapfile has extent requiring COW (%llu-%llu)",
+				  start, start + len - 1);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		set_bit(EXTENT_FLAG_SWAPFILE, &em->flags);
+
+		start = extent_map_end(em);
+		free_extent_map(em);
+	}
+
+out:
+	if (ret) {
+		__clear_swapfile_extents(inode);
+		atomic_dec(&BTRFS_I(inode)->root->nr_swapfiles);
+	}
+	unlock_extent_cached(io_tree, 0, isize - 1, &cached_state, GFP_NOFS);
+	return ret;
+}
+
+static void btrfs_swap_deactivate(struct file *file)
+{
+	struct inode *inode = file_inode(file);
+	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
+	struct extent_state *cached_state = NULL;
+	u64 isize = inode->i_size;
+
+	lock_extent_bits(io_tree, 0, isize - 1, 0, &cached_state);
+	__clear_swapfile_extents(inode);
+	unlock_extent_cached(io_tree, 0, isize - 1, &cached_state, GFP_NOFS);
+	atomic_dec(&BTRFS_I(inode)->root->nr_swapfiles);
+}
+
 static const struct inode_operations btrfs_dir_inode_operations = {
 	.getattr	= btrfs_getattr,
 	.lookup		= btrfs_lookup,
@@ -9520,6 +9649,8 @@ static const struct address_space_operations btrfs_aops = {
 	.releasepage	= btrfs_releasepage,
 	.set_page_dirty	= btrfs_set_page_dirty,
 	.error_remove_page = generic_error_remove_page,
+	.swap_activate	= btrfs_swap_activate,
+	.swap_deactivate = btrfs_swap_deactivate,
 };
 
 static const struct address_space_operations btrfs_symlink_aops = {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
