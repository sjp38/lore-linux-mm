Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [192.48.203.135])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id i6EJRS0f000905
	for <linux-mm@kvack.org>; Wed, 14 Jul 2004 14:27:28 -0500
Received: from kzerza.americas.sgi.com (kzerza.americas.sgi.com [128.162.233.27])
	by flecktone.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id i6EJRROW42243044
	for <linux-mm@kvack.org>; Wed, 14 Jul 2004 14:27:27 -0500 (CDT)
Date: Wed, 14 Jul 2004 14:27:27 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: [PATCH] /dev/zero page fault scaling
Message-ID: <Pine.SGI.4.58.0407141418280.115007@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As discussed earlier this week on the linux-mm list, there are some
scaling issues with the sbinfo stat_lock in mm/shmem.c.  In particular,
bouncing the corresponding cache-line between CPUs in a large machine
causes a dramatic slowdown in page fault performance.

However, the superblock statistics being kept for the /dev/zero use
of this code are unnecessary, and I don't even think there's a way
to obtain them.  The attached patch causes the relevant sections of
code to skip the locks and statistic updates for /dev/zero, causing
a significant speedup.

In a test program to measure the page fault performance, at 256P we
see a 150x improvement in the number of page faults per cpu per
wall-clock second (and other similar measures).  Page fault performance
drops by about 50% at 512P compared to 256P, however this is likely
a seperate problem (investigation has not started), but is still
138x better than before these changes.

I'm not sure if this list is the appropriate place to submit these
changes.  If not, please direct me to the correct lists/people to
submit this to.  The patch is against 2.6.(something recent, maybe 7).

Signed-off-by: Brent Casavant <bcasavan@sgi.com>

--- linux.orig/mm/shmem.c	2004-07-13 17:20:34.000000000 -0500
+++ linux/mm/shmem.c	2004-07-13 17:09:32.000000000 -0500
@@ -60,6 +60,7 @@
 /* info->flags needs VM_flags to handle pagein/truncate races efficiently */
 #define SHMEM_PAGEIN	 VM_READ
 #define SHMEM_TRUNCATE	 VM_WRITE
+#define SHMEM_NOSBINFO	 VM_EXEC

 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
@@ -185,6 +186,9 @@
 static void shmem_free_block(struct inode *inode)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (SHMEM_I(inode)->flags & SHMEM_NOSBINFO)
+		return;
 	spin_lock(&sbinfo->stat_lock);
 	sbinfo->free_blocks++;
 	inode->i_blocks -= BLOCKS_PER_PAGE;
@@ -213,11 +217,14 @@
 	if (freed > 0) {
 		struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 		info->alloced -= freed;
+		shmem_unacct_blocks(info->flags, freed);
+
+		if (info->flags & SHMEM_NOSBINFO)
+			return;
 		spin_lock(&sbinfo->stat_lock);
 		sbinfo->free_blocks += freed;
 		inode->i_blocks -= freed*BLOCKS_PER_PAGE;
 		spin_unlock(&sbinfo->stat_lock);
-		shmem_unacct_blocks(info->flags, freed);
 	}
 }

@@ -351,14 +358,16 @@
 		 * page (and perhaps indirect index pages) yet to allocate:
 		 * a waste to allocate index if we cannot allocate data.
 		 */
-		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks <= 1) {
+		if (!(info->flags & SHMEM_NOSBINFO)) {
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
@@ -1002,16 +1005,24 @@
 	} else {
 		shmem_swp_unmap(entry);
 		sbinfo = SHMEM_SB(inode->i_sb);
-		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks == 0 || shmem_acct_block(info->flags)) {
+		if (!(info->flags & SHMEM_NOSBINFO)) {
+			spin_lock(&sbinfo->stat_lock);
+			if (sbinfo->free_blocks == 0 || shmem_acct_block(info->flags)) {
+				spin_unlock(&sbinfo->stat_lock);
+				spin_unlock(&info->lock);
+				error = -ENOSPC;
+				goto failed;
+			}
+			sbinfo->free_blocks--;
+			inode->i_blocks += BLOCKS_PER_PAGE;
 			spin_unlock(&sbinfo->stat_lock);
-			spin_unlock(&info->lock);
-			error = -ENOSPC;
-			goto failed;
+		} else {
+			if (shmem_acct_block(info->flags)) {
+				spin_unlock(&info->lock);
+				error = -ENOSPC;
+				goto failed;
+			}
 		}
-		sbinfo->free_blocks--;
-		inode->i_blocks += BLOCKS_PER_PAGE;
-		spin_unlock(&sbinfo->stat_lock);

 		if (!filepage) {
 			spin_unlock(&info->lock);
@@ -2032,6 +2049,7 @@
 	struct inode *inode;
 	struct dentry *dentry, *root;
 	struct qstr this;
+	struct shmem_inode_info *info;

 	if (IS_ERR(shm_mnt))
 		return (void *)shm_mnt;
@@ -2061,7 +2079,11 @@
 	if (!inode)
 		goto close_file;

-	SHMEM_I(inode)->flags = flags & VM_ACCOUNT;
+	info = SHMEM_I(inode);
+	info->flags = flags & VM_ACCOUNT;
+	if (0 == strcmp("dev/zero", name)) {
+		info->flags |= SHMEM_NOSBINFO;
+	}
 	d_instantiate(dentry, inode);
 	inode->i_size = size;
 	inode->i_nlink = 0;	/* It is unlinked */

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
