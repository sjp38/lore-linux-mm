Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0AA6B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:04:22 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p49MoWB3008912
	for <linux-mm@kvack.org>; Mon, 9 May 2011 16:50:32 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p49N4E9r107796
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:04:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p49H4DOi012600
	for <linux-mm@kvack.org>; Mon, 9 May 2011 11:04:14 -0600
Subject: [PATCH 7/7] fat: Lock buffer_head during metadata updates
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Mon, 09 May 2011 16:04:11 -0700
Message-ID: <20110509230411.19566.66436.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

In order to stabilize page writes during writeback operations, it is necessary
to enforce a rule that writes to memory pages containing metadata cannot happen
at the same time that the page is being written to disk.  To provide this, lock
the buffer_head representing a piece of metadata while updating memory.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/fat/dir.c         |   14 ++++++++++++++
 fs/fat/fatent.c      |   12 ++++++++++++
 fs/fat/inode.c       |    2 ++
 fs/fat/misc.c        |    2 ++
 fs/fat/namei_msdos.c |    4 ++++
 fs/fat/namei_vfat.c  |    4 ++++
 6 files changed, 38 insertions(+), 0 deletions(-)


diff --git a/fs/fat/dir.c b/fs/fat/dir.c
index ee42b9e..9efea13 100644
--- a/fs/fat/dir.c
+++ b/fs/fat/dir.c
@@ -958,11 +958,13 @@ static int __fat_remove_entries(struct inode *dir, loff_t pos, int nr_slots)
 
 		orig_slots = nr_slots;
 		endp = (struct msdos_dir_entry *)(bh->b_data + sb->s_blocksize);
+		lock_buffer(bh);
 		while (nr_slots && de < endp) {
 			de->name[0] = DELETED_FLAG;
 			de++;
 			nr_slots--;
 		}
+		unlock_buffer(bh);
 		mark_buffer_dirty_inode(bh, dir);
 		if (IS_DIRSYNC(dir))
 			err = sync_dirty_buffer(bh);
@@ -992,11 +994,13 @@ int fat_remove_entries(struct inode *dir, struct fat_slot_info *sinfo)
 	sinfo->de = NULL;
 	bh = sinfo->bh;
 	sinfo->bh = NULL;
+	lock_buffer(bh);
 	while (nr_slots && de >= (struct msdos_dir_entry *)bh->b_data) {
 		de->name[0] = DELETED_FLAG;
 		de--;
 		nr_slots--;
 	}
+	unlock_buffer(bh);
 	mark_buffer_dirty_inode(bh, dir);
 	if (IS_DIRSYNC(dir))
 		err = sync_dirty_buffer(bh);
@@ -1045,7 +1049,9 @@ static int fat_zeroed_cluster(struct inode *dir, sector_t blknr, int nr_used,
 			err = -ENOMEM;
 			goto error;
 		}
+		lock_buffer(bhs[n]);
 		memset(bhs[n]->b_data, 0, sb->s_blocksize);
+		unlock_buffer(bhs[n]);
 		set_buffer_uptodate(bhs[n]);
 		mark_buffer_dirty_inode(bhs[n], dir);
 
@@ -1103,6 +1109,7 @@ int fat_alloc_new_dir(struct inode *dir, struct timespec *ts)
 	fat_time_unix2fat(sbi, ts, &time, &date, &time_cs);
 
 	de = (struct msdos_dir_entry *)bhs[0]->b_data;
+	lock_buffer(bhs[0]);
 	/* filling the new directory slots ("." and ".." entries) */
 	memcpy(de[0].name, MSDOS_DOT, MSDOS_NAME);
 	memcpy(de[1].name, MSDOS_DOTDOT, MSDOS_NAME);
@@ -1126,6 +1133,7 @@ int fat_alloc_new_dir(struct inode *dir, struct timespec *ts)
 	de[1].starthi = cpu_to_le16(MSDOS_I(dir)->i_logstart >> 16);
 	de[0].size = de[1].size = 0;
 	memset(de + 2, 0, sb->s_blocksize - 2 * sizeof(*de));
+	unlock_buffer(bhs[0]);
 	set_buffer_uptodate(bhs[0]);
 	mark_buffer_dirty_inode(bhs[0], dir);
 
@@ -1185,7 +1193,9 @@ static int fat_add_new_entries(struct inode *dir, void *slots, int nr_slots,
 
 			/* fill the directory entry */
 			copy = min(size, sb->s_blocksize);
+			lock_buffer(bhs[n]);
 			memcpy(bhs[n]->b_data, slots, copy);
+			unlock_buffer(bhs[n]);
 			slots += copy;
 			size -= copy;
 			set_buffer_uptodate(bhs[n]);
@@ -1288,7 +1298,9 @@ found:
 		/* Fill the long name slots. */
 		for (i = 0; i < long_bhs; i++) {
 			int copy = min_t(int, sb->s_blocksize - offset, size);
+			lock_buffer(bhs[i]);
 			memcpy(bhs[i]->b_data + offset, slots, copy);
+			unlock_buffer(bhs[i]);
 			mark_buffer_dirty_inode(bhs[i], dir);
 			offset = 0;
 			slots += copy;
@@ -1299,7 +1311,9 @@ found:
 		if (!err && i < nr_bhs) {
 			/* Fill the short name slot. */
 			int copy = min_t(int, sb->s_blocksize - offset, size);
+			lock_buffer(bhs[i]);
 			memcpy(bhs[i]->b_data + offset, slots, copy);
+			unlock_buffer(bhs[i]);
 			mark_buffer_dirty_inode(bhs[i], dir);
 			if (IS_DIRSYNC(dir))
 				err = sync_dirty_buffer(bhs[i]);
diff --git a/fs/fat/fatent.c b/fs/fat/fatent.c
index b47d2c9..e49a9dd 100644
--- a/fs/fat/fatent.c
+++ b/fs/fat/fatent.c
@@ -160,6 +160,9 @@ static void fat12_ent_put(struct fat_entry *fatent, int new)
 	if (new == FAT_ENT_EOF)
 		new = EOF_FAT12;
 
+	lock_buffer(fatent->bhs[0]);
+	if (fatent->nr_bhs == 2)
+		lock_buffer(fatent->bhs[1]);
 	spin_lock(&fat12_entry_lock);
 	if (fatent->entry & 1) {
 		*ent12_p[0] = (new << 4) | (*ent12_p[0] & 0x0f);
@@ -169,6 +172,9 @@ static void fat12_ent_put(struct fat_entry *fatent, int new)
 		*ent12_p[1] = (*ent12_p[1] & 0xf0) | (new >> 8);
 	}
 	spin_unlock(&fat12_entry_lock);
+	if (fatent->nr_bhs == 2)
+		unlock_buffer(fatent->bhs[1]);
+	unlock_buffer(fatent->bhs[0]);
 
 	mark_buffer_dirty_inode(fatent->bhs[0], fatent->fat_inode);
 	if (fatent->nr_bhs == 2)
@@ -180,7 +186,9 @@ static void fat16_ent_put(struct fat_entry *fatent, int new)
 	if (new == FAT_ENT_EOF)
 		new = EOF_FAT16;
 
+	lock_buffer(fatent->bhs[0]);
 	*fatent->u.ent16_p = cpu_to_le16(new);
+	unlock_buffer(fatent->bhs[0]);
 	mark_buffer_dirty_inode(fatent->bhs[0], fatent->fat_inode);
 }
 
@@ -191,7 +199,9 @@ static void fat32_ent_put(struct fat_entry *fatent, int new)
 
 	WARN_ON(new & 0xf0000000);
 	new |= le32_to_cpu(*fatent->u.ent32_p) & ~0x0fffffff;
+	lock_buffer(fatent->bhs[0]);
 	*fatent->u.ent32_p = cpu_to_le32(new);
+	unlock_buffer(fatent->bhs[0]);
 	mark_buffer_dirty_inode(fatent->bhs[0], fatent->fat_inode);
 }
 
@@ -382,7 +392,9 @@ static int fat_mirror_bhs(struct super_block *sb, struct buffer_head **bhs,
 				err = -ENOMEM;
 				goto error;
 			}
+			lock_buffer(c_bh);
 			memcpy(c_bh->b_data, bhs[n]->b_data, sb->s_blocksize);
+			unlock_buffer(c_bh);
 			set_buffer_uptodate(c_bh);
 			mark_buffer_dirty_inode(c_bh, sbi->fat_inode);
 			if (sb->s_flags & MS_SYNCHRONOUS)
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 8d68690..96da554 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -623,6 +623,7 @@ retry:
 		       "for updating (i_pos %lld)\n", i_pos);
 		return -EIO;
 	}
+	lock_buffer(bh);
 	spin_lock(&sbi->inode_hash_lock);
 	if (i_pos != MSDOS_I(inode)->i_pos) {
 		spin_unlock(&sbi->inode_hash_lock);
@@ -649,6 +650,7 @@ retry:
 				  &raw_entry->adate, NULL);
 	}
 	spin_unlock(&sbi->inode_hash_lock);
+	unlock_buffer(bh);
 	mark_buffer_dirty(bh);
 	err = 0;
 	if (wait)
diff --git a/fs/fat/misc.c b/fs/fat/misc.c
index 970e682..3386d81 100644
--- a/fs/fat/misc.c
+++ b/fs/fat/misc.c
@@ -70,10 +70,12 @@ int fat_clusters_flush(struct super_block *sb)
 		       le32_to_cpu(fsinfo->signature2),
 		       sbi->fsinfo_sector);
 	} else {
+		lock_buffer(bh);
 		if (sbi->free_clusters != -1)
 			fsinfo->free_clusters = cpu_to_le32(sbi->free_clusters);
 		if (sbi->prev_free != -1)
 			fsinfo->next_cluster = cpu_to_le32(sbi->prev_free);
+		unlock_buffer(bh);
 		mark_buffer_dirty(bh);
 	}
 	brelse(bh);
diff --git a/fs/fat/namei_msdos.c b/fs/fat/namei_msdos.c
index 7114990..cb53c8f 100644
--- a/fs/fat/namei_msdos.c
+++ b/fs/fat/namei_msdos.c
@@ -540,8 +540,10 @@ static int do_msdos_rename(struct inode *old_dir, unsigned char *old_name,
 
 	if (update_dotdot) {
 		int start = MSDOS_I(new_dir)->i_logstart;
+		lock_buffer(dotdot_bh);
 		dotdot_de->start = cpu_to_le16(start);
 		dotdot_de->starthi = cpu_to_le16(start >> 16);
+		unlock_buffer(dotdot_bh);
 		mark_buffer_dirty_inode(dotdot_bh, old_inode);
 		if (IS_DIRSYNC(new_dir)) {
 			err = sync_dirty_buffer(dotdot_bh);
@@ -582,8 +584,10 @@ error_dotdot:
 
 	if (update_dotdot) {
 		int start = MSDOS_I(old_dir)->i_logstart;
+		lock_buffer(dotdot_bh);
 		dotdot_de->start = cpu_to_le16(start);
 		dotdot_de->starthi = cpu_to_le16(start >> 16);
+		unlock_buffer(dotdot_bh);
 		mark_buffer_dirty_inode(dotdot_bh, old_inode);
 		corrupt |= sync_dirty_buffer(dotdot_bh);
 	}
diff --git a/fs/fat/namei_vfat.c b/fs/fat/namei_vfat.c
index adae3fb..f7e43f4 100644
--- a/fs/fat/namei_vfat.c
+++ b/fs/fat/namei_vfat.c
@@ -978,8 +978,10 @@ static int vfat_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 	if (update_dotdot) {
 		int start = MSDOS_I(new_dir)->i_logstart;
+		lock_buffer(dotdot_bh);
 		dotdot_de->start = cpu_to_le16(start);
 		dotdot_de->starthi = cpu_to_le16(start >> 16);
+		unlock_buffer(dotdot_bh);
 		mark_buffer_dirty_inode(dotdot_bh, old_inode);
 		if (IS_DIRSYNC(new_dir)) {
 			err = sync_dirty_buffer(dotdot_bh);
@@ -1022,8 +1024,10 @@ error_dotdot:
 
 	if (update_dotdot) {
 		int start = MSDOS_I(old_dir)->i_logstart;
+		lock_buffer(dotdot_bh);
 		dotdot_de->start = cpu_to_le16(start);
 		dotdot_de->starthi = cpu_to_le16(start >> 16);
+		unlock_buffer(dotdot_bh);
 		mark_buffer_dirty_inode(dotdot_bh, old_inode);
 		corrupt |= sync_dirty_buffer(dotdot_bh);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
