Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE45C6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 06:54:11 -0400 (EDT)
Received: by yxs7 with SMTP id 7so2121672yxs.14
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 03:54:07 -0700 (PDT)
Message-ID: <4C46D1C5.90200@gmail.com>
Date: Wed, 21 Jul 2010 18:53:57 +0800
From: Wang Sheng-Hui <crosslonelyover@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan >
 0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: sandeen@redhat.com, agruen@suse.de, hch@infradead.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Sorry. regerated the patch, please check it.
I wrapped most code in single pair of spinlock ops for 2 reasons:
1) get spinlock 2 times seems time consuming
2) use single pair of spinlock ops can keep "count"
   consistent for the shrink operation. 2 pairs may
   get some new ces created by other processes. 



Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>
---
 fs/mbcache.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..ee57aa3 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -201,21 +201,15 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
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
+
+	spin_lock(&mb_cache_spinlock);
+	if (nr_to_scan == 0)
 		goto out;
-	}
+
 	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
 		struct mb_cache_entry *ce =
 			list_entry(mb_cache_lru_list.next,
@@ -223,12 +217,18 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 		list_move_tail(&ce->e_lru_list, &free_list);
 		__mb_cache_entry_unhash(ce);
 	}
-	spin_unlock(&mb_cache_spinlock);
 	list_for_each_safe(l, ltmp, &free_list) {
 		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
 						   e_lru_list), gfp_mask);
 	}
 out:
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
