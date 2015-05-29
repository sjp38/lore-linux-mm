Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 216936B008A
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:38 -0400 (EDT)
Received: by pdea3 with SMTP id a3so55496473pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:37 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bm1si8742484pbd.212.2015.05.29.08.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:37 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so62707583pab.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:37 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 07/10] zsmalloc: introduce auto-compact support
Date: Sat, 30 May 2015 00:05:25 +0900
Message-Id: <1432911928-14654-8-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

perform class compaction in zs_free(), if zs_free() has created
a ZS_ALMOST_EMPTY page. this is the most trivial `policy'.

probably it would make zs_can_compact() to return an estimated number
of pages that potentially will be free and trigger auto-compaction
only when it's above some limit (e.g. at least 4 zs pages); or put it
under config option.

this also tweaks __zs_compact() -- we can't do reschedule
anymore, waiting for new pages in the current class. so we
compact as much as we can and return immediately if compaction
is not possible anymore.

auto-compaction is not a replacement of manual compaction.

compiled linux kernel with auto-compaction:

cat /sys/block/zram0/mm_stat
2339885056 1601034235 1624076288        0 1624076288    19961     1106

performing additional manual compaction:

echo 1 > /sys/block/zram0/compact
cat /sys/block/zram0/mm_stat
2339885056 1601034235 1624051712        0 1624076288    19961     1114

manual compaction was able to migrate additional 8 objects. so
auto-compaction is 'good enough'.

TEST

this test copies a 1.3G linux kernel tar to mounted zram disk,
and extracts it.

w/auto-compaction:

cat /sys/block/zram0/mm_stat
 1171456    26006    86016        0    86016    32781        0

time tar xf linux-3.10.tar.gz -C linux

real    0m16.970s
user    0m15.247s
sys     0m8.477s

du -sh linux
2.0G    linux

cat /sys/block/zram0/mm_stat
3547353088 2993384270 3011088384        0 3011088384    24310      108

=====================================================================

w/o auto compaction:

cat /sys/block/zram0/mm_stat
 1171456    26000    81920        0    81920    32781        0

time tar xf linux-3.10.tar.gz -C linux

real    0m16.983s
user    0m15.267s
sys     0m8.417s

du -sh linux
2.0G    linux

cat /sys/block/zram0/mm_stat
3548917760 2993566924 3011317760        0 3011317760    23928        0

=====================================================================

iozone shows that auto-compacted code runs faster in several
tests, which is hardly trustworthy. anyway.

iozone -t 3 -R -r 16K -s 60M -I +Z

       test           base       auto-compact (compacted 66123 objs)
   Initial write   1603682.25          1645112.38
         Rewrite   2502243.31          2256570.31
            Read   7040860.00          7130575.00
         Re-read   7036490.75          7066744.25
    Reverse Read   6617115.25          6155395.50
     Stride read   6705085.50          6350030.38
     Random read   6668497.75          6350129.38
  Mixed workload   5494030.38          5091669.62
    Random write   2526834.44          2500977.81
          Pwrite   1656874.00          1663796.94
           Pread   3322818.91          3359683.44
          Fwrite   4090124.25          4099773.88
           Fread   10358916.25         10324409.75

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c2a640a..70bf481 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1515,34 +1515,28 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 
 		while ((dst_page = isolate_target_page(class))) {
 			cc.d_page = dst_page;
-			/*
-			 * If there is no more space in dst_page, resched
-			 * and see if anyone had allocated another zspage.
-			 */
+
 			if (!migrate_zspage(pool, class, &cc))
-				break;
+				goto out;
 
 			putback_zspage(pool, class, dst_page);
 		}
 
-		/* Stop if we couldn't find slot */
-		if (dst_page == NULL)
+		if (!dst_page)
 			break;
-
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
-		spin_unlock(&class->lock);
-		cond_resched();
-		spin_lock(&class->lock);
 	}
 
+out:
+	if (dst_page)
+		putback_zspage(pool, class, dst_page);
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
 	spin_unlock(&class->lock);
 }
 
-
 unsigned long zs_get_total_pages(struct zs_pool *pool)
 {
 	return atomic_long_read(&pool->pages_allocated);
@@ -1741,6 +1735,13 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	unpin_tag(handle);
 
 	free_handle(pool, handle);
+
+	/*
+	 * actual fullness might have changed, __zs_compact() checks
+	 * if compaction makes sense
+	 */
+	if (fullness == ZS_ALMOST_EMPTY)
+		__zs_compact(pool, class);
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
