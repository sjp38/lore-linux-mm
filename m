Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 62C516B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 18:33:29 -0500 (EST)
Received: by qkht125 with SMTP id t125so62309142qkh.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:33:29 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id y19si22543535qhb.115.2015.12.11.15.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 15:33:28 -0800 (PST)
Received: by qgew101 with SMTP id w101so5507038qge.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:33:28 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: change incorrect strncmp use to strcmp
Date: Fri, 11 Dec 2015 18:33:11 -0500
Message-Id: <1449876791-15962-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, Seth Jennings <sjennings@variantweb.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Change the use of strncmp in zswap_pool_find_get() to strcmp.

The use of strncmp is no longer correct, now that zswap_zpool_type is
not an array; sizeof() will return the size of a pointer, which isn't
the right length to compare.  We don't need to use strncmp anyway,
because the existing params and the passed in params are all guaranteed
to be null terminated, so strcmp should be used.

Reported-by: Weijie Yang <weijie.yang@samsung.com>
Cc: Seth Jennings <sjennings@variantweb.net>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 025f8dc..bf14508 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -541,6 +541,7 @@ static struct zswap_pool *zswap_pool_last_get(void)
 	return last;
 }
 
+/* type and compressor must be null-terminated */
 static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
 {
 	struct zswap_pool *pool;
@@ -548,10 +549,9 @@ static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
 	assert_spin_locked(&zswap_pools_lock);
 
 	list_for_each_entry_rcu(pool, &zswap_pools, list) {
-		if (strncmp(pool->tfm_name, compressor, sizeof(pool->tfm_name)))
+		if (strcmp(pool->tfm_name, compressor))
 			continue;
-		if (strncmp(zpool_get_type(pool->zpool), type,
-			    sizeof(zswap_zpool_type)))
+		if (strcmp(zpool_get_type(pool->zpool), type))
 			continue;
 		/* if we can't get it, it's about to be destroyed */
 		if (!zswap_pool_get(pool))
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
