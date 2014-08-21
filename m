Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACCD6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:09:27 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so8423124qge.2
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:09:27 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id o3si37763346qat.117.2014.08.21.01.09.24
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:09:26 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/5] mm/slab: move cache_flusharray() out of unlikely.text section
Date: Thu, 21 Aug 2014 17:09:20 +0900
Message-Id: <1408608562-20339-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, due to likely keyword, compiled code of cache_flusharray() is
on unlikely.text section. Although it is uncommon case compared to
free to cpu cache case, it is common case than free_block(). But,
free_block() is on normal text section. This patch fix this odd situation
to remove likely keyword.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index d80b654..d364e3f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3406,7 +3406,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 	if (nr_online_nodes > 1 && cache_free_alien(cachep, objp))
 		return;
 
-	if (likely(ac->avail < ac->limit)) {
+	if (ac->avail < ac->limit) {
 		STATS_INC_FREEHIT(cachep);
 	} else {
 		STATS_INC_FREEMISS(cachep);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
