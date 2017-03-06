Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4DFE6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 13:41:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so216168228pgc.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 10:41:24 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y22si19840075pli.233.2017.03.06.10.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 10:41:23 -0800 (PST)
Date: Mon, 6 Mar 2017 10:41:09 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH] xfs: remove kmem_zalloc_greedy
Message-ID: <20170306184109.GC5280@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>

The sole remaining caller of kmem_zalloc_greedy is bulkstat, which uses
it to grab 1-4 pages for staging of inobt records.  The infinite loop in
the greedy allocation function is causing hangs[1] in generic/269, so
just get rid of the greedy allocator in favor of kmem_zalloc_large.
This makes bulkstat somewhat more likely to ENOMEM if there's really no
pages to spare, but eliminates a source of hangs.

[1] https://lkml.org/lkml/2017/2/28/832

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/kmem.c       |   18 ------------------
 fs/xfs/kmem.h       |    2 --
 fs/xfs/xfs_itable.c |   14 ++++++++------
 3 files changed, 8 insertions(+), 26 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 339c696..bb2beae 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -24,24 +24,6 @@
 #include "kmem.h"
 #include "xfs_message.h"
 
-/*
- * Greedy allocation.  May fail and may return vmalloced memory.
- */
-void *
-kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
-{
-	void		*ptr;
-	size_t		kmsize = maxsize;
-
-	while (!(ptr = vzalloc(kmsize))) {
-		if ((kmsize >>= 1) <= minsize)
-			kmsize = minsize;
-	}
-	if (ptr)
-		*size = kmsize;
-	return ptr;
-}
-
 void *
 kmem_alloc(size_t size, xfs_km_flags_t flags)
 {
diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index 689f746..f0fc84f 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -69,8 +69,6 @@ static inline void  kmem_free(const void *ptr)
 }
 
 
-extern void *kmem_zalloc_greedy(size_t *, size_t, size_t);
-
 static inline void *
 kmem_zalloc(size_t size, xfs_km_flags_t flags)
 {
diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
index 8b2150d..283e76c 100644
--- a/fs/xfs/xfs_itable.c
+++ b/fs/xfs/xfs_itable.c
@@ -362,7 +362,6 @@ xfs_bulkstat(
 	xfs_agino_t		agino;	/* inode # in allocation group */
 	xfs_agnumber_t		agno;	/* allocation group number */
 	xfs_btree_cur_t		*cur;	/* btree cursor for ialloc btree */
-	size_t			irbsize; /* size of irec buffer in bytes */
 	xfs_inobt_rec_incore_t	*irbuf;	/* start of irec buffer */
 	int			nirbuf;	/* size of irbuf */
 	int			ubcount; /* size of user's buffer */
@@ -389,11 +388,14 @@ xfs_bulkstat(
 	*ubcountp = 0;
 	*done = 0;
 
-	irbuf = kmem_zalloc_greedy(&irbsize, PAGE_SIZE, PAGE_SIZE * 4);
-	if (!irbuf)
-		return -ENOMEM;
-
-	nirbuf = irbsize / sizeof(*irbuf);
+	nirbuf = (PAGE_SIZE * 4) / sizeof(*irbuf);
+	irbuf = kmem_zalloc_large(PAGE_SIZE * 4, KM_SLEEP);
+	if (!irbuf) {
+		irbuf = kmem_zalloc_large(PAGE_SIZE, KM_SLEEP);
+		if (!irbuf)
+			return -ENOMEM;
+		nirbuf /= 4;
+	}
 
 	/*
 	 * Loop over the allocation groups, starting from the last

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
