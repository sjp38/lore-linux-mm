Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C9DDB6B0039
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:30:06 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so8666143pde.24
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:30:06 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00EXPQT6AJ20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:30:04 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 2/6] zbud: make freechunks a block local variable
Date: Tue, 08 Oct 2013 15:29:36 +0200
Message-id: <1381238980-2491-3-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Move freechunks variable in zbud_free() and zbud_alloc() to block-level
scope (from function scope).

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 mm/zbud.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 7574289..e19f36a 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -267,7 +267,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 			unsigned long *handle)
 {
-	int chunks, i, freechunks;
+	int chunks, i;
 	struct zbud_header *zhdr = NULL;
 	enum buddy bud;
 	struct page *page;
@@ -317,7 +317,7 @@ found:
 
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
 		/* Add to unbuddied list */
-		freechunks = num_free_chunks(zhdr);
+		int freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
 	} else {
 		/* Add to buddied list */
@@ -349,7 +349,6 @@ found:
 void zbud_free(struct zbud_pool *pool, unsigned long handle)
 {
 	struct zbud_header *zhdr;
-	int freechunks;
 
 	spin_lock(&pool->lock);
 	zhdr = handle_to_zbud_header(handle);
@@ -368,7 +367,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		pool->pages_nr--;
 	} else {
 		/* Add to unbuddied list */
-		freechunks = num_free_chunks(zhdr);
+		int freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
