Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9786B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 16:26:42 -0400 (EDT)
In-Reply-To: <4C46FD67.8070808@redhat.com>
References: <4C46FD67.8070808@redhat.com>
From: Andreas Gruenbacher <agruen@suse.de>
Date: Wed, 21 Jul 2010 19:44:45 +0200
Subject: [PATCH 2/2] mbcache: fix shrinker function return value
Message-Id: <20100721202637.2D6633C539AB@imap.suse.de>
Sender: owner-linux-mm@kvack.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Eric Sandeen <sandeen@redhat.com>, hch@infradead.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors <kernel-janitors@vger.kernel.org>, Wang Sheng-Hui <crosslonelyover@gmail.com>
List-ID: <linux-mm.kvack.org>

The shrinker function is supposed to return the number of cache
entries after shrinking, not before shrinking.  Fix that.

Based on a patch from Wang Sheng-Hui <crosslonelyover@gmail.com>.

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
---
 fs/mbcache.c |   27 ++++++++++-----------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index 8a2cbd8..cf4e6cd 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -176,22 +176,12 @@ static int
 mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(free_list);
-	struct list_head *l, *ltmp;
+	struct mb_cache *cache;
+	struct mb_cache_entry *entry, *tmp;
 	int count = 0;
 
-	spin_lock(&mb_cache_spinlock);
-	list_for_each(l, &mb_cache_list) {
-		struct mb_cache *cache =
-			list_entry(l, struct mb_cache, c_cache_list);
-		mb_debug("cache %s (%d)", cache->c_name,
-			  atomic_read(&cache->c_entry_count));
-		count += atomic_read(&cache->c_entry_count);
-	}
 	mb_debug("trying to free %d entries", nr_to_scan);
-	if (nr_to_scan == 0) {
-		spin_unlock(&mb_cache_spinlock);
-		goto out;
-	}
+	spin_lock(&mb_cache_spinlock);
 	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
 		struct mb_cache_entry *ce =
 			list_entry(mb_cache_lru_list.next,
@@ -199,12 +189,15 @@ mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 		list_move_tail(&ce->e_lru_list, &free_list);
 		__mb_cache_entry_unhash(ce);
 	}
+	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
+		mb_debug("cache %s (%d)", cache->c_name,
+			  atomic_read(&cache->c_entry_count));
+		count += atomic_read(&cache->c_entry_count);
+	}
 	spin_unlock(&mb_cache_spinlock);
-	list_for_each_safe(l, ltmp, &free_list) {
-		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
-						   e_lru_list), gfp_mask);
+	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
+		__mb_cache_entry_forget(entry, gfp_mask);
 	}
-out:
 	return (count / 100) * sysctl_vfs_cache_pressure;
 }
 
-- 
1.7.2.rc3.57.g77b5b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
