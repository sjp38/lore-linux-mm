Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8625D6B0026
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:44:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h11so3401648pfn.0
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:44:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i64-v6si4826966pli.78.2018.03.21.15.44.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 15:44:46 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH 2/3] fs: use memalloc_nofs API while shrinking superblock
Date: Wed, 21 Mar 2018 17:44:28 -0500
Message-Id: <20180321224429.15860-3-rgoldwyn@suse.de>
In-Reply-To: <20180321224429.15860-1-rgoldwyn@suse.de>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

The superblock shrinkers are responsible for pruning dcache and icache.
which evicts the inode by calling into local filesystem code. Protect
allocations under memalloc_nofs_save/restore().

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 fs/super.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index 672538ca9831..26fc2679118d 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -35,6 +35,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <linux/sched/mm.h>
 #include "internal.h"
 
 
@@ -63,6 +64,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	long	freed = 0;
 	long	dentries;
 	long	inodes;
+	unsigned flags;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
@@ -70,9 +72,11 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
 	 * to recurse into the FS that called us in clear_inode() and friends..
 	 */
-	if (!(sc->gfp_mask & __GFP_FS))
+	if (!(sc->gfp_mask & __GFP_FS) || (current->flags & PF_MEMALLOC_NOFS))
 		return SHRINK_STOP;
 
+	flags = memalloc_nofs_save();
+
 	if (!trylock_super(sb))
 		return SHRINK_STOP;
 
@@ -107,6 +111,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 		freed += sb->s_op->free_cached_objects(sb, sc);
 	}
 
+	memalloc_nofs_restore(flags);
 	up_read(&sb->s_umount);
 	return freed;
 }
-- 
2.16.2
