Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8FAEB6B0078
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 08:02:28 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 6so204729pwj.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 05:02:27 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 2/3] slub: Add lock release annotation
Date: Wed, 29 Sep 2010 21:02:14 +0900
Message-Id: <1285761735-31499-2-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The unfreeze_slab() releases page's PG_locked bit but was missing
proper annotation. The deactivate_slab() needs to be marked also
since it calls unfreeze_slab() without grabbing the lock.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/slub.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e137688..f0684a9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1405,6 +1405,7 @@ static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
  * On exit the slab lock will have been dropped.
  */
 static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
+	__releases(bitlock)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1447,6 +1448,7 @@ static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
  * Remove the cpu slab
  */
 static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
+	__releases(bitlock)
 {
 	struct page *page = c->page;
 	int tail = 1;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
