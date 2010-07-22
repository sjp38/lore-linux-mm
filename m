From: Wang Sheng-Hui <crosslonelyover@gmail.com>
Subject: re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan
 > 0
Date: Thu, 22 Jul 2010 08:54:38 +0800
Message-ID: <4C4796CE.6080306__845.358105334704$1279760091$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Obk3l-0002Mj-AA
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Jul 2010 02:54:49 +0200
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E8AA6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:54:46 -0400 (EDT)
Received: by pxi7 with SMTP id 7so3607934pxi.14
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 17:54:44 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>, agruen@suse.de, hch@infradead.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@
List-Id: linux-mm.kvack.org

Sorry, missed that. Regerated and passed checkpatch.pl check. 
Please check it.


Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>
---
 fs/mbcache.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..603170e 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -201,21 +201,14 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(free_list);
 	struct list_head *l, *ltmp;
+	struct mb_cache *cache;
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
+	if (nr_to_scan == 0)
 		goto out;
-	}
+
+	spin_lock(&mb_cache_spinlock);
 	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
 		struct mb_cache_entry *ce =
 			list_entry(mb_cache_lru_list.next,
@@ -229,6 +222,14 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 						   e_lru_list), gfp_mask);
 	}
 out:
+	spin_lock(&mb_cache_spinlock);
+	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
+		mb_debug("cache %s (%d)", cache->c_name,
+			  atomic_read(&cache->c_entry_count));
+		count += atomic_read(&cache->c_entry_count);
+	}
+	spin_unlock(&mb_cache_spinlock);
+
 	return (count / 100) * sysctl_vfs_cache_pressure;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
