Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE4F6B0089
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:52:40 -0400 (EDT)
Received: by mail-yk0-f177.google.com with SMTP id 19so1422263ykq.8
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:52:40 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id v24si23136930yhc.181.2014.05.07.14.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:52:40 -0700 (PDT)
Received: by mail-yk0-f174.google.com with SMTP id 9so1420141ykp.33
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:52:40 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/4] mm/zbud: change zbud_alloc size type to size_t
Date: Wed,  7 May 2014 17:51:34 -0400
Message-Id: <1399499496-3216-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
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
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Weijie Yang <weijie.yang@samsung.com>
---

While the rest of the patches in this set are v2, this is new for
the set; previously a patch to implement zsmalloc shrinking was
here, but that's removed.  This patch instead changes the
zbud_alloc() size parameter type from unsigned int to size_t, to
be the same as the zsmalloc and zpool size param type.

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
