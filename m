Date: Thu, 15 Jul 2004 21:28:52 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.SGI.4.58.0407151125150.116400@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jul 2004, Brent Casavant wrote:
> 
> Hmm.  There's more of the same lurking in here.  I moved on to the next
> page fault scaling problem on the list, namely with SysV shared memory
> segments.  I'll give you one guess which cacheline is the culprit in that
> case.
> 
> Unless I'm mistaken, we don't need to track sbinfo for SysV segments
> either.  So my next task is to figure out how to turn on the SHMEM_NOSBINFO
> bit for that case as well.

You should find that you've already fixed that one with your first patch:
the shared writable /dev/zero mappings and the SysV shared memory live in
the same internal mount.  But if you find that the SysV shm is still a
problem with your patch, then either I'm confused or your patch is wrong.

By the way, just curious, but can you tell us what it is that is making
so much use of the shared writable /dev/zero mappings?  I thought they
were just an odd corner not used very much; ordinary anonymous memory
doesn't involve tmpfs objects.

And in earlier mail you wrote:
> 
> Oh, one thing you might want to double-check in my patch: I not
> only avoided updating free_blocks, but also i_blocks, since it
> was under the same lock and always updated at the same time as
> free_blocks.  I didn't see any problems with this from my testing,
> but I also wasn't 100% sure that was the correct thing to do.  If
> it's not correct we still have a problem as the i_blocks cacheline
> would then need to ping-pong around the machine.

You're okay to avoid updating i_blocks too: if you look at the simple
fs functions in fs/libfs.c (used by ramfs for one), you'll find that
it's acceptable for simple filesystems to leave i_blocks, like f_bfree
etc, unsupported at 0.  Though the i_blocks cacheline itself shouldn't
have been much of a problem, since it's per-inode not per-sb: your
problem would again be with the sbinfo cacheline we use to lock it
(and, if we did want to update i_blocks, that could easily be changed
to the shmem info lock instead: it was just convenient for me to update
it at the same time and under the same protection as free_blocks).

Your patch, by the way, seemed to be against 2.6.8-rc1 or 2.6.8-rc1-mm1
or recent bk: applied cleanly to those rather than 2.6.6 or 2.6.7.
So I've done my NULL sbinfo version below against that too.

This is really an agglommeration of several patches: NULL sbinfo based
on (but eliminating) your SHMEM_NOSBINFO; a holey file panic fix which
I sent Linus and lkml earlier on (which I wouldn't have found for weeks
if you hadn't prompted me to look again here: thank you!); and replacing
the shmem_inodes list of all by shmem_swaplist list of those which might
have pages on swap, a less significant scalability enhancement.  I'll
break it up into smaller patches when I come to submit it in a couple
of weeks.  I've done basic testing, but it will need more later on
(I'm unfamiliar with MS_NOUSER, not sure if my use of it is correct).
I'm as likely to find a 512P machine as a basilisk, so scalability
testing I leave to you.

I felt a little vulnerable, in making this scalability improvement
for the invisible internal mount, that next someone (you?) would
make the same complaint of the visible tmpfs mounts.  So now, if
you "mount -t tmpfs -o nr_blocks=0 -o nr_inodes=0 tmpfs /wherever",
the 0s will be interpreted to give a NULL-sbinfo unlimited mount.
Generally inadvisable (unless /proc/sys/vm/overcommit_memory 2 is
independently enforcing strict memory accounting), but useful to
have as a more scalable option.

Hugh

--- 2.6.8-rc1/mm/shmem.c	2004-07-11 21:59:42.000000000 +0100
+++ linux/mm/shmem.c	2004-07-15 17:08:56.529384032 +0100
@@ -179,16 +179,19 @@ static struct backing_dev_info shmem_bac
 	.unplug_io_fn = default_unplug_io_fn,
 };
 
-LIST_HEAD(shmem_inodes);
-static spinlock_t shmem_ilock = SPIN_LOCK_UNLOCKED;
+LIST_HEAD(shmem_swaplist);
+static spinlock_t shmem_swaplist_lock = SPIN_LOCK_UNLOCKED;
 
 static void shmem_free_block(struct inode *inode)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
-	spin_lock(&sbinfo->stat_lock);
-	sbinfo->free_blocks++;
-	inode->i_blocks -= BLOCKS_PER_PAGE;
-	spin_unlock(&sbinfo->stat_lock);
+
+	if (sbinfo) {
+		spin_lock(&sbinfo->stat_lock);
+		sbinfo->free_blocks++;
+		inode->i_blocks -= BLOCKS_PER_PAGE;
+		spin_unlock(&sbinfo->stat_lock);
+	}
 }
 
 /*
@@ -213,11 +216,13 @@ static void shmem_recalc_inode(struct in
 	if (freed > 0) {
 		struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 		info->alloced -= freed;
-		spin_lock(&sbinfo->stat_lock);
-		sbinfo->free_blocks += freed;
-		inode->i_blocks -= freed*BLOCKS_PER_PAGE;
-		spin_unlock(&sbinfo->stat_lock);
 		shmem_unacct_blocks(info->flags, freed);
+		if (sbinfo) {
+			spin_lock(&sbinfo->stat_lock);
+			sbinfo->free_blocks += freed;
+			inode->i_blocks -= freed*BLOCKS_PER_PAGE;
+			spin_unlock(&sbinfo->stat_lock);
+		}
 	}
 }
 
@@ -337,7 +342,6 @@ static swp_entry_t *shmem_swp_alloc(stru
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 	struct page *page = NULL;
 	swp_entry_t *entry;
-	static const swp_entry_t unswapped = { 0 };
 
 	if (sgp != SGP_WRITE &&
 	    ((loff_t) index << PAGE_CACHE_SHIFT) >= i_size_read(inode))
@@ -345,20 +349,22 @@ static swp_entry_t *shmem_swp_alloc(stru
 
 	while (!(entry = shmem_swp_entry(info, index, &page))) {
 		if (sgp == SGP_READ)
-			return (swp_entry_t *) &unswapped;
+			return shmem_swp_map(ZERO_PAGE(0));
 		/*
 		 * Test free_blocks against 1 not 0, since we have 1 data
 		 * page (and perhaps indirect index pages) yet to allocate:
 		 * a waste to allocate index if we cannot allocate data.
 		 */
-		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks <= 1) {
+		if (sbinfo) {
+			spin_lock(&sbinfo->stat_lock);
+			if (sbinfo->free_blocks <= 1) {
+				spin_unlock(&sbinfo->stat_lock);
+				return ERR_PTR(-ENOSPC);
+			}
+			sbinfo->free_blocks--;
+			inode->i_blocks += BLOCKS_PER_PAGE;
 			spin_unlock(&sbinfo->stat_lock);
-			return ERR_PTR(-ENOSPC);
 		}
-		sbinfo->free_blocks--;
-		inode->i_blocks += BLOCKS_PER_PAGE;
-		spin_unlock(&sbinfo->stat_lock);
 
 		spin_unlock(&info->lock);
 		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
@@ -599,17 +605,21 @@ static void shmem_delete_inode(struct in
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	if (inode->i_op->truncate == shmem_truncate) {
-		spin_lock(&shmem_ilock);
-		list_del(&info->list);
-		spin_unlock(&shmem_ilock);
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
 		shmem_truncate(inode);
+		if (!list_empty(&info->list)) {
+			spin_lock(&shmem_swaplist_lock);
+			list_del_init(&info->list);
+			spin_unlock(&shmem_swaplist_lock);
+		}
+	}
+	if (sbinfo) {
+		BUG_ON(inode->i_blocks);
+		spin_lock(&sbinfo->stat_lock);
+		sbinfo->free_inodes++;
+		spin_unlock(&sbinfo->stat_lock);
 	}
-	BUG_ON(inode->i_blocks);
-	spin_lock(&sbinfo->stat_lock);
-	sbinfo->free_inodes++;
-	spin_unlock(&sbinfo->stat_lock);
 	clear_inode(inode);
 }
 
@@ -714,22 +724,23 @@ found:
  */
 int shmem_unuse(swp_entry_t entry, struct page *page)
 {
-	struct list_head *p;
+	struct list_head *p, *next;
 	struct shmem_inode_info *info;
 	int found = 0;
 
-	spin_lock(&shmem_ilock);
-	list_for_each(p, &shmem_inodes) {
+	spin_lock(&shmem_swaplist_lock);
+	list_for_each_safe(p, next, &shmem_swaplist) {
 		info = list_entry(p, struct shmem_inode_info, list);
-
-		if (info->swapped && shmem_unuse_inode(info, entry, page)) {
+		if (!info->swapped)
+			list_del_init(&info->list);
+		else if (shmem_unuse_inode(info, entry, page)) {
 			/* move head to start search for next from here */
-			list_move_tail(&shmem_inodes, &info->list);
+			list_move_tail(&shmem_swaplist, &info->list);
 			found = 1;
 			break;
 		}
 	}
-	spin_unlock(&shmem_ilock);
+	spin_unlock(&shmem_swaplist_lock);
 	return found;
 }
 
@@ -771,6 +782,12 @@ static int shmem_writepage(struct page *
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
 		spin_unlock(&info->lock);
+		if (list_empty(&info->list)) {
+			spin_lock(&shmem_swaplist_lock);
+			/* move instead of add in case we're racing */
+			list_move_tail(&info->list, &shmem_swaplist);
+			spin_unlock(&shmem_swaplist_lock);
+		}
 		unlock_page(page);
 		return 0;
 	}
@@ -1002,16 +1019,23 @@ repeat:
 	} else {
 		shmem_swp_unmap(entry);
 		sbinfo = SHMEM_SB(inode->i_sb);
-		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks == 0 || shmem_acct_block(info->flags)) {
+		if (sbinfo) {
+			spin_lock(&sbinfo->stat_lock);
+			if (sbinfo->free_blocks == 0 ||
+			    shmem_acct_block(info->flags)) {
+				spin_unlock(&sbinfo->stat_lock);
+				spin_unlock(&info->lock);
+				error = -ENOSPC;
+				goto failed;
+			}
+			sbinfo->free_blocks--;
+			inode->i_blocks += BLOCKS_PER_PAGE;
 			spin_unlock(&sbinfo->stat_lock);
+		} else if (shmem_acct_block(info->flags)) {
 			spin_unlock(&info->lock);
 			error = -ENOSPC;
 			goto failed;
 		}
-		sbinfo->free_blocks--;
-		inode->i_blocks += BLOCKS_PER_PAGE;
-		spin_unlock(&sbinfo->stat_lock);
 
 		if (!filepage) {
 			spin_unlock(&info->lock);
@@ -1185,13 +1209,15 @@ shmem_get_inode(struct super_block *sb, 
 	struct shmem_inode_info *info;
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
 
-	spin_lock(&sbinfo->stat_lock);
-	if (!sbinfo->free_inodes) {
+	if (sbinfo) {
+		spin_lock(&sbinfo->stat_lock);
+		if (!sbinfo->free_inodes) {
+			spin_unlock(&sbinfo->stat_lock);
+			return NULL;
+		}
+		sbinfo->free_inodes--;
 		spin_unlock(&sbinfo->stat_lock);
-		return NULL;
 	}
-	sbinfo->free_inodes--;
-	spin_unlock(&sbinfo->stat_lock);
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -1206,6 +1232,7 @@ shmem_get_inode(struct super_block *sb, 
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
+		INIT_LIST_HEAD(&info->list);
  		mpol_shared_policy_init(&info->policy);
 		switch (mode & S_IFMT) {
 		default:
@@ -1214,9 +1241,6 @@ shmem_get_inode(struct super_block *sb, 
 		case S_IFREG:
 			inode->i_op = &shmem_inode_operations;
 			inode->i_fop = &shmem_file_operations;
-			spin_lock(&shmem_ilock);
-			list_add_tail(&info->list, &shmem_inodes);
-			spin_unlock(&shmem_ilock);
 			break;
 		case S_IFDIR:
 			inode->i_nlink++;
@@ -1232,27 +1256,27 @@ shmem_get_inode(struct super_block *sb, 
 	return inode;
 }
 
-static int shmem_set_size(struct shmem_sb_info *info,
+static int shmem_set_size(struct shmem_sb_info *sbinfo,
 			  unsigned long max_blocks, unsigned long max_inodes)
 {
 	int error;
 	unsigned long blocks, inodes;
 
-	spin_lock(&info->stat_lock);
-	blocks = info->max_blocks - info->free_blocks;
-	inodes = info->max_inodes - info->free_inodes;
+	spin_lock(&sbinfo->stat_lock);
+	blocks = sbinfo->max_blocks - sbinfo->free_blocks;
+	inodes = sbinfo->max_inodes - sbinfo->free_inodes;
 	error = -EINVAL;
 	if (max_blocks < blocks)
 		goto out;
 	if (max_inodes < inodes)
 		goto out;
 	error = 0;
-	info->max_blocks  = max_blocks;
-	info->free_blocks = max_blocks - blocks;
-	info->max_inodes  = max_inodes;
-	info->free_inodes = max_inodes - inodes;
+	sbinfo->max_blocks  = max_blocks;
+	sbinfo->free_blocks = max_blocks - blocks;
+	sbinfo->max_inodes  = max_inodes;
+	sbinfo->free_inodes = max_inodes - inodes;
 out:
-	spin_unlock(&info->stat_lock);
+	spin_unlock(&sbinfo->stat_lock);
 	return error;
 }
 
@@ -1508,13 +1532,16 @@ static int shmem_statfs(struct super_blo
 
 	buf->f_type = TMPFS_MAGIC;
 	buf->f_bsize = PAGE_CACHE_SIZE;
-	spin_lock(&sbinfo->stat_lock);
-	buf->f_blocks = sbinfo->max_blocks;
-	buf->f_bavail = buf->f_bfree = sbinfo->free_blocks;
-	buf->f_files = sbinfo->max_inodes;
-	buf->f_ffree = sbinfo->free_inodes;
-	spin_unlock(&sbinfo->stat_lock);
 	buf->f_namelen = NAME_MAX;
+	if (sbinfo) {
+		spin_lock(&sbinfo->stat_lock);
+		buf->f_blocks = sbinfo->max_blocks;
+		buf->f_bavail = buf->f_bfree = sbinfo->free_blocks;
+		buf->f_files = sbinfo->max_inodes;
+		buf->f_ffree = sbinfo->free_inodes;
+		spin_unlock(&sbinfo->stat_lock);
+	}
+	/* else leave those fields 0 like simple_statfs */
 	return 0;
 }
 
@@ -1655,9 +1682,6 @@ static int shmem_symlink(struct inode *d
 			return error;
 		}
 		inode->i_op = &shmem_symlink_inode_operations;
-		spin_lock(&shmem_ilock);
-		list_add_tail(&info->list, &shmem_inodes);
-		spin_unlock(&shmem_ilock);
 		kaddr = kmap_atomic(page, KM_USER0);
 		memcpy(kaddr, symname, len);
 		kunmap_atomic(kaddr, KM_USER0);
@@ -1786,11 +1810,21 @@ bad_val:
 static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
-	unsigned long max_blocks = sbinfo->max_blocks;
-	unsigned long max_inodes = sbinfo->max_inodes;
+	unsigned long max_blocks = 0;
+	unsigned long max_inodes = 0;
 
+	if (sbinfo) {
+		max_blocks = sbinfo->max_blocks;
+		max_inodes = sbinfo->max_inodes;
+	}
 	if (shmem_parse_options(data, NULL, NULL, NULL, &max_blocks, &max_inodes))
 		return -EINVAL;
+	/* Keep it simple: disallow limited <-> unlimited remount */
+	if ((max_blocks || max_inodes) == !sbinfo)
+		return -EINVAL;
+	/* But allow the pointless unlimited -> unlimited remount */
+	if (!sbinfo)
+		return 0;
 	return shmem_set_size(sbinfo, max_blocks, max_inodes);
 }
 #endif
@@ -1800,39 +1834,38 @@ static int shmem_fill_super(struct super
 {
 	struct inode *inode;
 	struct dentry *root;
-	unsigned long blocks, inodes;
+	unsigned long blocks = 0;
+	unsigned long inodes = 0;
 	int mode   = S_IRWXUGO | S_ISVTX;
 	uid_t uid = current->fsuid;
 	gid_t gid = current->fsgid;
-	struct shmem_sb_info *sbinfo;
+	struct shmem_sb_info *sbinfo = NULL;
 	int err = -ENOMEM;
 
-	sbinfo = kmalloc(sizeof(struct shmem_sb_info), GFP_KERNEL);
-	if (!sbinfo)
-		return -ENOMEM;
-	sb->s_fs_info = sbinfo;
-	memset(sbinfo, 0, sizeof(struct shmem_sb_info));
-
+#ifdef CONFIG_TMPFS
 	/*
 	 * Per default we only allow half of the physical ram per
-	 * tmpfs instance
+	 * tmpfs instance; but the internal instance is left unlimited.
 	 */
-	blocks = inodes = totalram_pages / 2;
+	if (!(sb->s_flags & MS_NOUSER))
+		blocks = inodes = totalram_pages / 2;
 
-#ifdef CONFIG_TMPFS
-	if (shmem_parse_options(data, &mode, &uid, &gid, &blocks, &inodes)) {
-		err = -EINVAL;
-		goto failed;
+	if (shmem_parse_options(data, &mode, &uid, &gid, &blocks, &inodes))
+		return -EINVAL;
+
+	if (blocks || inodes) {
+		sbinfo = kmalloc(sizeof(struct shmem_sb_info), GFP_KERNEL);
+		if (!sbinfo)
+			return -ENOMEM;
+		sb->s_fs_info = sbinfo;
+		spin_lock_init(&sbinfo->stat_lock);
+		sbinfo->max_blocks = blocks;
+		sbinfo->free_blocks = blocks;
+		sbinfo->max_inodes = inodes;
+		sbinfo->free_inodes = inodes;
 	}
-#else
-	sb->s_flags |= MS_NOUSER;
 #endif
 
-	spin_lock_init(&sbinfo->stat_lock);
-	sbinfo->max_blocks = blocks;
-	sbinfo->free_blocks = blocks;
-	sbinfo->max_inodes = inodes;
-	sbinfo->free_inodes = inodes;
 	sb->s_maxbytes = SHMEM_MAX_BYTES;
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1997,15 +2030,13 @@ static int __init init_tmpfs(void)
 #ifdef CONFIG_TMPFS
 	devfs_mk_dir("shm");
 #endif
-	shm_mnt = kern_mount(&tmpfs_fs_type);
+	shm_mnt = do_kern_mount(tmpfs_fs_type.name, MS_NOUSER,
+				tmpfs_fs_type.name, NULL);
 	if (IS_ERR(shm_mnt)) {
 		error = PTR_ERR(shm_mnt);
 		printk(KERN_ERR "Could not kern_mount tmpfs\n");
 		goto out1;
 	}
-
-	/* The internal instance should not do size checking */
-	shmem_set_size(SHMEM_SB(shm_mnt->mnt_sb), ULONG_MAX, ULONG_MAX);
 	return 0;
 
 out1:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
