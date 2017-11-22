Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0366B02B1
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so15510226pfp.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c2si14957027pli.451.2017.11.22.13.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 45/62] xfs: Convert pag_ici_root to XArray
Date: Wed, 22 Nov 2017 13:07:22 -0800
Message-Id: <20171122210739.29916-46-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename pag_ici_root to pag_ici_xa and use XArray APIs instead of radix
tree APIs.  Shorter code, typechecking on tag numbers, better error
checking in xfs_reclaim_inode(), and eliminates a call to
radix_tree_preload().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/xfs/libxfs/xfs_sb.c |   2 +-
 fs/xfs/libxfs/xfs_sb.h |   2 +-
 fs/xfs/xfs_icache.c    | 107 ++++++++++++++++++++-----------------------------
 fs/xfs/xfs_icache.h    |   4 +-
 fs/xfs/xfs_inode.c     |  24 ++++-------
 fs/xfs/xfs_mount.c     |   3 +-
 fs/xfs/xfs_mount.h     |   3 +-
 7 files changed, 57 insertions(+), 88 deletions(-)

diff --git a/fs/xfs/libxfs/xfs_sb.c b/fs/xfs/libxfs/xfs_sb.c
index 811fa57007c9..9345fad57db8 100644
--- a/fs/xfs/libxfs/xfs_sb.c
+++ b/fs/xfs/libxfs/xfs_sb.c
@@ -76,7 +76,7 @@ struct xfs_perag *
 xfs_perag_get_tag(
 	struct xfs_mount	*mp,
 	xfs_agnumber_t		first,
-	int			tag)
+	xa_tag_t		tag)
 {
 	XA_STATE(xas, first);
 	struct xfs_perag	*pag;
diff --git a/fs/xfs/libxfs/xfs_sb.h b/fs/xfs/libxfs/xfs_sb.h
index 961e6475a309..d2de90b8f39c 100644
--- a/fs/xfs/libxfs/xfs_sb.h
+++ b/fs/xfs/libxfs/xfs_sb.h
@@ -23,7 +23,7 @@
  */
 extern struct xfs_perag *xfs_perag_get(struct xfs_mount *, xfs_agnumber_t);
 extern struct xfs_perag *xfs_perag_get_tag(struct xfs_mount *, xfs_agnumber_t,
-					   int tag);
+					   xa_tag_t tag);
 extern void	xfs_perag_put(struct xfs_perag *pag);
 extern int	xfs_initialize_perag_data(struct xfs_mount *, xfs_agnumber_t);
 
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index f56e500d89e2..26f261ef708a 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -186,7 +186,7 @@ xfs_perag_set_reclaim_tag(
 {
 	struct xfs_mount	*mp = pag->pag_mount;
 
-	lockdep_assert_held(&pag->pag_ici_lock);
+	lockdep_assert_held(&pag->pag_ici_xa.xa_lock);
 	if (pag->pag_ici_reclaimable++)
 		return;
 
@@ -205,7 +205,7 @@ xfs_perag_clear_reclaim_tag(
 {
 	struct xfs_mount	*mp = pag->pag_mount;
 
-	lockdep_assert_held(&pag->pag_ici_lock);
+	lockdep_assert_held(&pag->pag_ici_xa.xa_lock);
 	if (--pag->pag_ici_reclaimable)
 		return;
 
@@ -228,16 +228,16 @@ xfs_inode_set_reclaim_tag(
 	struct xfs_perag	*pag;
 
 	pag = xfs_perag_get(mp, XFS_INO_TO_AGNO(mp, ip->i_ino));
-	spin_lock(&pag->pag_ici_lock);
+	xa_lock(&pag->pag_ici_xa);
 	spin_lock(&ip->i_flags_lock);
 
-	radix_tree_tag_set(&pag->pag_ici_root, XFS_INO_TO_AGINO(mp, ip->i_ino),
+	__xa_set_tag(&pag->pag_ici_xa, XFS_INO_TO_AGINO(mp, ip->i_ino),
 			   XFS_ICI_RECLAIM_TAG);
 	xfs_perag_set_reclaim_tag(pag);
 	__xfs_iflags_set(ip, XFS_IRECLAIMABLE);
 
 	spin_unlock(&ip->i_flags_lock);
-	spin_unlock(&pag->pag_ici_lock);
+	xa_unlock(&pag->pag_ici_xa);
 	xfs_perag_put(pag);
 }
 
@@ -246,7 +246,7 @@ xfs_inode_clear_reclaim_tag(
 	struct xfs_perag	*pag,
 	xfs_ino_t		ino)
 {
-	radix_tree_tag_clear(&pag->pag_ici_root,
+	__xa_clear_tag(&pag->pag_ici_xa,
 			     XFS_INO_TO_AGINO(pag->pag_mount, ino),
 			     XFS_ICI_RECLAIM_TAG);
 	xfs_perag_clear_reclaim_tag(pag);
@@ -367,8 +367,8 @@ xfs_iget_cache_hit(
 		/*
 		 * We need to set XFS_IRECLAIM to prevent xfs_reclaim_inode
 		 * from stomping over us while we recycle the inode.  We can't
-		 * clear the radix tree reclaimable tag yet as it requires
-		 * pag_ici_lock to be held exclusive.
+		 * clear the xarray reclaimable tag yet as it requires
+		 * pag_ici_xa.xa_lock to be held exclusive.
 		 */
 		ip->i_flags |= XFS_IRECLAIM;
 
@@ -393,7 +393,7 @@ xfs_iget_cache_hit(
 			goto out_error;
 		}
 
-		spin_lock(&pag->pag_ici_lock);
+		xa_lock(&pag->pag_ici_xa);
 		spin_lock(&ip->i_flags_lock);
 
 		/*
@@ -410,7 +410,7 @@ xfs_iget_cache_hit(
 		init_rwsem(&inode->i_rwsem);
 
 		spin_unlock(&ip->i_flags_lock);
-		spin_unlock(&pag->pag_ici_lock);
+		xa_unlock(&pag->pag_ici_xa);
 	} else {
 		/* If the VFS inode is being torn down, pause and try again. */
 		if (!igrab(inode)) {
@@ -451,7 +451,7 @@ xfs_iget_cache_miss(
 	int			flags,
 	int			lock_flags)
 {
-	struct xfs_inode	*ip;
+	struct xfs_inode	*ip, *curr;
 	int			error;
 	xfs_agino_t		agino = XFS_INO_TO_AGINO(mp, ino);
 	int			iflags;
@@ -471,17 +471,6 @@ xfs_iget_cache_miss(
 		goto out_destroy;
 	}
 
-	/*
-	 * Preload the radix tree so we can insert safely under the
-	 * write spinlock. Note that we cannot sleep inside the preload
-	 * region. Since we can be called from transaction context, don't
-	 * recurse into the file system.
-	 */
-	if (radix_tree_preload(GFP_NOFS)) {
-		error = -EAGAIN;
-		goto out_destroy;
-	}
-
 	/*
 	 * Because the inode hasn't been added to the radix-tree yet it can't
 	 * be found by another thread, so we can do the non-sleeping lock here.
@@ -509,23 +498,18 @@ xfs_iget_cache_miss(
 	xfs_iflags_set(ip, iflags);
 
 	/* insert the new inode */
-	spin_lock(&pag->pag_ici_lock);
-	error = radix_tree_insert(&pag->pag_ici_root, agino, ip);
-	if (unlikely(error)) {
-		WARN_ON(error != -EEXIST);
+	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
+	if (unlikely(curr)) {
+		WARN_ON(IS_ERR(curr));
 		XFS_STATS_INC(mp, xs_ig_dup);
 		error = -EAGAIN;
-		goto out_preload_end;
+		goto out_unlock;
 	}
-	spin_unlock(&pag->pag_ici_lock);
-	radix_tree_preload_end();
 
 	*ipp = ip;
 	return 0;
 
-out_preload_end:
-	spin_unlock(&pag->pag_ici_lock);
-	radix_tree_preload_end();
+out_unlock:
 	if (lock_flags)
 		xfs_iunlock(ip, lock_flags);
 out_destroy:
@@ -592,7 +576,7 @@ xfs_iget(
 again:
 	error = 0;
 	rcu_read_lock();
-	ip = radix_tree_lookup(&pag->pag_ici_root, agino);
+	ip = xa_load(&pag->pag_ici_xa, agino);
 
 	if (ip) {
 		error = xfs_iget_cache_hit(pag, ip, ino, flags, lock_flags);
@@ -731,7 +715,7 @@ xfs_inode_ag_walk(
 					   void *args),
 	int			flags,
 	void			*args,
-	int			tag,
+	xa_tag_t		tag,
 	int			iter_flags)
 {
 	uint32_t		first_index;
@@ -752,14 +736,13 @@ xfs_inode_ag_walk(
 
 		rcu_read_lock();
 
-		if (tag == -1)
-			nr_found = radix_tree_gang_lookup(&pag->pag_ici_root,
-					(void **)batch, first_index,
+		if (tag == XFS_ICI_NO_TAG)
+			nr_found = xa_get_entries(&pag->pag_ici_xa,
+					(void **)batch, first_index, ULONG_MAX,
 					XFS_LOOKUP_BATCH);
 		else
-			nr_found = radix_tree_gang_lookup_tag(
-					&pag->pag_ici_root,
-					(void **) batch, first_index,
+			nr_found = xa_get_tagged(&pag->pag_ici_xa,
+					(void **)batch, first_index, ULONG_MAX,
 					XFS_LOOKUP_BATCH, tag);
 
 		if (!nr_found) {
@@ -896,8 +879,8 @@ xfs_inode_ag_iterator_flags(
 	ag = 0;
 	while ((pag = xfs_perag_get(mp, ag))) {
 		ag = pag->pag_agno + 1;
-		error = xfs_inode_ag_walk(mp, pag, execute, flags, args, -1,
-					  iter_flags);
+		error = xfs_inode_ag_walk(mp, pag, execute, flags, args,
+					  XFS_ICI_NO_TAG, iter_flags);
 		xfs_perag_put(pag);
 		if (error) {
 			last_error = error;
@@ -926,7 +909,7 @@ xfs_inode_ag_iterator_tag(
 					   void *args),
 	int			flags,
 	void			*args,
-	int			tag)
+	xa_tag_t		tag)
 {
 	struct xfs_perag	*pag;
 	int			error = 0;
@@ -1040,8 +1023,9 @@ xfs_reclaim_inode(
 	int			sync_mode)
 {
 	struct xfs_buf		*bp = NULL;
-	xfs_ino_t		ino = ip->i_ino; /* for radix_tree_delete */
+	xfs_ino_t		ino = ip->i_ino;
 	int			error;
+	XA_STATE(xas, XFS_INO_TO_AGINO(ip->i_mount, ino));
 
 restart:
 	error = 0;
@@ -1128,16 +1112,14 @@ xfs_reclaim_inode(
 	/*
 	 * Remove the inode from the per-AG radix tree.
 	 *
-	 * Because radix_tree_delete won't complain even if the item was never
-	 * added to the tree assert that it's been there before to catch
-	 * problems with the inode life time early on.
+	 * Check that it was there before to catch problems with the
+	 * inode life time early on.
 	 */
-	spin_lock(&pag->pag_ici_lock);
-	if (!radix_tree_delete(&pag->pag_ici_root,
-				XFS_INO_TO_AGINO(ip->i_mount, ino)))
+	xa_lock(&pag->pag_ici_xa);
+	if (xas_store(&pag->pag_ici_xa, &xas, NULL) != ip)
 		ASSERT(0);
 	xfs_perag_clear_reclaim_tag(pag);
-	spin_unlock(&pag->pag_ici_lock);
+	xa_unlock(&pag->pag_ici_xa);
 
 	/*
 	 * Here we do an (almost) spurious inode lock in order to coordinate
@@ -1213,9 +1195,8 @@ xfs_reclaim_inodes_ag(
 			int	i;
 
 			rcu_read_lock();
-			nr_found = radix_tree_gang_lookup_tag(
-					&pag->pag_ici_root,
-					(void **)batch, first_index,
+			nr_found = xa_get_tagged(&pag->pag_ici_xa,
+					(void **)batch, first_index, ULONG_MAX,
 					XFS_LOOKUP_BATCH,
 					XFS_ICI_RECLAIM_TAG);
 			if (!nr_found) {
@@ -1450,7 +1431,7 @@ __xfs_icache_free_eofblocks(
 	struct xfs_eofblocks	*eofb,
 	int			(*execute)(struct xfs_inode *ip, int flags,
 					   void *args),
-	int			tag)
+	xa_tag_t		tag)
 {
 	int flags = SYNC_TRYLOCK;
 
@@ -1546,10 +1527,10 @@ __xfs_inode_set_eofblocks_tag(
 	spin_unlock(&ip->i_flags_lock);
 
 	pag = xfs_perag_get(mp, XFS_INO_TO_AGNO(mp, ip->i_ino));
-	spin_lock(&pag->pag_ici_lock);
+	xa_lock(&pag->pag_ici_xa);
 
-	tagged = radix_tree_tagged(&pag->pag_ici_root, tag);
-	radix_tree_tag_set(&pag->pag_ici_root,
+	tagged = xa_tagged(&pag->pag_ici_xa, tag);
+	__xa_set_tag(&pag->pag_ici_xa,
 			   XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino), tag);
 	if (!tagged) {
 		/* propagate the eofblocks tag up into the perag radix tree */
@@ -1563,7 +1544,7 @@ __xfs_inode_set_eofblocks_tag(
 		set_tp(ip->i_mount, pag->pag_agno, -1, _RET_IP_);
 	}
 
-	spin_unlock(&pag->pag_ici_lock);
+	xa_unlock(&pag->pag_ici_xa);
 	xfs_perag_put(pag);
 }
 
@@ -1592,11 +1573,11 @@ __xfs_inode_clear_eofblocks_tag(
 	spin_unlock(&ip->i_flags_lock);
 
 	pag = xfs_perag_get(mp, XFS_INO_TO_AGNO(mp, ip->i_ino));
-	spin_lock(&pag->pag_ici_lock);
+	xa_lock(&pag->pag_ici_xa);
 
-	radix_tree_tag_clear(&pag->pag_ici_root,
+	__xa_clear_tag(&pag->pag_ici_xa,
 			     XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino), tag);
-	if (!radix_tree_tagged(&pag->pag_ici_root, tag)) {
+	if (!xa_tagged(&pag->pag_ici_xa, tag)) {
 		/* clear the eofblocks tag from the perag radix tree */
 		xa_clear_tag(&ip->i_mount->m_perag_xa,
 				     XFS_INO_TO_AGNO(ip->i_mount, ip->i_ino),
@@ -1604,7 +1585,7 @@ __xfs_inode_clear_eofblocks_tag(
 		clear_tp(ip->i_mount, pag->pag_agno, -1, _RET_IP_);
 	}
 
-	spin_unlock(&pag->pag_ici_lock);
+	xa_unlock(&pag->pag_ici_xa);
 	xfs_perag_put(pag);
 }
 
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index bd04d5adadfe..436e7f0b1ecc 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -35,7 +35,7 @@ struct xfs_eofblocks {
 /*
  * tags for inode radix tree
  */
-#define XFS_ICI_NO_TAG		(-1)	/* special flag for an untagged lookup
+#define XFS_ICI_NO_TAG		XA_NO_TAG /* special flag for an untagged lookup
 					   in xfs_inode_ag_iterator */
 #define XFS_ICI_RECLAIM_TAG	XA_TAG_0 /* inode is to be reclaimed */
 #define XFS_ICI_EOFBLOCKS_TAG	XA_TAG_1 /* inode has blocks beyond EOF */
@@ -90,7 +90,7 @@ int xfs_inode_ag_iterator_flags(struct xfs_mount *mp,
 	int flags, void *args, int iter_flags);
 int xfs_inode_ag_iterator_tag(struct xfs_mount *mp,
 	int (*execute)(struct xfs_inode *ip, int flags, void *args),
-	int flags, void *args, int tag);
+	int flags, void *args, xa_tag_t tag);
 
 static inline int
 xfs_fs_eofblocks_from_user(
diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index 61d1cb7dc10d..661f0ac655fa 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -2309,7 +2309,7 @@ xfs_ifree_cluster(
 		for (i = 0; i < inodes_per_cluster; i++) {
 retry:
 			rcu_read_lock();
-			ip = radix_tree_lookup(&pag->pag_ici_root,
+			ip = xa_load(&pag->pag_ici_xa,
 					XFS_INO_TO_AGINO(mp, (inum + i)));
 
 			/* Inode not in memory, nothing to do */
@@ -3186,7 +3186,7 @@ xfs_iflush_cluster(
 {
 	struct xfs_mount	*mp = ip->i_mount;
 	struct xfs_perag	*pag;
-	unsigned long		first_index, mask;
+	unsigned long		first_index, last_index, mask;
 	unsigned long		inodes_per_cluster;
 	int			cilist_size;
 	struct xfs_inode	**cilist;
@@ -3204,12 +3204,12 @@ xfs_iflush_cluster(
 	if (!cilist)
 		goto out_put;
 
-	mask = ~(((mp->m_inode_cluster_size >> mp->m_sb.sb_inodelog)) - 1);
-	first_index = XFS_INO_TO_AGINO(mp, ip->i_ino) & mask;
+	mask = (((mp->m_inode_cluster_size >> mp->m_sb.sb_inodelog)) - 1);
+	first_index = XFS_INO_TO_AGINO(mp, ip->i_ino) & ~mask;
+	last_index = first_index | mask;
 	rcu_read_lock();
-	/* really need a gang lookup range call here */
-	nr_found = radix_tree_gang_lookup(&pag->pag_ici_root, (void**)cilist,
-					first_index, inodes_per_cluster);
+	nr_found = xa_get_entries(&pag->pag_ici_xa, (void**)cilist, first_index,
+					last_index, inodes_per_cluster);
 	if (nr_found == 0)
 		goto out_free;
 
@@ -3230,16 +3230,6 @@ xfs_iflush_cluster(
 			spin_unlock(&cip->i_flags_lock);
 			continue;
 		}
-
-		/*
-		 * Once we fall off the end of the cluster, no point checking
-		 * any more inodes in the list because they will also all be
-		 * outside the cluster.
-		 */
-		if ((XFS_INO_TO_AGINO(mp, cip->i_ino) & mask) != first_index) {
-			spin_unlock(&cip->i_flags_lock);
-			break;
-		}
 		spin_unlock(&cip->i_flags_lock);
 
 		/*
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index ae90f6f8fa5c..d5185657f030 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -210,9 +210,8 @@ xfs_initialize_perag(
 			goto out_unwind_new_pags;
 		pag->pag_agno = index;
 		pag->pag_mount = mp;
-		spin_lock_init(&pag->pag_ici_lock);
 		mutex_init(&pag->pag_ici_reclaim_lock);
-		INIT_RADIX_TREE(&pag->pag_ici_root, GFP_ATOMIC);
+		xa_init(&pag->pag_ici_xa);
 		if (xfs_buf_hash_init(pag))
 			goto out_free_pag;
 		init_waitqueue_head(&pag->pagb_wait);
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 6e5ad7b26f46..ab0f706d2fd7 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -374,8 +374,7 @@ typedef struct xfs_perag {
 
 	atomic_t        pagf_fstrms;    /* # of filestreams active in this AG */
 
-	spinlock_t	pag_ici_lock;	/* incore inode cache lock */
-	struct radix_tree_root pag_ici_root;	/* incore inode cache root */
+	struct xarray	pag_ici_xa;	/* incore inode cache */
 	int		pag_ici_reclaimable;	/* reclaimable inodes */
 	struct mutex	pag_ici_reclaim_lock;	/* serialisation point */
 	unsigned long	pag_ici_reclaim_cursor;	/* reclaim restart point */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
