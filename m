Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B39DB6B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 16:27:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m72so256291wmc.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 13:27:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t2si2038637edb.424.2017.11.02.13.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Nov 2017 13:27:31 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] fs: fuse: account fuse_inode slab memory as reclaimable
Date: Thu,  2 Nov 2017 16:27:27 -0400
Message-Id: <20171102202727.12539-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <mszeredi@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Fuse inodes are currently included in the unreclaimable slab counts -
SUnreclaim in /proc/meminfo, slab_unreclaimable in /proc/vmstat and
the per-cgroup memory.stat. But they are reclaimable just like other
filesystems' inodes, and /proc/sys/vm/drop_caches frees them easily.

Mark the slab cache reclaimable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/fuse/inode.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 94a745acaef8..5c0f0d689fb2 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1273,9 +1273,9 @@ static int __init fuse_fs_init(void)
 	int err;
 
 	fuse_inode_cachep = kmem_cache_create("fuse_inode",
-					      sizeof(struct fuse_inode), 0,
-					      SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
-					      fuse_inode_init_once);
+			sizeof(struct fuse_inode), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT|SLAB_RECLAIM_ACCOUNT,
+			fuse_inode_init_once);
 	err = -ENOMEM;
 	if (!fuse_inode_cachep)
 		goto out;
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
