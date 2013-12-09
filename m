Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id F24F26B0036
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:12 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so1285469lab.4
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:12 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d10si3268065lae.157.2013.12.09.00.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:11 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 12/16] fs: mark list_lru based shrinkers memcg aware
Date: Mon, 9 Dec 2013 12:05:53 +0400
Message-ID: <9e1005848996c3df5ceca9e8262edcf8211a893d.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>

Since now list_lru automatically distributes objects among per-memcg
lists and list_lru_{count,walk} employ information passed in the
shrink_control argument to scan appropriate list, all shrinkers that
keep objects in the list_lru structure can already work as memcg-aware.
Let us mark them so.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/gfs2/quota.c  |    2 +-
 fs/super.c       |    2 +-
 fs/xfs/xfs_buf.c |    2 +-
 fs/xfs/xfs_qm.c  |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index f0435da..6cf6114 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -150,7 +150,7 @@ struct shrinker gfs2_qd_shrinker = {
 	.count_objects = gfs2_qd_shrink_count,
 	.scan_objects = gfs2_qd_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
 
diff --git a/fs/super.c b/fs/super.c
index 8f9a81b..05bead8 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -219,7 +219,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
-	s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	return s;
 
 fail:
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 5b2a49c..d8326b6 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1679,7 +1679,7 @@ xfs_alloc_buftarg(
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
 	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
 	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
-	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE;
+	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	register_shrinker(&btp->bt_shrinker);
 	return btp;
 
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index aaacf8f..1f9bbb5 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -903,7 +903,7 @@ xfs_qm_init_quotainfo(
 	qinf->qi_shrinker.count_objects = xfs_qm_shrink_count;
 	qinf->qi_shrinker.scan_objects = xfs_qm_shrink_scan;
 	qinf->qi_shrinker.seeks = DEFAULT_SEEKS;
-	qinf->qi_shrinker.flags = SHRINKER_NUMA_AWARE;
+	qinf->qi_shrinker.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	register_shrinker(&qinf->qi_shrinker);
 	return 0;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
