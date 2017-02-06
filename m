Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC1E6B0260
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:07:34 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so18730852wjd.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:34 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id x107si1043570wrb.294.2017.02.06.06.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:07:32 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id v77so22092119wmv.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:32 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
Date: Mon,  6 Feb 2017 15:07:16 +0100
Message-Id: <20170206140718.16222-5-mhocko@kernel.org>
In-Reply-To: <20170206140718.16222-1-mhocko@kernel.org>
References: <20170206140718.16222-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
index a76a05dae96b..0c9f94f41b6c 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -65,7 +65,7 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 void *
 kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 {
-	unsigned noio_flag = 0;
+	unsigned nofs_flag = 0;
 	void	*ptr;
 	gfp_t	lflags;
 
@@ -77,17 +77,17 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
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
index 8c7d01b75922..676a9ae75b9a 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -442,17 +442,17 @@ _xfs_buf_map_pages(
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
@@ -460,7 +460,7 @@ _xfs_buf_map_pages(
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
