Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82F546B038D
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:14:26 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so65495551wrg.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:14:26 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w4si14560163wme.115.2017.03.06.05.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:14:25 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id n11so13687819wma.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:14:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/7] xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
Date: Mon,  6 Mar 2017 14:14:06 +0100
Message-Id: <20170306131408.9828-6-mhocko@kernel.org>
In-Reply-To: <20170306131408.9828-1-mhocko@kernel.org>
References: <20170306131408.9828-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Brian Foster <bfoster@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

kmem_zalloc_large and _xfs_buf_map_pages use memalloc_noio_{save,restore}
API to prevent from reclaim recursion into the fs because vmalloc can
invoke unconditional GFP_KERNEL allocations and these functions might be
called from the NOFS contexts. The memalloc_noio_save will enforce
GFP_NOIO context which is even weaker than GFP_NOFS and that seems to be
unnecessary. Let's use memalloc_nofs_{save,restore} instead as it should
provide exactly what we need here - implicit GFP_NOFS context.

Changes since v1
- s@memalloc_noio_restore@memalloc_nofs_restore@ in _xfs_buf_map_pages
  as per Brian Foster

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Brian Foster <bfoster@redhat.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c    | 12 ++++++------
 fs/xfs/xfs_buf.c |  8 ++++----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index e14da724a0b5..6b7b04468aa8 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -66,7 +66,7 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 void *
 kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 {
-	unsigned noio_flag = 0;
+	unsigned nofs_flag = 0;
 	void	*ptr;
 	gfp_t	lflags;
 
@@ -78,17 +78,17 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 	 * __vmalloc() will allocate data pages and auxillary structures (e.g.
 	 * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
 	 * here. Hence we need to tell memory reclaim that we are in such a
-	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
+	 * context via PF_MEMALLOC_NOFS to prevent memory reclaim re-entering
 	 * the filesystem here and potentially deadlocking.
 	 */
-	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
-		noio_flag = memalloc_noio_save();
+	if (flags & KM_NOFS)
+		nofs_flag = memalloc_nofs_save();
 
 	lflags = kmem_flags_convert(flags);
 	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
 
-	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
-		memalloc_noio_restore(noio_flag);
+	if (flags & KM_NOFS)
+		memalloc_nofs_restore(nofs_flag);
 
 	return ptr;
 }
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index b6208728ba39..ca09061369cb 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -443,17 +443,17 @@ _xfs_buf_map_pages(
 		bp->b_addr = NULL;
 	} else {
 		int retried = 0;
-		unsigned noio_flag;
+		unsigned nofs_flag;
 
 		/*
 		 * vm_map_ram() will allocate auxillary structures (e.g.
 		 * pagetables) with GFP_KERNEL, yet we are likely to be under
 		 * GFP_NOFS context here. Hence we need to tell memory reclaim
-		 * that we are in such a context via PF_MEMALLOC_NOIO to prevent
+		 * that we are in such a context via PF_MEMALLOC_NOFS to prevent
 		 * memory reclaim re-entering the filesystem here and
 		 * potentially deadlocking.
 		 */
-		noio_flag = memalloc_noio_save();
+		nofs_flag = memalloc_nofs_save();
 		do {
 			bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
 						-1, PAGE_KERNEL);
@@ -461,7 +461,7 @@ _xfs_buf_map_pages(
 				break;
 			vm_unmap_aliases();
 		} while (retried++ <= 1);
-		memalloc_noio_restore(noio_flag);
+		memalloc_nofs_restore(nofs_flag);
 
 		if (!bp->b_addr)
 			return -ENOMEM;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
