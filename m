Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 34D776B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 05:21:00 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so31338750pad.1
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 02:20:59 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kd3si22560400pbc.233.2015.01.12.02.20.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 02:20:58 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] fs: shrinker: always scan at least one object of each type
Date: Mon, 12 Jan 2015 13:20:46 +0300
Message-ID: <1421058046-2434-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

In super_cache_scan() we divide the number of objects of particular type
by the total number of objects in order to distribute pressure among
different types of fs objects (inodes, dentries, fs-private objects).
As a result, in some corner cases we can get nr_to_scan=0 even if there
are some objects to reclaim, e.g. dentries=1, inodes=1, fs_objects=1,
nr_to_scan=1/3=0.

This is unacceptable for per memcg kmem accounting, because this means
that some objects may never get reclaimed after memcg death, preventing
it from being freed.

This patch therefore assures that super_cache_scan() will scan at least
one object of each type if any.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 482b4071f4de..63136156867e 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -92,13 +92,13 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	sc->nr_to_scan = dentries;
+	sc->nr_to_scan = dentries + 1;
 	freed = prune_dcache_sb(sb, sc);
-	sc->nr_to_scan = inodes;
+	sc->nr_to_scan = inodes + 1;
 	freed += prune_icache_sb(sb, sc);
 
 	if (fs_objects) {
-		sc->nr_to_scan = fs_objects;
+		sc->nr_to_scan = fs_objects + 1;
 		freed += sb->s_op->free_cached_objects(sb, sc);
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
