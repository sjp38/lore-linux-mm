Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 56C4D6B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 19:01:32 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8833dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 16:01:31 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] slab: do not call compound_head() in page_get_cache()
Date: Wed, 20 Jun 2012 16:01:13 -0700
Message-Id: <1340233273-10994-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

page_get_cache() does not need to call compound_head(), as its unique
caller virt_to_slab() already makes sure to return a head page.

Additionally, removing the compound_head() call makes page_get_cache()
consistent with page_get_slab().

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/slab.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e901a36..6a1aa1f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -501,7 +501,6 @@ static inline void page_set_cache(struct page *page, struct kmem_cache *cache)
 
 static inline struct kmem_cache *page_get_cache(struct page *page)
 {
-	page = compound_head(page);
 	BUG_ON(!PageSlab(page));
 	return (struct kmem_cache *)page->lru.next;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
