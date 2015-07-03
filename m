Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B4CF9280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 05:40:21 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so61157677pdb.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 02:40:21 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id qv6si13490859pab.172.2015.07.03.02.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 02:40:19 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQW009O2O747Q00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Jul 2015 10:40:16 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH 2/2] mm: zbud: Constify the zbud_ops
Date: Fri, 03 Jul 2015 18:40:13 +0900
Message-id: <1435916413-6475-2-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com>
References: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

The structure zbud_ops is not modified so make the pointer to it as
pointer to const.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zbud.h | 2 +-
 mm/zbud.c            | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index f9d41a6e361f..e183a0a65ac1 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -9,7 +9,7 @@ struct zbud_ops {
 	int (*evict)(struct zbud_pool *pool, unsigned long handle);
 };
 
-struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
+struct zbud_pool *zbud_create_pool(gfp_t gfp, const struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	unsigned long *handle);
diff --git a/mm/zbud.c b/mm/zbud.c
index 6f8158d64864..fa48bcdff9d5 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -96,7 +96,7 @@ struct zbud_pool {
 	struct list_head buddied;
 	struct list_head lru;
 	u64 pages_nr;
-	struct zbud_ops *ops;
+	const struct zbud_ops *ops;
 #ifdef CONFIG_ZPOOL
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
@@ -133,7 +133,7 @@ static int zbud_zpool_evict(struct zbud_pool *pool, unsigned long handle)
 		return -ENOENT;
 }
 
-static struct zbud_ops zbud_zpool_ops = {
+static const struct zbud_ops zbud_zpool_ops = {
 	.evict =	zbud_zpool_evict
 };
 
@@ -302,7 +302,7 @@ static int num_free_chunks(struct zbud_header *zhdr)
  * Return: pointer to the new zbud pool or NULL if the metadata allocation
  * failed.
  */
-struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
+struct zbud_pool *zbud_create_pool(gfp_t gfp, const struct zbud_ops *ops)
 {
 	struct zbud_pool *pool;
 	int i;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
