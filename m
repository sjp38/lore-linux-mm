Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BD5F1600365
	for <linux-mm@kvack.org>; Sat, 17 Jul 2010 21:01:40 -0400 (EDT)
Received: by pwi8 with SMTP id 8so1520273pwi.14
        for <linux-mm@kvack.org>; Sat, 17 Jul 2010 18:01:36 -0700 (PDT)
Message-ID: <4C425273.5000702@gmail.com>
Date: Sun, 18 Jul 2010 09:01:39 +0800
From: Wang Sheng-Hui <crosslonelyover@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan >
 0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, a.gruenbacher@computer.org
List-ID: <linux-mm.kvack.org>

Hi,

The comment for struct shrinker in include/linux/mm.h says
"shrink...It should return the number of objects which remain in the
cache."
Please notice the word "remain".

In fs/mbcache.h, mb_cache_shrink_fn is used as the shrink function:
 	static struct shrinker mb_cache_shrinker = {	
 		.shrink = mb_cache_shrink_fn,
 		.seeks = DEFAULT_SEEKS,
 	};
In mb_cache_shrink_fn, the return value for nr_to_scan > 0 is the
number of mb_cache_entry before shrink operation. It may because the
memory usage for mbcache is low, so the effect is not so obvious.
I think we'd better fix the return value issue.

Following patch is against 2.6.35-rc5. Please check it.

Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>
---
 fs/mbcache.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..412e7cc 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -228,6 +228,16 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
 						   e_lru_list), gfp_mask);
 	}
+	spin_lock(&mb_cache_spinlock);
+	count = 0;
+	list_for_each(l, &mb_cache_list) {
+		struct mb_cache *cache =
+			list_entry(l, struct mb_cache, c_cache_list);
+		mb_debug("cache %s (%d)", cache->c_name,
+			  atomic_read(&cache->c_entry_count));
+		count += atomic_read(&cache->c_entry_count);
+	}
+	spin_unlock(&mb_cache_spinlock);
 out:
 	return (count / 100) * sysctl_vfs_cache_pressure;
 }
-- 
1.7.1.1





-- 
Thanks and Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
