Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B021D6B003B
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:32:04 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so10176895pab.33
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:32:04 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dt16si8622774pdb.237.2014.07.28.02.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 02:32:03 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 5/6] fs: make shrinker memcg aware
Date: Mon, 28 Jul 2014 13:31:27 +0400
Message-ID: <7fe5b4cbc8263a3d284b3056c6cd995724da50ce.1406536261.git.vdavydov@parallels.com>
In-Reply-To: <cover.1406536261.git.vdavydov@parallels.com>
References: <cover.1406536261.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, david@fromorbit.com, viro@zeniv.linux.org.uk, gthelen@google.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now, to make any list_lru-based shrinker memcg aware we should only
initialize its list_lru as memcg-enabled. Let's do it for the general FS
shrinker (super_block::s_shrink) and mark it as memcg aware.

There are other FS-specific shrinkers that use list_lru for storing
objects, such as XFS and GFS2 dquot cache shrinkers, but since they
reclaim objects that are shared among different cgroups, there is no
point making them memcg aware.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 477102d59c7e..2e5ed2b51b37 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/cleancache.h>
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 
@@ -187,9 +188,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	INIT_HLIST_BL_HEAD(&s->s_anon);
 	INIT_LIST_HEAD(&s->s_inodes);
 
-	if (list_lru_init(&s->s_dentry_lru, false))
+	if (list_lru_init(&s->s_dentry_lru, true))
 		goto fail;
-	if (list_lru_init(&s->s_inode_lru, false))
+	if (list_lru_init(&s->s_inode_lru, true))
 		goto fail;
 
 	init_rwsem(&s->s_umount);
@@ -225,7 +226,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
-	s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	return s;
 
 fail:
@@ -280,6 +281,16 @@ void deactivate_locked_super(struct super_block *s)
 		unregister_shrinker(&s->s_shrink);
 		fs->kill_sb(s);
 
+		/*
+		 * list_lru_destroy() may sleep on memcg-aware lrus. Since
+		 * put_super() calls destroy_super() under a spin lock, we must
+		 * unregister lrus from memcg here to avoid sleeping in atomic
+		 * context. It's safe, because by the time we get here, lrus
+		 * must be empty.
+		 */
+		memcg_unregister_list_lru(&s->s_dentry_lru);
+		memcg_unregister_list_lru(&s->s_inode_lru);
+
 		put_filesystem(fs);
 		put_super(s);
 	} else {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
