Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 350656B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:09:17 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so4548314pab.19
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:09:16 -0800 (PST)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id xi4si7330624pbc.86.2014.11.21.02.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 02:09:13 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so4584578pab.30
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:09:12 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 5/5] btrfs: enable swap file support
Date: Fri, 21 Nov 2014 02:08:31 -0800
Message-Id: <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>
Cc: Omar Sandoval <osandov@osandov.com>

Implement the swap file a_ops on btrfs. Activation simply checks for a usable
swap file: it must be fully allocated (no holes), support direct I/O (so no
compressed or inline extents) and should be nocow (I'm not sure about that last
one).

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/inode.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d23362f..b8fd36b 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -9442,6 +9442,75 @@ out_inode:
 
 }
 
+static int btrfs_swap_activate(struct swap_info_struct *sis, struct file *file,
+			       sector_t *span)
+{
+	struct inode *inode = file_inode(file);
+	struct btrfs_inode *ip = BTRFS_I(inode);
+	int ret = 0;
+	u64 isize = inode->i_size;
+	struct extent_state *cached_state = NULL;
+	struct extent_map *em;
+	u64 start, len;
+
+	if (ip->flags & BTRFS_INODE_COMPRESS) {
+		/* Can't do direct I/O on a compressed file. */
+		pr_err("BTRFS: swapfile is compressed");
+		return -EINVAL;
+	}
+	if (!(ip->flags & BTRFS_INODE_NODATACOW)) {
+		/* The swap file can't be copy-on-write. */
+		pr_err("BTRFS: swapfile is copy-on-write");
+		return -EINVAL;
+	}
+
+	lock_extent_bits(&ip->io_tree, 0, isize - 1, 0, &cached_state);
+
+	/*
+	 * All of the extents must be allocated and support direct I/O. Inline
+	 * extents and compressed extents fall back to buffered I/O, so those
+	 * are no good.
+	 */
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
+			pr_err("BTRFS: swapfile has holes");
+			ret = -EINVAL;
+			goto out;
+		}
+		if (em->block_start == EXTENT_MAP_INLINE) {
+			pr_err("BTRFS: swapfile is inline");
+			ret = -EINVAL;
+			goto out;
+		}
+		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
+			pr_err("BTRFS: swapfile is compresed");
+			ret = -EINVAL;
+			goto out;
+		}
+
+		start = extent_map_end(em);
+		free_extent_map(em);
+	}
+
+out:
+	unlock_extent_cached(&ip->io_tree, 0, isize - 1, &cached_state,
+			     GFP_NOFS);
+	return ret;
+}
+
+static void btrfs_swap_deactivate(struct file *file)
+{
+}
+
 static const struct inode_operations btrfs_dir_inode_operations = {
 	.getattr	= btrfs_getattr,
 	.lookup		= btrfs_lookup,
@@ -9519,6 +9588,8 @@ static const struct address_space_operations btrfs_aops = {
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
