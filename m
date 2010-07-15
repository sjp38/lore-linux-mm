Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 20A86620203
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 07:47:48 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 3/3] xfs: track AGs with reclaimable inodes in per-ag radix tree
Date: Thu, 15 Jul 2010 21:46:58 +1000
Message-Id: <1279194418-16119-4-git-send-email-david@fromorbit.com>
In-Reply-To: <1279194418-16119-1-git-send-email-david@fromorbit.com>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

https://bugzilla.kernel.org/show_bug.cgi?id=16348

When the filesystem grows to a large number of allocation groups,
the summing of recalimable inodes gets expensive. In many cases,
most AGs won't have any reclaimable inodes and so we are wasting CPU
time aggregating over these AGs. This is particularly important for
the inode shrinker that gets called frequently under memory
pressure.

To avoid the overhead, track AGs with reclaimable inodes in the
per-ag radix tree so that we can find all the AGs with reclaimable
inodes via a simple gang tag lookup. This involves setting the tag
when the first reclaimable inode is tracked in the AG, and removing
the tag when the last reclaimable inode is removed from the tree.
Then the summation process becomes a loop walking the radix tree
summing AGs with the reclaim tag set.

This significantly reduces the overhead of scanning - a 6400 AG
filesystea now only uses about 25% of a cpu in kswapd while slab
reclaim progresses instead of being permanently stuck at 100% CPU
and making little progress. Clean filesystems filesystems will see
no overhead and the overhead only increases linearly with the number
of dirty AGs.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_sync.c  |   71 +++++++++++++++++++++++++++++++++++++----
 fs/xfs/linux-2.6/xfs_trace.h |    3 ++
 2 files changed, 67 insertions(+), 7 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index f433819..a51a07c 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -144,6 +144,41 @@ restart:
 	return last_error;
 }
 
+/*
+ * Select the next per-ag structure to iterate during the walk. The reclaim
+ * walk is optimised only to walk AGs with reclaimable inodes in them.
+ */
+static struct xfs_perag *
+xfs_inode_ag_iter_next_pag(
+	struct xfs_mount	*mp,
+	xfs_agnumber_t		*first,
+	int			tag)
+{
+	struct xfs_perag	*pag = NULL;
+
+	if (tag == XFS_ICI_RECLAIM_TAG) {
+		int found;
+		int ref;
+
+		spin_lock(&mp->m_perag_lock);
+		found = radix_tree_gang_lookup_tag(&mp->m_perag_tree,
+				(void **)&pag, *first, 1, tag);
+		if (found <= 0) {
+			spin_unlock(&mp->m_perag_lock);
+			return NULL;
+		}
+		*first = pag->pag_agno + 1;
+		/* open coded pag reference increment */
+		ref = atomic_inc_return(&pag->pag_ref);
+		spin_unlock(&mp->m_perag_lock);
+		trace_xfs_perag_get_reclaim(mp, pag->pag_agno, ref, _RET_IP_);
+	} else {
+		pag = xfs_perag_get(mp, *first);
+		(*first)++;
+	}
+	return pag;
+}
+
 int
 xfs_inode_ag_iterator(
 	struct xfs_mount	*mp,
@@ -154,16 +189,15 @@ xfs_inode_ag_iterator(
 	int			exclusive,
 	int			*nr_to_scan)
 {
+	struct xfs_perag	*pag;
 	int			error = 0;
 	int			last_error = 0;
 	xfs_agnumber_t		ag;
 	int			nr;
 
 	nr = nr_to_scan ? *nr_to_scan : INT_MAX;
-	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
-		struct xfs_perag	*pag;
-
-		pag = xfs_perag_get(mp, ag);
+	ag = 0;
+	while ((pag = xfs_inode_ag_iter_next_pag(mp, &ag, tag))) {
 		error = xfs_inode_ag_walk(mp, pag, execute, flags, tag,
 						exclusive, &nr);
 		xfs_perag_put(pag);
@@ -640,6 +674,17 @@ __xfs_inode_set_reclaim_tag(
 	radix_tree_tag_set(&pag->pag_ici_root,
 			   XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino),
 			   XFS_ICI_RECLAIM_TAG);
+
+	if (!pag->pag_ici_reclaimable) {
+		/* propagate the reclaim tag up into the perag radix tree */
+		spin_lock(&ip->i_mount->m_perag_lock);
+		radix_tree_tag_set(&ip->i_mount->m_perag_tree,
+				XFS_INO_TO_AGNO(ip->i_mount, ip->i_ino),
+				XFS_ICI_RECLAIM_TAG);
+		spin_unlock(&ip->i_mount->m_perag_lock);
+		trace_xfs_perag_set_reclaim(ip->i_mount, pag->pag_agno,
+							-1, _RET_IP_);
+	}
 	pag->pag_ici_reclaimable++;
 }
 
@@ -674,6 +719,16 @@ __xfs_inode_clear_reclaim_tag(
 	radix_tree_tag_clear(&pag->pag_ici_root,
 			XFS_INO_TO_AGINO(mp, ip->i_ino), XFS_ICI_RECLAIM_TAG);
 	pag->pag_ici_reclaimable--;
+	if (!pag->pag_ici_reclaimable) {
+		/* clear the reclaim tag from the perag radix tree */
+		spin_lock(&ip->i_mount->m_perag_lock);
+		radix_tree_tag_clear(&ip->i_mount->m_perag_tree,
+				XFS_INO_TO_AGNO(ip->i_mount, ip->i_ino),
+				XFS_ICI_RECLAIM_TAG);
+		spin_unlock(&ip->i_mount->m_perag_lock);
+		trace_xfs_perag_clear_reclaim(ip->i_mount, pag->pag_agno,
+							-1, _RET_IP_);
+	}
 }
 
 /*
@@ -838,7 +893,7 @@ xfs_reclaim_inode_shrink(
 	struct xfs_mount *mp;
 	struct xfs_perag *pag;
 	xfs_agnumber_t	ag;
-	int		reclaimable = 0;
+	int		reclaimable;
 
 	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
 	if (nr_to_scan) {
@@ -852,8 +907,10 @@ xfs_reclaim_inode_shrink(
 			return -1;
        }
 
-	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
-		pag = xfs_perag_get(mp, ag);
+	reclaimable = 0;
+	ag = 0;
+	while ((pag = xfs_inode_ag_iter_next_pag(mp, &ag,
+					XFS_ICI_RECLAIM_TAG))) {
 		reclaimable += pag->pag_ici_reclaimable;
 		xfs_perag_put(pag);
 	}
diff --git a/fs/xfs/linux-2.6/xfs_trace.h b/fs/xfs/linux-2.6/xfs_trace.h
index 73d5aa1..3028206 100644
--- a/fs/xfs/linux-2.6/xfs_trace.h
+++ b/fs/xfs/linux-2.6/xfs_trace.h
@@ -124,7 +124,10 @@ DEFINE_EVENT(xfs_perag_class, name,	\
 		 unsigned long caller_ip),					\
 	TP_ARGS(mp, agno, refcount, caller_ip))
 DEFINE_PERAG_REF_EVENT(xfs_perag_get);
+DEFINE_PERAG_REF_EVENT(xfs_perag_get_reclaim);
 DEFINE_PERAG_REF_EVENT(xfs_perag_put);
+DEFINE_PERAG_REF_EVENT(xfs_perag_set_reclaim);
+DEFINE_PERAG_REF_EVENT(xfs_perag_clear_reclaim);
 
 TRACE_EVENT(xfs_attr_list_node_descend,
 	TP_PROTO(struct xfs_attr_list_context *ctx,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
