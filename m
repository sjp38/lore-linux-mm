Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 62CE66B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 05:36:55 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR3006EDS1D07K0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 18:36:53 +0900 (KST)
From: Piotr Sarna <p.sarna@partner.samsung.com>
Subject: [PATCH] mm: zcache: zcache_cleancache_flush_fs fix
Date: Tue, 06 Aug 2013 11:36:02 +0200
Message-id: <1375781762-15344-1-git-send-email-p.sarna@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com
Cc: b.zolnierkie@samsung.com, p.sarna@partner.samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>

This patch fixes "mm: zcache: core functions added" patch,
available at https://lkml.org/lkml/2013/7/20/90.
It regards incorrect implementation of zcache_cleancache_flush_fs().

Function above should be effective only if cleancache pool referred
by pool_id is valid. This issue is checked by testing whether zpool
points to NULL.

Unfortunately, if filesystem mount fails, such pool is never created
and fs/super.c calls cleancache_invalidate_fs() function with pool_id
parameter set to -1. This results in assigning zpool with pools[-1],
which causes zpool to be not NULL and thus whole function hangs on
uninitialized read-write lock.

To prevent that behaviour, pool_id should be checked for being positive
before assigning zpool variable with pools[pool_id].

Signed-off-by: Piotr Sarna <p.sarna@partner.samsung.com>
Acked-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/zcache.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/zcache.c b/mm/zcache.c
index a2408e8..7e6d2e7 100644
--- a/mm/zcache.c
+++ b/mm/zcache.c
@@ -600,8 +600,12 @@ static void zcache_cleancache_flush_fs(int pool_id)
 	struct zcache_rb_entry *entry = NULL;
 	struct rb_node *node;
 	unsigned long flags1, flags2;
-	struct zcache_pool *zpool = zcache.pools[pool_id];
+	struct zcache_pool *zpool;
+
+	if (pool_id < 0)
+		return;
 
+	zpool = zcache.pools[pool_id];
 	if (!zpool)
 		return;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
