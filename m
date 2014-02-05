Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id D16786B004D
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:43 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so647945lbv.10
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:43 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id n3si15535445lae.79.2014.02.05.10.39.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:41 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 10/13] fs: make shrinker memcg aware
Date: Wed, 5 Feb 2014 22:39:26 +0400
Message-ID: <b876ce42d48db8b68fc6b29dd4f1fddc4f5ac949.1391624021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391624021.git.vdavydov@parallels.com>
References: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Al Viro <viro@zeniv.linux.org.uk>

Now, to make any list_lru-based shrinker memcg aware we should only
initialize its list_lru as memcg-enabled. Let's do it for the general FS
shrinker (super_block::s_shrink) and mark it as memcg aware.

There are other FS-specific shrinkers that use list_lru for storing
objects, such as XFS and GFS2 dquot cache shrinkers, but since they
reclaim objects that may be shared among different cgroups, there is no
point making them memcg aware.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/super.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 33cbff3769e7..6a58a7196fb2 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -191,9 +191,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	INIT_LIST_HEAD(&s->s_inodes);
 	INIT_WORK(&s->destroy, destroy_super_work_func);
 
-	if (list_lru_init(&s->s_dentry_lru))
+	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
-	if (list_lru_init(&s->s_inode_lru))
+	if (list_lru_init_memcg(&s->s_inode_lru))
 		goto fail;
 
 	init_rwsem(&s->s_umount);
@@ -230,7 +230,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
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
