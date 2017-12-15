Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48F416B02E8
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:07:32 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id n186so8001369ybc.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:07:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z32si1479702ywj.163.2017.12.15.14.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:07:31 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 71/78] xfs: Convert m_perag_tree to XArray
Date: Fri, 15 Dec 2017 14:04:43 -0800
Message-Id: <20171215220450.7899-72-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Getting rid of the m_perag_lock lets us also get rid of the call to
radix_tree_preload().  This is a relatively naive conversion; we could
improve performance over the radix tree implementation by passing around
xa_state pointers instead of indices, possibly at the expense of extending
rcu_read_lock() periods.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/xfs/libxfs/xfs_sb.c |  9 ++++-----
 fs/xfs/xfs_icache.c    | 35 +++++++++--------------------------
 fs/xfs/xfs_icache.h    |  6 +++---
 fs/xfs/xfs_mount.c     | 19 ++++---------------
 fs/xfs/xfs_mount.h     |  3 +--
 5 files changed, 21 insertions(+), 51 deletions(-)

diff --git a/fs/xfs/libxfs/xfs_sb.c b/fs/xfs/libxfs/xfs_sb.c
index 9b5aae2bcc0b..3b0b65eb8224 100644
--- a/fs/xfs/libxfs/xfs_sb.c
+++ b/fs/xfs/libxfs/xfs_sb.c
@@ -59,7 +59,7 @@ xfs_perag_get(
 	int			ref = 0;
 
 	rcu_read_lock();
-	pag = radix_tree_lookup(&mp->m_perag_tree, agno);
+	pag = xa_load(&mp->m_perag_xa, agno);
 	if (pag) {
 		ASSERT(atomic_read(&pag->pag_ref) >= 0);
 		ref = atomic_inc_return(&pag->pag_ref);
@@ -78,14 +78,13 @@ xfs_perag_get_tag(
 	xfs_agnumber_t		first,
 	int			tag)
 {
+	XA_STATE(xas, &mp->m_perag_xa, first);
 	struct xfs_perag	*pag;
-	int			found;
 	int			ref;
 
 	rcu_read_lock();
-	found = radix_tree_gang_lookup_tag(&mp->m_perag_tree,
-					(void **)&pag, first, 1, tag);
-	if (found <= 0) {
+	pag = xas_find_tag(&xas, ULONG_MAX, tag);
+	if (!pag) {
 		rcu_read_unlock();
 		return NULL;
 	}
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 43005fbe8b1e..f56e500d89e2 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -156,13 +156,10 @@ static void
 xfs_reclaim_work_queue(
 	struct xfs_mount        *mp)
 {
-
-	rcu_read_lock();
-	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_RECLAIM_TAG)) {
+	if (xa_tagged(&mp->m_perag_xa, XFS_ICI_RECLAIM_TAG)) {
 		queue_delayed_work(mp->m_reclaim_workqueue, &mp->m_reclaim_work,
 			msecs_to_jiffies(xfs_syncd_centisecs / 6 * 10));
 	}
-	rcu_read_unlock();
 }
 
 /*
@@ -194,10 +191,7 @@ xfs_perag_set_reclaim_tag(
 		return;
 
 	/* propagate the reclaim tag up into the perag radix tree */
-	spin_lock(&mp->m_perag_lock);
-	radix_tree_tag_set(&mp->m_perag_tree, pag->pag_agno,
-			   XFS_ICI_RECLAIM_TAG);
-	spin_unlock(&mp->m_perag_lock);
+	xa_set_tag(&mp->m_perag_xa, pag->pag_agno, XFS_ICI_RECLAIM_TAG);
 
 	/* schedule periodic background inode reclaim */
 	xfs_reclaim_work_queue(mp);
@@ -216,10 +210,7 @@ xfs_perag_clear_reclaim_tag(
 		return;
 
 	/* clear the reclaim tag from the perag radix tree */
-	spin_lock(&mp->m_perag_lock);
-	radix_tree_tag_clear(&mp->m_perag_tree, pag->pag_agno,
-			     XFS_ICI_RECLAIM_TAG);
-	spin_unlock(&mp->m_perag_lock);
+	xa_clear_tag(&mp->m_perag_xa, pag->pag_agno, XFS_ICI_RECLAIM_TAG);
 	trace_xfs_perag_clear_reclaim(mp, pag->pag_agno, -1, _RET_IP_);
 }
 
@@ -847,12 +838,10 @@ void
 xfs_queue_eofblocks(
 	struct xfs_mount *mp)
 {
-	rcu_read_lock();
-	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_EOFBLOCKS_TAG))
+	if (xa_tagged(&mp->m_perag_xa, XFS_ICI_EOFBLOCKS_TAG))
 		queue_delayed_work(mp->m_eofblocks_workqueue,
 				   &mp->m_eofblocks_work,
 				   msecs_to_jiffies(xfs_eofb_secs * 1000));
-	rcu_read_unlock();
 }
 
 void
@@ -874,12 +863,10 @@ STATIC void
 xfs_queue_cowblocks(
 	struct xfs_mount *mp)
 {
-	rcu_read_lock();
-	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_COWBLOCKS_TAG))
+	if (xa_tagged(&mp->m_perag_xa, XFS_ICI_COWBLOCKS_TAG))
 		queue_delayed_work(mp->m_eofblocks_workqueue,
 				   &mp->m_cowblocks_work,
 				   msecs_to_jiffies(xfs_cowb_secs * 1000));
-	rcu_read_unlock();
 }
 
 void
@@ -1542,7 +1529,7 @@ __xfs_inode_set_eofblocks_tag(
 	void		(*execute)(struct xfs_mount *mp),
 	void		(*set_tp)(struct xfs_mount *mp, xfs_agnumber_t agno,
 				  int error, unsigned long caller_ip),
-	int		tag)
+	xa_tag_t	tag)
 {
 	struct xfs_mount *mp = ip->i_mount;
 	struct xfs_perag *pag;
@@ -1566,11 +1553,9 @@ __xfs_inode_set_eofblocks_tag(
 			   XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino), tag);
 	if (!tagged) {
 		/* propagate the eofblocks tag up into the perag radix tree */
-		spin_lock(&ip->i_mount->m_perag_lock);
-		radix_tree_tag_set(&ip->i_mount->m_perag_tree,
+		xa_set_tag(&ip->i_mount->m_perag_xa,
 				   XFS_INO_TO_AGNO(ip->i_mount, ip->i_ino),
 				   tag);
-		spin_unlock(&ip->i_mount->m_perag_lock);
 
 		/* kick off background trimming */
 		execute(ip->i_mount);
@@ -1597,7 +1582,7 @@ __xfs_inode_clear_eofblocks_tag(
 	xfs_inode_t	*ip,
 	void		(*clear_tp)(struct xfs_mount *mp, xfs_agnumber_t agno,
 				    int error, unsigned long caller_ip),
-	int		tag)
+	xa_tag_t	tag)
 {
 	struct xfs_mount *mp = ip->i_mount;
 	struct xfs_perag *pag;
@@ -1613,11 +1598,9 @@ __xfs_inode_clear_eofblocks_tag(
 			     XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino), tag);
 	if (!radix_tree_tagged(&pag->pag_ici_root, tag)) {
 		/* clear the eofblocks tag from the perag radix tree */
-		spin_lock(&ip->i_mount->m_perag_lock);
-		radix_tree_tag_clear(&ip->i_mount->m_perag_tree,
+		xa_clear_tag(&ip->i_mount->m_perag_xa,
 				     XFS_INO_TO_AGNO(ip->i_mount, ip->i_ino),
 				     tag);
-		spin_unlock(&ip->i_mount->m_perag_lock);
 		clear_tp(ip->i_mount, pag->pag_agno, -1, _RET_IP_);
 	}
 
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index bff4d85e5498..bd04d5adadfe 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -37,9 +37,9 @@ struct xfs_eofblocks {
  */
 #define XFS_ICI_NO_TAG		(-1)	/* special flag for an untagged lookup
 					   in xfs_inode_ag_iterator */
-#define XFS_ICI_RECLAIM_TAG	0	/* inode is to be reclaimed */
-#define XFS_ICI_EOFBLOCKS_TAG	1	/* inode has blocks beyond EOF */
-#define XFS_ICI_COWBLOCKS_TAG	2	/* inode can have cow blocks to gc */
+#define XFS_ICI_RECLAIM_TAG	XA_TAG_0 /* inode is to be reclaimed */
+#define XFS_ICI_EOFBLOCKS_TAG	XA_TAG_1 /* inode has blocks beyond EOF */
+#define XFS_ICI_COWBLOCKS_TAG	XA_TAG_2 /* inode can have cow blocks to gc */
 
 /*
  * Flags for xfs_iget()
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index c879b517cc94..0541aeb8449c 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -156,9 +156,7 @@ xfs_free_perag(
 	struct xfs_perag *pag;
 
 	for (agno = 0; agno < mp->m_sb.sb_agcount; agno++) {
-		spin_lock(&mp->m_perag_lock);
-		pag = radix_tree_delete(&mp->m_perag_tree, agno);
-		spin_unlock(&mp->m_perag_lock);
+		pag = xa_erase(&mp->m_perag_xa, agno);
 		ASSERT(pag);
 		ASSERT(atomic_read(&pag->pag_ref) == 0);
 		xfs_buf_hash_destroy(pag);
@@ -219,19 +217,11 @@ xfs_initialize_perag(
 			goto out_free_pag;
 		init_waitqueue_head(&pag->pagb_wait);
 
-		if (radix_tree_preload(GFP_NOFS))
-			goto out_hash_destroy;
-
-		spin_lock(&mp->m_perag_lock);
-		if (radix_tree_insert(&mp->m_perag_tree, index, pag)) {
+		if (xa_store(&mp->m_perag_xa, index, pag, GFP_NOFS)) {
 			BUG();
-			spin_unlock(&mp->m_perag_lock);
-			radix_tree_preload_end();
 			error = -EEXIST;
 			goto out_hash_destroy;
 		}
-		spin_unlock(&mp->m_perag_lock);
-		radix_tree_preload_end();
 		/* first new pag is fully initialized */
 		if (first_initialised == NULLAGNUMBER)
 			first_initialised = index;
@@ -252,7 +242,7 @@ xfs_initialize_perag(
 out_unwind_new_pags:
 	/* unwind any prior newly initialized pags */
 	for (index = first_initialised; index < agcount; index++) {
-		pag = radix_tree_delete(&mp->m_perag_tree, index);
+		pag = xa_erase(&mp->m_perag_xa, index);
 		if (!pag)
 			break;
 		xfs_buf_hash_destroy(pag);
@@ -816,8 +806,7 @@ xfs_mountfs(
 	/*
 	 * Allocate and initialize the per-ag data.
 	 */
-	spin_lock_init(&mp->m_perag_lock);
-	INIT_RADIX_TREE(&mp->m_perag_tree, GFP_ATOMIC);
+	xa_init(&mp->m_perag_xa);
 	error = xfs_initialize_perag(mp, sbp->sb_agcount, &mp->m_maxagi);
 	if (error) {
 		xfs_warn(mp, "Failed per-ag init: %d", error);
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index e0792d036be2..6e5ad7b26f46 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -134,8 +134,7 @@ typedef struct xfs_mount {
 	xfs_extlen_t		m_ag_prealloc_blocks; /* reserved ag blocks */
 	uint			m_alloc_set_aside; /* space we can't use */
 	uint			m_ag_max_usable; /* max space per AG */
-	struct radix_tree_root	m_perag_tree;	/* per-ag accounting info */
-	spinlock_t		m_perag_lock;	/* lock for m_perag_tree */
+	struct xarray		m_perag_xa;	/* per-ag accounting info */
 	struct mutex		m_growlock;	/* growfs mutex */
 	int			m_fixedfsid[2];	/* unchanged for life of FS */
 	uint			m_dmevmask;	/* DMI events for this FS */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
