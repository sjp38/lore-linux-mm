Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF056B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 19:35:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y17so31433127pgh.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 16:35:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u2si1485071plk.164.2017.03.07.16.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 16:35:39 -0800 (PST)
Date: Tue, 7 Mar 2017 16:35:28 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH v2] xfs: remove kmem_zalloc_greedy
Message-ID: <20170308003528.GK5280@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>

The sole remaining caller of kmem_zalloc_greedy is bulkstat, which uses
it to grab 1-4 pages for staging of inobt records.  The infinite loop in
the greedy allocation function is causing hangs[1] in generic/269, so
just get rid of the greedy allocator in favor of kmem_zalloc_large.
This makes bulkstat somewhat more likely to ENOMEM if there's really no
pages to spare, but eliminates a source of hangs.

[1] http://lkml.kernel.org/r/20170301044634.rgidgdqqiiwsmfpj%40XZHOUW.usersys.redhat.com

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
v2: remove single-page fallback
---
 fs/xfs/kmem.c       |   18 ------------------
 fs/xfs/kmem.h       |    2 --
 fs/xfs/xfs_itable.c |    6 ++----
 3 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 2dfdc62..70a5b55 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -25,24 +25,6 @@
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
index 8b2150d..e775f78 100644
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
@@ -389,11 +388,10 @@ xfs_bulkstat(
 	*ubcountp = 0;
 	*done = 0;
 
-	irbuf = kmem_zalloc_greedy(&irbsize, PAGE_SIZE, PAGE_SIZE * 4);
+	irbuf = kmem_zalloc_large(PAGE_SIZE * 4, KM_SLEEP);
 	if (!irbuf)
 		return -ENOMEM;
-
-	nirbuf = irbsize / sizeof(*irbuf);
+	nirbuf = (PAGE_SIZE * 4) / sizeof(*irbuf);
 
 	/*
 	 * Loop over the allocation groups, starting from the last

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
