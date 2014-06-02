Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id C8E2B6B0075
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 18:20:22 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 79so4232963ykr.3
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:20:22 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id i4si25898222yhd.185.2014.06.02.15.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 15:20:22 -0700 (PDT)
Received: by mail-yk0-f171.google.com with SMTP id 142so4218940ykq.16
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:20:22 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/6] mm/zbud: change zbud_alloc size type to size_t
Date: Mon,  2 Jun 2014 18:19:42 -0400
Message-Id: <1401747586-11861-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Change the type of the zbud_alloc() size param from unsigned int
to size_t.

Technically, this should not make any difference, as the zbud
implementation already restricts the size to well within either
type's limits; but as zsmalloc (and kmalloc) use size_t, and
zpool will use size_t, this brings the size parameter type
in line with zsmalloc/zpool.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Acked-by: Seth Jennings <sjennings@variantweb.net>
Cc: Weijie Yang <weijie.yang@samsung.com>
---

No change since v1 : https://lkml.org/lkml/2014/5/7/757

 include/linux/zbud.h | 2 +-
 mm/zbud.c            | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 0b2534e..1e9cb57 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -11,7 +11,7 @@ struct zbud_ops {
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
-int zbud_alloc(struct zbud_pool *pool, unsigned int size,
+int zbud_alloc(struct zbud_pool *pool, size_t size,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
diff --git a/mm/zbud.c b/mm/zbud.c
index 847c01c..dd13665 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -123,7 +123,7 @@ enum buddy {
 };
 
 /* Converts an allocation size in bytes to size in zbud chunks */
-static int size_to_chunks(int size)
+static int size_to_chunks(size_t size)
 {
 	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
 }
@@ -250,8 +250,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * -EINVAL if the @size is 0, or -ENOMEM if the pool was unable to
  * allocate a new page.
  */
-int zbud_alloc(struct zbud_pool *pool, unsigned int size,
-			unsigned long *handle)
+int zbud_alloc(struct zbud_pool *pool, size_t size, unsigned long *handle)
 {
 	int chunks, i, freechunks;
 	struct zbud_header *zhdr = NULL;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
