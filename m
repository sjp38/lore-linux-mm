Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 97CB76B0087
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:17 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 14/15 v2] ext4: make punch hole code path work with bigalloc
Date: Fri, 31 Aug 2012 18:21:50 -0400
Message-Id: <1346451711-1931-15-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>

Currently punch hole is disabled in file systems with bigalloc
feature enabled. However the recent changes in punch hole patch should
make it easier to support punching holes on bigalloc enabled file
systems.

This commit changes partial_cluster handling in ext4_remove_blocks(),
ext4_ext_rm_leaf() and ext4_ext_remove_space(). Currently
partial_cluster is unsigned long long type and it makes sure that we
will free the partial cluster if all extents has been released from that
cluster. However it has been specifically designed only for truncate.

With punch hole we can be freeing just some extents in the cluster
leaving the rest untouched. So we have to make sure that we will notice
cluster which still has some extents. To do this I've changed
partial_cluster to be signed long long type. The only scenario where
this could be a problem is when cluster_size == block size, however in
that case there would not be any partial clusters so we're safe. For
bigger clusters the signed type is enough. Now we use the negative value
in partial_cluster to mark such cluster used, hence we know that we must
not free it even if all other extents has been freed from such cluster.

This scenario can be described in simple diagram:

|FFF...FF..FF.UUU|
 ^----------^
  punch hole

. - free space
| - cluster boundary
F - freed extent
U - used extent

Also update respective tracepoints to use signed long long type for
partial_cluster.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/extents.c           |   69 +++++++++++++++++++++++++++++++-----------
 include/trace/events/ext4.h |   25 ++++++++-------
 2 files changed, 64 insertions(+), 30 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 83be6ad..f4805fd 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -2268,7 +2268,7 @@ int ext4_ext_index_trans_blocks(struct inode *inode, int nrblocks, int chunk)
 
 static int ext4_remove_blocks(handle_t *handle, struct inode *inode,
 			      struct ext4_extent *ex,
-			      ext4_fsblk_t *partial_cluster,
+			      signed long long *partial_cluster,
 			      ext4_lblk_t from, ext4_lblk_t to)
 {
 	struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
@@ -2294,7 +2294,8 @@ static int ext4_remove_blocks(handle_t *handle, struct inode *inode,
 	 * partial cluster here.
 	 */
 	pblk = ext4_ext_pblock(ex) + ee_len - 1;
-	if (*partial_cluster && (EXT4_B2C(sbi, pblk) != *partial_cluster)) {
+	if ((*partial_cluster > 0) &&
+	    (EXT4_B2C(sbi, pblk) != *partial_cluster)) {
 		ext4_free_blocks(handle, inode, NULL,
 				 EXT4_C2B(sbi, *partial_cluster),
 				 sbi->s_cluster_ratio, flags);
@@ -2320,23 +2321,41 @@ static int ext4_remove_blocks(handle_t *handle, struct inode *inode,
 	    && to == le32_to_cpu(ex->ee_block) + ee_len - 1) {
 		/* tail removal */
 		ext4_lblk_t num;
+		unsigned int unaligned;
 
 		num = le32_to_cpu(ex->ee_block) + ee_len - from;
 		pblk = ext4_ext_pblock(ex) + ee_len - num;
-		ext_debug("free last %u blocks starting %llu\n", num, pblk);
+		/*
+		 * Usually we want to free partial cluster at the end of the
+		 * extent, except for the situation when the cluster is still
+		 * used by any other extent (partial_cluster is negative).
+		 */
+		if (*partial_cluster < 0 &&
+		    -(*partial_cluster) == EXT4_B2C(sbi, pblk + num - 1))
+			flags |= EXT4_FREE_BLOCKS_NOFREE_LAST_CLUSTER;
+
+		ext_debug("free last %u blocks starting %llu partial %lld\n",
+			  num, pblk, *partial_cluster);
 		ext4_free_blocks(handle, inode, NULL, pblk, num, flags);
 		/*
 		 * If the block range to be freed didn't start at the
 		 * beginning of a cluster, and we removed the entire
-		 * extent, save the partial cluster here, since we
-		 * might need to delete if we determine that the
-		 * truncate operation has removed all of the blocks in
-		 * the cluster.
+		 * extent and the cluster is not used by any other extent,
+		 * save the partial cluster here, since we might need to
+		 * delete if we determine that the truncate operation has
+		 * removed all of the blocks in the cluster.
+		 *
+		 * On the other hand, if we did not manage to free the whole
+		 * extent, we have to mark the cluster as used (store negative
+		 * cluster number in partial_cluster).
 		 */
-		if (pblk & (sbi->s_cluster_ratio - 1) &&
-		    (ee_len == num))
+		unaligned = pblk & (sbi->s_cluster_ratio - 1);
+		if (unaligned && (ee_len == num) &&
+		    (*partial_cluster != -((long long)EXT4_B2C(sbi, pblk))))
 			*partial_cluster = EXT4_B2C(sbi, pblk);
-		else
+		else if (unaligned)
+			*partial_cluster = -((long long)EXT4_B2C(sbi, pblk));
+		else if (*partial_cluster > 0)
 			*partial_cluster = 0;
 	} else
 		ext4_error(sbi->s_sb, "strange request: removal(2) "
@@ -2354,12 +2373,16 @@ static int ext4_remove_blocks(handle_t *handle, struct inode *inode,
  * @handle: The journal handle
  * @inode:  The files inode
  * @path:   The path to the leaf
+ * @partial_cluster: The cluster which we'll have to free if all extents
+ *                   has been released from it. It gets negative in case
+ *                   that the cluster is still used.
  * @start:  The first block to remove
  * @end:   The last block to remove
  */
 static int
 ext4_ext_rm_leaf(handle_t *handle, struct inode *inode,
-		 struct ext4_ext_path *path, ext4_fsblk_t *partial_cluster,
+		 struct ext4_ext_path *path,
+		 signed long long *partial_cluster,
 		 ext4_lblk_t start, ext4_lblk_t end)
 {
 	struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
@@ -2372,6 +2395,7 @@ ext4_ext_rm_leaf(handle_t *handle, struct inode *inode,
 	unsigned short ex_ee_len;
 	unsigned uninitialized = 0;
 	struct ext4_extent *ex;
+	ext4_fsblk_t pblk;
 
 	/* the header must be checked already in ext4_ext_remove_space() */
 	ext_debug("truncate since %u in leaf to %u\n", start, end);
@@ -2410,6 +2434,16 @@ ext4_ext_rm_leaf(handle_t *handle, struct inode *inode,
 
 		/* If this extent is beyond the end of the hole, skip it */
 		if (end < ex_ee_block) {
+			/*
+			 * We're going to skip this extent and move to another,
+			 * so if this extent is not cluster aligned we have
+			 * to mark the current cluster as used to avoid
+			 * accidentally freeing it later on
+			 */
+			pblk = ext4_ext_pblock(ex);
+			if (pblk & (sbi->s_cluster_ratio - 1))
+				*partial_cluster =
+					-((long long)EXT4_B2C(sbi, pblk));
 			ex--;
 			ex_ee_block = le32_to_cpu(ex->ee_block);
 			ex_ee_len = ext4_ext_get_actual_len(ex);
@@ -2485,7 +2519,7 @@ ext4_ext_rm_leaf(handle_t *handle, struct inode *inode,
 					sizeof(struct ext4_extent));
 			}
 			le16_add_cpu(&eh->eh_entries, -1);
-		} else
+		} else if (*partial_cluster > 0)
 			*partial_cluster = 0;
 
 		err = ext4_ext_dirty(handle, inode, path + depth);
@@ -2503,11 +2537,10 @@ ext4_ext_rm_leaf(handle_t *handle, struct inode *inode,
 		err = ext4_ext_correct_indexes(handle, inode, path);
 
 	/*
-	 * If there is still a entry in the leaf node, check to see if
-	 * it references the partial cluster.  This is the only place
-	 * where it could; if it doesn't, we can free the cluster.
+	 * Free the partial cluster only if the current extent does not
+	 * reference it. Otherwise we might free used cluster.
 	 */
-	if (*partial_cluster && ex >= EXT_FIRST_EXTENT(eh) &&
+	if (*partial_cluster > 0 &&
 	    (EXT4_B2C(sbi, ext4_ext_pblock(ex) + ex_ee_len - 1) !=
 	     *partial_cluster)) {
 		int flags = EXT4_FREE_BLOCKS_FORGET;
@@ -2557,7 +2590,7 @@ static int ext4_ext_remove_space(struct inode *inode, ext4_lblk_t start,
 	struct super_block *sb = inode->i_sb;
 	int depth = ext_depth(inode);
 	struct ext4_ext_path *path = NULL;
-	ext4_fsblk_t partial_cluster = 0;
+	signed long long partial_cluster = 0;
 	handle_t *handle;
 	int i = 0, err;
 
@@ -2741,7 +2774,7 @@ cont:
 	/* If we still have something in the partial cluster and we have removed
 	 * even the first extent, then we should free the blocks in the partial
 	 * cluster as well. */
-	if (partial_cluster && path->p_hdr->eh_entries == 0) {
+	if (partial_cluster > 0 && path->p_hdr->eh_entries == 0) {
 		int flags = EXT4_FREE_BLOCKS_FORGET;
 
 		if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
diff --git a/include/trace/events/ext4.h b/include/trace/events/ext4.h
index ed461d7..4b3a8e9 100644
--- a/include/trace/events/ext4.h
+++ b/include/trace/events/ext4.h
@@ -1900,7 +1900,7 @@ TRACE_EVENT(ext4_ext_show_extent,
 TRACE_EVENT(ext4_remove_blocks,
 	    TP_PROTO(struct inode *inode, struct ext4_extent *ex,
 		ext4_lblk_t from, ext4_fsblk_t to,
-		ext4_fsblk_t partial_cluster),
+		long long int partial_cluster),
 
 	TP_ARGS(inode, ex, from, to, partial_cluster),
 
@@ -1912,7 +1912,7 @@ TRACE_EVENT(ext4_remove_blocks,
 		__field(	unsigned short,	ee_len	)
 		__field(	ext4_lblk_t,	from	)
 		__field(	ext4_lblk_t,	to	)
-		__field(	ext4_fsblk_t,	partial	)
+		__field(	long long int,	partial	)
 	),
 
 	TP_fast_assign(
@@ -1927,7 +1927,7 @@ TRACE_EVENT(ext4_remove_blocks,
 	),
 
 	TP_printk("dev %d,%d ino %lu extent [%u(%llu), %u]"
-		  "from %u to %u partial_cluster %u",
+		  "from %u to %u partial_cluster %lld",
 		  MAJOR(__entry->dev), MINOR(__entry->dev),
 		  (unsigned long) __entry->ino,
 		  (unsigned) __entry->ee_lblk,
@@ -1935,12 +1935,13 @@ TRACE_EVENT(ext4_remove_blocks,
 		  (unsigned short) __entry->ee_len,
 		  (unsigned) __entry->from,
 		  (unsigned) __entry->to,
-		  (unsigned) __entry->partial)
+		  (long long int) __entry->partial)
 );
 
 TRACE_EVENT(ext4_ext_rm_leaf,
 	TP_PROTO(struct inode *inode, ext4_lblk_t start,
-		 struct ext4_extent *ex, ext4_fsblk_t partial_cluster),
+		 struct ext4_extent *ex,
+		 long long int partial_cluster),
 
 	TP_ARGS(inode, start, ex, partial_cluster),
 
@@ -1951,7 +1952,7 @@ TRACE_EVENT(ext4_ext_rm_leaf,
 		__field(	ext4_lblk_t,	ee_lblk	)
 		__field(	ext4_fsblk_t,	ee_pblk	)
 		__field(	short,		ee_len	)
-		__field(	ext4_fsblk_t,	partial	)
+		__field(	long long int,	partial	)
 	),
 
 	TP_fast_assign(
@@ -1965,14 +1966,14 @@ TRACE_EVENT(ext4_ext_rm_leaf,
 	),
 
 	TP_printk("dev %d,%d ino %lu start_lblk %u last_extent [%u(%llu), %u]"
-		  "partial_cluster %u",
+		  "partial_cluster %lld",
 		  MAJOR(__entry->dev), MINOR(__entry->dev),
 		  (unsigned long) __entry->ino,
 		  (unsigned) __entry->start,
 		  (unsigned) __entry->ee_lblk,
 		  (unsigned long long) __entry->ee_pblk,
 		  (unsigned short) __entry->ee_len,
-		  (unsigned) __entry->partial)
+		  (long long int) __entry->partial)
 );
 
 TRACE_EVENT(ext4_ext_rm_idx,
@@ -2030,7 +2031,7 @@ TRACE_EVENT(ext4_ext_remove_space,
 
 TRACE_EVENT(ext4_ext_remove_space_done,
 	TP_PROTO(struct inode *inode, ext4_lblk_t start, ext4_lblk_t end,
-		 int depth, ext4_lblk_t partial, unsigned short eh_entries),
+		 int depth, long long int partial, unsigned short eh_entries),
 
 	TP_ARGS(inode, start, end, depth, partial, eh_entries),
 
@@ -2040,7 +2041,7 @@ TRACE_EVENT(ext4_ext_remove_space_done,
 		__field(	ext4_lblk_t,	start		)
 		__field(	ext4_lblk_t,	end		)
 		__field(	int,		depth		)
-		__field(	ext4_lblk_t,	partial		)
+		__field(	long long int,	partial		)
 		__field(	unsigned short,	eh_entries	)
 	),
 
@@ -2054,14 +2055,14 @@ TRACE_EVENT(ext4_ext_remove_space_done,
 		__entry->eh_entries	= eh_entries;
 	),
 
-	TP_printk("dev %d,%d ino %lu start %u end %u depth %d partial %u "
+	TP_printk("dev %d,%d ino %lu start %u end %u depth %d partial %lld "
 		  "remaining_entries %u",
 		  MAJOR(__entry->dev), MINOR(__entry->dev),
 		  (unsigned long) __entry->ino,
 		  (unsigned) __entry->start,
 		  (unsigned) __entry->end,
 		  __entry->depth,
-		  (unsigned) __entry->partial,
+		  (long long int) __entry->partial,
 		  (unsigned short) __entry->eh_entries)
 );
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
