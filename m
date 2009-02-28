Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E95186B004D
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:41:30 -0500 (EST)
Date: Sat, 28 Feb 2009 12:41:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 3/5] minix: fsblock conversion
Message-ID: <20090228114123.GG28496@wotan.suse.de>
References: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228112858.GD28496@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>


---
 fs/minix/bitmap.c       |  148 ++++++++++++++++++++----------
 fs/minix/dir.c          |    3 
 fs/minix/file.c         |   47 +++++----
 fs/minix/inode.c        |  214 ++++++++++++++++++++++++++++++--------------
 fs/minix/itree_common.c |  233 +++++++++++++++++++++++++++++++-----------------
 fs/minix/itree_v1.c     |    8 -
 fs/minix/itree_v2.c     |    8 -
 fs/minix/minix.h        |   22 +++-
 8 files changed, 453 insertions(+), 230 deletions(-)

Index: linux-2.6/fs/minix/minix.h
===================================================================
--- linux-2.6.orig/fs/minix/minix.h
+++ linux-2.6/fs/minix/minix.h
@@ -1,4 +1,5 @@
 #include <linux/fs.h>
+#include <linux/fsblock.h>
 #include <linux/pagemap.h>
 #include <linux/minix_fs.h>
 
@@ -32,17 +33,21 @@ struct minix_sb_info {
 	int s_dirsize;
 	int s_namelen;
 	int s_link_max;
-	struct buffer_head ** s_imap;
-	struct buffer_head ** s_zmap;
-	struct buffer_head * s_sbh;
+	struct fsblock_meta ** s_imap;
+	struct fsblock_meta ** s_zmap;
+	struct fsblock_meta * s_smblock;
 	struct minix_super_block * s_ms;
 	unsigned short s_mount_state;
 	unsigned short s_version;
+
+	struct fsblock_sb fsb_sb;
 };
 
 extern struct inode *minix_iget(struct super_block *, unsigned long);
-extern struct minix_inode * minix_V1_raw_inode(struct super_block *, ino_t, struct buffer_head **);
-extern struct minix2_inode * minix_V2_raw_inode(struct super_block *, ino_t, struct buffer_head **);
+extern struct minix_inode * minix_V1_raw_inode(struct super_block *, ino_t, struct fsblock_meta **);
+extern void minix_put_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta *mblock, struct minix_inode *p);
+extern struct minix2_inode * minix_V2_raw_inode(struct super_block *, ino_t, struct fsblock_meta **);
+extern void minix2_put_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta *mblock, struct minix2_inode *p);
 extern struct inode * minix_new_inode(const struct inode * dir, int * error);
 extern void minix_free_inode(struct inode * inode);
 extern unsigned long minix_count_free_inodes(struct minix_sb_info *sbi);
@@ -53,14 +58,17 @@ extern int minix_getattr(struct vfsmount
 extern int __minix_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata);
+extern int minix_page_mkwrite(struct vm_area_struct *vma, struct page *page);
 
 extern void V1_minix_truncate(struct inode *);
 extern void V2_minix_truncate(struct inode *);
 extern void minix_truncate(struct inode *);
 extern int minix_sync_inode(struct inode *);
 extern void minix_set_inode(struct inode *, dev_t);
-extern int V1_minix_get_block(struct inode *, long, struct buffer_head *, int);
-extern int V2_minix_get_block(struct inode *, long, struct buffer_head *, int);
+extern int V1_minix_map_block(struct address_space *,
+				struct fsblock *, loff_t, int);
+extern int V2_minix_map_block(struct address_space *,
+				struct fsblock *, loff_t, int);
 extern unsigned V1_minix_blocks(loff_t, struct super_block *);
 extern unsigned V2_minix_blocks(loff_t, struct super_block *);
 
Index: linux-2.6/fs/minix/itree_common.c
===================================================================
--- linux-2.6.orig/fs/minix/itree_common.c
+++ linux-2.6/fs/minix/itree_common.c
@@ -1,31 +1,30 @@
 /* Generic part */
+#include <linux/rwsem.h>
 
 typedef struct {
-	block_t	*p;
+	block_t *mem;
+	int offset;
 	block_t	key;
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
 } Indirect;
 
-static DEFINE_RWLOCK(pointers_lock);
+static DECLARE_RWSEM(pointers_sem);
 
-static inline void add_chain(Indirect *p, struct buffer_head *bh, block_t *v)
+static inline void add_chain(Indirect *p, struct fsblock_meta *mblock, block_t *mem, int offset)
 {
-	p->key = *(p->p = v);
-	p->bh = bh;
+	p->mem = mem;
+	p->offset = offset;
+	p->key = mem[offset];
+	p->mblock = mblock;
 }
 
 static inline int verify_chain(Indirect *from, Indirect *to)
 {
-	while (from <= to && from->key == *from->p)
+	while (from <= to && from->key == from->mem[from->offset])
 		from++;
 	return (from > to);
 }
 
-static inline block_t *block_end(struct buffer_head *bh)
-{
-	return (block_t *)((char*)bh->b_data + bh->b_size);
-}
-
 static inline Indirect *get_branch(struct inode *inode,
 					int depth,
 					int *offsets,
@@ -33,36 +32,45 @@ static inline Indirect *get_branch(struc
 					int *err)
 {
 	struct super_block *sb = inode->i_sb;
+	struct minix_sb_info *sbi = minix_sb(sb);
 	Indirect *p = chain;
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
 
 	*err = 0;
 	/* i_data is not going away, no lock needed */
-	add_chain (chain, NULL, i_data(inode) + *offsets);
+	add_chain (chain, NULL, i_data(inode), *offsets);
 	if (!p->key)
-		goto no_block;
+		goto out;
 	while (--depth) {
-		bh = sb_bread(sb, block_to_cpu(p->key));
-		if (!bh)
-			goto failure;
-		read_lock(&pointers_lock);
-		if (!verify_chain(chain, p))
-			goto changed;
-		add_chain(++p, bh, (block_t *)bh->b_data + *++offsets);
-		read_unlock(&pointers_lock);
+		void *data;
+
+		mblock = sb_mbread(&sbi->fsb_sb, block_to_cpu(p->key));
+		if (!mblock) {
+			*err = -EIO;
+			goto out;
+		}
+		down_read(&pointers_sem);
+		if (!verify_chain(chain, p)) {
+			/* changed */
+			*err = -EAGAIN;
+			goto out_unlock;
+		}
+		data = vmap_mblock(mblock, 0, sb->s_blocksize);
+		if (!data) {
+			*err = -ENOMEM;
+			goto out_unlock;
+		}
+		add_chain(++p, mblock, (block_t *)data, *++offsets);
+		up_read(&pointers_sem);
 		if (!p->key)
-			goto no_block;
+			goto out;
 	}
 	return NULL;
 
-changed:
-	read_unlock(&pointers_lock);
-	brelse(bh);
-	*err = -EAGAIN;
-	goto no_block;
-failure:
-	*err = -EIO;
-no_block:
+out_unlock:
+	up_read(&pointers_sem);
+	mblock_put(mblock);
+out:
 	return p;
 }
 
@@ -71,35 +79,55 @@ static int alloc_branch(struct inode *in
 			     int *offsets,
 			     Indirect *branch)
 {
+	struct super_block *sb = inode->i_sb;
+	struct minix_sb_info *sbi = minix_sb(sb);
 	int n = 0;
 	int i;
 	int parent = minix_new_block(inode);
+	int ret = -ENOSPC;
 
 	branch[0].key = cpu_to_block(parent);
 	if (parent) for (n = 1; n < num; n++) {
-		struct buffer_head *bh;
+		struct fsblock_meta *mblock;
+		void *data;
+
 		/* Allocate the next block */
 		int nr = minix_new_block(inode);
 		if (!nr)
 			break;
 		branch[n].key = cpu_to_block(nr);
-		bh = sb_getblk(inode->i_sb, parent);
-		lock_buffer(bh);
-		memset(bh->b_data, 0, bh->b_size);
-		branch[n].bh = bh;
-		branch[n].p = (block_t*) bh->b_data + offsets[n];
-		*branch[n].p = branch[n].key;
-		set_buffer_uptodate(bh);
-		unlock_buffer(bh);
-		mark_buffer_dirty_inode(bh, inode);
+		mblock = sb_find_or_create_mblock(&sbi->fsb_sb, parent);
+		if (IS_ERR(mblock)) {
+			ret = PTR_ERR(mblock);
+			break;
+		}
+
+		data = vmap_mblock(mblock, 0, sb->s_blocksize);
+		if (!data) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		lock_block(mblock);
+		memset(data, 0, sb->s_blocksize); /* XXX: or mblock->size */
+
+		branch[n].mblock = mblock;
+		branch[n].mem = data;
+		branch[n].offset = offsets[n];
+		branch[n].mem[branch[n].offset] = branch[n].key;
+		mark_mblock_uptodate(mblock);
+		unlock_block(mblock);
+		mark_mblock_dirty_inode(mblock, inode);
 		parent = nr;
 	}
 	if (n == num)
 		return 0;
 
 	/* Allocation failed, free what we already allocated */
-	for (i = 1; i < n; i++)
-		bforget(branch[i].bh);
+	for (i = 1; i < n; i++) {
+		vunmap_mblock(branch[i].mblock, 0, sb->s_blocksize, branch[i].mem);
+		mbforget(branch[i].mblock);
+	}
 	for (i = 0; i < n; i++)
 		minix_free_block(inode, block_to_cpu(branch[i].key));
 	return -ENOSPC;
@@ -110,48 +138,55 @@ static inline int splice_branch(struct i
 				     Indirect *where,
 				     int num)
 {
+	struct super_block *sb = inode->i_sb;
 	int i;
 
-	write_lock(&pointers_lock);
+	down_write(&pointers_sem);
 
 	/* Verify that place we are splicing to is still there and vacant */
-	if (!verify_chain(chain, where-1) || *where->p)
+	if (!verify_chain(chain, where-1) || where->mem[where->offset])
 		goto changed;
 
-	*where->p = where->key;
+	where->mem[where->offset] = where->key;
 
-	write_unlock(&pointers_lock);
+	up_write(&pointers_sem);
 
 	/* We are done with atomic stuff, now do the rest of housekeeping */
 
 	inode->i_ctime = CURRENT_TIME_SEC;
 
 	/* had we spliced it onto indirect block? */
-	if (where->bh)
-		mark_buffer_dirty_inode(where->bh, inode);
+	if (where->mblock)
+		mark_mblock_dirty_inode(where->mblock, inode);
 
 	mark_inode_dirty(inode);
 	return 0;
 
 changed:
-	write_unlock(&pointers_lock);
-	for (i = 1; i < num; i++)
-		bforget(where[i].bh);
+	up_write(&pointers_sem);
+	for (i = 1; i < num; i++) {
+		vunmap_mblock(where[i].mblock, 0, sb->s_blocksize, where[i].mem);
+		mbforget(where[i].mblock);
+	}
 	for (i = 0; i < num; i++)
 		minix_free_block(inode, block_to_cpu(where[i].key));
 	return -EAGAIN;
 }
 
-static inline int get_block(struct inode * inode, sector_t block,
-			struct buffer_head *bh, int create)
+static inline int insert_block(struct inode *inode, struct fsblock *block, sector_t blocknr, int create)
 {
+	struct super_block *sb = inode->i_sb;
 	int err = -EIO;
 	int offsets[DEPTH];
 	Indirect chain[DEPTH];
 	Indirect *partial;
 	int left;
-	int depth = block_to_path(inode, block, offsets);
+	int depth;
+
+	if (block->flags & BL_mapped)
+		return 0;
 
+	depth = block_to_path(inode, blocknr, offsets);
 	if (depth == 0)
 		goto out;
 
@@ -160,8 +195,10 @@ reread:
 
 	/* Simplest case - block found, no allocation needed */
 	if (!partial) {
+		spin_lock_block_irq(block);
 got_it:
-		map_bh(bh, inode->i_sb, block_to_cpu(chain[depth-1].key));
+		map_fsblock(block, block_to_cpu(chain[depth-1].key));
+		spin_unlock_block_irq(block);
 		/* Clean up and exit */
 		partial = chain+depth-1; /* the whole chain */
 		goto cleanup;
@@ -171,9 +208,16 @@ got_it:
 	if (!create || err == -EIO) {
 cleanup:
 		while (partial > chain) {
-			brelse(partial->bh);
+			vunmap_mblock(partial->mblock, 0, sb->s_blocksize, partial->mem);
+			mblock_put(partial->mblock);
+			/* XXX: balance puts and unmaps etc etc */
 			partial--;
 		}
+		if (!err && !(block->flags & BL_mapped)) {
+			spin_lock_block_irq(block);
+			block->flags |= BL_hole;
+			spin_unlock_block_irq(block);
+		}
 out:
 		return err;
 	}
@@ -194,17 +238,31 @@ out:
 	if (splice_branch(inode, chain, partial, left) < 0)
 		goto changed;
 
-	set_buffer_new(bh);
+	spin_lock_block_irq(block);
+	block->flags &= ~BL_hole;
+	block->flags |= BL_new;
 	goto got_it;
 
 changed:
 	while (partial > chain) {
-		brelse(partial->bh);
+		vunmap_mblock(partial->mblock, 0, sb->s_blocksize, partial->mem);
+		mblock_put(partial->mblock);
 		partial--;
 	}
 	goto reread;
 }
 
+static inline int map_block(struct address_space *mapping,
+				struct fsblock *block, loff_t pos, int create)
+{
+	struct inode *inode = mapping->host;
+	sector_t blocknr;
+
+        blocknr = pos >> inode->i_blkbits;
+
+	return insert_block(inode, block, blocknr, create);
+}
+
 static inline int all_zeroes(block_t *p, block_t *q)
 {
 	while (p < q)
@@ -219,6 +277,7 @@ static Indirect *find_shared(struct inod
 				Indirect chain[DEPTH],
 				block_t *top)
 {
+	struct super_block *sb = inode->i_sb;
 	Indirect *partial, *p;
 	int k, err;
 
@@ -227,26 +286,28 @@ static Indirect *find_shared(struct inod
 		;
 	partial = get_branch(inode, k, offsets, chain, &err);
 
-	write_lock(&pointers_lock);
+	down_write(&pointers_sem);
 	if (!partial)
 		partial = chain + k-1;
-	if (!partial->key && *partial->p) {
-		write_unlock(&pointers_lock);
+	if (!partial->key && partial->mem[partial->offset]) {
+		up_write(&pointers_sem);
 		goto no_top;
 	}
-	for (p=partial;p>chain && all_zeroes((block_t*)p->bh->b_data,p->p);p--)
-		;
+	p = partial;
+	while (p > chain && all_zeroes(p->mem, &p->mem[p->offset]))
+		p--;
 	if (p == chain + k - 1 && p > chain) {
-		p->p--;
+		p->offset--;
 	} else {
-		*top = *p->p;
-		*p->p = 0;
+		*top = p->mem[p->offset];
+		p->mem[p->offset] = 0;
 	}
-	write_unlock(&pointers_lock);
+	up_write(&pointers_sem);
 
 	while(partial > p)
 	{
-		brelse(partial->bh);
+		vunmap_mblock(partial->mblock, 0, sb->s_blocksize, partial->mem);
+		mblock_put(partial->mblock);
 		partial--;
 	}
 no_top:
@@ -268,21 +329,26 @@ static inline void free_data(struct inod
 
 static void free_branches(struct inode *inode, block_t *p, block_t *q, int depth)
 {
-	struct buffer_head * bh;
+	struct super_block *sb = inode->i_sb;
+	struct minix_sb_info *sbi = minix_sb(sb);
+	struct fsblock_meta *mblock;
 	unsigned long nr;
 
 	if (depth--) {
 		for ( ; p < q ; p++) {
+			block_t *start, *end;
 			nr = block_to_cpu(*p);
 			if (!nr)
 				continue;
 			*p = 0;
-			bh = sb_bread(inode->i_sb, nr);
-			if (!bh)
+			mblock = sb_mbread(&sbi->fsb_sb, nr);
+			if (!mblock)
 				continue;
-			free_branches(inode, (block_t*)bh->b_data,
-				      block_end(bh), depth);
-			bforget(bh);
+			start = vmap_mblock(mblock, 0, sb->s_blocksize);
+			end = (block_t *)((unsigned long)start + sb->s_blocksize);
+			free_branches(inode, start, end, depth);
+			vunmap_mblock(mblock, 0, sb->s_blocksize, start);
+			mbforget(mblock);
 			minix_free_block(inode, nr);
 			mark_inode_dirty(inode);
 		}
@@ -303,7 +369,7 @@ static inline void truncate (struct inod
 	long iblock;
 
 	iblock = (inode->i_size + sb->s_blocksize -1) >> sb->s_blocksize_bits;
-	block_truncate_page(inode->i_mapping, inode->i_size, get_block);
+	fsblock_truncate_page(inode->i_mapping, inode->i_size);
 
 	n = block_to_path(inode, iblock, offsets);
 	if (!n)
@@ -321,15 +387,18 @@ static inline void truncate (struct inod
 		if (partial == chain)
 			mark_inode_dirty(inode);
 		else
-			mark_buffer_dirty_inode(partial->bh, inode);
+			mark_mblock_dirty_inode(partial->mblock, inode);
 		free_branches(inode, &nr, &nr+1, (chain+n-1) - partial);
 	}
 	/* Clear the ends of indirect blocks on the shared branch */
 	while (partial > chain) {
-		free_branches(inode, partial->p + 1, block_end(partial->bh),
-				(chain+n-1) - partial);
-		mark_buffer_dirty_inode(partial->bh, inode);
-		brelse (partial->bh);
+		block_t *start, *end;
+		start = &partial->mem[partial->offset + 1];
+		end = (block_t *)((unsigned long)partial->mem + sb->s_blocksize);
+		free_branches(inode, start, end, (chain+n-1) - partial);
+		mark_mblock_dirty_inode(partial->mblock, inode);
+		vunmap_mblock(partial->mblock, 0, sb->s_blocksize, partial->mem);
+		mblock_put(partial->mblock);
 		partial--;
 	}
 do_indirects:
Index: linux-2.6/fs/minix/itree_v1.c
===================================================================
--- linux-2.6.orig/fs/minix/itree_v1.c
+++ linux-2.6/fs/minix/itree_v1.c
@@ -1,4 +1,4 @@
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include "minix.h"
 
 enum {DEPTH = 3, DIRECT = 7};	/* Only double indirect */
@@ -49,10 +49,10 @@ static int block_to_path(struct inode *
 
 #include "itree_common.c"
 
-int V1_minix_get_block(struct inode * inode, long block,
-			struct buffer_head *bh_result, int create)
+int V1_minix_map_block(struct address_space *mapping,
+				struct fsblock *block, loff_t off, int create)
 {
-	return get_block(inode, block, bh_result, create);
+	return map_block(mapping, block, off, create);
 }
 
 void V1_minix_truncate(struct inode * inode)
Index: linux-2.6/fs/minix/itree_v2.c
===================================================================
--- linux-2.6.orig/fs/minix/itree_v2.c
+++ linux-2.6/fs/minix/itree_v2.c
@@ -1,4 +1,4 @@
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include "minix.h"
 
 enum {DIRECT = 7, DEPTH = 4};	/* Have triple indirect */
@@ -55,10 +55,10 @@ static int block_to_path(struct inode *
 
 #include "itree_common.c"
 
-int V2_minix_get_block(struct inode * inode, long block,
-			struct buffer_head *bh_result, int create)
+int V2_minix_map_block(struct address_space *mapping,
+				struct fsblock *block, loff_t off, int create)
 {
-	return get_block(inode, block, bh_result, create);
+	return map_block(mapping, block, off, create);
 }
 
 void V2_minix_truncate(struct inode * inode)
Index: linux-2.6/fs/minix/bitmap.c
===================================================================
--- linux-2.6.orig/fs/minix/bitmap.c
+++ linux-2.6/fs/minix/bitmap.c
@@ -13,39 +13,48 @@
 
 #include "minix.h"
 #include <linux/smp_lock.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/bitops.h>
 #include <linux/sched.h>
 
 static const int nibblemap[] = { 4,3,3,2,3,2,2,1,3,2,2,1,2,1,1,0 };
 
-static unsigned long count_free(struct buffer_head *map[], unsigned numblocks, __u32 numbits)
+static unsigned long count_free(struct fsblock_meta *map[], unsigned numblocks, __u32 numbits)
 {
 	unsigned i, j, sum = 0;
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
+	unsigned int size;
+	char *data;
   
-	for (i=0; i<numblocks-1; i++) {
-		if (!(bh=map[i])) 
+	for (i = 0; i < numblocks - 1; i++) {
+		if (!(mblock = map[i]))
 			return(0);
-		for (j=0; j<bh->b_size; j++)
-			sum += nibblemap[bh->b_data[j] & 0xf]
-				+ nibblemap[(bh->b_data[j]>>4) & 0xf];
+		size = fsblock_size(mblock_block(mblock));
+		data = vmap_mblock(mblock, 0, size);
+		for (j = 0; j < size; j++)
+			sum += nibblemap[data[j] & 0xf]
+				+ nibblemap[(data[j]>>4) & 0xf];
+		vunmap_mblock(mblock, 0, size, data);
 	}
 
-	if (numblocks==0 || !(bh=map[numblocks-1]))
+	if (numblocks == 0 || !(mblock = map[numblocks-1]))
 		return(0);
-	i = ((numbits - (numblocks-1) * bh->b_size * 8) / 16) * 2;
+	size = fsblock_size(mblock_block(mblock));
+	i = ((numbits - (numblocks-1) * size * 8) / 16) * 2;
+	data = vmap_mblock(mblock, 0, size);
 	for (j=0; j<i; j++) {
-		sum += nibblemap[bh->b_data[j] & 0xf]
-			+ nibblemap[(bh->b_data[j]>>4) & 0xf];
+		sum += nibblemap[data[j] & 0xf]
+			+ nibblemap[(data[j]>>4) & 0xf];
 	}
 
 	i = numbits%16;
 	if (i!=0) {
-		i = *(__u16 *)(&bh->b_data[j]) | ~((1<<i) - 1);
+		i = *(__u16 *)(&data[j]) | ~((1<<i) - 1);
 		sum += nibblemap[i & 0xf] + nibblemap[(i>>4) & 0xf];
 		sum += nibblemap[(i>>8) & 0xf] + nibblemap[(i>>12) & 0xf];
 	}
+	vunmap_mblock(mblock, 0, size, data);
+
 	return(sum);
 }
 
@@ -53,7 +62,9 @@ void minix_free_block(struct inode *inod
 {
 	struct super_block *sb = inode->i_sb;
 	struct minix_sb_info *sbi = minix_sb(sb);
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
+	char *data;
+	unsigned int size;
 	int k = sb->s_blocksize_bits + 3;
 	unsigned long bit, zone;
 
@@ -68,13 +79,16 @@ void minix_free_block(struct inode *inod
 		printk("minix_free_block: nonexistent bitmap buffer\n");
 		return;
 	}
-	bh = sbi->s_zmap[zone];
+	mblock = sbi->s_zmap[zone];
+	size = fsblock_size(mblock_block(mblock));
+	data = vmap_mblock(mblock, 0, size);
 	lock_kernel();
-	if (!minix_test_and_clear_bit(bit, bh->b_data))
+	if (!minix_test_and_clear_bit(bit, data))
 		printk("minix_free_block (%s:%lu): bit already cleared\n",
 		       sb->s_id, block);
 	unlock_kernel();
-	mark_buffer_dirty(bh);
+	vunmap_mblock(mblock, 0, size, data);
+	mark_mblock_dirty_inode(mblock, inode);
 	return;
 }
 
@@ -85,21 +99,26 @@ int minix_new_block(struct inode * inode
 	int i;
 
 	for (i = 0; i < sbi->s_zmap_blocks; i++) {
-		struct buffer_head *bh = sbi->s_zmap[i];
+		struct fsblock_meta *mblock = sbi->s_zmap[i];
+		unsigned int size = fsblock_size(mblock_block(mblock));
+		char *data;
 		int j;
 
+		data = vmap_mblock(mblock, 0, size);
 		lock_kernel();
-		j = minix_find_first_zero_bit(bh->b_data, bits_per_zone);
+		j = minix_find_first_zero_bit(data, bits_per_zone);
 		if (j < bits_per_zone) {
-			minix_set_bit(j, bh->b_data);
+			minix_set_bit(j, data);
 			unlock_kernel();
-			mark_buffer_dirty(bh);
+			vunmap_mblock(mblock, 0, size, data);
+			mark_mblock_dirty_inode(mblock, inode);
 			j += i * bits_per_zone + sbi->s_firstdatazone-1;
 			if (j < sbi->s_firstdatazone || j >= sbi->s_nzones)
 				break;
 			return j;
 		}
 		unlock_kernel();
+		vunmap_mblock(mblock, 0, size, data);
 	}
 	return 0;
 }
@@ -112,11 +131,12 @@ unsigned long minix_count_free_blocks(st
 }
 
 struct minix_inode *
-minix_V1_raw_inode(struct super_block *sb, ino_t ino, struct buffer_head **bh)
+minix_V1_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta **mblock)
 {
 	int block;
 	struct minix_sb_info *sbi = minix_sb(sb);
 	struct minix_inode *p;
+	unsigned int size;
 
 	if (!ino || ino > sbi->s_ninodes) {
 		printk("Bad inode number on dev %s: %ld is out of range\n",
@@ -126,24 +146,32 @@ minix_V1_raw_inode(struct super_block *s
 	ino--;
 	block = 2 + sbi->s_imap_blocks + sbi->s_zmap_blocks +
 		 ino / MINIX_INODES_PER_BLOCK;
-	*bh = sb_bread(sb, block);
-	if (!*bh) {
+	*mblock = sb_mbread(&sbi->fsb_sb, block);
+	if (!*mblock) {
 		printk("Unable to read inode block\n");
 		return NULL;
 	}
-	p = (void *)(*bh)->b_data;
+	size = fsblock_size(mblock_block(*mblock));
+	p = vmap_mblock(*mblock, 0, size);
 	return p + ino % MINIX_INODES_PER_BLOCK;
 }
 
+void minix_put_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta *mblock, struct minix_inode *p)
+{
+	unsigned int size = fsblock_size(mblock_block(mblock));
+	vunmap_mblock(mblock, 0, size, p - ino%MINIX_INODES_PER_BLOCK);
+	mblock_put(mblock);
+}
+
 struct minix2_inode *
-minix_V2_raw_inode(struct super_block *sb, ino_t ino, struct buffer_head **bh)
+minix_V2_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta **mblock)
 {
 	int block;
 	struct minix_sb_info *sbi = minix_sb(sb);
 	struct minix2_inode *p;
 	int minix2_inodes_per_block = sb->s_blocksize / sizeof(struct minix2_inode);
+	unsigned int size;
 
-	*bh = NULL;
 	if (!ino || ino > sbi->s_ninodes) {
 		printk("Bad inode number on dev %s: %ld is out of range\n",
 		       sb->s_id, (long)ino);
@@ -152,49 +180,64 @@ minix_V2_raw_inode(struct super_block *s
 	ino--;
 	block = 2 + sbi->s_imap_blocks + sbi->s_zmap_blocks +
 		 ino / minix2_inodes_per_block;
-	*bh = sb_bread(sb, block);
-	if (!*bh) {
+	*mblock = sb_mbread(&sbi->fsb_sb, block);
+	if (!*mblock) {
 		printk("Unable to read inode block\n");
 		return NULL;
 	}
-	p = (void *)(*bh)->b_data;
+	size = fsblock_size(mblock_block(*mblock));
+	p = vmap_mblock(*mblock, 0, size);
 	return p + ino % minix2_inodes_per_block;
 }
 
+void minix2_put_raw_inode(struct super_block *sb, ino_t ino, struct fsblock_meta *mblock, struct minix2_inode *p)
+{
+	int minix2_inodes_per_block = sb->s_blocksize / sizeof(struct minix2_inode);
+	unsigned int size = fsblock_size(mblock_block(mblock));
+
+	ino--;
+	vunmap_mblock(mblock, 0, size, p - ino%minix2_inodes_per_block);
+	mblock_put(mblock);
+}
+
 /* Clear the link count and mode of a deleted inode on disk. */
 
 static void minix_clear_inode(struct inode *inode)
 {
-	struct buffer_head *bh = NULL;
+	struct super_block *sb = inode->i_sb;
+	ino_t ino = inode->i_ino;
+	struct fsblock_meta *mblock;
 
 	if (INODE_VERSION(inode) == MINIX_V1) {
 		struct minix_inode *raw_inode;
-		raw_inode = minix_V1_raw_inode(inode->i_sb, inode->i_ino, &bh);
+		raw_inode = minix_V1_raw_inode(sb, ino, &mblock);
 		if (raw_inode) {
 			raw_inode->i_nlinks = 0;
 			raw_inode->i_mode = 0;
+			mark_mblock_dirty(mblock);
+			minix_put_raw_inode(sb, ino, mblock, raw_inode);
 		}
 	} else {
 		struct minix2_inode *raw_inode;
-		raw_inode = minix_V2_raw_inode(inode->i_sb, inode->i_ino, &bh);
+		raw_inode = minix_V2_raw_inode(sb, ino, &mblock);
 		if (raw_inode) {
 			raw_inode->i_nlinks = 0;
 			raw_inode->i_mode = 0;
+			mark_mblock_dirty(mblock);
+			minix2_put_raw_inode(sb, ino, mblock, raw_inode);
 		}
 	}
-	if (bh) {
-		mark_buffer_dirty(bh);
-		brelse (bh);
-	}
 }
 
 void minix_free_inode(struct inode * inode)
 {
 	struct super_block *sb = inode->i_sb;
 	struct minix_sb_info *sbi = minix_sb(inode->i_sb);
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
 	int k = sb->s_blocksize_bits + 3;
 	unsigned long ino, bit;
+	unsigned int size;
+	char *data;
 
 	ino = inode->i_ino;
 	if (ino < 1 || ino > sbi->s_ninodes) {
@@ -210,12 +253,15 @@ void minix_free_inode(struct inode * ino
 
 	minix_clear_inode(inode);	/* clear on-disk copy */
 
-	bh = sbi->s_imap[ino];
+	mblock = sbi->s_imap[ino];
+	size = fsblock_size(mblock_block(mblock));
+	data = vmap_mblock(mblock, 0, size);
 	lock_kernel();
-	if (!minix_test_and_clear_bit(bit, bh->b_data))
+	if (!minix_test_and_clear_bit(bit, data))
 		printk("minix_free_inode: bit %lu already cleared\n", bit);
 	unlock_kernel();
-	mark_buffer_dirty(bh);
+	vunmap_mblock(mblock, 0, size, data);
+	mark_mblock_dirty(mblock);
  out:
 	clear_inode(inode);		/* clear in-memory copy */
 }
@@ -225,7 +271,9 @@ struct inode * minix_new_inode(const str
 	struct super_block *sb = dir->i_sb;
 	struct minix_sb_info *sbi = minix_sb(sb);
 	struct inode *inode = new_inode(sb);
-	struct buffer_head * bh;
+	struct fsblock_meta * mblock;
+	unsigned int size;
+	char * data;
 	int bits_per_zone = 8 * sb->s_blocksize;
 	unsigned long j;
 	int i;
@@ -235,28 +283,32 @@ struct inode * minix_new_inode(const str
 		return NULL;
 	}
 	j = bits_per_zone;
-	bh = NULL;
+	mblock = NULL;
 	*error = -ENOSPC;
 	lock_kernel();
 	for (i = 0; i < sbi->s_imap_blocks; i++) {
-		bh = sbi->s_imap[i];
-		j = minix_find_first_zero_bit(bh->b_data, bits_per_zone);
+		mblock = sbi->s_imap[i];
+		size = fsblock_size(mblock_block(mblock));
+		data = vmap_mblock(mblock, 0, size);
+		j = minix_find_first_zero_bit(data, bits_per_zone);
 		if (j < bits_per_zone)
 			break;
+		vunmap_mblock(mblock, 0, size, data);
 	}
-	if (!bh || j >= bits_per_zone) {
+	if (!mblock || j >= bits_per_zone) {
 		unlock_kernel();
 		iput(inode);
 		return NULL;
 	}
-	if (minix_test_and_set_bit(j, bh->b_data)) {	/* shouldn't happen */
+	if (minix_test_and_set_bit(j, data)) {	/* shouldn't happen */
 		unlock_kernel();
 		printk("minix_new_inode: bit already set\n");
 		iput(inode);
 		return NULL;
 	}
 	unlock_kernel();
-	mark_buffer_dirty(bh);
+	vunmap_mblock(mblock, 0, size, data);
+	mark_mblock_dirty(mblock);
 	j += i * bits_per_zone;
 	if (!j || j > sbi->s_ninodes) {
 		iput(inode);
Index: linux-2.6/fs/minix/inode.c
===================================================================
--- linux-2.6.orig/fs/minix/inode.c
+++ linux-2.6/fs/minix/inode.c
@@ -12,6 +12,7 @@
 
 #include <linux/module.h>
 #include "minix.h"
+#include <linux/fsblock.h>
 #include <linux/buffer_head.h>
 #include <linux/slab.h>
 #include <linux/init.h>
@@ -24,29 +25,37 @@ static int minix_remount (struct super_b
 
 static void minix_delete_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	struct address_space *mapping = &inode->i_data;
+
+	truncate_inode_pages(mapping, 0);
 	inode->i_size = 0;
 	minix_truncate(inode);
+	fsblock_release(mapping, 1);
 	minix_free_inode(inode);
 }
 
 static void minix_put_super(struct super_block *sb)
 {
 	int i;
+	unsigned int offset;
 	struct minix_sb_info *sbi = minix_sb(sb);
 
 	if (!(sb->s_flags & MS_RDONLY)) {
 		if (sbi->s_version != MINIX_V3)	 /* s_state is now out from V3 sb */
 			sbi->s_ms->s_state = sbi->s_mount_state;
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_mblock_dirty(sbi->s_smblock);
 	}
 	for (i = 0; i < sbi->s_imap_blocks; i++)
-		brelse(sbi->s_imap[i]);
+		mblock_put(sbi->s_imap[i]);
 	for (i = 0; i < sbi->s_zmap_blocks; i++)
-		brelse(sbi->s_zmap[i]);
-	brelse (sbi->s_sbh);
+		mblock_put(sbi->s_zmap[i]);
+
+	offset = BLOCK_SIZE - mblock_block(sbi->s_smblock)->block_nr * sb->s_blocksize;
+	vunmap_mblock(sbi->s_smblock, offset, BLOCK_SIZE, sbi->s_ms);
+	mblock_put(sbi->s_smblock);
 	kfree(sbi->s_imap);
 	sb->s_fs_info = NULL;
+	fsblock_unregister_super(sb, &sbi->fsb_sb);
 	kfree(sbi);
 
 	return;
@@ -117,7 +126,7 @@ static int minix_remount (struct super_b
 		/* Mounting a rw partition read-only. */
 		if (sbi->s_version != MINIX_V3)
 			ms->s_state = sbi->s_mount_state;
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_mblock_dirty(sbi->s_smblock);
 	} else {
 	  	/* Mount a partition which is read-only, read-write. */
 		if (sbi->s_version != MINIX_V3) {
@@ -126,7 +135,7 @@ static int minix_remount (struct super_b
 		} else {
 			sbi->s_mount_state = MINIX_VALID_FS;
 		}
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_mblock_dirty(sbi->s_smblock);
 
 		if (!(sbi->s_mount_state & MINIX_VALID_FS))
 			printk("MINIX-fs warning: remounting unchecked fs, "
@@ -140,13 +149,18 @@ static int minix_remount (struct super_b
 
 static int minix_fill_super(struct super_block *s, void *data, int silent)
 {
-	struct buffer_head *bh;
-	struct buffer_head **map;
+	struct buffer_head * bh;
+	struct fsblock_meta *mblock;
+	struct fsblock_meta **map;
 	struct minix_super_block *ms;
 	struct minix3_super_block *m3s = NULL;
 	unsigned long i, block;
 	struct inode *root_inode;
 	struct minix_sb_info *sbi;
+	char *d;
+	unsigned int size = BLOCK_SIZE;
+	sector_t blocknr = BLOCK_SIZE / size;
+	unsigned int offset = BLOCK_SIZE - blocknr * size;
 	int ret = -EINVAL;
 
 	sbi = kzalloc(sizeof(struct minix_sb_info), GFP_KERNEL);
@@ -157,15 +171,27 @@ static int minix_fill_super(struct super
 	BUILD_BUG_ON(32 != sizeof (struct minix_inode));
 	BUILD_BUG_ON(64 != sizeof(struct minix2_inode));
 
-	if (!sb_set_blocksize(s, BLOCK_SIZE))
+	if (!sb_set_blocksize(s, size))
 		goto out_bad_hblock;
 
-	if (!(bh = sb_bread(s, 1)))
+#if 1
+	bh = sb_bread(s, blocknr);
+	if (!bh)
+		goto out_bad_sb;
+
+	ms = (void *)bh->b_data;
+#else
+	ret = fsblock_register_super(s, &sbi->fsb_sb);
+	if (ret)
+		goto out_bad_fsblock;
+
+	if (!(mblock = sb_mbread(&sbi->fsb_sb, blocknr)))
 		goto out_bad_sb;
 
-	ms = (struct minix_super_block *) bh->b_data;
+	ms = vmap_mblock(mblock, offset, BLOCK_SIZE); /* XXX: unmap where? */
 	sbi->s_ms = ms;
-	sbi->s_sbh = bh;
+	sbi->s_smblock = mblock;
+#endif
 	sbi->s_mount_state = ms->s_state;
 	sbi->s_ninodes = ms->s_ninodes;
 	sbi->s_nzones = ms->s_nzones;
@@ -197,8 +223,8 @@ static int minix_fill_super(struct super
 		sbi->s_dirsize = 32;
 		sbi->s_namelen = 30;
 		sbi->s_link_max = MINIX2_LINK_MAX;
-	} else if ( *(__u16 *)(bh->b_data + 24) == MINIX3_SUPER_MAGIC) {
-		m3s = (struct minix3_super_block *) bh->b_data;
+	} else if ( *((__u16 *)ms + 12) == MINIX3_SUPER_MAGIC) {
+		m3s = (struct minix3_super_block *)ms;
 		s->s_magic = m3s->s_magic;
 		sbi->s_imap_blocks = m3s->s_imap_blocks;
 		sbi->s_zmap_blocks = m3s->s_zmap_blocks;
@@ -212,16 +238,49 @@ static int minix_fill_super(struct super
 		sbi->s_version = MINIX_V3;
 		sbi->s_link_max = MINIX2_LINK_MAX;
 		sbi->s_mount_state = MINIX_VALID_FS;
-		sb_set_blocksize(s, m3s->s_blocksize);
+		size = m3s->s_blocksize;
+		if (size != BLOCK_SIZE) {
+			blocknr = BLOCK_SIZE / size;
+			offset = BLOCK_SIZE - blocknr * size;
+
+#if 0
+			vunmap_mblock(mblock, offset, BLOCK_SIZE, ms);
+			mblock_put(mblock);
+#endif
+			put_bh(bh);
+			bh = NULL;
+			if (!sb_set_blocksize(s, size))
+				goto out_bad_hblock;
+#if 0
+			if (!(mblock = sb_mbread(&sbi->fsb_sb, blocknr)))
+				goto out_bad_sb;
+			ms = vmap_mblock(mblock, offset, BLOCK_SIZE);
+			sbi->s_ms = ms;
+			sbi->s_smblock = mblock;
+#endif
+		}
 	} else
 		goto out_no_fs;
+#if 1
+	if (bh)
+		put_bh(bh);
+	ret = fsblock_register_super(s, &sbi->fsb_sb);
+	if (ret)
+		goto out_bad_fsblock;
+
+	if (!(mblock = sb_mbread(&sbi->fsb_sb, blocknr)))
+		goto out_bad_sb;
+	ms = vmap_mblock(mblock, offset, BLOCK_SIZE);
+	sbi->s_ms = ms;
+	sbi->s_smblock = mblock;
+#endif
 
 	/*
 	 * Allocate the buffer map to keep the superblock small.
 	 */
 	if (sbi->s_imap_blocks == 0 || sbi->s_zmap_blocks == 0)
 		goto out_illegal_sb;
-	i = (sbi->s_imap_blocks + sbi->s_zmap_blocks) * sizeof(bh);
+	i = (sbi->s_imap_blocks + sbi->s_zmap_blocks) * sizeof(mblock);
 	map = kzalloc(i, GFP_KERNEL);
 	if (!map)
 		goto out_no_map;
@@ -230,22 +289,27 @@ static int minix_fill_super(struct super
 
 	block=2;
 	for (i=0 ; i < sbi->s_imap_blocks ; i++) {
-		if (!(sbi->s_imap[i]=sb_bread(s, block)))
+		if (!(sbi->s_imap[i] = sb_mbread(&sbi->fsb_sb, block)))
 			goto out_no_bitmap;
 		block++;
 	}
 	for (i=0 ; i < sbi->s_zmap_blocks ; i++) {
-		if (!(sbi->s_zmap[i]=sb_bread(s, block)))
+		if (!(sbi->s_zmap[i] = sb_mbread(&sbi->fsb_sb, block)))
 			goto out_no_bitmap;
 		block++;
 	}
 
-	minix_set_bit(0,sbi->s_imap[0]->b_data);
-	minix_set_bit(0,sbi->s_zmap[0]->b_data);
+	d = vmap_mblock(sbi->s_imap[0], 0, size);
+	minix_set_bit(0, d);
+	vunmap_mblock(sbi->s_imap[0], 0, size, d);
+
+	d = vmap_mblock(sbi->s_zmap[0], 0, size);
+	minix_set_bit(0, d);
+	vunmap_mblock(sbi->s_zmap[0], 0, size, d);
 
 	/* set up enough so that it can read an inode */
 	s->s_op = &minix_sops;
-	root_inode = minix_iget(s, MINIX_ROOT_INO);
+	root_inode = minix_iget(s, MINIX_ROOT_INO); /*XXXoops*/
 	if (IS_ERR(root_inode)) {
 		ret = PTR_ERR(root_inode);
 		goto out_no_root;
@@ -259,8 +323,9 @@ static int minix_fill_super(struct super
 	if (!(s->s_flags & MS_RDONLY)) {
 		if (sbi->s_version != MINIX_V3) /* s_state is now out from V3 sb */
 			ms->s_state &= ~MINIX_VALID_FS;
-		mark_buffer_dirty(bh);
+		mark_mblock_dirty(mblock);
 	}
+
 	if (!(sbi->s_mount_state & MINIX_VALID_FS))
 		printk("MINIX-fs: mounting unchecked file system, "
 			"running fsck is recommended\n");
@@ -282,9 +347,9 @@ out_no_bitmap:
 	printk("MINIX-fs: bad superblock or unable to read bitmaps\n");
 out_freemap:
 	for (i = 0; i < sbi->s_imap_blocks; i++)
-		brelse(sbi->s_imap[i]);
+		mblock_put(sbi->s_imap[i]);
 	for (i = 0; i < sbi->s_zmap_blocks; i++)
-		brelse(sbi->s_zmap[i]);
+		mblock_put(sbi->s_zmap[i]);
 	kfree(sbi->s_imap);
 	goto out_release;
 
@@ -304,7 +369,12 @@ out_no_fs:
 		printk("VFS: Can't find a Minix filesystem V1 | V2 | V3 "
 		       "on device %s.\n", s->s_id);
 out_release:
-	brelse(bh);
+	vunmap_mblock(mblock, offset, BLOCK_SIZE, ms);
+	mblock_put(mblock);
+	goto out;
+
+out_bad_fsblock:
+	/* XXX: leaky */
 	goto out;
 
 out_bad_hblock:
@@ -333,31 +403,31 @@ static int minix_statfs(struct dentry *d
 	return 0;
 }
 
-static int minix_get_block(struct inode *inode, sector_t block,
-		    struct buffer_head *bh_result, int create)
+static int minix_map_block(struct address_space *mapping,
+			struct fsblock *block, loff_t off, int create)
 {
-	if (INODE_VERSION(inode) == MINIX_V1)
-		return V1_minix_get_block(inode, block, bh_result, create);
+	if (INODE_VERSION(mapping->host) == MINIX_V1)
+		return V1_minix_map_block(mapping, block, off, create);
 	else
-		return V2_minix_get_block(inode, block, bh_result, create);
+		return V2_minix_map_block(mapping, block, off, create);
 }
 
 static int minix_writepage(struct page *page, struct writeback_control *wbc)
 {
-	return block_write_full_page(page, minix_get_block, wbc);
+	return fsblock_write_page(page, minix_map_block, wbc);
 }
 
 static int minix_readpage(struct file *file, struct page *page)
 {
-	return block_read_full_page(page,minix_get_block);
+	return fsblock_read_page(page, minix_map_block);
 }
 
 int __minix_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	return block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
-				minix_get_block);
+	return fsblock_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+				minix_map_block);
 }
 
 static int minix_write_begin(struct file *file, struct address_space *mapping,
@@ -368,18 +438,27 @@ static int minix_write_begin(struct file
 	return __minix_write_begin(file, mapping, pos, len, flags, pagep, fsdata);
 }
 
+int minix_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+{
+	return fsblock_page_mkwrite(vma, page, minix_map_block);
+}
+
 static sector_t minix_bmap(struct address_space *mapping, sector_t block)
 {
-	return generic_block_bmap(mapping,block,minix_get_block);
+	return fsblock_bmap(mapping, block, minix_map_block);
 }
 
 static const struct address_space_operations minix_aops = {
 	.readpage = minix_readpage,
 	.writepage = minix_writepage,
-	.sync_page = block_sync_page,
+//	.sync_page = block_sync_page,
 	.write_begin = minix_write_begin,
-	.write_end = generic_write_end,
-	.bmap = minix_bmap
+	.write_end = fsblock_write_end,
+	.bmap = minix_bmap,
+	.set_page_dirty = fsblock_set_page_dirty,
+	.invalidatepage = fsblock_invalidate_page,
+	.release = fsblock_release,
+	.sync = fsblock_sync,
 };
 
 static const struct inode_operations minix_symlink_inode_operations = {
@@ -411,12 +490,12 @@ void minix_set_inode(struct inode *inode
  */
 static struct inode *V1_minix_iget(struct inode *inode)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta *mblock;
 	struct minix_inode * raw_inode;
 	struct minix_inode_info *minix_inode = minix_i(inode);
 	int i;
 
-	raw_inode = minix_V1_raw_inode(inode->i_sb, inode->i_ino, &bh);
+	raw_inode = minix_V1_raw_inode(inode->i_sb, inode->i_ino, &mblock);
 	if (!raw_inode) {
 		iget_failed(inode);
 		return ERR_PTR(-EIO);
@@ -434,7 +513,7 @@ static struct inode *V1_minix_iget(struc
 	for (i = 0; i < 9; i++)
 		minix_inode->u.i1_data[i] = raw_inode->i_zone[i];
 	minix_set_inode(inode, old_decode_dev(raw_inode->i_zone[0]));
-	brelse(bh);
+	minix_put_raw_inode(inode->i_sb, inode->i_ino, mblock, raw_inode);
 	unlock_new_inode(inode);
 	return inode;
 }
@@ -444,12 +523,13 @@ static struct inode *V1_minix_iget(struc
  */
 static struct inode *V2_minix_iget(struct inode *inode)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta *mblock;
 	struct minix2_inode * raw_inode;
 	struct minix_inode_info *minix_inode = minix_i(inode);
 	int i;
+	ino_t ino = inode->i_ino;
 
-	raw_inode = minix_V2_raw_inode(inode->i_sb, inode->i_ino, &bh);
+	raw_inode = minix_V2_raw_inode(inode->i_sb, ino, &mblock);
 	if (!raw_inode) {
 		iget_failed(inode);
 		return ERR_PTR(-EIO);
@@ -469,7 +549,7 @@ static struct inode *V2_minix_iget(struc
 	for (i = 0; i < 10; i++)
 		minix_inode->u.i2_data[i] = raw_inode->i_zone[i];
 	minix_set_inode(inode, old_decode_dev(raw_inode->i_zone[0]));
-	brelse(bh);
+	minix2_put_raw_inode(inode->i_sb, ino, mblock, raw_inode);
 	unlock_new_inode(inode);
 	return inode;
 }
@@ -496,14 +576,14 @@ struct inode *minix_iget(struct super_bl
 /*
  * The minix V1 function to synchronize an inode.
  */
-static struct buffer_head * V1_minix_update_inode(struct inode * inode)
+static struct fsblock_meta * V1_minix_update_inode(struct inode * inode)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mblock;
 	struct minix_inode * raw_inode;
 	struct minix_inode_info *minix_inode = minix_i(inode);
 	int i;
 
-	raw_inode = minix_V1_raw_inode(inode->i_sb, inode->i_ino, &bh);
+	raw_inode = minix_V1_raw_inode(inode->i_sb, inode->i_ino, &mblock);
 	if (!raw_inode)
 		return NULL;
 	raw_inode->i_mode = inode->i_mode;
@@ -516,21 +596,23 @@ static struct buffer_head * V1_minix_upd
 		raw_inode->i_zone[0] = old_encode_dev(inode->i_rdev);
 	else for (i = 0; i < 9; i++)
 		raw_inode->i_zone[i] = minix_inode->u.i1_data[i];
-	mark_buffer_dirty(bh);
-	return bh;
+	mblock_get(mblock);
+	mark_mblock_dirty_inode(mblock, inode);
+	minix_put_raw_inode(inode->i_sb, inode->i_ino, mblock, raw_inode);
+	return mblock;
 }
 
 /*
  * The minix V2 function to synchronize an inode.
  */
-static struct buffer_head * V2_minix_update_inode(struct inode * inode)
+static struct fsblock_meta * V2_minix_update_inode(struct inode * inode)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mblock;
 	struct minix2_inode * raw_inode;
 	struct minix_inode_info *minix_inode = minix_i(inode);
 	int i;
 
-	raw_inode = minix_V2_raw_inode(inode->i_sb, inode->i_ino, &bh);
+	raw_inode = minix_V2_raw_inode(inode->i_sb, inode->i_ino, &mblock);
 	if (!raw_inode)
 		return NULL;
 	raw_inode->i_mode = inode->i_mode;
@@ -545,11 +627,13 @@ static struct buffer_head * V2_minix_upd
 		raw_inode->i_zone[0] = old_encode_dev(inode->i_rdev);
 	else for (i = 0; i < 10; i++)
 		raw_inode->i_zone[i] = minix_inode->u.i2_data[i];
-	mark_buffer_dirty(bh);
-	return bh;
+	mblock_get(mblock);
+	mark_mblock_dirty_inode(mblock, inode);
+	minix2_put_raw_inode(inode->i_sb, inode->i_ino, mblock, raw_inode);
+	return mblock;
 }
 
-static struct buffer_head *minix_update_inode(struct inode *inode)
+static struct fsblock_meta *minix_update_inode(struct inode *inode)
 {
 	if (INODE_VERSION(inode) == MINIX_V1)
 		return V1_minix_update_inode(inode);
@@ -559,29 +643,27 @@ static struct buffer_head *minix_update_
 
 static int minix_write_inode(struct inode * inode, int wait)
 {
-	brelse(minix_update_inode(inode));
+	mblock_put(minix_update_inode(inode));
 	return 0;
 }
 
 int minix_sync_inode(struct inode * inode)
 {
 	int err = 0;
-	struct buffer_head *bh;
+	struct fsblock_meta *mblock;
 
-	bh = minix_update_inode(inode);
-	if (bh && buffer_dirty(bh))
-	{
-		sync_dirty_buffer(bh);
-		if (buffer_req(bh) && !buffer_uptodate(bh))
-		{
+	mblock = minix_update_inode(inode);
+	if (mblock && (mblock_block(mblock)->flags & BL_dirty)) {
+		sync_block(mblock_block(mblock));
+		if (mblock_block(mblock)->flags & BL_error) {
 			printk("IO error syncing minix inode [%s:%08lx]\n",
 				inode->i_sb->s_id, inode->i_ino);
 			err = -1;
 		}
 	}
-	else if (!bh)
+	else if (!mblock)
 		err = -1;
-	brelse (bh);
+	mblock_put(mblock);
 	return err;
 }
 
Index: linux-2.6/fs/minix/file.c
===================================================================
--- linux-2.6.orig/fs/minix/file.c
+++ linux-2.6/fs/minix/file.c
@@ -6,22 +6,47 @@
  *  minix regular file handling primitives
  */
 
-#include <linux/buffer_head.h>		/* for fsync_inode_buffers() */
+#include <linux/fsblock.h>
 #include "minix.h"
 
+static struct vm_operations_struct minix_file_vm_ops = {
+	.fault		= filemap_fault,
+	.page_mkwrite	= minix_page_mkwrite,
+};
+
+static int minix_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	file_accessed(file);
+	vma->vm_ops = &minix_file_vm_ops;
+	return 0;
+}
+
+int minix_sync_file(struct file * file, struct dentry *dentry, int datasync)
+{
+	struct inode *inode = dentry->d_inode;
+	int err;
+
+	err = fsblock_sync(inode->i_mapping);
+	if (!(inode->i_state & I_DIRTY))
+		return err;
+	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
+		return err;
+
+	err |= minix_sync_inode(inode);
+	return err ? -EIO : 0;
+}
+
 /*
  * We have mostly NULLs here: the current defaults are OK for
  * the minix filesystem.
  */
-int minix_sync_file(struct file *, struct dentry *, int);
-
 const struct file_operations minix_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
 	.aio_read	= generic_file_aio_read,
 	.write		= do_sync_write,
 	.aio_write	= generic_file_aio_write,
-	.mmap		= generic_file_mmap,
+	.mmap		= minix_file_mmap,
 	.fsync		= minix_sync_file,
 	.splice_read	= generic_file_splice_read,
 };
@@ -31,17 +56,3 @@ const struct inode_operations minix_file
 	.getattr	= minix_getattr,
 };
 
-int minix_sync_file(struct file * file, struct dentry *dentry, int datasync)
-{
-	struct inode *inode = dentry->d_inode;
-	int err;
-
-	err = sync_mapping_buffers(inode->i_mapping);
-	if (!(inode->i_state & I_DIRTY))
-		return err;
-	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
-		return err;
-	
-	err |= minix_sync_inode(inode);
-	return err ? -EIO : 0;
-}
Index: linux-2.6/fs/minix/dir.c
===================================================================
--- linux-2.6.orig/fs/minix/dir.c
+++ linux-2.6/fs/minix/dir.c
@@ -55,7 +55,8 @@ static int dir_commit_chunk(struct page
 	struct address_space *mapping = page->mapping;
 	struct inode *dir = mapping->host;
 	int err = 0;
-	block_write_end(NULL, mapping, pos, len, len, page, NULL);
+
+	__fsblock_write_end(mapping, pos, len, len, page, NULL);
 
 	if (pos+len > dir->i_size) {
 		i_size_write(dir, pos+len);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
