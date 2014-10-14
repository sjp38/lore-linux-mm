Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 135396B006E
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:55 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so7781882pab.16
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:55 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:54 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF008IWNZSWQ10@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:52 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 1/9] mm/zbud: tidy up a bit
Date: Tue, 14 Oct 2014 20:59:20 +0900
Message-id: <1413287968-13940-2-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

For aesthetics, add a blank line between functions, remove useless
initialization statements, and simplify codes a bit. No functional
differences are introduced.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index ecf1dbe..6f36394 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -145,6 +145,7 @@ static int zbud_zpool_malloc(void *pool, size_t size, gfp_t gfp,
 {
 	return zbud_alloc(pool, size, gfp, handle);
 }
+
 static void zbud_zpool_free(void *pool, unsigned long handle)
 {
 	zbud_free(pool, handle);
@@ -174,6 +175,7 @@ static void *zbud_zpool_map(void *pool, unsigned long handle,
 {
 	return zbud_map(pool, handle);
 }
+
 static void zbud_zpool_unmap(void *pool, unsigned long handle)
 {
 	zbud_unmap(pool, handle);
@@ -350,16 +352,11 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	spin_lock(&pool->lock);
 
 	/* First, try to find an unbuddied zbud page. */
-	zhdr = NULL;
 	for_each_unbuddied_list(i, chunks) {
 		if (!list_empty(&pool->unbuddied[i])) {
 			zhdr = list_first_entry(&pool->unbuddied[i],
 					struct zbud_header, buddy);
 			list_del(&zhdr->buddy);
-			if (zhdr->first_chunks == 0)
-				bud = FIRST;
-			else
-				bud = LAST;
 			goto found;
 		}
 	}
@@ -372,13 +369,15 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	spin_lock(&pool->lock);
 	pool->pages_nr++;
 	zhdr = init_zbud_page(page);
-	bud = FIRST;
 
 found:
-	if (bud == FIRST)
+	if (zhdr->first_chunks == 0) {
 		zhdr->first_chunks = chunks;
-	else
+		bud = FIRST;
+	} else {
 		zhdr->last_chunks = chunks;
+		bud = LAST;
+	}
 
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
 		/* Add to unbuddied list */
@@ -433,7 +432,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	/* Remove from existing buddy list */
 	list_del(&zhdr->buddy);
 
-	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+	if (num_free_chunks(zhdr) == NCHUNKS) {
 		/* zbud page is empty, free */
 		list_del(&zhdr->lru);
 		free_zbud_page(zhdr);
@@ -489,7 +488,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 {
 	int i, ret, freechunks;
 	struct zbud_header *zhdr;
-	unsigned long first_handle = 0, last_handle = 0;
+	unsigned long first_handle, last_handle;
 
 	spin_lock(&pool->lock);
 	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
@@ -529,7 +528,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 next:
 		spin_lock(&pool->lock);
 		zhdr->under_reclaim = false;
-		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+		if (num_free_chunks(zhdr) == NCHUNKS) {
 			/*
 			 * Both buddies are now free, free the zbud page and
 			 * return success.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
