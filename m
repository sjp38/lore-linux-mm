Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4B556B0009
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 11:11:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 202so3638393pgb.13
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 08:11:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n59-v6sor1472135plb.30.2018.02.17.08.11.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 17 Feb 2018 08:11:12 -0800 (PST)
Date: Sat, 17 Feb 2018 21:42:31 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: zbud: Remove zbud_map() and zbud_unmap() function
Message-ID: <20180217161230.GA16890@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@redhat.com, ddstreet@ieee.org
Cc: linux-mm@kvack.org

zbud_unmap() is empty function and not getting called from
anywhere except from zbud_zpool_unmap(). Hence we can remove
zbud_unmap().

Similarly, zbud_map() is only returning (void *)(handle)
which can be done within zbud_zpool_map(). Hence we can
remove zbud_map().

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/zbud.h |  2 --
 mm/zbud.c            | 30 ++----------------------------
 2 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index b1eaf6e..565b88c 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -16,8 +16,6 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
-void *zbud_map(struct zbud_pool *pool, unsigned long handle);
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
 u64 zbud_get_pool_size(struct zbud_pool *pool);

 #endif /* _ZBUD_H_ */
diff --git a/mm/zbud.c b/mm/zbud.c
index 28458f7..c83c876 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -188,11 +188,11 @@ static int zbud_zpool_shrink(void *pool, unsigned int pages,
 static void *zbud_zpool_map(void *pool, unsigned long handle,
 			enum zpool_mapmode mm)
 {
-	return zbud_map(pool, handle);
+	return (void *)(handle);
 }
 static void zbud_zpool_unmap(void *pool, unsigned long handle)
 {
-	zbud_unmap(pool, handle);
+
 }

 static u64 zbud_zpool_total_size(void *pool)
@@ -569,32 +569,6 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 }

 /**
- * zbud_map() - maps the allocation associated with the given handle
- * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be mapped
- *
- * While trivial for zbud, the mapping functions for others allocators
- * implementing this allocation API could have more complex information encoded
- * in the handle and could create temporary mappings to make the data
- * accessible to the user.
- *
- * Returns: a pointer to the mapped allocation
- */
-void *zbud_map(struct zbud_pool *pool, unsigned long handle)
-{
-	return (void *)(handle);
-}
-
-/**
- * zbud_unmap() - maps the allocation associated with the given handle
- * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be unmapped
- */
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
-{
-}
-
-/**
  * zbud_get_pool_size() - gets the zbud pool size in pages
  * @pool:	pool whose size is being queried
  *
--
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
