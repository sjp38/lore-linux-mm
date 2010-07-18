Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E9F57600365
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 00:06:47 -0400 (EDT)
Message-ID: <4C427DC8.6020504@redhat.com>
Date: Sat, 17 Jul 2010 23:06:32 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan
 > 0
References: <4C425273.5000702@gmail.com>
In-Reply-To: <4C425273.5000702@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, a.gruenbacher@computer.org
List-ID: <linux-mm.kvack.org>

Wang Sheng-Hui wrote:

> Hi,
>
> The comment for struct shrinker in include/linux/mm.h says
> "shrink...It should return the number of objects which remain in the
> cache."
> Please notice the word "remain".
>
> In fs/mbcache.h, mb_cache_shrink_fn is used as the shrink function:
>  	static struct shrinker mb_cache_shrinker = {	
>  		.shrink = mb_cache_shrink_fn,
>  		.seeks = DEFAULT_SEEKS,
>  	};
> In mb_cache_shrink_fn, the return value for nr_to_scan > 0 is the
> number of mb_cache_entry before shrink operation. It may because the
> memory usage for mbcache is low, so the effect is not so obvious.
> I think we'd better fix the return value issue.
>
> Following patch is against 2.6.35-rc5. Please check it.
>
>   
you are right that it's not returning the remaining entries, but I think
we can do this more simply; there isn't any reason to calculate it twice
How about just moving the accounting to the end, since "count" isn't actually
used when freeing, anyway.... something like this?

diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..3af79de 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -203,19 +203,11 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 	struct list_head *l, *ltmp;
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
+	spin_lock &mb_cache_spinlock);
 	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
 		struct mb_cache_entry *ce =
 			list_entry(mb_cache_lru_list.next,
@@ -229,6 +221,17 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
 						   e_lru_list), gfp_mask);
 	}
 out:
+	/* Count remaining entries */
+	spin_lock(&mb_cache_spinlock);
+	list_for_each(l, &mb_cache_list) {
+		struct mb_cache *cache =
+			list_entry(l, struct mb_cache, c_cache_list);
+		mb_debug("cache %s (%d)", cache->c_name,
+			  atomic_read(&cache->c_entry_count));
+		count += atomic_read(&cache->c_entry_count);
+	}
+	spin_unlock(&mb_cache_spinlock);
+
 	return (count / 100) * sysctl_vfs_cache_pressure;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
