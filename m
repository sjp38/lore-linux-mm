Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7673C6B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:28:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v4so82867837pgc.20
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 08:28:53 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10092.outbound.protection.outlook.com. [40.107.1.92])
        by mx.google.com with ESMTPS id a11si5536084pfl.214.2017.03.31.08.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 08:28:52 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm/zswap: fix potential deadlock in zswap_frontswap_store()
Date: Fri, 31 Mar 2017 18:30:09 +0300
Message-ID: <20170331153009.11397-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

zswap_frontswap_store() is called during memory reclaim from
__frontswap_store() from swap_writepage() from shrink_page_list().
This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
otherwise we may renter into fs code and deadlock.
zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
into itself.

zswap_frontswap_store() call zpool_malloc() with __GFP_NORETRY |
__GFP_NOWARN | __GFP_KSWAPD_RECLAIM, so let's use the same flags for
zswap_entry_cache_alloc() as well, instead of GFP_KERNEL.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/zswap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index eedc278..12ad7e9 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -966,6 +966,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry, *dupentry;
 	struct crypto_comp *tfm;
+	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
 	int ret;
 	unsigned int dlen = PAGE_SIZE, len;
 	unsigned long handle;
@@ -989,7 +990,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* allocate entry */
-	entry = zswap_entry_cache_alloc(GFP_KERNEL);
+	entry = zswap_entry_cache_alloc(gfp);
 	if (!entry) {
 		zswap_reject_kmemcache_fail++;
 		ret = -ENOMEM;
@@ -1017,9 +1018,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zpool_malloc(entry->pool->zpool, len,
-			   __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
-			   &handle);
+	ret = zpool_malloc(entry->pool->zpool, len, gfp, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto put_dstmem;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
