Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 546A36B0078
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:54:02 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so10588047pdb.4
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:54:02 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ki10si8154225pdb.1.2015.01.08.02.54.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:54:00 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 9/9] fs: make shrinker memcg aware
Date: Thu, 8 Jan 2015 13:53:19 +0300
Message-ID: <0c7964c3143c16338565430656d5b2c197e0d946.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now, to make any list_lru-based shrinker memcg aware we should only
initialize its list_lru as memcg aware. Let's do it for the general FS
shrinker (super_block::s_shrink).

There are other FS-specific shrinkers that use list_lru for storing
objects, such as XFS and GFS2 dquot cache shrinkers, but since they
reclaim objects that are shared among different cgroups, there is no
point making them memcg aware. It's a big question whether we should
account them to memcg at all.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index b027849d92d2..482b4071f4de 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -189,9 +189,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	INIT_HLIST_BL_HEAD(&s->s_anon);
 	INIT_LIST_HEAD(&s->s_inodes);
 
-	if (list_lru_init(&s->s_dentry_lru))
+	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
-	if (list_lru_init(&s->s_inode_lru))
+	if (list_lru_init_memcg(&s->s_inode_lru))
 		goto fail;
 
 	init_rwsem(&s->s_umount);
@@ -227,7 +227,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
-	s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	return s;
 
 fail:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
